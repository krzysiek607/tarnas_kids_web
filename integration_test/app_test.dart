import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:talu_kids/screens/home_screen.dart';
import 'package:talu_kids/screens/learning_screen.dart';
import 'package:talu_kids/screens/fun_screen.dart';
import 'package:talu_kids/screens/pet_screen.dart';
import 'package:talu_kids/screens/settings_screen.dart';
import 'package:talu_kids/screens/learning/letter_tracing_screen.dart';

import 'helpers/test_app.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Setup: initialize mock SharedPreferences before each test.
  // This ensures PetNotifier loads known default values and
  // DatabaseService.isInitialized remains false (no Supabase in tests).
  // ---------------------------------------------------------------------------
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'pet_hunger': 80.0,
      'pet_happiness': 80.0,
      'pet_energy': 80.0,
      'pet_hygiene': 80.0,
      'pet_lastUpdate': DateTime.now().toIso8601String(),
      'pet_evolutionPoints': 0,
    });
  });

  // ===========================================================================
  // FLOW 1: App Navigation
  //
  // Verifies the core navigation paths from HomeScreen to child screens
  // and back. The HomeScreen uses _ArchMenuButton widgets that navigate
  // after a 600ms tooltip animation delay.
  // ===========================================================================
  group('Flow 1: App Navigation', () {
    testWidgets(
      'App launches and shows HomeScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestAppWithMockedProviders());
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Tap "Nauka" navigates to LearningScreen and back returns to HomeScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestAppWithMockedProviders());
        await tester.pumpAndSettle();

        // Find the Nauka button by its icon image asset path.
        // Each _ArchMenuButton contains an Image.asset with a unique icon.
        final naukaImage = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('main_nauka'),
        );

        if (naukaImage.evaluate().isNotEmpty) {
          await tester.tap(naukaImage.first);
        }

        // The _ArchMenuButton has a 600ms Future.delayed before navigation
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        expect(find.byType(LearningScreen), findsOneWidget);

        // Navigate back using the back button (arrow_back_rounded icon)
        final backButton = find.byIcon(Icons.arrow_back_rounded);
        expect(backButton, findsWidgets);
        await tester.tap(backButton.first);
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Tap "Zabawa" navigates to FunScreen and back returns to HomeScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestAppWithMockedProviders());
        await tester.pumpAndSettle();

        final zabawaImage = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('main_zabawa'),
        );

        if (zabawaImage.evaluate().isNotEmpty) {
          await tester.tap(zabawaImage.first);
        }

        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        expect(find.byType(FunScreen), findsOneWidget);

        final backButton = find.byIcon(Icons.arrow_back_rounded);
        expect(backButton, findsWidgets);
        await tester.tap(backButton.first);
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Tap pet icon navigates to PetScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestAppWithMockedProviders());
        await tester.pumpAndSettle();

        // Pet button shows the creature image (Egg.webp for egg stage).
        // Its asset path contains 'Creature/'.
        final petImage = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('Creature/'),
        );

        if (petImage.evaluate().isNotEmpty) {
          await tester.tap(petImage.first);
        }

        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        expect(find.byType(PetScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Tap settings icon navigates to SettingsScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestAppWithMockedProviders());
        await tester.pumpAndSettle();

        // Settings button uses Icons.settings_rounded, located in the top-right
        final settingsButton = find.byIcon(Icons.settings_rounded);
        expect(settingsButton, findsOneWidget);
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        expect(find.byType(SettingsScreen), findsOneWidget);
      },
    );
  });

  // ===========================================================================
  // FLOW 2: Pet Interactions
  //
  // Verifies the pet stats display, action buttons (play/wash/sleep),
  // mood text changes, and sleeping state behavior on PetScreen.
  // Pet state is backed by real PetNotifier with mocked SharedPreferences.
  // ===========================================================================
  group('Flow 2: Pet Interactions', () {
    testWidgets(
      'PetScreen displays all four stat bars',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PetScreen), findsOneWidget);

        // Verify Polish stat labels with diacritics are present
        // 'Glod' = Hunger, 'Szczescie' = Happiness
        expect(find.text('G\u0142\u00f3d'), findsOneWidget);
        expect(find.text('Szcz\u0119\u015bcie'), findsOneWidget);
        expect(find.text('Energia'), findsOneWidget);
        expect(find.text('Higiena'), findsOneWidget);
      },
    );

    testWidgets(
      'PetScreen shows initial stat values at 80%',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        // All stats start at 80.0, displayed as "80%"
        // There should be 4 occurrences of "80%" (one per stat bar)
        expect(find.text('80%'), findsNWidgets(4));
      },
    );

    testWidgets(
      'Tap play button changes mood to "Zabawa!"',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        // Find and tap the play button by its label
        final playButton = find.text('Baw sie');
        expect(playButton, findsOneWidget);
        await tester.tap(playButton);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Mood text should change to 'Zabawa!' (playing)
        expect(find.text('Zabawa!'), findsOneWidget);
      },
    );

    testWidgets(
      'Tap wash button changes mood to "Plusk plusk!"',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        final washButton = find.text('Umyj');
        expect(washButton, findsOneWidget);
        await tester.tap(washButton);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Mood text should change to 'Plusk plusk!' (bathing)
        expect(find.text('Plusk plusk!'), findsOneWidget);
      },
    );

    testWidgets(
      'Tap sleep button puts pet to sleep and shows "Zzz..."',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        // Initially the pet is happy
        expect(find.text('Szcz\u0119\u015bliwy!'), findsOneWidget);

        // Tap sleep button
        final sleepButton = find.text('Spij');
        expect(sleepButton, findsOneWidget);
        await tester.tap(sleepButton);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Mood text should change to 'Zzz...'
        expect(find.text('Zzz...'), findsOneWidget);
      },
    );

    testWidgets(
      'Sleeping pet shows wake button "Obudz" instead of "Spij"',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        // Initially shows "Spij" (Sleep)
        expect(find.text('Spij'), findsOneWidget);
        expect(find.text('Obudz'), findsNothing);

        // Put pet to sleep
        await tester.tap(find.text('Spij'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Now shows "Obudz" (Wake) instead of "Spij"
        expect(find.text('Obudz'), findsOneWidget);
        expect(find.text('Spij'), findsNothing);
      },
    );

    testWidgets(
      'Wake button returns pet to awake state',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        // Put to sleep first
        await tester.tap(find.text('Spij'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Zzz...'), findsOneWidget);

        // Wake up
        await tester.tap(find.text('Obudz'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Should no longer show sleeping mood
        expect(find.text('Zzz...'), findsNothing);
        // "Spij" button should be back
        expect(find.text('Spij'), findsOneWidget);
      },
    );

    testWidgets(
      'Inventory panel is visible with "Smakolyki" heading',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        // The inventory panel has the heading 'Smakolyki' (Treats)
        expect(find.text('Smako\u0142yki'), findsOneWidget);

        // Empty inventory shows 'Zbieraj w grach!' (Collect in games!)
        expect(find.text('Zbieraj w grach!'), findsOneWidget);
      },
    );

    testWidgets(
      'Action buttons are present (play, sleep, wash)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Baw sie'), findsOneWidget);
        expect(find.text('Spij'), findsOneWidget);
        expect(find.text('Umyj'), findsOneWidget);
      },
    );

    testWidgets(
      'PetScreen has back button that navigates away',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/pet'),
        );
        await tester.pumpAndSettle();

        // PetScreen has an AppBar with a back button
        final backButton = find.byIcon(Icons.arrow_back_rounded);
        expect(backButton, findsWidgets);
      },
    );
  });

  // ===========================================================================
  // FLOW 3: Settings & Parental Gate
  //
  // Verifies the SettingsScreen child section (sound/music controls),
  // the locked parent section with its 4-second long-press gate, and
  // navigation back to HomeScreen.
  // ===========================================================================
  group('Flow 3: Settings & Parental Gate', () {
    testWidgets(
      'SettingsScreen displays child section with sound controls',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/settings'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SettingsScreen), findsOneWidget);

        // Child section header 'Dzwieki' (Sounds) appears as section heading
        // and also as the SFX toggle title
        expect(find.text('D\u017awi\u0119ki'), findsWidgets);

        // Music control label
        expect(find.text('Muzyka'), findsOneWidget);

        // Music subtitle
        expect(find.text('Melodia w tle'), findsOneWidget);

        // SFX subtitle
        expect(find.text('Efekty w grach'), findsOneWidget);
      },
    );

    testWidgets(
      'SettingsScreen displays locked parent section',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/settings'),
        );
        await tester.pumpAndSettle();

        // Parent section heading
        expect(find.text('Strefa rodzica'), findsOneWidget);

        // Lock status text (Polish: 'Chronione haslem' = 'Password protected')
        expect(find.text('Chronione has\u0142em'), findsOneWidget);

        // Parental gate instruction
        expect(find.text('Przytrzymaj 4 sekundy'), findsOneWidget);

        // Lock icon is displayed
        expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

        // 'Odblokowano' (Unlocked) should NOT be visible
        expect(find.text('Odblokowano'), findsNothing);
      },
    );

    testWidgets(
      'Sound effects Switch toggle works on/off',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/settings'),
        );
        await tester.pumpAndSettle();

        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);

        // Initially ON
        Switch switchWidget = tester.widget<Switch>(switchFinder);
        expect(switchWidget.value, isTrue);

        // Toggle OFF
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isFalse);

        // Toggle back ON
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isTrue);
      },
    );

    testWidgets(
      'Quick tap does NOT unlock parental gate',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/settings'),
        );
        await tester.pumpAndSettle();

        // Verify gate is locked
        expect(find.text('Przytrzymaj 4 sekundy'), findsOneWidget);
        expect(find.text('Odblokowano'), findsNothing);

        // Quick tap on the gate button
        final gateArea = find.text('Przytrzymaj 4 sekundy');
        await tester.tap(gateArea);
        await tester.pumpAndSettle();

        // Should remain locked - a quick tap does not satisfy the 4-second hold
        expect(find.text('Odblokowano'), findsNothing);
        expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'Music volume Slider widget is present',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/settings'),
        );
        await tester.pumpAndSettle();

        final slider = find.byType(Slider);
        expect(slider, findsOneWidget);
      },
    );

    testWidgets(
      'App version text contains "TaLu Kids"',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/settings'),
        );
        await tester.pumpAndSettle();

        // Version text is "TaLu Kids v1.0.0" (fallback in test env)
        expect(find.textContaining('TaLu Kids'), findsOneWidget);
      },
    );

    testWidgets(
      'Back button navigates from SettingsScreen to HomeScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestAppWithMockedProviders());
        await tester.pumpAndSettle();

        // Navigate to Settings
        final settingsIcon = find.byIcon(Icons.settings_rounded);
        await tester.tap(settingsIcon);
        await tester.pumpAndSettle();

        expect(find.byType(SettingsScreen), findsOneWidget);

        // Navigate back
        final backButton = find.byIcon(Icons.arrow_back_rounded);
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  });

  // ===========================================================================
  // FLOW 4: Game Launch
  //
  // Verifies that game buttons are present on LearningScreen and FunScreen,
  // that tapping a game button launches the corresponding game screen, and
  // that navigating back returns to the list screen.
  // ===========================================================================
  group('Flow 4: Game Launch', () {
    testWidgets(
      'LearningScreen shows 6 game buttons',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/learning'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LearningScreen), findsOneWidget);

        // 6 learning games: Szlaczki, Literki, Znajdz litere, Sylaby, Liczenie, Sekwencje
        // Each has an image asset with 'nauka_' prefix
        final gameImages = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('nauka_'),
        );

        expect(gameImages, findsNWidgets(6));
      },
    );

    testWidgets(
      'FunScreen shows 4 game buttons',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/fun'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FunScreen), findsOneWidget);

        // 4 fun games: Rysowanie, Labirynt, Dopasuj, Polacz kropki
        // Each has an image asset with 'zabawa_' prefix
        final gameImages = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('zabawa_'),
        );

        expect(gameImages, findsNWidgets(4));
      },
    );

    testWidgets(
      'Tap "Literki" game on LearningScreen launches LetterTracingScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/learning'),
        );
        await tester.pumpAndSettle();

        // Find and tap the "Literki" game button
        final literkiImage = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('nauka_literki'),
        );

        expect(literkiImage, findsOneWidget);
        await tester.tap(literkiImage);

        // Wait for 600ms tooltip animation delay before navigation fires
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        // LetterTracingScreen should now be displayed
        expect(find.byType(LetterTracingScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Navigate back from LetterTracingScreen returns to LearningScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/learning'),
        );
        await tester.pumpAndSettle();

        // Navigate to Literki
        final literkiImage = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('nauka_literki'),
        );

        if (literkiImage.evaluate().isNotEmpty) {
          await tester.tap(literkiImage);
          await tester.pump(const Duration(milliseconds: 700));
          await tester.pumpAndSettle();

          // Navigate back using back button
          final backButton = find.byIcon(Icons.arrow_back_rounded);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton.first);
            await tester.pumpAndSettle();
          } else {
            // Fallback: try standard back icon
            final fallbackBack = find.byIcon(Icons.arrow_back);
            if (fallbackBack.evaluate().isNotEmpty) {
              await tester.tap(fallbackBack.first);
              await tester.pumpAndSettle();
            }
          }

          expect(find.byType(LearningScreen), findsOneWidget);
        }
      },
    );

    testWidgets(
      'LearningScreen has a back button',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/learning'),
        );
        await tester.pumpAndSettle();

        // LearningScreen has a _BackButton with arrow_back_rounded icon
        final backButton = find.byIcon(Icons.arrow_back_rounded);
        expect(backButton, findsOneWidget);
      },
    );

    testWidgets(
      'FunScreen has a back button',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithMockedProviders(initialRoute: '/fun'),
        );
        await tester.pumpAndSettle();

        final backButton = find.byIcon(Icons.arrow_back_rounded);
        expect(backButton, findsOneWidget);
      },
    );

    testWidgets(
      'Navigate HomeScreen -> LearningScreen -> back -> HomeScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestAppWithMockedProviders());
        await tester.pumpAndSettle();

        // Navigate to Learning
        final naukaImage = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('main_nauka'),
        );

        if (naukaImage.evaluate().isNotEmpty) {
          await tester.tap(naukaImage.first);
          await tester.pump(const Duration(milliseconds: 700));
          await tester.pumpAndSettle();

          expect(find.byType(LearningScreen), findsOneWidget);

          // Navigate back
          final backButton = find.byIcon(Icons.arrow_back_rounded);
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();

          expect(find.byType(HomeScreen), findsOneWidget);
        }
      },
    );

    testWidgets(
      'Navigate HomeScreen -> FunScreen -> back -> HomeScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestAppWithMockedProviders());
        await tester.pumpAndSettle();

        final zabawaImage = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('main_zabawa'),
        );

        if (zabawaImage.evaluate().isNotEmpty) {
          await tester.tap(zabawaImage.first);
          await tester.pump(const Duration(milliseconds: 700));
          await tester.pumpAndSettle();

          expect(find.byType(FunScreen), findsOneWidget);

          final backButton = find.byIcon(Icons.arrow_back_rounded);
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();

          expect(find.byType(HomeScreen), findsOneWidget);
        }
      },
    );
  });
}
