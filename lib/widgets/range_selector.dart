import 'package:flutter/material.dart';

enum DateRange { days7, days30, days90 }

class RangeSelector extends StatelessWidget {
  final DateRange selectedRange;
  final Function(DateRange) onRangeChanged;
  final bool largeDataset;
  final Function(bool) onLargeDatasetToggle;

  const RangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.largeDataset,
    required this.onLargeDatasetToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          SegmentedButton<DateRange>(
            segments: const [
              ButtonSegment(
                value: DateRange.days7,
                label: Text('7d'),
              ),
              ButtonSegment(
                value: DateRange.days30,
                label: Text('30d'),
              ),
              ButtonSegment(
                value: DateRange.days90,
                label: Text('90d'),
              ),
            ],
            selected: {selectedRange},
            onSelectionChanged: (Set<DateRange> selection) {
              onRangeChanged(selection.first);
            },
          ),
          const Spacer(),
          Row(
            children: [
              const Text('Large Dataset (10k+)'),
              const SizedBox(width: 8),
              Switch(
                value: largeDataset,
                onChanged: onLargeDatasetToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
