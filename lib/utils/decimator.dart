import 'dart:math';

/// Largest Triangle Three Buckets (LTTB) decimation algorithm
/// Reference: https://github.com/sveinn-steinarsson/flot-downsample
class Decimator {
  /// Decimates a list of points using LTTB algorithm while preserving min/max values
  static List<T> decimate<T>(
    List<T> points,
    int targetSize,
    double Function(T) xGetter,
    double Function(T) yGetter,
  ) {
    if (points.length <= targetSize || targetSize < 3) {
      return List.from(points);
    }

    final result = <T>[];
    final bucketSize = (points.length - 2) / (targetSize - 2);
    
    // Always include first point
    result.add(points.first);
    
    // Find global min and max to preserve them
    T? minPoint, maxPoint;
    double minY = double.infinity, maxY = double.negativeInfinity;
    
    for (final point in points) {
      final y = yGetter(point);
      if (y < minY) {
        minY = y;
        minPoint = point;
      }
      if (y > maxY) {
        maxY = y;
        maxPoint = point;
      }
    }

    int nextA = 0;

    for (int i = 0; i < targetSize - 2; i++) {
      final bucketStart = ((i + 1) * bucketSize).floor() + 1;
      final bucketEnd = min(((i + 2) * bucketSize).floor() + 1, points.length - 1);
      
      // Calculate average point of next bucket for triangle area calculation
      double avgX = 0, avgY = 0;
      int avgRangeStart = min(bucketEnd, points.length - 1);
      int avgRangeEnd = min(avgRangeStart + bucketSize.ceil(), points.length);
      
      for (int j = avgRangeStart; j < avgRangeEnd; j++) {
        avgX += xGetter(points[j]);
        avgY += yGetter(points[j]);
      }
      
      if (avgRangeEnd > avgRangeStart) {
        avgX /= (avgRangeEnd - avgRangeStart);
        avgY /= (avgRangeEnd - avgRangeStart);
      }

      // Find point with largest triangle area in current bucket
      double maxArea = -1;
      int maxAreaIndex = bucketStart;
      
      final pointAX = xGetter(points[nextA]);
      final pointAY = yGetter(points[nextA]);
      
      for (int j = bucketStart; j < bucketEnd; j++) {
        final pointBX = xGetter(points[j]);
        final pointBY = yGetter(points[j]);
        
        final area = ((pointAX * (pointBY - avgY) + 
                      pointBX * (avgY - pointAY) + 
                      avgX * (pointAY - pointBY)) / 2).abs();
        
        if (area > maxArea) {
          maxArea = area;
          maxAreaIndex = j;
        }
      }
      
      result.add(points[maxAreaIndex]);
      nextA = maxAreaIndex;
    }
    
    // Always include last point
    result.add(points.last);
    
    // Ensure min/max points are included if not already present
    if (minPoint != null && !result.contains(minPoint)) {
      result.add(minPoint);
    }
    if (maxPoint != null && !result.contains(maxPoint)) {
      result.add(maxPoint);
    }
    
    // Sort by x-axis to maintain chronological order
    result.sort((a, b) => xGetter(a).compareTo(xGetter(b)));
    
    return result;
  }
}
