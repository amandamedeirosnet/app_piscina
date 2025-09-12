import 'package:flutter/material.dart';
import '../services/data_service.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    setState(() {
      _loading = true;
    });

    try {
      final stats = await DataService.getStatistics();
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar estatísticas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estatísticas'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _stats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhuma estatística disponível'),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Resumo geral
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Resumo Geral',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatCard(
                                    'Total de Leituras',
                                    _stats['totalReadings'].toString(),
                                    Icons.analytics,
                                    Colors.blue,
                                  ),
                                  _buildStatCard(
                                    'pH Médio',
                                    _stats['avgPh'].toString(),
                                    Icons.science,
                                    Colors.green,
                                  ),
                                  _buildStatCard(
                                    'Cloro Médio',
                                    '${_stats['avgCloro']} ppm',
                                    Icons.water_drop,
                                    Colors.cyan,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Status atual
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Atual',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              _buildStatusRow('pH', _stats['phStatus']),
                              _buildStatusRow('Cloro', _stats['cloroStatus']),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Recomendações
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recomendações',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              ..._buildRecommendations(),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Botão de atualizar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _carregarEstatisticas,
                          icon: Icon(Icons.refresh),
                          label: Text('Atualizar Estatísticas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusRow(String parametro, String status) {
    Color statusColor = status.contains("Ideal") ? Colors.green : 
                       status.contains("Atenção") ? Colors.orange : Colors.red;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$parametro: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecommendations() {
    List<Widget> recommendations = [];
    
    if (_stats['phStatus'] == 'Crítico') {
      recommendations.add(_buildRecommendation(
        'pH Crítico',
        'O pH está fora dos limites seguros. Ajuste imediatamente.',
        Icons.warning,
        Colors.red,
      ));
    } else if (_stats['phStatus'] == 'Atenção') {
      recommendations.add(_buildRecommendation(
        'pH em Atenção',
        'O pH está próximo dos limites. Monitore de perto.',
        Icons.info,
        Colors.orange,
      ));
    }

    if (_stats['cloroStatus'] == 'Crítico') {
      recommendations.add(_buildRecommendation(
        'Cloro Crítico',
        'O nível de cloro está fora dos limites seguros. Ajuste imediatamente.',
        Icons.warning,
        Colors.red,
      ));
    } else if (_stats['cloroStatus'] == 'Atenção') {
      recommendations.add(_buildRecommendation(
        'Cloro em Atenção',
        'O nível de cloro está próximo dos limites. Monitore de perto.',
        Icons.info,
        Colors.orange,
      ));
    }

    if (recommendations.isEmpty) {
      recommendations.add(_buildRecommendation(
        'Tudo em Ordem',
        'Todos os parâmetros estão dentro dos limites ideais.',
        Icons.check_circle,
        Colors.green,
      ));
    }

    return recommendations;
  }

  Widget _buildRecommendation(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
