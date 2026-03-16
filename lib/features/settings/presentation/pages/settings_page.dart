import 'package:flutter/material.dart';

import '../../../../core/widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Configuracoes',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(child: ListTile(title: Text('Nome do proprietario'), subtitle: Text('Em breve: edicao local'))),
          SizedBox(height: 8),
          Card(child: ListTile(title: Text('Nome do sitio'), subtitle: Text('Em breve: edicao local'))),
          SizedBox(height: 8),
          Card(child: ListTile(title: Text('Moeda'), subtitle: Text('BRL'))),
          SizedBox(height: 8),
          Card(child: ListTile(title: Text('Unidade padrao'), subtitle: Text('un'))),
          SizedBox(height: 8),
          Card(child: ListTile(title: Text('Backup/exportacao'), subtitle: Text('Base pronta para futura implementacao offline/online'))),
        ],
      ),
    );
  }
}
