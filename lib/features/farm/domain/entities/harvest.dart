class Harvest {
  Harvest({
    this.id,
    required this.plantingId,
    required this.cropName,
    required this.areaName,
    required this.harvestDate,
    required this.quantity,
    required this.unit,
    this.lossQuantity,
    this.notes,
    required this.soldQuantity,
  });

  final int? id;
  final int plantingId;
  final String cropName;
  final String areaName;
  final DateTime harvestDate;
  final double quantity;
  final String unit;
  final double? lossQuantity;
  final String? notes;
  final double soldQuantity;

  double get availableQuantity => quantity - soldQuantity;
}
