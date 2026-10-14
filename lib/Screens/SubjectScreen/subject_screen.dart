import 'package:flutter/material.dart';
import 'package:kep/Screens/QuizScreen/quiz_splash_screen.dart';

class SubjectsScreen extends StatelessWidget {
  final String language;
  const SubjectsScreen({super.key, required this.language});
  static const subjects = [
    'Maths',
    'Physics',
    'Chemistry',
    'Biology',
    'Geography',
    'General Knowledge',
    'Geology',
    'History',
    'IslamicStudies',
    'Pashto',
    'Dari',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Subject practice')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Up to 5 questions · 5 minutes per quiz'),
            ),
            for (final subject in subjects)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.auto_stories_outlined),
                  title: Text(
                    subject == 'IslamicStudies' ? 'Islamic studies' : subject,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => QuizSplashScreen(
                        subject: subject,
                        language: language,
                        time: 300,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
