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
import '../../domain/entities/planting.dart';

class HarvestsPage extends ConsumerWidget {
  const HarvestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(harvestsControllerProvider);

    return AppScaffold(
      title: 'Colheitas',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova colheita'),
      ),
      body: state.when(
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              title: 'Nenhuma colheita registrada',
              subtitle: 'Toque em "Nova colheita" para cadastrar.',
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return AppAnimatedEntry(
                index: index,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      '${item.cropName} - ${item.areaName}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Colhido: ${item.quantity.toStringAsFixed(2)} ${item.unit} | '
                        'Saldo: ${item.availableQuantity.toStringAsFixed(2)} ${item.unit}',
                      ),
                    ),
                    trailing: Text(Formatters.date(item.harvestDate)),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const AppLoadingState(itemCount: 5),
        error: (e, _) => AppErrorState(
          message: e.toString(),
          onRetry: () => ref.read(harvestsControllerProvider.notifier).load(),
        ),
      ),
    );
  }

  Future<void> _showForm(BuildContext context, WidgetRef ref) async {
    final plantings = await ref.read(farmDatasourceProvider).getPlantings();
    if (!context.mounted) return;
    if (plantings.isEmpty) {
      AppFeedback.error(context, 'Cadastre um plantio antes da colheita.');
      return;
    }

    final activePlantings = plantings
        .where((p) => p.status != 'closed' && p.status != 'harvested')
        .toList();
    if (activePlantings.isEmpty) {
      AppFeedback.error(context, 'Não há plantios abertos para colher.');
      return;
    }

    int plantingId = activePlantings.first.id!;
    final quantity = TextEditingController();
    final unit = TextEditingController(
      text: activePlantings.first.plantedUnit ?? 'kg',
    );
    final loss = TextEditingController();
    final notes = TextEditingController();
    DateTime harvestDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nova colheita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: plantingId,
                  items: activePlantings
                      .map(
                        (Planting p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.cropName} - ${p.areaName}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    final selected = activePlantings.firstWhere(
                      (e) => e.id == value,
                    );
                    setState(() {
                      plantingId = value;
                      unit.text = selected.plantedUnit ?? unit.text;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Plantio'),
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: quantity,
                  label: 'Quantidade colhida',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                AppFormTextField(controller: unit, label: 'Unidade'),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: loss,
                  label: 'Perda (opcional)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: harvestDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => harvestDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data da colheita',
                    ),
                    child: Row(
                      children: [
                        Text(Formatters.date(harvestDate)),
                        const Spacer(),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: notes,
                  label: 'Observações',
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
                if (unit.text.trim().isEmpty) {
                  AppFeedback.error(context, 'Informe a unidade da colheita.');
                  return;
                }

                await ref
                    .read(harvestsControllerProvider.notifier)
                    .register(
                      plantingId: plantingId,
                      harvestDate: harvestDate,
                      quantity: qty,
                      unit: unit.text.trim(),
                      lossQuantity: double.tryParse(
                        loss.text.replaceAll(',', '.'),
                      ),
                      notes: notes.text.trim(),
                    );
                ref.invalidate(plantingsControllerProvider);
                ref.invalidate(dashboardSummaryProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  AppFeedback.success(context, 'Colheita salva com sucesso.');
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
