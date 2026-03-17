import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_animated_entry.dart';
import '../../../../core/widgets/ui/app_error_state.dart';
import '../../../../core/widgets/ui/app_loading_state.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesState = ref.watch(modulesSettingsProvider);

    return AppScaffold(
      title: 'Mais',
      body: modulesState.when(
        data: (config) {
          final tiles = <Widget>[
            if (config.isActive('areas'))
              _item(context, 'Áreas', Icons.map_outlined, AppRoutes.areas),
            if (config.isActive('management'))
              _item(
                context,
                'Manejo',
                Icons.spa_outlined,
                AppRoutes.management,
              ),
            if (config.isActive('expenses'))
              _item(
                context,
                'Gastos',
                Icons.receipt_long_outlined,
                AppRoutes.expenses,
              ),
            if (config.isActive('results'))
              _item(
                context,
                'Resultados',
                Icons.insights_outlined,
                AppRoutes.results,
              ),
            if (config.isActive('customers'))
              _item(
                context,
                'Clientes',
                Icons.people_outline,
                AppRoutes.customers,
              ),
            if (config.isActive('orders'))
              _item(
                context,
                'Encomendas',
                Icons.assignment_outlined,
                AppRoutes.orders,
              ),
            if (config.isActive('woodworking'))
              _item(
                context,
                'Marcenaria',
                Icons.handyman_outlined,
                AppRoutes.woodworking,
              ),
            _item(
              context,
              'Configurações',
              Icons.settings_outlined,
              AppRoutes.settings,
            ),
          ];

          return ListView.separated(
            itemCount: tiles.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (_, index) =>
                AppAnimatedEntry(index: index, child: tiles[index]),
          );
        },
        loading: () => const AppLoadingState(itemCount: 6, withHeader: true),
        error: (e, _) => AppErrorState(message: e.toString()),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
