import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_feedback.dart';
import '../../../../core/widgets/ui/app_form_text_field.dart';
import '../../domain/entities/farm_area.dart';
import '../../domain/services/farm_area_geometry.dart';
import '../models/area_map_draft.dart';
import 'area_map_page.dart';

class AreaFormPageArgs {
  const AreaFormPageArgs({this.area});

  final FarmArea? area;
}

class AreaFormPage extends ConsumerStatefulWidget {
  const AreaFormPage({super.key, this.args = const AreaFormPageArgs()});

  final AreaFormPageArgs args;

  @override
  ConsumerState<AreaFormPage> createState() => _AreaFormPageState();
}

class _AreaFormPageState extends ConsumerState<AreaFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _observationsController;
  late bool _isActive;
  late AreaMapDraft _mapDraft;

  bool get _isEditing => widget.args.area != null;

  @override
  void initState() {
    super.initState();
    final area = widget.args.area;
    _nameController = TextEditingController(text: area?.name ?? '');
    _descriptionController = TextEditingController(
      text: area?.description ?? '',
    );
    _observationsController = TextEditingController(
      text: area?.observations ?? area?.notes ?? '',
    );
    _isActive = area?.isActive ?? true;
    _mapDraft = AreaMapDraft(
      points: area?.polygonPoints ?? const [],
      areaM2: area?.areaM2 ?? 0,
      areaHectares: area?.areaHectares ?? 0,
      perimeter: area?.perimeter ?? 0,
      isClosed: (area?.polygonPoints.length ?? 0) >= 3,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _isEditing ? 'Editar área' : 'Nova área',
      body: ListView(
        children: [
          const Text(
            'Cadastre a área de plantio de forma simples.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          AppFormTextField(controller: _nameController, label: 'Nome da área'),
          const SizedBox(height: 8),
          AppFormTextField(
            controller: _descriptionController,
            label: 'Descrição (opcional)',
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          AppFormTextField(
            controller: _observationsController,
            label: 'Observações (opcional)',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            title: const Text('Área ativa'),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mapa da área',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _mapDraft.points.isEmpty
                        ? 'Toque em "Desenhar no mapa" para marcar o terreno.'
                        : 'Pontos salvos: ${_mapDraft.points.length}',
                  ),
                  const SizedBox(height: 4),
                  if (_mapDraft.isClosed && _mapDraft.points.length >= 3) ...[
                    Text('Área: ${Formatters.decimal(_mapDraft.areaM2)} m²'),
                    Text(
                      'Hectares: ${Formatters.hectares(_mapDraft.areaHectares)} ha',
                    ),
                    Text(
                      'Perímetro: ${Formatters.decimal(_mapDraft.perimeter)} m',
                    ),
                  ] else
                    const Text('Feche a área no mapa para calcular o tamanho.'),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openMap,
                      icon: const Icon(Icons.map_outlined),
                      label: Text(
                        _mapDraft.points.isEmpty
                            ? 'Desenhar no mapa'
                            : 'Editar desenho no mapa',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar área'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _openMap() async {
    final result = await context.push<AreaMapDraft>(
      AppRoutes.areaMap,
      extra: AreaMapPageArgs(initialDraft: _mapDraft),
    );

    if (result == null) return;
    setState(() => _mapDraft = result);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppFeedback.error(context, 'Informe o nome da área.');
      return;
    }

    if (_mapDraft.points.length < 3 || !_mapDraft.isClosed) {
      AppFeedback.error(
        context,
        'Desenhe e feche a área no mapa antes de salvar.',
      );
      return;
    }

    final metrics = FarmAreaGeometry.calculate(_mapDraft.points);
    await ref
        .read(areasControllerProvider.notifier)
        .save(
          FarmArea(
            id: widget.args.area?.id,
            name: name,
            description: _descriptionController.text.trim(),
            observations: _observationsController.text.trim(),
            areaM2: metrics.areaM2,
            areaHectares: metrics.areaHectares,
            perimeter: metrics.perimeter,
            polygonPoints: _mapDraft.points,
            notes: widget.args.area?.notes,
            isActive: _isActive,
          ),
        );

    if (!mounted) return;
    AppFeedback.success(context, 'Área salva com sucesso.');
    context.pop();
  }
}
