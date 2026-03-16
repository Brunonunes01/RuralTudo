import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsControllerProvider);

    return AppScaffold(
      title: 'Relatorios',
      body: state.when(
        data: (report) => ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text('Vendas no periodo'),
                trailing: Text(Formatters.currency(report.totalSales)),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Despesas no periodo'),
                trailing: Text(Formatters.currency(report.totalExpenses)),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Lucro estimado'),
                trailing: Text(Formatters.currency(report.estimatedProfit)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Produtos mais vendidos', style: TextStyle(fontWeight: FontWeight.bold)),
            ...report.topProducts.map((e) => ListTile(title: Text(e))),
            const SizedBox(height: 12),
            const Text('Produtos com estoque baixo', style: TextStyle(fontWeight: FontWeight.bold)),
            ...report.lowStockProducts.map((e) => ListTile(title: Text(e))),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Producao no periodo'),
              trailing: Text(report.totalProduction.toStringAsFixed(2)),
            ),
            const SizedBox(height: 12),
            const Text('Resumo por categoria', style: TextStyle(fontWeight: FontWeight.bold)),
            ...report.salesByCategory.map((e) => ListTile(title: Text(e))),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
