import 'package:flutter_test/flutter_test.dart';

import 'package:tuinier_app/main.dart';

void main() {
  testWidgets('Startscherm toont titel Groentenatlas', (tester) async {
    await tester.pumpWidget(const TuinierApp());
    expect(find.text('Groentenatlas'), findsOneWidget);
  });
}
