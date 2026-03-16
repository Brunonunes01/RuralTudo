import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getAll();
  Future<void> upsert(Expense expense);
  Future<void> delete(int id);
}
