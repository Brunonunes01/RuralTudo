import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/farm/presentation/pages/area_form_page.dart';
import '../../features/farm/presentation/pages/area_map_page.dart';
import '../../features/farm/presentation/models/area_map_draft.dart';
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
  GoRoute route(String path, Widget Function(GoRouterState state) builder) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        child: builder(state),
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
            routes: [route(AppRoutes.dashboard, (_) => const DashboardPage())],
          ),
          StatefulShellBranch(
            routes: [route(AppRoutes.plantings, (_) => const PlantingsPage())],
          ),
          StatefulShellBranch(
            routes: [route(AppRoutes.harvests, (_) => const HarvestsPage())],
          ),
          StatefulShellBranch(
            routes: [route(AppRoutes.sales, (_) => const SalesPage())],
          ),
          StatefulShellBranch(
            routes: [
              route(AppRoutes.more, (_) => const MorePage()),
              route(AppRoutes.areas, (_) => const AreasPage()),
              route(
                AppRoutes.areaForm,
                (state) => AreaFormPage(
                  args: state.extra is AreaFormPageArgs
                      ? state.extra! as AreaFormPageArgs
                      : const AreaFormPageArgs(),
                ),
              ),
              route(
                AppRoutes.areaMap,
                (state) => AreaMapPage(
                  args: state.extra is AreaMapPageArgs
                      ? state.extra! as AreaMapPageArgs
                      : AreaMapPageArgs(initialDraft: AreaMapDraft.empty()),
                ),
              ),
              route(AppRoutes.management, (_) => const ManagementPage()),
              route(AppRoutes.customers, (_) => const CustomersPage()),
              route(AppRoutes.expenses, (_) => const ExpensesPage()),
              route(AppRoutes.orders, (_) => const OrdersPage()),
              route(AppRoutes.results, (_) => const ResultsPage()),
              route(AppRoutes.woodworking, (_) => const WoodworkingPage()),
              route(AppRoutes.reports, (_) => const ReportsPage()),
              route(AppRoutes.settings, (_) => const SettingsPage()),
              route(AppRoutes.categories, (_) => const CategoriesPage()),
              route(AppRoutes.stock, (_) => const StockPage()),
            ],
          ),
        ],
      ),
    ],
  );
});
