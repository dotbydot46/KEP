import 'package:flutter_test/flutter_test.dart';
import 'package:kep/Model/Question/question.dart';
import 'package:kep/Model/Quiz/quiz.dart';
import 'package:kep/Model/Quiz/quiz_session.dart';
import 'package:kep/Model/Result/result.dart';

const question = Question(
  title: '2 + 2?',
  option1: '3',
  option2: '4',
  option3: '5',
  option4: '6',
  answer: '4',
  subject: 'Maths',
);
Map<String, dynamic> record() => {
  'title': '2 + 2?',
  'option1': '3',
  'option2': '4',
  'option3': '5',
  'option4': '6',
  'answer': '4',
  'subject': 'Maths',
};

void main() {
  test('short and empty question banks are safe; English makes no translation calls', () async {
    var calls = 0;
    Future<String> translate(String text, String language) async {
      calls++;
      return text;
    }

    expect(
      await Quiz.prepareQuestions([], 20, 'en', translate: translate),
      isEmpty,
    );
    final short = await Quiz.prepareQuestions(
      [record()],
      5,
      'en',
      translate: translate,
    );
    expect(short.length, 1);
    expect(calls, 0);
  });
  test('malformed and unscorable records are skipped', () async {
    final records = [
      <String, dynamic>{'title': 'Incomplete'},
      {...record(), 'answer': 'none'},
      record(),
    ];
    final questions = await Quiz.prepareQuestions(
      records,
      5,
      'en',
      translate: (t, l) async => t,
    );
    expect(questions.length, 1);
  });
  test(
    'translations do not change correct option when wording collides',
    () async {
      var calls = 0;
      final questions = await Quiz.prepareQuestions(
        [record()],
        5,
        'fa',
        translate: (text, language) async {
          calls++;
          return 'same translated text';
        },
      );
      expect(calls, 5);
      expect(questions.single.correctOption, 1);
      final session = QuizSession(questions)..submit(0);
      expect(session.correct, 0);
      expect(session.wrong, 1);
    },
  );
  test('reviewed translations avoid external translation requests', () async {
    final localized = {
      ...record(),
      'translations': {
        'fa': {
          'title': 'عنوان',
          'option1': '۳',
          'option2': '۴',
          'option3': '۵',
          'option4': '۶',
        },
      },
    };
    final questions = await Quiz.prepareQuestions(
      [localized],
      5,
      'fa',
      translate: (_, _) => throw StateError('Must use stored translations'),
    );
    expect(questions.single.answer, '۴');
    expect(questions.single.correctOption, 1);
  });
  test('translation failures reach the loader for retry instead of partial quizzes', () async {
    expect(
      Quiz.prepareQuestions(
        [record()],
        5,
        'ps',
        translate: (_, _) async => throw StateError('Offline'),
      ),
      throwsStateError,
    );
  });
  test(
    'each question submits once; skipped and unknown subjects are counted',
    () {
      const other = Question(
        title: 'Other?',
        option1: 'a',
        option2: 'b',
        option3: 'c',
        option4: 'd',
        answer: 'a',
        subject: 'New subject',
      );
      final session = QuizSession([question, other, question]);
      session.submit(1);
      session.submit(1);
      session.submit(null);
      session.submit(1);
      expect(session.finished, true);
      expect(session.correct, 1);
      expect(session.wrong, 1);
      expect(session.answers, [1, 1, null]);
      expect(session.counts(correctAnswers: false)['New subject'], 1);
    },
  );
  test('empty results are finite', () {
    final result = Result();
    expect(result.percentage(), 0);
    expect(result.notAttempted(), 0);
  });
}
