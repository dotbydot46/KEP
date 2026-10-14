import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kep/Model/Student/student.dart';
import 'package:kep/Screens/LanguageScreen/language_page.dart';
import 'package:kep/Screens/LoginScreen/login_page.dart';
import 'package:kep/Screens/UpdateScreen/update_page.dart';

class LoadingPage extends StatefulWidget {
  final String email;
  const LoadingPage({super.key, required this.email});
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final student = Student()..email = widget.email;
      var data = await student.getStudentData(widget.email);
      if (!mounted) return;
      if (data.isEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => UpdatePage(student: student)),
        );
        if (!mounted) return;
        data = await student.getStudentData(widget.email);
        if (!mounted) return;
        if (data.isEmpty) {
          setState(() => _error = 'Complete your profile to continue.');
          return;
        }
      }
      student.load(data.first);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => LanguagePage(student: student)),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not load your profile. Check your connection and retry.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error == null) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Loading your profile…'),
            ] else ...[
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Retry')),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                    (_) => false,
                  );
                },
                child: const Text('Back to sign in'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
