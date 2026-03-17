import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/farm_local_datasource.dart';
import '../../domain/entities/farm_expense.dart';

class FarmExpensesController
    extends StateNotifier<AsyncValue<List<FarmExpense>>> {
  FarmExpensesController(this._datasource) : super(const AsyncValue.loading()) {
    load();
  }

  final FarmLocalDatasource _datasource;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_datasource.getFarmExpenses);
  }

  Future<void> save({
    int? id,
    int? plantingId,
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    await _datasource.upsertFarmExpense(
      id: id,
      plantingId: plantingId,
      category: category,
      description: description,
      amount: amount,
      date: date,
      notes: notes,
    );
    await load();
  }
}
