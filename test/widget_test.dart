import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruraltudo/app/app.dart';

void main() {
  testWidgets('app renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RuralTudoApp()));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
