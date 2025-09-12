import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pool_data.dart';

class DataService {
  static const String _historicoKey = 'historico_piscina';
  static const String _configKey = 'config_piscina';

  // Salvar dados da piscina
  static Future<void> savePoolData(PoolData data) async {
    final prefs = await SharedPreferences.getInstance();
    final historicoJson = prefs.getStringList(_historicoKey) ?? [];
    
    historicoJson.add(json.encode(data.toJson()));
    await prefs.setStringList(_historicoKey, historicoJson);
  }

  // Carregar histórico de dados
  static Future<List<PoolData>> loadPoolHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historicoJson = prefs.getStringList(_historicoKey) ?? [];
    
    return historicoJson
        .map((item) => PoolData.fromJson(json.decode(item)))
        .toList();
  }

  // Obter última leitura
  static Future<PoolData?> getLastReading() async {
    final history = await loadPoolHistory();
    return history.isNotEmpty ? history.last : null;
  }

  // Limpar histórico
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historicoKey);
  }

  // Salvar configurações
  static Future<void> saveConfig(Map<String, dynamic> config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, json.encode(config));
  }

  // Carregar configurações
  static Future<Map<String, dynamic>> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_configKey);
    
    if (configJson != null) {
      return Map<String, dynamic>.from(json.decode(configJson));
    }
    
    return {
      'wifiEndpoint': 'http://192.168.1.100:80/api/pool-data',
      'bluetoothDeviceName': 'ESP32-Pool',
      'autoSync': true,
      'notificationEnabled': true,
    };
  }

  // Estatísticas dos dados
  static Future<Map<String, dynamic>> getStatistics() async {
    final history = await loadPoolHistory();
    
    if (history.isEmpty) {
      return {
        'totalReadings': 0,
        'avgPh': 0.0,
        'avgCloro': 0.0,
        'phStatus': 'Sem dados',
        'cloroStatus': 'Sem dados',
      };
    }

    final phValues = history.map((data) => double.tryParse(data.ph) ?? 0).toList();
    final cloroValues = history.map((data) => double.tryParse(data.cloro) ?? 0).toList();

    final avgPh = phValues.reduce((a, b) => a + b) / phValues.length;
    final avgCloro = cloroValues.reduce((a, b) => a + b) / cloroValues.length;

    return {
      'totalReadings': history.length,
      'avgPh': double.parse(avgPh.toStringAsFixed(2)),
      'avgCloro': double.parse(avgCloro.toStringAsFixed(2)),
      'phStatus': _getPhStatus(avgPh),
      'cloroStatus': _getCloroStatus(avgCloro),
    };
  }

  static String _getPhStatus(double ph) {
    if (ph >= 7.2 && ph <= 7.8) return "Ideal";
    if (ph >= 7.0 && ph <= 8.0) return "Atenção";
    return "Crítico";
  }

  static String _getCloroStatus(double cloro) {
    if (cloro >= 1.0 && cloro <= 3.0) return "Ideal";
    if (cloro >= 0.5 && cloro <= 4.0) return "Atenção";
    return "Crítico";
  }
}
