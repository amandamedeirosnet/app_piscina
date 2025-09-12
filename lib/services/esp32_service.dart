import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/pool_data.dart';

class ESP32Service {
  static const String _wifiEndpoint = 'http://192.168.1.100:80/api/dados';
  
  // Configurações WiFi
  static Future<bool> sendDataViaWiFi(PoolData data) async {
    try {
      final response = await http.post(
        Uri.parse(_wifiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ph': data.ph,
          'cloro': data.cloro,
          'timestamp': data.timestamp,
        }),
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Erro WiFi: $e');
      return false;
    }
  }

  // Configurações Bluetooth
  static Future<bool> sendDataViaBluetooth(PoolData data) async {
    try {
      // Verificar se o Bluetooth está disponível
      bool? isAvailable = await FlutterBluetoothSerial.instance.isAvailable;
      if (isAvailable != true) {
        print('Bluetooth não disponível');
        return false;
      }

      // Listar dispositivos pareados
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      BluetoothDevice? esp32Device;
      
      for (var device in devices) {
        if (device.name?.contains('ESP32') == true || 
            device.name?.contains('Pool') == true) {
          esp32Device = device;
          break;
        }
      }

      if (esp32Device == null) {
        print('Dispositivo ESP32 não encontrado');
        return false;
      }

      // Conectar e enviar dados
      BluetoothConnection? connection = await BluetoothConnection.toAddress(esp32Device.address);
      
      if (connection.isConnected) {
        String message = '${data.ph},${data.cloro},${data.timestamp}\n';
        connection.output.add(utf8.encode(message));
        await connection.output.allSent;
        connection.dispose();
        return true;
      }

      return false;
    } catch (e) {
      print('Erro Bluetooth: $e');
      return false;
    }
  }

  // Método principal que tenta WiFi primeiro, depois Bluetooth
  static Future<bool> sendData(PoolData data) async {
    print('Tentando enviar dados via WiFi...');
    bool wifiSuccess = await sendDataViaWiFi(data);
    
    if (wifiSuccess) {
      print('Dados enviados via WiFi com sucesso');
      return true;
    }

    print('WiFi falhou, tentando Bluetooth...');
    bool bluetoothSuccess = await sendDataViaBluetooth(data);
    
    if (bluetoothSuccess) {
      print('Dados enviados via Bluetooth com sucesso');
      return true;
    }

    print('Falha ao enviar dados via WiFi e Bluetooth');
    return false;
  }

  // Verificar conectividade
  static Future<bool> checkWiFiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_wifiEndpoint/status'),
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkBluetoothConnection() async {
    try {
      bool? isAvailable = await FlutterBluetoothSerial.instance.isAvailable;
      if (isAvailable != true) return false;

      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      return devices.any((device) => 
        device.name?.contains('ESP32') == true || 
        device.name?.contains('Pool') == true);
    } catch (e) {
      return false;
    }
  }
}
