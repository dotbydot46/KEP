import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kep/Model/Question/question.dart';
import 'package:kep/Model/Quiz/quiz_session.dart';
import 'package:kep/Screens/ResultScreen/result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> quizQuestions;
  final int time;
  final String language;
  final String subject;
  final DateTime Function()? now;
  const QuizScreen({
    super.key,
    required this.quizQuestions,
    required this.time,
    required this.language,
    required this.subject,
    this.now,
  });
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  late final QuizSession _session;
  late final DateTime _deadline;
  Timer? _timer;
  int? _selected;
  int _remaining = 0;
  bool _finishing = false;
  bool _exitDialogOpen = false;
  DateTime get _now => widget.now?.call() ?? DateTime.now();
  TextAlign get _align =>
      widget.language == 'en' ? TextAlign.start : TextAlign.end;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = QuizSession(widget.quizQuestions);
    _remaining = widget.time;
    _deadline = _now.add(Duration(seconds: widget.time));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    if (widget.quizQuestions.isEmpty || widget.time <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _tick() {
    if (!mounted || _finishing) return;
    final millis = _deadline.difference(_now).inMilliseconds;
    final remaining = ((millis + 999) ~/ 1000).clamp(0, widget.time);
    if (remaining == 0) {
      _finish();
    } else {
      setState(() => _remaining = remaining);
    }
  }

  void _next({bool skip = false}) {
    if (_finishing || (!skip && _selected == null)) return;
    if (!_now.isBefore(_deadline)) {
      _finish();
      return;
    }
    _session.submit(skip ? null : _selected);
    if (_session.finished) {
      _finish();
    } else {
      setState(() => _selected = null);
    }
  }

  void _finish() {
    if (!mounted || _finishing) return;
    _finishing = true;
    _timer?.cancel();
    if (_exitDialogOpen) {
      _exitDialogOpen = false;
      Navigator.of(context).pop();
    }
    // A selected answer is committed at expiry, exactly once.
    if (!_session.finished && _selected != null) _session.submit(_selected);
    _session.finished = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultPage(
          trueAns: _session.correct,
          falseAns: _session.wrong,
          totalQuestions: widget.quizQuestions.length,
          quizQuestion: widget.quizQuestions,
          align: _align,
          correctAnswers: _session.counts(correctAnswers: true),
          wrongAnswers: _session.counts(correctAnswers: false),
          selectedAnswers: List.of(_session.answers),
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || _finishing) return;
    _exitDialogOpen = true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this quiz?'),
        content: const Text('Your current attempt will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep studying'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (!mounted || _finishing || leave != true) return;
    _finishing = true;
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizQuestions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No questions available.')),
      );
    }
    final question = widget.quizQuestions[_session.index];
    return PopScope(
      canPop: _finishing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Leave quiz',
            onPressed: _confirmExit,
          ),
          title: Text(
            '${_remaining ~/ 60}:${(_remaining % 60).toString().padLeft(2, '0')} remaining',
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Question ${_session.index + 1} of ${widget.quizQuestions.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_session.index + 1) / widget.quizQuestions.length,
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: widget.language == 'en'
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        question.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      for (var i = 0; i < 4; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OutlinedButton(
                            onPressed: () => setState(() => _selected = i),
                            style: OutlinedButton.styleFrom(
                              alignment: AlignmentDirectional.centerStart,
                              padding: const EdgeInsets.all(20),
                              backgroundColor: _selected == i
                                  ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selected == i
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(question.options[i])),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _selected == null ? null : () => _next(),
                  child: Text(
                    _session.index == widget.quizQuestions.length - 1
                        ? 'Finish quiz'
                        : 'Next question',
                  ),
                ),
                TextButton(
                  onPressed: () => _next(skip: true),
                  child: const Text('Skip question'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
