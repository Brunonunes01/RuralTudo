import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../di/app_providers.dart';

class MainTabShell extends ConsumerWidget {
  const MainTabShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesSettingsProvider);
    final active = modules.maybeWhen(
      data: (value) => value.activeModules,
      orElse: () => const <String, bool>{
        'plantings': true,
        'harvests': true,
        'sales': true,
      },
    );

    final branchIndexes = <int>[0];
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Início',
      ),
    ];

    if (active['plantings'] ?? true) {
      branchIndexes.add(1);
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.eco_outlined),
          selectedIcon: Icon(Icons.eco),
          label: 'Plantios',
        ),
      );
    }
    if (active['harvests'] ?? true) {
      branchIndexes.add(2);
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.agriculture_outlined),
          selectedIcon: Icon(Icons.agriculture),
          label: 'Colheitas',
        ),
      );
    }
    if (active['sales'] ?? true) {
      branchIndexes.add(3);
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.point_of_sale_outlined),
          selectedIcon: Icon(Icons.point_of_sale),
          label: 'Vendas',
        ),
      );
    }
    branchIndexes.add(4);
    destinations.add(
      const NavigationDestination(
        icon: Icon(Icons.menu),
        selectedIcon: Icon(Icons.menu_open),
        label: 'Mais',
      ),
    );

    final selectedIndex = branchIndexes.indexOf(navigationShell.currentIndex);
    final selectedDisplayIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Scaffold(
      body: TweenAnimationBuilder<double>(
        key: ValueKey(navigationShell.currentIndex),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 6),
            child: child,
          ),
        ),
        child: navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedDisplayIndex,
        onDestinationSelected: (displayIndex) {
          final branchIndex = branchIndexes[displayIndex];
          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
        destinations: destinations,
      ),
    );
  }
}
