import 'package:flutter_test/flutter_test.dart';
import 'package:tarnas_kids/main.dart';

void main() {
  testWidgets('App shows home screen with welcome message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TarnasKidsApp());

    // Verify that welcome text is displayed.
    expect(find.text('Witaj!'), findsOneWidget);

    // Verify that subtitle is displayed.
    expect(find.text('Co chcesz dzisiaj robić?'), findsOneWidget);

    // Verify that all three buttons are displayed.
    expect(find.text('Rysowanie'), findsOneWidget);
    expect(find.text('Nauka'), findsOneWidget);
    expect(find.text('Zabawa'), findsOneWidget);
  });
}
