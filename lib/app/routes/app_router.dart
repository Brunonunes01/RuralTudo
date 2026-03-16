import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/production/presentation/pages/production_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/stock/presentation/pages/stock_page.dart';
import '../../core/widgets/main_tab_shell.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainTabShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (context, state) => const ProductsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sales,
                builder: (context, state) => const SalesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.production,
                builder: (context, state) => const ProductionPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => const MorePage(),
              ),
              GoRoute(
                path: AppRoutes.customers,
                builder: (context, state) => const CustomersPage(),
              ),
              GoRoute(
                path: AppRoutes.expenses,
                builder: (context, state) => const ExpensesPage(),
              ),
              GoRoute(
                path: AppRoutes.orders,
                builder: (context, state) => const OrdersPage(),
              ),
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => const ReportsPage(),
              ),
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: AppRoutes.categories,
                builder: (context, state) => const CategoriesPage(),
              ),
              GoRoute(
                path: AppRoutes.stock,
                builder: (context, state) => const StockPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
