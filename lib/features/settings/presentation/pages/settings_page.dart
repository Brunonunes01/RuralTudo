import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/widgets/app_scaffold.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modulesSettingsProvider);

    return AppScaffold(
      title: 'Configurações',
      body: state.when(
        data: (config) {
          return ListView(
            children: [
              const Card(
                child: ListTile(
                  title: Text('Perfil de uso'),
                  subtitle: Text('Escolha o tipo de atividade principal.'),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: config.profileMode,
                items: const [
                  DropdownMenuItem(
                    value: 'agriculture',
                    child: Text('Agricultura'),
                  ),
                  DropdownMenuItem(
                    value: 'woodworking',
                    child: Text('Marcenaria'),
                  ),
                  DropdownMenuItem(value: 'both', child: Text('Ambos')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(modulesSettingsProvider.notifier).setProfile(value);
                },
                decoration: const InputDecoration(labelText: 'Perfil'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Módulos ativos',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ..._moduleTiles(ref, config.activeModules),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  List<Widget> _moduleTiles(WidgetRef ref, Map<String, bool> modules) {
    final labels = <String, String>{
      'areas': 'Áreas',
      'plantings': 'Plantios',
      'management': 'Manejo',
      'harvests': 'Colheitas',
      'sales': 'Vendas',
      'expenses': 'Gastos',
      'results': 'Resultados',
      'customers': 'Clientes',
      'orders': 'Encomendas',
      'woodworking': 'Marcenaria',
    };

    return labels.entries.map((entry) {
      final key = entry.key;
      return Card(
        child: SwitchListTile(
          value: modules[key] ?? false,
          title: Text(entry.value),
          onChanged: (value) {
            ref.read(modulesSettingsProvider.notifier).setModule(key, value);
          },
        ),
      );
    }).toList();
  }
}
