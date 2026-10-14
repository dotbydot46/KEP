import 'package:flutter/material.dart';
import 'package:kep/Model/Student/student.dart';
import 'package:kep/Screens/HomeScreen/home_page.dart';

class LanguagePage extends StatelessWidget {
  final Student student;
  const LanguagePage({super.key, required this.student});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.translate, size: 56),
              const SizedBox(height: 24),
              Text(
                'Choose your question language',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'You can change this from the home menu.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              for (final language in {
                'en': 'English',
                'fa': 'Dari / فارسی',
                'ps': 'Pashto / پښتو',
              }.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            HomePage(student: student, language: language.key),
                      ),
                    ),
                    child: Text(language.value),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
