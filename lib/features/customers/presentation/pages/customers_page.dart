import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/entities/customer.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerControllerProvider);

    return AppScaffold(
      title: 'Clientes',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        data: (customers) => ListView.separated(
          itemCount: customers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final item = customers[i];
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(item.phone ?? 'Sem telefone'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showForm(context, ref, customer: item),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => ref.read(customerControllerProvider.notifier).remove(item.id!),
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

  Future<void> _showForm(BuildContext context, WidgetRef ref, {Customer? customer}) async {
    final name = TextEditingController(text: customer?.name ?? '');
    final phone = TextEditingController(text: customer?.phone ?? '');
    final address = TextEditingController(text: customer?.address ?? '');
    final notes = TextEditingController(text: customer?.notes ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(customer == null ? 'Novo cliente' : 'Editar cliente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 8),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Telefone')),
              const SizedBox(height: 8),
              TextField(controller: address, decoration: const InputDecoration(labelText: 'Endereco')),
              const SizedBox(height: 8),
              TextField(controller: notes, decoration: const InputDecoration(labelText: 'Observacoes')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              await ref.read(customerControllerProvider.notifier).save(
                    id: customer?.id,
                    name: name.text.trim(),
                    phone: phone.text.trim(),
                    address: address.text.trim(),
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
