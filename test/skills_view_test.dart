import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_skills/main.dart';
import 'package:bloc_skills/skills/cubit/counter/counter_page.dart';
import 'package:bloc_skills/skills/cubit/theme/theme_page.dart';

void main() {
  testWidgets('HomeScreen displays skill titles and example numbers',
      (tester) async {
    await tester.pumpWidget(const BlocSkillsApp());
    await tester.pumpAndSettle();

    // Verify Skill titles appear
    expect(find.text('Skill 1: Cubit — The Simplified BLoC'), findsOneWidget);
    expect(find.text('Skill 2: BLoC — Events & States'), findsOneWidget);

    // Tap on Cubit skill to open examples screen
    await tester.tap(find.text('Skill 1: Cubit — The Simplified BLoC'));
    await tester.pumpAndSettle();

    // Verify Example numbers (1, 2, 3) in CircleAvatar
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('CounterPage displays counter number and updates on increment',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CounterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify counter initial number 0 appears
    expect(find.text('0'), findsOneWidget);

    // Tap Increment
    await tester.tap(find.byType(FloatingActionButton).last);
    await tester.pumpAndSettle();

    // Verify counter updated to 1
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('ThemePage displays active theme name', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ThemePage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Active Theme title appears
    expect(find.text('Active Theme: LIGHT'), findsOneWidget);

    // Toggle theme
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Verify Active Theme toggled to DARK
    expect(find.text('Active Theme: DARK'), findsOneWidget);
  });
}

