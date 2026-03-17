import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_stat_card.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardSummaryProvider);

    return AppScaffold(
      title: 'Resultados',
      body: dashboard.when(
        data: (summary) => ListView(
          children: [
            AppStatCard(
              label: 'Plantios em andamento',
              value: summary.plantingsInProgress.toString(),
              icon: Icons.eco_outlined,
            ),
            const SizedBox(height: 10),
            AppStatCard(
              label: 'Plantios prontos para colher',
              value: summary.plantingsReadyToHarvest.toString(),
              icon: Icons.grass_outlined,
            ),
            const SizedBox(height: 10),
            AppStatCard(
              label: 'Saldo disponível das colheitas recentes',
              value: summary.availableFromRecentHarvests.toStringAsFixed(2),
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 10),
            AppStatCard(
              label: 'Lucro estimado no período',
              value: Formatters.currency(summary.estimatedProfitPeriod),
              icon: Icons.trending_up_outlined,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
