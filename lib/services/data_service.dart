import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/biometric_entry.dart';
import '../models/journal_entry.dart';

class DataService {
  static final _random = Random();
  
  Future<List<BiometricEntry>> loadBiometrics({bool largeDataset = false}) async {
    await _simulateLatency();
    _simulateFailure();
    
    final String jsonString = await rootBundle.loadString('assets/biometrics_90d.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    
    List<BiometricEntry> entries = jsonList
        .map((json) => BiometricEntry.fromJson(json))
        .toList();
    
    if (largeDataset) {
      entries = _generateLargeDataset(entries);
    }
    
    return entries;
  }

  Future<List<JournalEntry>> loadJournals() async {
    await _simulateLatency();
    _simulateFailure();
    
    final String jsonString = await rootBundle.loadString('assets/journals.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    
    return jsonList
        .map((json) => JournalEntry.fromJson(json))
        .toList();
  }

  List<BiometricEntry> _generateLargeDataset(List<BiometricEntry> baseEntries) {
    final List<BiometricEntry> largeDataset = [];
    final startDate = DateTime(2023, 1, 1);
    
    for (int i = 0; i < 10000; i++) {
      final date = startDate.add(Duration(days: i));
      final baseEntry = baseEntries[i % baseEntries.length];
      
      largeDataset.add(BiometricEntry(
        date: date,
        hrv: (baseEntry.hrv ?? 60) + (_random.nextDouble() - 0.5) * 10,
        rhr: (baseEntry.rhr ?? 60) + (_random.nextInt(10) - 5),
        steps: (baseEntry.steps ?? 7000) + _random.nextInt(4000) - 2000,
        sleepScore: (baseEntry.sleepScore ?? 80) + _random.nextInt(20) - 10,
      ));
    }
    
    return largeDataset;
  }

  Future<void> _simulateLatency() async {
    final delay = 700 + _random.nextInt(500); // 700-1200ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  void _simulateFailure() {
    if (_random.nextDouble() < 0.1) { // 10% failure rate
      throw Exception('Simulated network failure');
    }
  }
}
