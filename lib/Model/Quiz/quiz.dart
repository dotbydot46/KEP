import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kep/Model/Question/question.dart';
import 'package:translator/translator.dart';

class Quiz {
  final _translator = GoogleTranslator();
  Future<List<Question>> getQuiz(String subject, String language) async {
    final collection = FirebaseFirestore.instance.collection('questions');
    final aliases = switch (subject) {
      'IslamicStudies' => ['IslamicStudies', 'Islamic Studies'],
      'Maths' => ['Maths', 'Mathematics'],
      _ => [subject],
    };
    final snapshot = subject == 'all'
        ? await collection.get()
        : await collection.where('subject', whereIn: aliases).get();
    final records = snapshot.docs.map((doc) => doc.data()).toList()..shuffle();
    return prepareQuestions(
      records,
      subject == 'all' ? 20 : 5,
      language,
      translate: (text, language) async =>
          (await _translator
                  .translate(text, from: 'en', to: language)
                  .timeout(const Duration(seconds: 15)))
              .text,
    );
  }

  /// Preserve the original answer index, even if translations produce equal text.
  /// Prefer reviewed translations stored alongside each question.
  static Future<List<Question>> prepareQuestions(
    List<Map<String, dynamic>> records,
    int limit,
    String language, {
    required Future<String> Function(String, String) translate,
  }) async {
    final result = <Question>[];
    for (final record in records) {
      if (result.length >= limit) break;
      final fields = [
        'title',
        'option1',
        'option2',
        'option3',
        'option4',
        'answer',
        'subject',
      ];
      if (fields.any(
        (key) =>
            record[key] is! String || (record[key] as String).trim().isEmpty,
      )) {
        continue;
      }
      final options = [
        for (var i = 1; i <= 4; i++) record['option$i'] as String,
      ];
      final answerIndex = options.indexOf(record['answer'] as String);
      if (answerIndex < 0) continue;
      var title = record['title'] as String;
      var translatedOptions = options;
      if (language != 'en') {
        final translations = record['translations'];
        final localized = translations is Map ? translations[language] : null;
        if (localized is Map &&
            ['title', 'option1', 'option2', 'option3', 'option4'].every(
              (key) =>
                  localized[key] is String &&
                  (localized[key] as String).isNotEmpty,
            )) {
          title = localized['title'] as String;
          translatedOptions = [
            for (var i = 1; i <= 4; i++) localized['option$i'] as String,
          ];
        } else {
          final texts = await Future.wait(
            [title, ...options].map((text) => translate(text, language)),
          );
          title = texts.first;
          translatedOptions = texts.skip(1).toList();
        }
      }
      result.add(
        Question(
          title: title,
          option1: translatedOptions[0],
          option2: translatedOptions[1],
          option3: translatedOptions[2],
          option4: translatedOptions[3],
          answer: translatedOptions[answerIndex],
          answerIndex: answerIndex,
          subject: record['subject'] as String,
        ),
      );
    }
    return result;
  }
}
