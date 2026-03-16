import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAll();
  Future<void> upsert(Customer customer);
  Future<void> delete(int id);
}
