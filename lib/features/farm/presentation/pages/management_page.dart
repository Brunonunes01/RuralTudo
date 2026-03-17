import 'package:flutter/material.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/ui/app_empty_state.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Manejo',
      body: AppEmptyState(
        title: 'Manejo em evolução',
        subtitle:
            'Aqui você vai registrar adubação, irrigação, capina e outros manejos por plantio.',
      ),
    );
  }
}
