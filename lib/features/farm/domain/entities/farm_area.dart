class FarmArea {
  FarmArea({
    this.id,
    required this.name,
    this.description,
    this.areaSize,
    this.areaUnit,
    this.notes,
    this.isActive = true,
  });

  final int? id;
  final String name;
  final String? description;
  final double? areaSize;
  final String? areaUnit;
  final String? notes;
  final bool isActive;
}
