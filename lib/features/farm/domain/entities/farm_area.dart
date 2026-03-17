class FarmArea {
  FarmArea({
    this.id,
    required this.name,
    this.description,
    this.observations,
    this.areaM2,
    this.areaHectares,
    this.perimeter,
    this.polygonPoints = const [],
    this.createdAt,
    this.updatedAt,
    this.notes,
    this.isActive = true,
  });

  final int? id;
  final String name;
  final String? description;
  final String? observations;
  final double? areaM2;
  final double? areaHectares;
  final double? perimeter;
  final List<FarmAreaPoint> polygonPoints;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final bool isActive;

  FarmArea copyWith({
    int? id,
    String? name,
    String? description,
    String? observations,
    double? areaM2,
    double? areaHectares,
    double? perimeter,
    List<FarmAreaPoint>? polygonPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    bool? isActive,
  }) {
    return FarmArea(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      observations: observations ?? this.observations,
      areaM2: areaM2 ?? this.areaM2,
      areaHectares: areaHectares ?? this.areaHectares,
      perimeter: perimeter ?? this.perimeter,
      polygonPoints: polygonPoints ?? this.polygonPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}

class FarmAreaPoint {
  const FarmAreaPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;

  Map<String, double> toJson() => {'lat': lat, 'lng': lng};

  factory FarmAreaPoint.fromJson(Map<String, dynamic> json) {
    return FarmAreaPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}
