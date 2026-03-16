import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._datasource);

  final ExpenseLocalDatasource _datasource;

  @override
  Future<void> delete(int id) => _datasource.delete(id);

  @override
  Future<List<Expense>> getAll() => _datasource.getAll();

  @override
  Future<void> upsert(Expense expense) => _datasource.upsert(ExpenseModel.fromEntity(expense));
}
