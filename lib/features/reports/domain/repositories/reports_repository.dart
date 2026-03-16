import '../entities/report_summary.dart';

abstract class ReportsRepository {
  Future<ReportSummary> getSummary({required DateTime start, required DateTime end});
}
