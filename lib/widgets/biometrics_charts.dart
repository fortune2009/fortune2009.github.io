import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/biometric_entry.dart';
import '../models/journal_entry.dart';
import '../utils/rolling_stats.dart';
import '../utils/decimator.dart';
import 'chart_container.dart';

final tooltipDateProvider = StateProvider<DateTime?>((ref) => null);

class BiometricsCharts extends ConsumerWidget {
  final List<BiometricEntry> data;
  final List<JournalEntry> journals;
  final DateTime startDate;
  final DateTime endDate;
  final bool shouldDecimate;

  const BiometricsCharts({
    super.key,
    required this.data,
    required this.journals,
    required this.startDate,
    required this.endDate,
    this.shouldDecimate = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No data available for selected range'),
        ),
      );
    }

    final filteredData = data
        .where((entry) =>
            entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();

    final decimatedData = shouldDecimate && filteredData.length > 100
        ? Decimator.decimate(
            filteredData,
            100,
            (entry) => entry.date.millisecondsSinceEpoch.toDouble(),
            (entry) => entry.hrv ?? 0,
          )
        : filteredData;

    return Column(
      children: [
        ChartContainer(
          title: 'Heart Rate Variability',
          unit: 'ms',
          chart: _buildHRVChart(context, ref, decimatedData),
        ),
        ChartContainer(
          title: 'Resting Heart Rate',
          unit: 'bpm',
          chart: _buildRHRChart(context, ref, decimatedData),
        ),
        ChartContainer(
          title: 'Steps',
          unit: 'count',
          chart: _buildStepsChart(context, ref, decimatedData),
        ),
      ],
    );
  }

  Widget _buildHRVChart(
      BuildContext context, WidgetRef ref, List<BiometricEntry> data) {
    final hrvData = data
        .where((entry) => entry.hrv != null)
        .map((entry) => MapEntry(entry.date, entry.hrv!))
        .toList();

    if (hrvData.isEmpty) return const Center(child: Text('No HRV data'));

    final rollingStats = RollingStats.calculate7DayRolling(hrvData);
    final tooltipDate = ref.watch(tooltipDateProvider);

    return LineChart(
      LineChartData(
        minX: startDate.millisecondsSinceEpoch.toDouble(),
        maxX: endDate.millisecondsSinceEpoch.toDouble(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (endDate.difference(startDate).inDays / 4) *
                  24 *
                  60 *
                  60 *
                  1000,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text('${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}ms',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          // HRV band (mean ± 1σ)
          LineChartBarData(
            spots: rollingStats.entries
                .map((entry) => FlSpot(
                      entry.key.millisecondsSinceEpoch.toDouble(),
                      entry.value.upperBand,
                    ))
                .toList(),
            isCurved: true,
            color: Colors.blue.withValues(alpha: 0.3),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
              cutOffY: rollingStats.values.first.lowerBand,
              applyCutOffY: true,
            ),
          ),
          // HRV line
          LineChartBarData(
            spots: hrvData
                .map((entry) => FlSpot(
                      entry.key.millisecondsSinceEpoch.toDouble(),
                      entry.value,
                    ))
                .toList(),
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(
              show: tooltipDate != null,
              checkToShowDot: (spot, barData) {
                if (tooltipDate == null) return false;
                final spotDate =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return spotDate.day == tooltipDate.day &&
                    spotDate.month == tooltipDate.month &&
                    spotDate.year == tooltipDate.year;
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            if (response?.lineBarSpots?.isNotEmpty == true) {
              final spot = response!.lineBarSpots!.first;
              final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
              ref.read(tooltipDateProvider.notifier).state = date;
            }
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return LineTooltipItem(
                  '${date.month}/${date.day}: ${spot.y.toStringAsFixed(1)} ms',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          verticalLines: _buildJournalMarkers(context),
        ),
      ),
    );
  }

  Widget _buildRHRChart(
      BuildContext context, WidgetRef ref, List<BiometricEntry> data) {
    final rhrData = data.where((entry) => entry.rhr != null).toList();
    if (rhrData.isEmpty) return const Center(child: Text('No RHR data'));

    final tooltipDate = ref.watch(tooltipDateProvider);

    return LineChart(
      LineChartData(
        minX: startDate.millisecondsSinceEpoch.toDouble(),
        maxX: endDate.millisecondsSinceEpoch.toDouble(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (endDate.difference(startDate).inDays / 4) *
                  24 *
                  60 *
                  60 *
                  1000,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text('${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: rhrData
                .map((entry) => FlSpot(
                      entry.date.millisecondsSinceEpoch.toDouble(),
                      entry.rhr!.toDouble(),
                    ))
                .toList(),
            isCurved: true,
            color: Colors.red,
            dotData: FlDotData(
              show: tooltipDate != null,
              checkToShowDot: (spot, barData) {
                if (tooltipDate == null) return false;
                final spotDate =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return spotDate.day == tooltipDate.day &&
                    spotDate.month == tooltipDate.month &&
                    spotDate.year == tooltipDate.year;
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            if (response?.lineBarSpots?.isNotEmpty == true) {
              final spot = response!.lineBarSpots!.first;
              final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
              ref.read(tooltipDateProvider.notifier).state = date;
            }
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return LineTooltipItem(
                  '${date.month}/${date.day}: ${spot.y.toStringAsFixed(0)} bpm',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          verticalLines: _buildJournalMarkers(context),
        ),
      ),
    );
  }

  Widget _buildStepsChart(
      BuildContext context, WidgetRef ref, List<BiometricEntry> data) {
    final stepsData = data.where((entry) => entry.steps != null).toList();
    if (stepsData.isEmpty) return const Center(child: Text('No steps data'));

    final tooltipDate = ref.watch(tooltipDateProvider);

    return LineChart(
      LineChartData(
        minX: startDate.millisecondsSinceEpoch.toDouble(),
        maxX: endDate.millisecondsSinceEpoch.toDouble(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (endDate.difference(startDate).inDays / 4) *
                  24 *
                  60 *
                  60 *
                  1000,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text('${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text('${(value / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: stepsData
                .map((entry) => FlSpot(
                      entry.date.millisecondsSinceEpoch.toDouble(),
                      entry.steps!.toDouble(),
                    ))
                .toList(),
            isCurved: true,
            color: Colors.green,
            dotData: FlDotData(
              show: tooltipDate != null,
              checkToShowDot: (spot, barData) {
                if (tooltipDate == null) return false;
                final spotDate =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return spotDate.day == tooltipDate.day &&
                    spotDate.month == tooltipDate.month &&
                    spotDate.year == tooltipDate.year;
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            if (response?.lineBarSpots?.isNotEmpty == true) {
              final spot = response!.lineBarSpots!.first;
              final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
              ref.read(tooltipDateProvider.notifier).state = date;
            }
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return LineTooltipItem(
                  '${date.month}/${date.day}: ${spot.y.toStringAsFixed(0)} steps',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          verticalLines: _buildJournalMarkers(context),
        ),
      ),
    );
  }

  List<VerticalLine> _buildJournalMarkers(BuildContext context) {
    return journals
        .where((journal) =>
            journal.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            journal.date.isBefore(endDate.add(const Duration(days: 1))))
        .map((journal) => VerticalLine(
              x: journal.date.millisecondsSinceEpoch.toDouble(),
              color: _getMoodColor(journal.mood),
              strokeWidth: 2,
            ))
        .toList();
  }

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
