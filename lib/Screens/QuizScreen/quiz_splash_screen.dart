import 'package:flutter/material.dart';
import 'package:kep/Model/Quiz/quiz.dart';
import 'package:kep/Screens/QuizScreen/quiz_screen.dart';

class QuizSplashScreen extends StatefulWidget {
  final String subject;
  final String language;
  final int time;
  const QuizSplashScreen({
    super.key,
    required this.subject,
    required this.language,
    required this.time,
  });
  @override
  State<QuizSplashScreen> createState() => _QuizSplashScreenState();
}

class _QuizSplashScreenState extends State<QuizSplashScreen> {
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final questions = await Quiz().getQuiz(widget.subject, widget.language);
      if (!mounted) return;
      if (questions.isEmpty) {
        setState(
          () => _error = 'No questions are available for this subject yet.',
        );
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => QuizScreen(
            quizQuestions: questions,
            time: widget.time,
            language: widget.language,
            subject: widget.subject,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not prepare this quiz. Check your connection and retry.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Prepare quiz')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error == null) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Preparing your questions…'),
            ] else ...[
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Retry')),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
