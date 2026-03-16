import '../repositories/production_repository.dart';

class RegisterProductionUseCase {
  RegisterProductionUseCase(this._repository);

  final ProductionRepository _repository;

  Future<void> call({
    required int productId,
    required String productionType,
    required double quantity,
    double? estimatedCost,
    String? notes,
    required DateTime date,
  }) {
    return _repository.register(
      productId: productId,
      productionType: productionType,
      quantity: quantity,
      estimatedCost: estimatedCost,
      notes: notes,
      date: date,
    );
  }
}
