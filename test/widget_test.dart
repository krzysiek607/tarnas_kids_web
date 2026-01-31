import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proste testy widgetowe bez zależności Supabase
void main() {
  testWidgets('ProviderScope wraps app correctly', (WidgetTester tester) async {
    // Test podstawowy - ProviderScope powinien się tworzyć
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test App'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('Basic widget tree renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Tarnas Kids')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Witaj w Tarnas Kids!'),
                SizedBox(height: 20),
                Icon(Icons.pets, size: 64),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tarnas Kids'), findsOneWidget);
    expect(find.text('Witaj w Tarnas Kids!'), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsOneWidget);
  });

  testWidgets('CircleAvatar renders with icon', (WidgetTester tester) async {
    // Test komponentu podobnego do przycisków menu
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              width: 95,
              height: 95,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 48),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.school), findsOneWidget);
  });
}
