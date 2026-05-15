import 'package:flutter_test/flutter_test.dart';
import 'package:healthnorth_mobile/main.dart';

void main() {
  testWidgets('App démarre sans erreur', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthNorthApp());
    expect(find.byType(HealthNorthApp), findsOneWidget);
  });
}
