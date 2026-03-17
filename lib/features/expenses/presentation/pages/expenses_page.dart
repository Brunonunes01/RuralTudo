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
import '../../../farm/domain/entities/farm_expense.dart';
import '../../../farm/domain/entities/planting.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(farmExpensesControllerProvider);

    return AppScaffold(
      title: 'Gastos',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Novo gasto'),
      ),
      body: state.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return const AppEmptyState(
              title: 'Nenhum gasto registrado',
              subtitle: 'Toque em "Novo gasto" para adicionar.',
            );
          }

          return ListView.separated(
            itemCount: expenses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final item = expenses[i];
              return AppAnimatedEntry(
                index: i,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      item.description,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${item.category} | ${Formatters.date(item.date)}${item.plantingLabel == null ? '' : ' | ${item.plantingLabel}'}',
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(Formatters.currency(item.amount)),
                        IconButton(
                          onPressed: () =>
                              _showForm(context, ref, expense: item),
                          icon: const Icon(Icons.edit_outlined),
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
              ref.read(farmExpensesControllerProvider.notifier).load(),
        ),
      ),
    );
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    FarmExpense? expense,
  }) async {
    final plantings = await ref.read(farmDatasourceProvider).getPlantings();
    if (!context.mounted) return;

    final description = TextEditingController(text: expense?.description ?? '');
    final category = TextEditingController(
      text: expense?.category ?? 'Insumos',
    );
    final amount = TextEditingController(
      text: (expense?.amount ?? 0).toString(),
    );
    final notes = TextEditingController(text: expense?.notes ?? '');
    DateTime selectedDate = expense?.date ?? DateTime.now();
    int? selectedPlantingId = expense?.plantingId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(expense == null ? 'Novo gasto' : 'Editar gasto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int?>(
                  initialValue: selectedPlantingId,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Sem vínculo com plantio'),
                    ),
                    ...plantings.map(
                      (Planting p) => DropdownMenuItem<int?>(
                        value: p.id,
                        child: Text('${p.cropName} - ${p.areaName}'),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedPlantingId = value),
                  decoration: const InputDecoration(
                    labelText: 'Plantio (opcional)',
                  ),
                ),
                const SizedBox(height: 8),
                AppFormTextField(controller: description, label: 'Descrição'),
                const SizedBox(height: 8),
                AppFormTextField(controller: category, label: 'Categoria'),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: amount,
                  label: 'Valor',
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
                if (description.text.trim().isEmpty) {
                  AppFeedback.error(context, 'Informe a descrição do gasto.');
                  return;
                }
                final value =
                    double.tryParse(amount.text.replaceAll(',', '.')) ?? 0;
                if (value <= 0) {
                  AppFeedback.error(context, 'Informe um valor válido.');
                  return;
                }

                await ref
                    .read(farmExpensesControllerProvider.notifier)
                    .save(
                      id: expense?.id,
                      plantingId: selectedPlantingId,
                      category: category.text.trim(),
                      description: description.text.trim(),
                      amount: value,
                      date: selectedDate,
                      notes: notes.text.trim(),
                    );
                ref.invalidate(dashboardSummaryProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  AppFeedback.success(context, 'Gasto salvo com sucesso.');
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
