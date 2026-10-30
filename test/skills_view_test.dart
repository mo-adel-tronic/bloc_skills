import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_skills/main.dart';
import 'package:bloc_skills/skills/cubit/counter/counter_page.dart';
import 'package:bloc_skills/skills/cubit/theme/theme_page.dart';
import 'package:bloc_skills/skills/widgets/builder/build_when_page.dart';
import 'package:bloc_skills/skills/widgets/listener/listener_page.dart';
import 'package:bloc_skills/skills/widgets/consumer/consumer_page.dart';
import 'package:bloc_skills/skills/widgets/multi_bloc/multi_bloc_page.dart';

void main() {
  testWidgets('HomeScreen displays skill titles and unlocks Skill 3',
      (tester) async {
    await tester.pumpWidget(const BlocSkillsApp());
    await tester.pumpAndSettle();

    // Verify Skill titles appear
    expect(find.text('Skill 1: Cubit — The Simplified BLoC'), findsOneWidget);
    expect(find.text('Skill 2: BLoC — Events & States'), findsOneWidget);
    expect(find.text('Skill 3: BLoC Widgets'), findsOneWidget);

    // Tap on Skill 3 (now unlocked!)
    await tester.tap(find.text('Skill 3: BLoC Widgets'));
    await tester.pumpAndSettle();

    // Verify 4 examples appear
    expect(find.text('BlocBuilder — buildWhen Optimization'), findsOneWidget);
    expect(find.text('BlocListener — Side Effects & Dialogs'), findsOneWidget);
    expect(find.text('BlocConsumer — Builder + Listener Combined'), findsOneWidget);
    expect(find.text('MultiBloc — MultiBlocProvider & Listener'), findsOneWidget);
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

    // Ensure visible then tap Count + 1
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

    // Deposit $30
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

    // Tap Add Book
    await tester.tap(find.text('Add Book (+\$25)'));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('\$25'), findsOneWidget);
  });
}
