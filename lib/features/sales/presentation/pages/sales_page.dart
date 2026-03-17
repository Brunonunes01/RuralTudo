import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_animated_entry.dart';
import '../../../../core/widgets/ui/app_empty_state.dart';
import '../../../../core/widgets/ui/app_error_state.dart';
import '../../../../core/widgets/ui/app_feedback.dart';
import '../../../../core/widgets/ui/app_form_text_field.dart';
import '../../../../core/widgets/ui/app_loading_state.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../farm/domain/entities/harvest.dart';

class SalesPage extends ConsumerWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(farmSalesControllerProvider);

    return AppScaffold(
      title: 'Vendas',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSaleForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova venda'),
      ),
      body: state.when(
        data: (sales) {
          if (sales.isEmpty) {
            return const AppEmptyState(
              title: 'Nenhuma venda registrada',
              subtitle: 'Toque em "Nova venda" para começar.',
            );
          }
          return ListView.separated(
            itemCount: sales.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final sale = sales[i];
              return AppAnimatedEntry(
                index: i,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      '${sale.cropName} - ${Formatters.currency(sale.totalAmount)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${sale.quantity.toStringAsFixed(2)} ${sale.unit} | ${_paymentLabel(sale.paymentMethod)} | ${Formatters.date(sale.saleDate)}',
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const AppLoadingState(itemCount: 5),
        error: (e, _) => AppErrorState(
          message: e.toString(),
          onRetry: () => ref.read(farmSalesControllerProvider.notifier).load(),
        ),
      ),
    );
  }

  Future<void> _showSaleForm(BuildContext context, WidgetRef ref) async {
    final harvests = await ref.read(farmDatasourceProvider).getHarvests();
    if (!context.mounted) return;

    final availableHarvests = harvests
        .where((h) => h.availableQuantity > 0)
        .toList();
    if (availableHarvests.isEmpty) {
      AppFeedback.error(
        context,
        'Não há colheita com saldo disponível para vender.',
      );
      return;
    }

    final customers = await ref.read(customerRepositoryProvider).getAll();
    if (!context.mounted) return;

    Harvest selectedHarvest = availableHarvests.first;
    int? customerId;
    final quantityController = TextEditingController();
    final unitPriceController = TextEditingController(text: '0');
    final notesController = TextEditingController();
    String paymentMethod = 'pix';

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          final quantity =
              double.tryParse(quantityController.text.replaceAll(',', '.')) ??
              0;
          final unitPrice =
              double.tryParse(unitPriceController.text.replaceAll(',', '.')) ??
              0;
          final total = quantity * unitPrice;

          return AlertDialog(
            title: const Text('Nova venda'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedHarvest.id,
                      items: availableHarvests
                          .map(
                            (h) => DropdownMenuItem<int>(
                              value: h.id,
                              child: Text(
                                '${h.cropName} - saldo ${h.availableQuantity.toStringAsFixed(2)} ${h.unit}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        final selected = availableHarvests.firstWhere(
                          (e) => e.id == value,
                        );
                        setState(() => selectedHarvest = selected);
                      },
                      decoration: const InputDecoration(labelText: 'Colheita'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      initialValue: customerId,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Sem cliente'),
                        ),
                        ...customers.map(
                          (Customer c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => customerId = value),
                      decoration: const InputDecoration(
                        labelText: 'Cliente (opcional)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppFormTextField(
                      controller: quantityController,
                      label: 'Quantidade vendida (${selectedHarvest.unit})',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    AppFormTextField(
                      controller: unitPriceController,
                      label: 'Valor por ${selectedHarvest.unit}',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: paymentMethod,
                      items: const [
                        DropdownMenuItem(
                          value: 'cash',
                          child: Text('Dinheiro'),
                        ),
                        DropdownMenuItem(value: 'pix', child: Text('PIX')),
                        DropdownMenuItem(value: 'card', child: Text('Cartão')),
                        DropdownMenuItem(value: 'credit', child: Text('Fiado')),
                        DropdownMenuItem(
                          value: 'transfer',
                          child: Text('Transferência'),
                        ),
                      ],
                      onChanged: (value) => setState(
                        () => paymentMethod = value ?? paymentMethod,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Forma de pagamento',
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppFormTextField(
                      controller: notesController,
                      label: 'Observações',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total: ${Formatters.currency(total)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Saldo atual: ${selectedHarvest.availableQuantity.toStringAsFixed(2)} ${selectedHarvest.unit}',
                      ),
                    ),
                  ],
                ),
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
                      double.tryParse(
                        quantityController.text.replaceAll(',', '.'),
                      ) ??
                      0;
                  final price =
                      double.tryParse(
                        unitPriceController.text.replaceAll(',', '.'),
                      ) ??
                      0;

                  if (qty <= 0) {
                    AppFeedback.error(
                      context,
                      'Informe uma quantidade válida.',
                    );
                    return;
                  }
                  if (price <= 0) {
                    AppFeedback.error(
                      context,
                      'Informe um valor unitário válido.',
                    );
                    return;
                  }

                  try {
                    await ref
                        .read(farmSalesControllerProvider.notifier)
                        .register(
                          harvestId: selectedHarvest.id!,
                          customerId: customerId,
                          saleDate: DateTime.now(),
                          quantity: qty,
                          unit: selectedHarvest.unit,
                          unitPrice: price,
                          paymentMethod: paymentMethod,
                          notes: notesController.text.trim(),
                        );
                    ref.invalidate(harvestsControllerProvider);
                    ref.invalidate(dashboardSummaryProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      AppFeedback.success(context, 'Venda salva com sucesso.');
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    final message = e is AppException
                        ? e.message
                        : e.toString();
                    AppFeedback.error(context, message);
                  }
                },
                child: const Text('Salvar venda'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _paymentLabel(String value) {
    switch (value) {
      case 'pix':
        return 'PIX';
      case 'cash':
        return 'Dinheiro';
      case 'card':
        return 'Cartão';
      case 'transfer':
        return 'Transferência';
      case 'credit':
        return 'Fiado';
      default:
        return value;
    }
  }
}
