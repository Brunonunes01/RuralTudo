import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/entities/expense.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseControllerProvider);

    return AppScaffold(
      title: 'Despesas',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        data: (expenses) => ListView.separated(
          itemCount: expenses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final item = expenses[i];
            return Card(
              child: ListTile(
                title: Text(item.description),
                subtitle: Text('${item.category} - ${Formatters.date(item.date)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(Formatters.currency(item.amount)),
                    IconButton(
                      onPressed: () => _showForm(context, ref, expense: item),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => ref.read(expenseControllerProvider.notifier).remove(item.id!),
                      icon: const Icon(Icons.delete),
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

  Future<void> _showForm(BuildContext context, WidgetRef ref, {Expense? expense}) async {
    final description = TextEditingController(text: expense?.description ?? '');
    final category = TextEditingController(text: expense?.category ?? 'Insumos');
    final amount = TextEditingController(text: (expense?.amount ?? 0).toString());
    final notes = TextEditingController(text: expense?.notes ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(expense == null ? 'Nova despesa' : 'Editar despesa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: description, decoration: const InputDecoration(labelText: 'Descricao')),
              const SizedBox(height: 8),
              TextField(controller: category, decoration: const InputDecoration(labelText: 'Categoria')),
              const SizedBox(height: 8),
              TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor')),
              const SizedBox(height: 8),
              TextField(controller: notes, decoration: const InputDecoration(labelText: 'Observacoes')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              await ref.read(expenseControllerProvider.notifier).save(
                    id: expense?.id,
                    description: description.text.trim(),
                    category: category.text.trim(),
                    amount: double.tryParse(amount.text.replaceAll(',', '.')) ?? 0,
                    date: expense?.date ?? DateTime.now(),
                    notes: notes.text.trim(),
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
