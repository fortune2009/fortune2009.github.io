import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wear_data/widgets/range_selector.dart';

void main() {
  testWidgets('Range selector smoke test', (WidgetTester tester) async {
    // Build a simple widget to test basic functionality
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RangeSelector(
            selectedRange: DateRange.days90,
            onRangeChanged: (range) {},
            largeDataset: false,
            onLargeDatasetToggle: (value) {},
          ),
        ),
      ),
    );

    // Verify that the range selector renders
    expect(find.text('7d'), findsOneWidget);
    expect(find.text('30d'), findsOneWidget);
    expect(find.text('90d'), findsOneWidget);
  });
}
