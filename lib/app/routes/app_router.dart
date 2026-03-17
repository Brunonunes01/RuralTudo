import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/farm/presentation/pages/areas_page.dart';
import '../../features/farm/presentation/pages/harvests_page.dart';
import '../../features/farm/presentation/pages/management_page.dart';
import '../../features/farm/presentation/pages/plantings_page.dart';
import '../../features/farm/presentation/pages/results_page.dart';
import '../../features/farm/presentation/pages/woodworking_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/stock/presentation/pages/stock_page.dart';
import '../../core/widgets/main_tab_shell.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  GoRoute route(String path, Widget Function() builder) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        child: builder(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(fade);
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainTabShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [route(AppRoutes.dashboard, () => const DashboardPage())],
          ),
          StatefulShellBranch(
            routes: [route(AppRoutes.plantings, () => const PlantingsPage())],
          ),
          StatefulShellBranch(
            routes: [route(AppRoutes.harvests, () => const HarvestsPage())],
          ),
          StatefulShellBranch(
            routes: [route(AppRoutes.sales, () => const SalesPage())],
          ),
          StatefulShellBranch(
            routes: [
              route(AppRoutes.more, () => const MorePage()),
              route(AppRoutes.areas, () => const AreasPage()),
              route(AppRoutes.management, () => const ManagementPage()),
              route(AppRoutes.customers, () => const CustomersPage()),
              route(AppRoutes.expenses, () => const ExpensesPage()),
              route(AppRoutes.orders, () => const OrdersPage()),
              route(AppRoutes.results, () => const ResultsPage()),
              route(AppRoutes.woodworking, () => const WoodworkingPage()),
              route(AppRoutes.reports, () => const ReportsPage()),
              route(AppRoutes.settings, () => const SettingsPage()),
              route(AppRoutes.categories, () => const CategoriesPage()),
              route(AppRoutes.stock, () => const StockPage()),
            ],
          ),
        ],
      ),
    ],
  );
});
