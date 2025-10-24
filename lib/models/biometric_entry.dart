class BiometricEntry {
  final DateTime date;
  final double? hrv;
  final double? rhr;
  final int? steps;
  final int? sleepScore;

  BiometricEntry({
    required this.date,
    this.hrv,
    this.rhr,
    this.steps,
    this.sleepScore,
  });

  factory BiometricEntry.fromJson(Map<String, dynamic> json) {
    return BiometricEntry(
      date: DateTime.parse(json['date'] ?? ''),
      hrv: json['hrv']?.toDouble(),
      rhr: json['rhr']?.toDouble(),
      steps: json['steps']?.toInt(),
      sleepScore: json['sleepScore']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'hrv': hrv,
      'rhr': rhr,
      'steps': steps,
      'sleepScore': sleepScore,
    };
  }
}
