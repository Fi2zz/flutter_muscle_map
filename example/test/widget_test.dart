import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_map_example/main.dart';

void main() {
  testWidgets('Demo app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DemoApp());
    expect(find.byType(DemoApp), findsOneWidget);
  });
}
