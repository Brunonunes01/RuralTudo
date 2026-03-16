import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/upsert_expense_usecase.dart';

class ExpenseController extends StateNotifier<AsyncValue<List<Expense>>> {
  ExpenseController(this._getExpenses, this._upsertExpense, this._deleteExpense)
      : super(const AsyncValue.loading()) {
    load();
  }

  final GetExpensesUseCase _getExpenses;
  final UpsertExpenseUseCase _upsertExpense;
  final DeleteExpenseUseCase _deleteExpense;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getExpenses.call);
  }

  Future<void> save({
    int? id,
    required String description,
    required String category,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    await _upsertExpense(
      Expense(
        id: id,
        description: description,
        category: category,
        amount: amount,
        date: date,
        notes: notes,
        createdAt: DateTime.now(),
      ),
    );
    await load();
  }

  Future<void> remove(int id) async {
    await _deleteExpense(id);
    await load();
  }
}
