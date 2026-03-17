import 'package:flutter/material.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_empty_state.dart';

class WoodworkingPage extends StatelessWidget {
  const WoodworkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Marcenaria',
      body: AppEmptyState(
        title: 'Módulo opcional de marcenaria',
        subtitle:
            'Use este espaço para itens sob encomenda, pedidos e vendas da oficina.',
      ),
    );
  }
}
