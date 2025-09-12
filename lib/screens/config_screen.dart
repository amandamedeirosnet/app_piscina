import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../services/esp32_service.dart';

class ConfigScreen extends StatefulWidget {
  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _wifiController = TextEditingController();
  final _bluetoothController = TextEditingController();
  bool _autoSync = true;
  bool _notificationEnabled = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final config = await DataService.loadConfig();
    setState(() {
      _wifiController.text = config['wifiEndpoint'] ?? 'http://192.168.1.100:80/api/pool-data';
      _bluetoothController.text = config['bluetoothDeviceName'] ?? 'ESP32-Pool';
      _autoSync = config['autoSync'] ?? true;
      _notificationEnabled = config['notificationEnabled'] ?? true;
    });
  }

  Future<void> _salvarConfiguracoes() async {
    setState(() {
      _loading = true;
    });

    try {
      final config = {
        'wifiEndpoint': _wifiController.text,
        'bluetoothDeviceName': _bluetoothController.text,
        'autoSync': _autoSync,
        'notificationEnabled': _notificationEnabled,
      };

      await DataService.saveConfig(config);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configurações salvas com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar configurações: $e')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testarConexao() async {
    setState(() {
      _loading = true;
    });

    try {
      bool wifiOk = await ESP32Service.checkWiFiConnection();
      bool bluetoothOk = await ESP32Service.checkBluetoothConnection();

      String mensagem = '';
      if (wifiOk && bluetoothOk) {
        mensagem = 'WiFi e Bluetooth conectados!';
      } else if (wifiOk) {
        mensagem = 'WiFi conectado, Bluetooth não disponível';
      } else if (bluetoothOk) {
        mensagem = 'Bluetooth conectado, WiFi não disponível';
      } else {
        mensagem = 'Nenhuma conexão disponível';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao testar conexão: $e')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configurações WiFi
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações WiFi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _wifiController,
                      decoration: InputDecoration(
                        labelText: 'Endpoint WiFi',
                        hintText: 'http://192.168.1.100:80/api/pool-data',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.wifi),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Configurações Bluetooth
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações Bluetooth',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _bluetoothController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Dispositivo',
                        hintText: 'ESP32-Pool',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bluetooth),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Configurações Gerais
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações Gerais',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Sincronização Automática'),
                      subtitle: Text('Enviar dados automaticamente para ESP32'),
                      value: _autoSync,
                      onChanged: (value) {
                        setState(() {
                          _autoSync = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Notificações'),
                      subtitle: Text('Receber notificações sobre status da piscina'),
                      value: _notificationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _testarConexao,
                    icon: Icon(Icons.network_check),
                    label: Text('Testar Conexão'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _salvarConfiguracoes,
                    icon: Icon(Icons.save),
                    label: Text('Salvar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            if (_loading)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _wifiController.dispose();
    _bluetoothController.dispose();
    super.dispose();
  }
}
