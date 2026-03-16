import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';

class DashboardController extends StateNotifier<AsyncValue<DashboardSummary>> {
  DashboardController(this._getSummary) : super(const AsyncValue.loading()) {
    load();
  }

  final GetDashboardSummaryUseCase _getSummary;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getSummary.call);
  }
}
