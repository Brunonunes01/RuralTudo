import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class UpsertExpenseUseCase {
  UpsertExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(Expense expense) => _repository.upsert(expense);
}
