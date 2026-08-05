import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kipack/main.dart';

void main() {
  testWidgets('Shows the empty state on first launch', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KipackApp()));
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes viajes'), findsOneWidget);
    expect(find.text('Nuevo viaje'), findsOneWidget);
  });
}
