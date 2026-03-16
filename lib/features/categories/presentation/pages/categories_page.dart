import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/entities/category.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryControllerProvider);
    final controller = ref.read(categoryControllerProvider.notifier);

    return AppScaffold(
      title: 'Categorias',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        data: (categories) => ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = categories[index];
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(item.description ?? 'Sem descricao'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(context, ref, category: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => controller.remove(item.id!),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Future<void> _showForm(BuildContext context, WidgetRef ref, {Category? category}) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(category == null ? 'Nova categoria' : 'Editar categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
            const SizedBox(height: 12),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descricao')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              await ref.read(categoryControllerProvider.notifier).save(
                    id: category?.id,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
