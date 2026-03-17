import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_empty_state.dart';
import '../../../../core/widgets/ui/app_feedback.dart';
import '../../../../core/widgets/ui/app_form_text_field.dart';
import '../../../products/domain/entities/product.dart';

class ProductionPage extends ConsumerWidget {
  const ProductionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productionControllerProvider);

    return AppScaffold(
      title: 'Produção',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova produção'),
      ),
      body: state.when(
        data: (records) {
          if (records.isEmpty) {
            return const AppEmptyState(
              title: 'Nenhuma produção registrada',
              subtitle: 'Toque em "Nova produção" para registrar.',
            );
          }

          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final item = records[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Data: ${Formatters.date(item.date)}'),
                  ),
                  trailing: Text(
                    item.quantity.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Future<void> _showForm(BuildContext context, WidgetRef ref) async {
    final products = await ref.read(productRepositoryProvider).getAll();
    if (!context.mounted) return;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre produtos antes de registrar produção.'),
        ),
      );
      return;
    }

    var productId = products.first.id!;
    final quantity = TextEditingController();
    final notes = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nova produção'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: productId,
                  items: products
                      .map(
                        (Product p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => productId = value ?? productId),
                  decoration: const InputDecoration(labelText: 'Produto'),
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: quantity,
                  label: 'Quantidade',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Data'),
                    child: Row(
                      children: [
                        Text(Formatters.date(selectedDate)),
                        const Spacer(),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: notes,
                  label: 'Observação (opcional)',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final qty =
                    double.tryParse(quantity.text.replaceAll(',', '.')) ?? 0;
                if (qty <= 0) {
                  AppFeedback.error(context, 'Informe uma quantidade válida.');
                  return;
                }
                await ref
                    .read(productionControllerProvider.notifier)
                    .register(
                      productId: productId,
                      productionType: 'harvest',
                      quantity: qty,
                      notes: notes.text.trim(),
                      date: selectedDate,
                    );
                ref.invalidate(productControllerProvider);
                ref.invalidate(stockControllerProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  AppFeedback.success(context, 'Produção salva com sucesso.');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
