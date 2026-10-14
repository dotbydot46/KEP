import 'package:flutter/material.dart';
import 'package:kep/Model/Question/question.dart';
import 'package:kep/Screens/AsnwerScreen/asnwer_page.dart';
import 'package:kep/services/attempt_history.dart';

class ResultPage extends StatefulWidget {
  final int trueAns;
  final int falseAns;
  final int totalQuestions;
  final TextAlign align;
  final List<Question> quizQuestion;
  final Map<String, int> correctAnswers;
  final Map<String, int> wrongAnswers;
  final List<int?>? selectedAnswers;
  const ResultPage({
    super.key,
    required this.trueAns,
    required this.falseAns,
    required this.totalQuestions,
    required this.align,
    required this.quizQuestion,
    required this.correctAnswers,
    required this.wrongAnswers,
    this.selectedAnswers,
  });
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? _saveError;
  @override
  void initState() {
    super.initState();
    if (widget.totalQuestions > 0) _save();
  }

  Future<void> _save() async {
    try {
      await AttemptHistory.save(
        correct: widget.trueAns,
        wrong: widget.falseAns,
        total: widget.totalQuestions,
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _saveError = 'This result could not be saved on this device.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.totalQuestions == 0
        ? 0.0
        : widget.trueAns / widget.totalQuestions * 100;
    final subjects = {
      ...widget.correctAnswers.keys,
      ...widget.wrongAnswers.keys,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Your results')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '${score.toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Every attempt helps you prepare.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _row('Correct', widget.trueAns),
                      _row('Wrong', widget.falseAns),
                      _row(
                        'Skipped',
                        widget.totalQuestions -
                            widget.trueAns -
                            widget.falseAns,
                      ),
                      _row('Total questions', widget.totalQuestions),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('By subject', style: Theme.of(context).textTheme.titleLarge),
              for (final subject in subjects)
                Card(
                  child: ListTile(
                    title: Text(subject),
                    subtitle: Text(
                      '${widget.correctAnswers[subject] ?? 0} correct · ${widget.wrongAnswers[subject] ?? 0} wrong',
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (_saveError != null) Text(_saveError!),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => AnswerPage(
                      quizQuestions: widget.quizQuestion,
                      align: widget.align,
                      selectedAnswers: widget.selectedAnswers,
                    ),
                  ),
                ),
                child: const Text('Review answers'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to preparation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, int count) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text('$count')],
    ),
  );
}
