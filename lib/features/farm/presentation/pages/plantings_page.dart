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
import '../../domain/entities/farm_area.dart';
import '../../domain/entities/planting.dart';

class PlantingsPage extends ConsumerWidget {
  const PlantingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantingsState = ref.watch(plantingsControllerProvider);

    return AppScaffold(
      title: 'Plantios',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Novo plantio'),
      ),
      body: plantingsState.when(
        data: (plantings) {
          if (plantings.isEmpty) {
            return const AppEmptyState(
              title: 'Nenhum plantio cadastrado',
              subtitle: 'Toque em "Novo plantio" para começar.',
            );
          }
          return ListView.separated(
            itemCount: plantings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = plantings[index];
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
                        'Plantio: ${Formatters.date(item.plantingDate)} | Status: ${_statusLabel(item.status)}',
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showForm(context, ref, planting: item),
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
          onRetry: () => ref.read(plantingsControllerProvider.notifier).load(),
        ),
      ),
    );
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    Planting? planting,
  }) async {
    final areas = await ref.read(farmDatasourceProvider).getAreas();
    if (!context.mounted) return;
    if (areas.where((a) => a.isActive).isEmpty) {
      AppFeedback.error(
        context,
        'Cadastre uma área antes de registrar plantio.',
      );
      return;
    }

    final activeAreas = areas.where((a) => a.isActive).toList();
    int areaId = planting?.areaId ?? activeAreas.first.id!;
    final cropController = TextEditingController(
      text: planting?.cropName ?? '',
    );
    final varietyController = TextEditingController(
      text: planting?.variety ?? '',
    );
    final cycleController = TextEditingController(
      text: (planting?.cycleDays ?? '').toString(),
    );
    final quantityController = TextEditingController(
      text: (planting?.plantedQuantity ?? '').toString(),
    );
    final unitController = TextEditingController(
      text: planting?.plantedUnit ?? 'kg',
    );
    final costController = TextEditingController(
      text: planting?.initialCost.toString() ?? '0',
    );
    final notesController = TextEditingController(text: planting?.notes ?? '');

    DateTime plantingDate = planting?.plantingDate ?? DateTime.now();
    DateTime? expectedHarvestDate = planting?.expectedHarvestDate;
    String status = planting?.status ?? 'planted';

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(planting == null ? 'Novo plantio' : 'Editar plantio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: areaId,
                  items: activeAreas
                      .map(
                        (FarmArea e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => areaId = value ?? areaId),
                  decoration: const InputDecoration(labelText: 'Área'),
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: cropController,
                  label: 'Cultura (ex: milho)',
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: varietyController,
                  label: 'Variedade (opcional)',
                ),
                const SizedBox(height: 8),
                _dateInput(
                  context,
                  label: 'Data do plantio',
                  value: plantingDate,
                  onSelect: (date) => setState(() => plantingDate = date),
                ),
                const SizedBox(height: 8),
                _optionalDateInput(
                  context,
                  label: 'Previsão de colheita',
                  value: expectedHarvestDate,
                  onSelect: (date) =>
                      setState(() => expectedHarvestDate = date),
                  onClear: () => setState(() => expectedHarvestDate = null),
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: cycleController,
                  label: 'Ciclo estimado (dias)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: quantityController,
                  label: 'Quantidade plantada (opcional)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: unitController,
                  label: 'Unidade (opcional)',
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: costController,
                  label: 'Custo inicial',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: const [
                    DropdownMenuItem(value: 'planted', child: Text('Plantado')),
                    DropdownMenuItem(
                      value: 'growing',
                      child: Text('Em crescimento'),
                    ),
                    DropdownMenuItem(
                      value: 'ready_to_harvest',
                      child: Text('Pronto para colher'),
                    ),
                    DropdownMenuItem(
                      value: 'harvested',
                      child: Text('Colhido'),
                    ),
                    DropdownMenuItem(value: 'closed', child: Text('Encerrado')),
                  ],
                  onChanged: (value) =>
                      setState(() => status = value ?? status),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: notesController,
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
                if (cropController.text.trim().isEmpty) {
                  AppFeedback.error(context, 'Informe a cultura do plantio.');
                  return;
                }

                await ref
                    .read(plantingsControllerProvider.notifier)
                    .save(
                      id: planting?.id,
                      areaId: areaId,
                      cropName: cropController.text.trim(),
                      variety: varietyController.text.trim(),
                      plantingDate: plantingDate,
                      expectedHarvestDate: expectedHarvestDate,
                      cycleDays: int.tryParse(cycleController.text),
                      plantedQuantity: double.tryParse(
                        quantityController.text.replaceAll(',', '.'),
                      ),
                      plantedUnit: unitController.text.trim(),
                      initialCost:
                          double.tryParse(
                            costController.text.replaceAll(',', '.'),
                          ) ??
                          0,
                      notes: notesController.text.trim(),
                      status: status,
                    );
                ref.invalidate(dashboardSummaryProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  AppFeedback.success(context, 'Plantio salvo com sucesso.');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateInput(
    BuildContext context, {
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onSelect(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Text(Formatters.date(value)),
            const Spacer(),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _optionalDateInput(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onSelect,
    required VoidCallback onClear,
  }) {
    return InkWell(
      onTap: () async {
        final baseDate = value ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: baseDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onSelect(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: value == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClear,
                ),
        ),
        child: Row(
          children: [
            Text(value == null ? 'Não informado' : Formatters.date(value)),
            const Spacer(),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'planted':
        return 'Plantado';
      case 'growing':
        return 'Em crescimento';
      case 'ready_to_harvest':
        return 'Pronto para colher';
      case 'harvested':
        return 'Colhido';
      case 'closed':
        return 'Encerrado';
      default:
        return value;
    }
  }
}
