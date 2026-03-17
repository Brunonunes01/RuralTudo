class Planting {
  Planting({
    this.id,
    required this.areaId,
    required this.areaName,
    required this.cropName,
    this.variety,
    required this.plantingDate,
    this.expectedHarvestDate,
    this.cycleDays,
    this.plantedQuantity,
    this.plantedUnit,
    required this.initialCost,
    this.notes,
    required this.status,
  });

  final int? id;
  final int areaId;
  final String areaName;
  final String cropName;
  final String? variety;
  final DateTime plantingDate;
  final DateTime? expectedHarvestDate;
  final int? cycleDays;
  final double? plantedQuantity;
  final String? plantedUnit;
  final double initialCost;
  final String? notes;
  final String status;
}
