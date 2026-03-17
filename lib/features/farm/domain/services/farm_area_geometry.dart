import 'dart:math' as math;

import '../entities/farm_area.dart';

class FarmAreaMetrics {
  const FarmAreaMetrics({
    required this.areaM2,
    required this.areaHectares,
    required this.perimeter,
  });

  final double areaM2;
  final double areaHectares;
  final double perimeter;
}

abstract final class FarmAreaGeometry {
  static const _earthRadius = 6378137.0;

  static FarmAreaMetrics calculate(List<FarmAreaPoint> points) {
    if (points.length < 3) {
      return const FarmAreaMetrics(areaM2: 0, areaHectares: 0, perimeter: 0);
    }

    final area = _sphericalArea(points);
    final perimeter = _perimeter(points);
    return FarmAreaMetrics(
      areaM2: area,
      areaHectares: area / 10000,
      perimeter: perimeter,
    );
  }

  static double _perimeter(List<FarmAreaPoint> points) {
    var total = 0.0;
    for (var i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];
      total += _haversineDistance(current, next);
    }
    return total;
  }

  static double _haversineDistance(FarmAreaPoint a, FarmAreaPoint b) {
    final lat1 = _toRadians(a.lat);
    final lon1 = _toRadians(a.lng);
    final lat2 = _toRadians(b.lat);
    final lon2 = _toRadians(b.lng);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final x =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
    return _earthRadius * c;
  }

  static double _sphericalArea(List<FarmAreaPoint> points) {
    var total = 0.0;
    for (var i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];
      final lat1 = _toRadians(current.lat);
      final lat2 = _toRadians(next.lat);
      final lon1 = _toRadians(current.lng);
      final lon2 = _toRadians(next.lng);
      total += (lon2 - lon1) * (2 + math.sin(lat1) + math.sin(lat2));
    }
    final area = total * _earthRadius * _earthRadius / 2;
    return area.abs();
  }

  static double _toRadians(double value) => value * math.pi / 180;
}
