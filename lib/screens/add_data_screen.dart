import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pool_data.dart';
import '../services/data_service.dart';

class AddDataScreen extends StatefulWidget {
  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phController = TextEditingController();
  final _cloroController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _phController.dispose();
    _cloroController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final poolData = PoolData(
        ph: _phController.text,
        cloro: _cloroController.text,
        data: DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate),
        timestamp: _selectedDate.millisecondsSinceEpoch,
      );

      await DataService.savePoolData(poolData);

      // Mostrar confirmação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dados salvos com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Limpar formulário
      _phController.clear();
      _cloroController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validatePh(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o valor do pH';
    }
    final ph = double.tryParse(value);
    if (ph == null) {
      return 'Por favor, insira um valor numérico válido';
    }
    if (ph < 0 || ph > 14) {
      return 'O pH deve estar entre 0 e 14';
    }
    return null;
  }

  String? _validateCloro(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o valor do cloro';
    }
    final cloro = double.tryParse(value);
    if (cloro == null) {
      return 'Por favor, insira um valor numérico válido';
    }
    if (cloro < 0) {
      return 'O cloro não pode ser negativo';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Dados'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card principal
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.blue[600],
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Nova Leitura da Piscina',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Campo pH
                        Text(
                          'Nível de pH',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _phController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Ex: 7.4',
                            prefixIcon: Icon(Icons.science, color: Colors.blue[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                            ),
                          ),
                          validator: _validatePh,
                        ),
                        SizedBox(height: 16),

                        // Campo Cloro
                        Text(
                          'Nível de Cloro (ppm)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _cloroController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Ex: 2.5',
                            prefixIcon: Icon(Icons.water_drop, color: Colors.blue[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                            ),
                          ),
                          validator: _validateCloro,
                        ),
                        SizedBox(height: 24),

                        // Data e Hora
                        Text(
                          'Data e Hora da Leitura',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _selectDate,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.blue[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _selectTime,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.blue[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        DateFormat('HH:mm').format(_selectedDate),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Botão Salvar
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Salvando...', style: TextStyle(fontSize: 16)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text('Salvar Dados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),

                SizedBox(height: 16),

                // Informações sobre valores ideais
                Card(
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[600]),
                            SizedBox(width: 8),
                            Text(
                              'Valores Ideais',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildInfoItem('pH', '7.2 - 7.8', 'Ideal'),
                        _buildInfoItem('Cloro', '1.0 - 3.0 ppm', 'Ideal'),
                        _buildInfoItem('pH', '7.0 - 8.0', 'Atenção'),
                        _buildInfoItem('Cloro', '0.5 - 4.0 ppm', 'Atenção'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String parameter, String range, String status) {
    Color statusColor = status == 'Ideal' ? Colors.green : Colors.orange;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$parameter: ',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            range,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
