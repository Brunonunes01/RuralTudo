import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._datasource);

  final ReportsLocalDatasource _datasource;

  @override
  Future<ReportSummary> getSummary({required DateTime start, required DateTime end}) {
    return _datasource.getSummary(start: start, end: end);
  }
}
