import 'package:flutter/material.dart';
import 'package:kep/Model/Question/question.dart';

class AnswerPage extends StatelessWidget {
  final List<Question> quizQuestions;
  final TextAlign align;
  final List<int?>? selectedAnswers;
  const AnswerPage({
    super.key,
    required this.quizQuestions,
    required this.align,
    this.selectedAnswers,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Answer review')),
    body: Directionality(
      textDirection: align == TextAlign.end
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizQuestions.length,
        itemBuilder: (context, index) {
          final question = quizQuestions[index];
          final selected =
              selectedAnswers != null && index < selectedAnswers!.length
              ? selectedAnswers![index]
              : null;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${question.title}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your answer: ${selected == null ? 'Skipped' : question.options[selected]}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correct answer: ${question.answer}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
