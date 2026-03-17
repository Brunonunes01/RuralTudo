import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_action_button.dart';
import '../../../../core/widgets/ui/app_animated_entry.dart';
import '../../../../core/widgets/ui/app_error_state.dart';
import '../../../../core/widgets/ui/app_loading_state.dart';
import '../../../../core/widgets/ui/app_section_header.dart';
import '../../../../core/widgets/ui/app_stat_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardSummaryProvider);

    return AppScaffold(
      title: 'Início',
      body: state.when(
        data: (summary) => RefreshIndicator(
          onRefresh: () => ref.read(dashboardSummaryProvider.notifier).load(),
          child: ListView(
            children: [
              const AppAnimatedEntry(
                index: 0,
                child: AppSectionHeader(
                  title: 'Resumo do sítio',
                  subtitle: 'Acompanhe o que precisa de atenção hoje',
                ),
              ),
              const SizedBox(height: 12),
              AppAnimatedEntry(
                index: 1,
                child: AppStatCard(
                  label: 'Plantios em andamento',
                  value: summary.plantingsInProgress.toString(),
                  icon: Icons.eco_outlined,
                ),
              ),
              const SizedBox(height: 10),
              AppAnimatedEntry(
                index: 2,
                child: AppStatCard(
                  label: 'Plantios prontos para colher',
                  value: summary.plantingsReadyToHarvest.toString(),
                  icon: Icons.grass_outlined,
                ),
              ),
              const SizedBox(height: 10),
              AppAnimatedEntry(
                index: 3,
                child: AppStatCard(
                  label: 'Colheitas recentes (30 dias)',
                  value: summary.recentHarvests.toString(),
                  icon: Icons.agriculture_outlined,
                ),
              ),
              const SizedBox(height: 10),
              AppAnimatedEntry(
                index: 4,
                child: AppStatCard(
                  label: 'Vendas recentes (30 dias)',
                  value: summary.recentSales.toString(),
                  icon: Icons.point_of_sale_outlined,
                ),
              ),
              const SizedBox(height: 10),
              AppAnimatedEntry(
                index: 5,
                child: AppStatCard(
                  label: 'Gastos recentes (30 dias)',
                  value: summary.recentExpenses.toString(),
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(height: 20),
              const AppAnimatedEntry(
                index: 6,
                child: AppSectionHeader(title: 'Atalhos rápidos'),
              ),
              const SizedBox(height: 10),
              AppAnimatedEntry(
                index: 7,
                child: Row(
                  children: [
                    Expanded(
                      child: AppActionButton(
                        label: 'Novo plantio',
                        icon: Icons.eco_outlined,
                        onPressed: () => context.go(AppRoutes.plantings),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppActionButton(
                        label: 'Nova colheita',
                        icon: Icons.agriculture_outlined,
                        onPressed: () => context.go(AppRoutes.harvests),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppAnimatedEntry(
                index: 8,
                child: Row(
                  children: [
                    Expanded(
                      child: AppActionButton(
                        label: 'Nova venda',
                        icon: Icons.point_of_sale_outlined,
                        onPressed: () => context.go(AppRoutes.sales),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppActionButton(
                        label: 'Novo gasto',
                        icon: Icons.receipt_long_outlined,
                        onPressed: () => context.go(AppRoutes.expenses),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const AppAnimatedEntry(
                index: 9,
                child: AppSectionHeader(title: 'Resultado do período'),
              ),
              const SizedBox(height: 10),
              AppAnimatedEntry(
                index: 10,
                child: AppStatCard(
                  label: 'Saldo das colheitas recentes',
                  value: summary.availableFromRecentHarvests.toStringAsFixed(2),
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(height: 10),
              AppAnimatedEntry(
                index: 11,
                child: AppStatCard(
                  label: 'Lucro estimado no mês',
                  value: Formatters.currency(summary.estimatedProfitPeriod),
                  icon: Icons.trending_up_outlined,
                ),
              ),
            ],
          ),
        ),
        loading: () => const AppLoadingState(itemCount: 8, withHeader: true),
        error: (e, _) => AppErrorState(
          message: e.toString(),
          onRetry: () => ref.read(dashboardSummaryProvider.notifier).load(),
        ),
      ),
    );
  }
}
