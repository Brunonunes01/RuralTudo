import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/app_scaffold.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Mais',
      body: ListView(
        children: [
          _item(context, 'Clientes', Icons.people_outline, AppRoutes.customers),
          _item(
            context,
            'Despesas',
            Icons.receipt_long_outlined,
            AppRoutes.expenses,
          ),
          _item(
            context,
            'Encomendas',
            Icons.assignment_outlined,
            AppRoutes.orders,
          ),
          _item(
            context,
            'Relatórios',
            Icons.bar_chart_outlined,
            AppRoutes.reports,
          ),
          _item(
            context,
            'Configurações',
            Icons.settings_outlined,
            AppRoutes.settings,
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
