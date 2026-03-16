import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_form_text_field.dart';
import '../../../../core/widgets/ui/app_section_header.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/sale_item.dart';

class SalesPage extends ConsumerWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesControllerProvider);

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
            return const Center(child: Text('Nenhuma venda registrada.'));
          }
          return ListView.separated(
            itemCount: sales.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final sale = sales[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    'Venda #${sale.id} - ${Formatters.currency(sale.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${Formatters.date(sale.saleDate)} | ${sale.paymentMethod} | ${sale.status}',
                    ),
                  ),
                  trailing: sale.status == 'completed'
                      ? TextButton(
                          onPressed: () async {
                            await ref
                                .read(salesControllerProvider.notifier)
                                .cancel(sale.id);
                            ref.invalidate(productControllerProvider);
                            ref.invalidate(stockControllerProvider);
                            ref.invalidate(dashboardSummaryProvider);
                          },
                          child: const Text('Cancelar'),
                        )
                      : const Text('Cancelada'),
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

  Future<void> _showSaleForm(BuildContext context, WidgetRef ref) async {
    final products = await ref.read(productRepositoryProvider).getAll();
    if (!context.mounted) return;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre produtos antes de registrar vendas.'),
        ),
      );
      return;
    }

    final customers = await ref.read(customerRepositoryProvider).getAll();
    if (!context.mounted) return;

    int? customerId;
    String paymentMethod = 'pix';
    final notes = TextEditingController();
    final saleItems = <SaleItem>[];

    Future<void> addItemDialog(StateSetter setState) async {
      var selectedProduct = products.first;
      final quantity = TextEditingController(text: '1');

      await showDialog<void>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, localSetState) => AlertDialog(
            title: const Text('Adicionar item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedProduct.id,
                  items: products
                      .map(
                        (Product p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.name} (${p.stockQuantity} ${p.unit})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    localSetState(() {
                      selectedProduct = products.firstWhere(
                        (e) => e.id == value,
                      );
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Produto'),
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: quantity,
                  label: 'Quantidade',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final qty =
                      double.tryParse(quantity.text.replaceAll(',', '.')) ?? 0;
                  if (qty <= 0) return;
                  setState(() {
                    saleItems.add(
                      SaleItem(
                        productId: selectedProduct.id!,
                        productName: selectedProduct.name,
                        quantity: qty,
                        unitPrice: selectedProduct.salePrice,
                      ),
                    );
                  });
                  Navigator.pop(context);
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          final total = saleItems.fold<double>(
            0,
            (sum, item) => sum + item.subtotal,
          );

          return AlertDialog(
            title: const Text('Nova venda'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(title: '1. Cliente (opcional)'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      initialValue: customerId,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Consumidor final'),
                        ),
                        ...customers.map(
                          (Customer c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => customerId = value),
                      decoration: const InputDecoration(labelText: 'Cliente'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Expanded(
                          child: AppSectionHeader(title: '2. Itens'),
                        ),
                        TextButton.icon(
                          onPressed: () => addItemDialog(setState),
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar item'),
                        ),
                      ],
                    ),
                    if (saleItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text('Nenhum item adicionado.'),
                      )
                    else
                      ...saleItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.productName),
                          subtitle: Text(
                            '${item.quantity} x ${Formatters.currency(item.unitPrice)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(Formatters.currency(item.subtotal)),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () =>
                                    setState(() => saleItems.removeAt(index)),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 12),
                    const AppSectionHeader(title: '3. Pagamento'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: paymentMethod,
                      items: const [
                        DropdownMenuItem(value: 'pix', child: Text('PIX')),
                        DropdownMenuItem(
                          value: 'cash',
                          child: Text('Dinheiro'),
                        ),
                        DropdownMenuItem(value: 'card', child: Text('Cartão')),
                        DropdownMenuItem(
                          value: 'transfer',
                          child: Text('Transferência'),
                        ),
                        DropdownMenuItem(
                          value: 'credit',
                          child: Text('Fiado/Crédito'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => paymentMethod = value ?? 'pix'),
                      decoration: const InputDecoration(
                        labelText: 'Forma de pagamento',
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppFormTextField(
                      controller: notes,
                      label: 'Observação (opcional)',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    const AppSectionHeader(title: '4. Revisão'),
                    const SizedBox(height: 8),
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
                onPressed: saleItems.isEmpty
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(salesControllerProvider.notifier)
                              .register(
                                customerId: customerId,
                                saleDate: DateTime.now(),
                                paymentMethod: paymentMethod,
                                notes: notes.text.trim(),
                                items: saleItems,
                              );
                          ref.invalidate(productControllerProvider);
                          ref.invalidate(stockControllerProvider);
                          ref.invalidate(dashboardSummaryProvider);
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (!context.mounted) return;
                          final message = e is AppException
                              ? e.message
                              : e.toString();
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
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
}
