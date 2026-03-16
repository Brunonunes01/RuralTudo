import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._datasource);

  final CustomerLocalDatasource _datasource;

  @override
  Future<void> delete(int id) => _datasource.delete(id);

  @override
  Future<List<Customer>> getAll() => _datasource.getAll();

  @override
  Future<void> upsert(Customer customer) => _datasource.upsert(CustomerModel.fromEntity(customer));
}
