import 'dart:math';

class RollingStats {
  /// Calculates 7-day rolling mean and standard deviation
  static Map<DateTime, RollingStatsResult> calculate7DayRolling(
    List<MapEntry<DateTime, double>> data,
  ) {
    final Map<DateTime, RollingStatsResult> results = {};
    
    for (int i = 0; i < data.length; i++) {
      final currentDate = data[i].key;
      final values = <double>[];
      
      // Collect values from current day and up to 6 days before
      for (int j = max(0, i - 6); j <= i; j++) {
        values.add(data[j].value);
      }
      
      final mean = values.reduce((a, b) => a + b) / values.length;
      
      double variance = 0;
      for (final value in values) {
        variance += pow(value - mean, 2);
      }
      variance /= values.length;
      
      final stdDev = sqrt(variance);
      
      results[currentDate] = RollingStatsResult(
        mean: mean,
        standardDeviation: stdDev,
      );
    }
    
    return results;
  }
}

class RollingStatsResult {
  final double mean;
  final double standardDeviation;
  
  RollingStatsResult({
    required this.mean,
    required this.standardDeviation,
  });
  
  double get upperBand => mean + standardDeviation;
  double get lowerBand => mean - standardDeviation;
}
