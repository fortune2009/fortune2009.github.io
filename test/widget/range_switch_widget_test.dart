import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wear_data/widgets/range_selector.dart';
import 'package:wear_data/widgets/biometrics_charts.dart';

void main() {
  group('Range Switch Widget Tests', () {
    testWidgets('range selector updates selected range', (WidgetTester tester) async {
      DateRange? selectedRange;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RangeSelector(
              selectedRange: DateRange.days90,
              onRangeChanged: (range) => selectedRange = range,
              largeDataset: false,
              onLargeDatasetToggle: (_) {},
            ),
          ),
        ),
      );
      
      // Find and tap the 7d button
      await tester.tap(find.text('7d'));
      await tester.pumpAndSettle();
      
      expect(selectedRange, equals(DateRange.days7));
      
      // Find and tap the 30d button
      await tester.tap(find.text('30d'));
      await tester.pumpAndSettle();
      
      expect(selectedRange, equals(DateRange.days30));
    });
    
    testWidgets('large dataset toggle works', (WidgetTester tester) async {
      bool? largeDataset;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RangeSelector(
              selectedRange: DateRange.days90,
              onRangeChanged: (range) {},
              largeDataset: false,
              onLargeDatasetToggle: (value) => largeDataset = value,
            ),
          ),
        ),
      );
      
      // Find and tap the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      
      expect(largeDataset, isTrue);
    });
    
    testWidgets('tooltip synchronization test', (WidgetTester tester) async {
      // This test verifies that the tooltip provider can be updated
      // In a real scenario, this would test chart interaction
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final tooltipDate = ref.watch(tooltipDateProvider);
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Tooltip: ${tooltipDate?.toString() ?? 'None'}'),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(tooltipDateProvider.notifier).state = 
                              DateTime(2025, 10, 22);
                        },
                        child: const Text('Set Tooltip'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially no tooltip
      expect(find.text('Tooltip: None'), findsOneWidget);
      
      // Tap button to set tooltip
      await tester.tap(find.text('Set Tooltip'));
      await tester.pumpAndSettle();
      
      // Verify tooltip is set
      expect(find.textContaining('2025-10-22'), findsOneWidget);
    });
  });
}
