import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_skills/main.dart';
import 'package:bloc_skills/skills/cubit/counter/counter_page.dart';
import 'package:bloc_skills/skills/cubit/theme/theme_page.dart';
import 'package:bloc_skills/skills/widgets/builder/build_when_page.dart';
import 'package:bloc_skills/skills/widgets/listener/listener_page.dart';
import 'package:bloc_skills/skills/widgets/consumer/consumer_page.dart';
import 'package:bloc_skills/skills/widgets/multi_bloc/multi_bloc_page.dart';
import 'package:bloc_skills/skills/access/patterns/access_patterns_page.dart';
import 'package:bloc_skills/skills/access/route_value/provider_value_page.dart';
import 'package:bloc_skills/skills/access/repository/repository_provider_page.dart';

void main() {
  testWidgets('HomeScreen displays skill titles and unlocks Skills 1-4',
      (tester) async {
    await tester.pumpWidget(const BlocSkillsApp());
    await tester.pumpAndSettle();

    // Verify Skill titles appear
    expect(find.text('Skill 1: Cubit — The Simplified BLoC'), findsOneWidget);
    expect(find.text('Skill 2: BLoC — Events & States'), findsOneWidget);
    expect(find.text('Skill 3: BLoC Widgets'), findsOneWidget);
    expect(find.text('Skill 4: BLoC Access & DI'), findsOneWidget);

    // Tap on Skill 4 (now unlocked!)
    await tester.tap(find.text('Skill 4: BLoC Access & DI'));
    await tester.pumpAndSettle();

    // Verify 3 examples appear
    expect(find.text('Access Patterns — read, watch, select'), findsOneWidget);
    expect(find.text('BlocProvider.value — Route Passing'), findsOneWidget);
    expect(find.text('RepositoryProvider — Service DI'), findsOneWidget);
  });

  testWidgets('CounterPage displays counter number and updates on increment',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CounterPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton).last);
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('ThemePage displays active theme name', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ThemePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active Theme: LIGHT'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Active Theme: DARK'), findsOneWidget);
  });

  testWidgets('BuildWhenPage renders and responds to count changes',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BuildWhenPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('buildWhen Optimization'), findsOneWidget);
    expect(find.text('Current Note: Initial state'), findsOneWidget);

    await tester.ensureVisible(find.text('Count + 1'));
    await tester.tap(find.text('Count + 1'));
    await tester.pumpAndSettle();

    expect(find.text('Current Note: Odd number (1)'), findsOneWidget);
  });

  testWidgets('ListenerPage renders balance and allows deposit',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ListenerPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('\$50'), findsOneWidget);

    await tester.tap(find.text('Deposit +\$30'));
    await tester.pumpAndSettle();

    expect(find.text('\$80'), findsOneWidget);
  });

  testWidgets('ConsumerPage renders ready state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ConsumerPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready to Download'), findsOneWidget);
    expect(find.text('Download (Success)'), findsOneWidget);
  });

  testWidgets('MultiBlocPage renders cart and adds item', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MultiBlocPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('\$0'), findsOneWidget);

    await tester.tap(find.text('Add Book (+\$25)'));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('\$25'), findsOneWidget);
  });

  testWidgets('AccessPatternsPage updates score via context.select',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AccessPatternsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('100 pts'), findsOneWidget);
    expect(find.text('Alex Johnson'), findsOneWidget);

    await tester.ensureVisible(find.text('Add Score (+25)'));
    await tester.tap(find.text('Add Score (+25)'));
    await tester.pumpAndSettle();

    expect(find.text('125 pts'), findsOneWidget);
  });

  testWidgets('ProviderValuePage shares cubit across routes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProviderValuePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Screen A (Parent Route)'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // Open Screen B
    await tester.tap(find.text('Open Screen B with BlocProvider.value'));
    await tester.pumpAndSettle();

    expect(find.text('Screen B (Child Route)'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // Increment in Screen B
    await tester.tap(find.text('Increment'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);

    // Return to Screen A
    await tester.tap(find.text('Return to Screen A (Instance Kept Alive)'));
    await tester.pumpAndSettle();

    // Verify Screen A now shows 1
    expect(find.text('Screen A (Parent Route)'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('RepositoryProviderPage fetches user through injected repository',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RepositoryProviderPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No User Loaded'), findsOneWidget);

    // Fetch Sarah Connor
    await tester.tap(find.text('Fetch Sarah (user_1)'));
    await tester.pump(); // Start fetch

    expect(find.text('Calling UserRepository.fetchUser()...'), findsOneWidget);

    // Wait for mock network delay
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    expect(find.text('Sarah Connor'), findsOneWidget);
    expect(find.text('sarah.connor@sky.net'), findsOneWidget);
    expect(find.text('Lead Architect'), findsOneWidget);
  });
}
