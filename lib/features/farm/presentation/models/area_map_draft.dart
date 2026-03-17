import '../../domain/entities/farm_area.dart';

class AreaMapDraft {
  const AreaMapDraft({
    required this.points,
    required this.areaM2,
    required this.areaHectares,
    required this.perimeter,
    required this.isClosed,
  });

  final List<FarmAreaPoint> points;
  final double areaM2;
  final double areaHectares;
  final double perimeter;
  final bool isClosed;

  AreaMapDraft copyWith({
    List<FarmAreaPoint>? points,
    double? areaM2,
    double? areaHectares,
    double? perimeter,
    bool? isClosed,
  }) {
    return AreaMapDraft(
      points: points ?? this.points,
      areaM2: areaM2 ?? this.areaM2,
      areaHectares: areaHectares ?? this.areaHectares,
      perimeter: perimeter ?? this.perimeter,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  factory AreaMapDraft.empty() {
    return const AreaMapDraft(
      points: [],
      areaM2: 0,
      areaHectares: 0,
      perimeter: 0,
      isClosed: false,
    );
  }
}
