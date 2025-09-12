import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'screens/config_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/add_data_screen.dart';

void main() {
  runApp(PiscinaApp());
}

class PiscinaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle da Piscina',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _ultimaLeitura = "Nenhuma leitura registrada";
  List<Map<String, dynamic>> _historico = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final historico = await DataService.loadPoolHistory();
    final ultimaLeitura = await DataService.getLastReading();

    setState(() {
      _historico = historico.map((data) => data.toJson()).toList();
      if (ultimaLeitura != null) {
        _ultimaLeitura = "pH ${ultimaLeitura.ph} | Cloro ${ultimaLeitura.cloro} ppm | ${ultimaLeitura.data}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Piscina'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card com última leitura
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.pool, size: 48, color: Colors.blue[600]),
                    SizedBox(height: 16),
                    Text(
                      "Última Leitura",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _ultimaLeitura,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddDataScreen()),
                      ).then((_) => _carregarDados());
                    },
                    icon: Icon(Icons.add),
                    label: Text("Inserir Dados"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StatsScreen()),
                      );
                    },
                    icon: Icon(Icons.analytics),
                    label: Text("Estatísticas"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Status da piscina
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status da Piscina",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    _buildStatusItem("pH", _getPhStatus()),
                    _buildStatusItem("Cloro", _getCloroStatus()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String parametro, String status) {
    Color statusColor = status.contains("Ideal") ? Colors.green :
    status.contains("Atenção") ? Colors.orange : Colors.red;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$parametro: ", style: TextStyle(fontWeight: FontWeight.w500)),
          Text(status, style: TextStyle(color: statusColor)),
        ],
      ),
    );
  }

  String _getPhStatus() {
    if (_historico.isEmpty) return "Sem dados";
    final ultima = _historico.last;
    final ph = double.tryParse(ultima['ph']) ?? 0;
    if (ph >= 7.2 && ph <= 7.8) return "Ideal";
    if (ph >= 7.0 && ph <= 8.0) return "Atenção";
    return "Crítico";
  }

  String _getCloroStatus() {
    if (_historico.isEmpty) return "Sem dados";
    final ultima = _historico.last;
    final cloro = double.tryParse(ultima['cloro']) ?? 0;
    if (cloro >= 1.0 && cloro <= 3.0) return "Ideal";
    if (cloro >= 0.5 && cloro <= 4.0) return "Atenção";
    return "Crítico";
  }
}