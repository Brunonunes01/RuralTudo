import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/report_summary.dart';
import '../../domain/usecases/get_report_summary_usecase.dart';

class ReportsController extends StateNotifier<AsyncValue<ReportSummary>> {
  ReportsController(this._useCase) : super(const AsyncValue.loading()) {
    load();
  }

  final GetReportSummaryUseCase _useCase;

  Future<void> load({DateTime? start, DateTime? end}) async {
    final now = DateTime.now();
    final from = start ?? DateTime(now.year, now.month, 1);
    final to = end ?? now;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _useCase(start: from, end: to));
  }
}
