// Basic widget test for fresh_app
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_app/main.dart';

void main() {
  testWidgets('App renders heading', (WidgetTester tester) async {
    await tester.pumpWidget(const MaxDemandCalculatorApp());
    expect(find.text('Maximum Demand'), findsWidgets);
    expect(find.text('Seaspray Electrical'), findsWidgets);
  });
}
