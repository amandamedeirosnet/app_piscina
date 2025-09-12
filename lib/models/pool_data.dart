class PoolData {
  final String ph;
  final String cloro;
  final String data;
  final int timestamp;

  PoolData({
    required this.ph,
    required this.cloro,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'ph': ph,
      'cloro': cloro,
      'data': data,
      'timestamp': timestamp,
    };
  }

  factory PoolData.fromJson(Map<String, dynamic> json) {
    return PoolData(
      ph: json['ph'],
      cloro: json['cloro'],
      data: json['data'],
      timestamp: json['timestamp'],
    );
  }

  String get phStatus {
    final phValue = double.tryParse(ph) ?? 0;
    if (phValue >= 7.2 && phValue <= 7.8) return "Ideal";
    if (phValue >= 7.0 && phValue <= 8.0) return "Atenção";
    return "Crítico";
  }

  String get cloroStatus {
    final cloroValue = double.tryParse(cloro) ?? 0;
    if (cloroValue >= 1.0 && cloroValue <= 3.0) return "Ideal";
    if (cloroValue >= 0.5 && cloroValue <= 4.0) return "Atenção";
    return "Crítico";
  }
}
