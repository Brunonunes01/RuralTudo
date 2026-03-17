import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_empty_state.dart';
import '../../../../core/widgets/ui/app_error_state.dart';
import '../../../../core/widgets/ui/app_loading_state.dart';
import '../../domain/entities/farm_area.dart';
import 'area_form_page.dart';

class AreasPage extends ConsumerWidget {
  const AreasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(areasControllerProvider);

    return AppScaffold(
      title: 'Áreas',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.areaForm),
        icon: const Icon(Icons.add),
        label: const Text('Nova área'),
      ),
      body: state.when(
        data: (areas) {
          if (areas.isEmpty) {
            return const AppEmptyState(
              title: 'Nenhuma área cadastrada',
              subtitle:
                  'Toque em "Nova área" para desenhar no mapa e cadastrar.',
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
                  onTap: () => context.push(
                    AppRoutes.areaForm,
                    extra: AreaFormPageArgs(area: area),
                  ),
                  title: Text(
                    area.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_subtitle(area)),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
        loading: () => const AppLoadingState(itemCount: 4),
        error: (e, _) => AppErrorState(
          message: e.toString(),
          onRetry: () => ref.read(areasControllerProvider.notifier).load(),
        ),
      ),
    );
  }

  String _subtitle(FarmArea area) {
    if ((area.areaM2 ?? 0) <= 0) {
      return area.description?.isNotEmpty == true
          ? area.description!
          : 'Área sem desenho cadastrado';
    }

    final parts = <String>[
      '${Formatters.hectares(area.areaHectares ?? 0)} ha',
      '${Formatters.decimal(area.areaM2 ?? 0)} m²',
    ];

    if ((area.perimeter ?? 0) > 0) {
      parts.add('Perímetro: ${Formatters.decimal(area.perimeter ?? 0)} m');
    }

    if (area.description?.isNotEmpty == true) {
      parts.add(area.description!);
    }

    if (!area.isActive) {
      parts.add('Inativa');
    }

    return parts.join(' | ');
  }
}
