import '../entities/report_summary.dart';
import '../repositories/reports_repository.dart';

class GetReportSummaryUseCase {
  GetReportSummaryUseCase(this._repository);

  final ReportsRepository _repository;

  Future<ReportSummary> call({required DateTime start, required DateTime end}) {
    return _repository.getSummary(start: start, end: end);
  }
}
