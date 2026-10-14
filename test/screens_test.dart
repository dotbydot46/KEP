import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kep/main.dart';
import 'package:kep/Model/Question/question.dart';
import 'package:kep/Screens/LoginScreen/login_page.dart';
import 'package:kep/Screens/QuizScreen/quiz_screen.dart';
import 'package:kep/Screens/ResultScreen/result_screen.dart';

const question = Question(
  title: '2 + 2?',
  option1: '3',
  option2: '4',
  option3: '5',
  option4: '6',
  answer: '4',
  subject: 'Maths',
);

void main() {
  testWidgets('sign-in validates empty input without contacting Firebase', (
    tester,
  ) async {
    await tester.pumpWidget(const Kankor(home: LoginPage()));
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('quiz finish counts the selected answer once and reviews it', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Kankor(
        home: QuizScreen(
          quizQuestions: [question],
          time: 300,
          language: 'en',
          subject: 'Maths',
        ),
      ),
    );
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.ensureVisible(find.text('Finish quiz'));
    await tester.tap(find.text('Finish quiz'));
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
    expect(find.byType(ResultPage), findsOneWidget);
    await tester.ensureVisible(find.text('Review answers'));
    await tester.tap(find.text('Review answers'));
    await tester.pumpAndSettle();
    expect(find.text('Your answer: 4'), findsOneWidget);
    expect(find.text('Correct answer: 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('expiry dismisses exit dialog and commits pending answer once', (
    tester,
  ) async {
    var now = DateTime(2026, 1, 1);
    await tester.pumpWidget(
      Kankor(
        home: QuizScreen(
          quizQuestions: const [question],
          time: 2,
          language: 'en',
          subject: 'Maths',
          now: () => now,
        ),
      ),
    );
    await tester.tap(find.text('4'));
    await tester.tap(find.byTooltip('Leave quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Leave this quiz?'), findsOneWidget);
    now = now.add(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Leave this quiz?'), findsNothing);
    expect(find.byType(ResultPage), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('narrow screen and large text keep sign-in usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2),
          ),
          child: LoginPage(),
        ),
      ),
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
