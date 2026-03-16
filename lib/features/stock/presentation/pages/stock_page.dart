import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';

class StockPage extends ConsumerWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movements = ref.watch(stockControllerProvider);
    final lowStock = ref.watch(lowStockProductsProvider);

    return AppScaffold(
      title: 'Estoque',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alertas de estoque baixo', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: lowStock.when(
              data: (items) => items.isEmpty
                  ? const Card(child: Center(child: Text('Nenhum alerta no momento')))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('${items[i].name}: ${items[i].stockQuantity}/${items[i].minStock}'),
                        ),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Movimentacoes', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: movements.when(
              data: (items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final movement = items[i];
                  return Card(
                    child: ListTile(
                      title: Text(movement.productName),
                      subtitle: Text('${movement.movementType} - ${movement.origin} - ${Formatters.date(movement.date)}'),
                      trailing: Text(movement.quantity.toStringAsFixed(2)),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
