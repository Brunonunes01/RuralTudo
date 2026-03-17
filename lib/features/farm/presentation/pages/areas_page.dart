import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_empty_state.dart';
import '../../../../core/widgets/ui/app_feedback.dart';
import '../../../../core/widgets/ui/app_form_text_field.dart';
import '../../domain/entities/farm_area.dart';

class AreasPage extends ConsumerWidget {
  const AreasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(areasControllerProvider);

    return AppScaffold(
      title: 'Áreas',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova área'),
      ),
      body: state.when(
        data: (areas) {
          if (areas.isEmpty) {
            return const AppEmptyState(
              title: 'Nenhuma área cadastrada',
              subtitle: 'Exemplo: Horta do fundo, Talhão 1, Área do milho.',
            );
          }
          return ListView.separated(
            itemCount: areas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final area = areas[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    area.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    [
                      if (area.areaSize != null)
                        '${area.areaSize!.toStringAsFixed(2)} ${area.areaUnit ?? ''}'
                            .trim(),
                      if (area.description?.isNotEmpty == true)
                        area.description!,
                    ].join(' | '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!area.isActive)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text('Inativa'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showForm(context, ref, area: area),
                      ),
                    ],
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

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    FarmArea? area,
  }) async {
    final name = TextEditingController(text: area?.name ?? '');
    final description = TextEditingController(text: area?.description ?? '');
    final areaSize = TextEditingController(
      text: (area?.areaSize ?? '').toString(),
    );
    final areaUnit = TextEditingController(text: area?.areaUnit ?? 'm²');
    final notes = TextEditingController(text: area?.notes ?? '');
    var isActive = area?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(area == null ? 'Nova área' : 'Editar área'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppFormTextField(controller: name, label: 'Nome da área'),
                const SizedBox(height: 8),
                AppFormTextField(controller: description, label: 'Descrição'),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: areaSize,
                  label: 'Tamanho (opcional)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: areaUnit,
                  label: 'Unidade (m², ha, etc.)',
                ),
                const SizedBox(height: 8),
                AppFormTextField(
                  controller: notes,
                  label: 'Observações',
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                  title: const Text('Área ativa'),
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
                if (name.text.trim().isEmpty) {
                  AppFeedback.error(context, 'Informe o nome da área.');
                  return;
                }

                await ref
                    .read(areasControllerProvider.notifier)
                    .save(
                      FarmArea(
                        id: area?.id,
                        name: name.text.trim(),
                        description: description.text.trim(),
                        areaSize: double.tryParse(
                          areaSize.text.replaceAll(',', '.'),
                        ),
                        areaUnit: areaUnit.text.trim(),
                        notes: notes.text.trim(),
                        isActive: isActive,
                      ),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  AppFeedback.success(context, 'Área salva com sucesso.');
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
