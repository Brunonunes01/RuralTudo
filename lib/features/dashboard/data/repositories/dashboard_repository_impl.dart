import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._datasource);

  final DashboardLocalDatasource _datasource;

  @override
  Future<DashboardSummary> getSummary() => _datasource.getSummary();
}
