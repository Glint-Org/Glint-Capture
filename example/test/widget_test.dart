import 'package:flutter_test/flutter_test.dart';
import 'package:glint_capture_example/main.dart';

void main() {
  testWidgets('Example app renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('Welcome to MyApp'), findsOneWidget);
  });
}
