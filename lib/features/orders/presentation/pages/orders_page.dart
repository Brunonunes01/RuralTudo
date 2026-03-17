import 'package:flutter/material.dart';

import '../../../../core/widgets/app_scaffold.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Encomendas',
      body: Center(
        child: Text(
          'Aqui você acompanha as encomendas: pendente, em produção, pronto, entregue e cancelado.',
        ),
      ),
    );
  }
}
