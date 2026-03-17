import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_animated_entry.dart';
import '../../../../core/widgets/ui/app_empty_state.dart';
import '../../../../core/widgets/ui/app_error_state.dart';
import '../../../../core/widgets/ui/app_feedback.dart';
import '../../../../core/widgets/ui/app_form_text_field.dart';
import '../../../../core/widgets/ui/app_loading_state.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/product.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productControllerProvider);
    final categoryState = ref.watch(categoryControllerProvider);
    final categoryMap = categoryState.maybeWhen(
      data: (categories) => {for (final c in categories) c.id!: c.name},
      orElse: () => <int, String>{},
    );

    return AppScaffold(
      title: 'Produtos',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Buscar produto',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          categoryState.when(
            data: (categories) => DropdownButtonFormField<int?>(
              initialValue: _selectedCategoryId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todas as categorias'),
                ),
                ...categories.map(
                  (c) =>
                      DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
                ),
              ],
              onChanged: (value) => setState(() => _selectedCategoryId = value),
              decoration: const InputDecoration(
                labelText: 'Filtrar por categoria',
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: productState.when(
              data: (products) {
                final filtered = _filteredProducts(products);
                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    title: 'Nenhum produto encontrado',
                    subtitle: 'Toque em "Adicionar" para cadastrar o primeiro.',
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return AppAnimatedEntry(
                      index: index,
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Categoria: ${categoryMap[product.categoryId] ?? 'Sem categoria'}\n'
                              'Estoque: ${product.stockQuantity} ${product.unit} | Preço: ${Formatters.currency(product.salePrice)}',
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.isLowStock)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.warning_amber,
                                    color: Colors.orange,
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () =>
                                    _showForm(context, ref, product: product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => ref
                                    .read(productControllerProvider.notifier)
                                    .remove(product.id!),
                              ),
                            ],
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
                onRetry: () =>
                    ref.read(productControllerProvider.notifier).load(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _filteredProducts(List<Product> products) {
    final search = _searchController.text.trim().toLowerCase();
    return products.where((product) {
      final matchSearch =
          search.isEmpty || product.name.toLowerCase().contains(search);
      final matchCategory =
          _selectedCategoryId == null ||
          product.categoryId == _selectedCategoryId;
      return matchSearch && matchCategory;
    }).toList();
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    Product? product,
  }) async {
    final categories = await ref.read(categoryRepositoryProvider).getAll();
    if (!context.mounted) return;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre uma categoria antes de criar produtos.'),
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final unitController = TextEditingController(text: product?.unit ?? 'un');
    final costController = TextEditingController(
      text: (product?.costPrice ?? 0).toString(),
    );
    final saleController = TextEditingController(
      text: (product?.salePrice ?? 0).toString(),
    );
    final stockController = TextEditingController(
      text: (product?.stockQuantity ?? 0).toString(),
    );
    final minStockController = TextEditingController(
      text: (product?.minStock ?? 0).toString(),
    );
    var selectedCategoryId = product?.categoryId ?? categories.first.id!;
    var isActive = product?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product == null ? 'Novo produto' : 'Editar produto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppFormTextField(controller: nameController, label: 'Nome'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: selectedCategoryId,
                  items: categories
                      .map(
                        (Category c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => selectedCategoryId = value ?? selectedCategoryId,
                  ),
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
                const SizedBox(height: 8),
                AppFormTextField(controller: unitController, label: 'Unidade'),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: saleController,
                  label: 'Preço de venda',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: stockController,
                  label: 'Estoque atual',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: minStockController,
                  label: 'Estoque mínimo',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: costController,
                  label: 'Preço de custo (opcional)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: descriptionController,
                  label: 'Descrição (opcional)',
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                  title: const Text('Produto ativo'),
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
                if (nameController.text.trim().isEmpty) {
                  AppFeedback.error(context, 'Informe o nome do produto.');
                  return;
                }
                await ref
                    .read(productControllerProvider.notifier)
                    .save(
                      id: product?.id,
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      categoryId: selectedCategoryId,
                      productType: product?.productType ?? 'agriculture',
                      unit: unitController.text.trim(),
                      costPrice:
                          double.tryParse(
                            costController.text.replaceAll(',', '.'),
                          ) ??
                          0,
                      salePrice:
                          double.tryParse(
                            saleController.text.replaceAll(',', '.'),
                          ) ??
                          0,
                      stockQuantity:
                          double.tryParse(
                            stockController.text.replaceAll(',', '.'),
                          ) ??
                          0,
                      minStock:
                          double.tryParse(
                            minStockController.text.replaceAll(',', '.'),
                          ) ??
                          0,
                      isActive: isActive,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  AppFeedback.success(context, 'Produto salvo com sucesso.');
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
