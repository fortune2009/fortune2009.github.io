import 'package:flutter_test/flutter_test.dart';
import 'package:wear_data/utils/decimator.dart';

class TestPoint {
  final double x;
  final double y;
  
  TestPoint(this.x, this.y);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestPoint && runtimeType == other.runtimeType && x == other.x && y == other.y;
  
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

void main() {
  group('Decimator', () {
    test('preserves min and max values', () {
      // Create test data with known min and max
      final points = <TestPoint>[
        TestPoint(1, 10),
        TestPoint(2, 5),   // min
        TestPoint(3, 15),
        TestPoint(4, 20),  // max
        TestPoint(5, 12),
        TestPoint(6, 8),
        TestPoint(7, 18),
        TestPoint(8, 14),
      ];
      
      final decimated = Decimator.decimate(
        points,
        4,
        (p) => p.x,
        (p) => p.y,
      );
      
      // Find min and max in original data
      final originalMin = points.reduce((a, b) => a.y < b.y ? a : b);
      final originalMax = points.reduce((a, b) => a.y > b.y ? a : b);
      
      // Check that min and max are preserved
      expect(decimated.contains(originalMin), isTrue, reason: 'Min value should be preserved');
      expect(decimated.contains(originalMax), isTrue, reason: 'Max value should be preserved');
    });
    
    test('reduces output to target size or smaller', () {
      final points = List.generate(100, (i) => TestPoint(i.toDouble(), i.toDouble()));
      
      final decimated = Decimator.decimate(
        points,
        20,
        (p) => p.x,
        (p) => p.y,
      );
      
      expect(decimated.length, lessThanOrEqualTo(25), // Allow for min/max preservation
          reason: 'Output should be close to target size');
    });
    
    test('returns original list when target size is larger', () {
      final points = [
        TestPoint(1, 10),
        TestPoint(2, 20),
        TestPoint(3, 15),
      ];
      
      final decimated = Decimator.decimate(
        points,
        10,
        (p) => p.x,
        (p) => p.y,
      );
      
      expect(decimated.length, equals(points.length));
    });
    
    test('maintains chronological order', () {
      final points = <TestPoint>[
        TestPoint(1, 10),
        TestPoint(3, 15),
        TestPoint(2, 5),   // Out of order
        TestPoint(4, 20),
        TestPoint(5, 12),
      ];
      
      final decimated = Decimator.decimate(
        points,
        3,
        (p) => p.x,
        (p) => p.y,
      );
      
      // Check that result is sorted by x
      for (int i = 1; i < decimated.length; i++) {
        expect(decimated[i].x, greaterThanOrEqualTo(decimated[i - 1].x),
            reason: 'Points should be in chronological order');
      }
    });
  });
}
