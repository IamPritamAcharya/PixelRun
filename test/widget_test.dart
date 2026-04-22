import 'package:flutter_test/flutter_test.dart';
import 'package:runner/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RunnerApp());
    // Verify main menu renders
    expect(find.text('NEON'), findsOneWidget);
    expect(find.text('RUNNER'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });
}
