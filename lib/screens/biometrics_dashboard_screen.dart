import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/biometric_entry.dart';
import '../models/journal_entry.dart';
import '../services/data_service.dart';
import '../widgets/biometrics_charts.dart';
import '../widgets/range_selector.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../app.dart';

final dataServiceProvider = Provider((ref) => DataService());
final selectedRangeProvider = StateProvider<DateRange>((ref) => DateRange.days90);
final largeDatasetProvider = StateProvider<bool>((ref) => false);

final biometricsDataProvider = FutureProvider.family<List<BiometricEntry>, bool>((ref, largeDataset) {
  final dataService = ref.read(dataServiceProvider);
  return dataService.loadBiometrics(largeDataset: largeDataset);
});

final journalsDataProvider = FutureProvider<List<JournalEntry>>((ref) {
  final dataService = ref.read(dataServiceProvider);
  return dataService.loadJournals();
});

class BiometricsDashboardScreen extends ConsumerWidget {
  const BiometricsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(selectedRangeProvider);
    final largeDataset = ref.watch(largeDatasetProvider);
    final biometricsAsync = ref.watch(biometricsDataProvider(largeDataset));
    final journalsAsync = ref.watch(journalsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometrics Dashboard'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final currentTheme = ref.read(themeProvider);
              ref.read(themeProvider.notifier).state = 
                  currentTheme == ThemeMode.dark 
                      ? ThemeMode.light 
                      : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          RangeSelector(
            selectedRange: selectedRange,
            onRangeChanged: (range) {
              ref.read(selectedRangeProvider.notifier).state = range;
            },
            largeDataset: largeDataset,
            onLargeDatasetToggle: (value) {
              ref.read(largeDatasetProvider.notifier).state = value;
            },
          ),
          Expanded(
            child: biometricsAsync.when(
              loading: () => const LoadingView(),
              error: (error, stack) => ErrorView(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(biometricsDataProvider);
                  ref.invalidate(journalsDataProvider);
                },
              ),
              data: (biometrics) => journalsAsync.when(
                loading: () => const LoadingView(),
                error: (error, stack) => ErrorView(
                  message: error.toString(),
                  onRetry: () {
                    ref.invalidate(journalsDataProvider);
                  },
                ),
                data: (journals) => _buildCharts(
                  context,
                  biometrics,
                  journals,
                  selectedRange,
                  largeDataset,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(
    BuildContext context,
    List<BiometricEntry> biometrics,
    List<JournalEntry> journals,
    DateRange selectedRange,
    bool largeDataset,
  ) {
    final now = DateTime.now();
    final DateTime startDate;
    
    switch (selectedRange) {
      case DateRange.days7:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case DateRange.days30:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case DateRange.days90:
        startDate = now.subtract(const Duration(days: 90));
        break;
    }

    final shouldDecimate = selectedRange != DateRange.days7 || largeDataset;

    return SingleChildScrollView(
      child: BiometricsCharts(
        data: biometrics,
        journals: journals,
        startDate: startDate,
        endDate: now,
        shouldDecimate: shouldDecimate,
      ),
    );
  }
}
