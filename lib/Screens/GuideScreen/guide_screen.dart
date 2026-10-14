import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class KankorGuide extends StatefulWidget {
  final String language;
  const KankorGuide({super.key, required this.language});
  @override
  State<KankorGuide> createState() => _KankorGuideState();
}

class _KankorGuideState extends State<KankorGuide> {
  static const _english =
      'Prepare a little every day.\n\n'
      'Start with a subject quiz, review the answers, and return to the topics you found difficult. '
      'Use the bundled books for offline study and the online library for more materials.\n\n'
      'When you are ready, try a timed mock exam. KEP practice scores are for learning; '
      'they do not predict official admission outcomes.\n\n'
      'For exam dates, eligibility, registration and the current syllabus, consult the official exam authority.';
  String _guide = _english;
  bool _loading = false;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    if (widget.language != 'en') _translate();
  }

  Future<void> _translate() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final result = await GoogleTranslator()
          .translate(_english, from: 'en', to: widget.language)
          .timeout(const Duration(seconds: 15));
      if (mounted) setState(() => _guide = result.text);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Study guide')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (_loading) const LinearProgressIndicator(),
        if (_failed) ...[
          const Text('Translation is unavailable. Showing the English guide.'),
          TextButton(
            onPressed: _translate,
            child: const Text('Retry translation'),
          ),
        ],
        const SizedBox(height: 16),
        Directionality(
          textDirection: _guide == _english
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Text(_guide, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    ),
  );
}
