import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_action_button.dart';
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
              const AppSectionHeader(
                title: 'Resumo essencial',
                subtitle: 'Visão rápida do dia e do mês',
              ),
              const SizedBox(height: 12),
              AppStatCard(
                label: 'Total vendido hoje',
                value: Formatters.currency(summary.soldToday),
                icon: Icons.today_outlined,
              ),
              const SizedBox(height: 10),
              AppStatCard(
                label: 'Total vendido no mês',
                value: Formatters.currency(summary.soldMonth),
                icon: Icons.calendar_month_outlined,
              ),
              const SizedBox(height: 10),
              AppStatCard(
                label: 'Despesas do mês',
                value: Formatters.currency(summary.expensesMonth),
                icon: Icons.receipt_long_outlined,
              ),
              const SizedBox(height: 10),
              AppStatCard(
                label: 'Lucro estimado',
                value: Formatters.currency(summary.estimatedProfit),
                icon: Icons.trending_up_outlined,
              ),
              const SizedBox(height: 20),
              const AppSectionHeader(title: 'Atalhos rápidos'),
              const SizedBox(height: 10),
              Row(
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
                      label: 'Nova produção',
                      isPrimary: false,
                      icon: Icons.agriculture_outlined,
                      onPressed: () => context.go(AppRoutes.production),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const AppSectionHeader(title: 'Alertas'),
              const SizedBox(height: 10),
              AppStatCard(
                label: 'Estoque baixo',
                value: summary.lowStockCount.toString(),
                icon: Icons.warning_amber_outlined,
                iconColor: Colors.orange.shade700,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
