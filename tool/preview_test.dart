// Run explicitly with: flutter test tool/preview_test.dart --update-goldens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kep/main.dart';
import 'package:kep/Model/Question/question.dart';
import 'package:kep/Screens/LoginScreen/login_page.dart';
import 'package:kep/Screens/QuizScreen/quiz_screen.dart';

void main() {
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT'] ?? '../tools/flutter';
    final font = File(
      '$sdk/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
    );
    final loader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.sublistView(font.readAsBytesSync())));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  testWidgets('sign-in preview', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(const Kankor(home: LoginPage()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Kankor),
      matchesGoldenFile('../docs/previews/sign_in.png'),
    );
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets('quiz preview', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      const Kankor(
        home: QuizScreen(
          quizQuestions: [
            Question(
              title: 'What is the chemical symbol for oxygen?',
              option1: 'O',
              option2: 'H',
              option3: 'N',
              option4: 'C',
              answer: 'O',
              subject: 'Chemistry',
            ),
          ],
          time: 300,
          language: 'en',
          subject: 'Chemistry',
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(Kankor),
      matchesGoldenFile('../docs/previews/quiz.png'),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });
}
