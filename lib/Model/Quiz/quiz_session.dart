import 'package:kep/Model/Question/question.dart';

/// A submitted answer is an option index. Null represents a skipped question.
class QuizSession {
  QuizSession(this.questions)
    : answers = List<int?>.filled(questions.length, null);
  final List<Question> questions;
  final List<int?> answers;
  int index = 0;
  bool finished = false;

  void submit(int? option) {
    if (finished || questions.isEmpty) return;
    if (option != null && (option < 0 || option > 3)) {
      throw RangeError.range(option, 0, 3);
    }
    answers[index] = option;
    if (index == questions.length - 1) {
      finished = true;
    } else {
      index++;
    }
  }

  bool isCorrect(int i) => answers[i] == questions[i].correctOption;
  int get correct => List.generate(
    questions.length,
    (i) => i,
  ).where((i) => answers[i] != null && isCorrect(i)).length;
  int get wrong => answers.whereType<int>().length - correct;
  Map<String, int> counts({required bool correctAnswers}) {
    final result = <String, int>{};
    for (var i = 0; i < questions.length; i++) {
      final subject = questions[i].subject;
      result.putIfAbsent(subject, () => 0);
      if (answers[i] != null && isCorrect(i) == correctAnswers) {
        result[subject] = result[subject]! + 1;
      }
    }
    return result;
  }
}
