import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kep/Model/Student/student.dart';
import 'package:kep/Screens/BooksScreen/book_screen.dart';
import 'package:kep/Screens/GuideScreen/guide_screen.dart';
import 'package:kep/Screens/LanguageScreen/language_page.dart';
import 'package:kep/Screens/LoginScreen/login_page.dart';
import 'package:kep/Screens/PastPapersScreen/past_paper_screen.dart';
import 'package:kep/Screens/ProfileScreen/profile_page.dart';
import 'package:kep/Screens/QuizScreen/quiz_splash_screen.dart';
import 'package:kep/Screens/SubjectScreen/subject_screen.dart';
import 'package:kep/services/attempt_history.dart';

class HomePage extends StatefulWidget {
  final Student student;
  final String language;
  const HomePage({super.key, required this.student, required this.language});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _history;
  @override
  void initState() {
    super.initState();
    _history = AttemptHistory.load();
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (mounted) setState(() => _history = AttemptHistory.load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('KEP'),
      actions: [
        IconButton(
          tooltip: 'Your profile',
          onPressed: () => _open(ProfilePage(student: widget.student)),
          icon: const Icon(Icons.person_outline),
        ),
      ],
    ),
    drawer: Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text(
                '${widget.student.firstName} ${widget.student.lastName}',
              ),
              subtitle: Text(widget.student.email),
              leading: const CircleAvatar(child: Icon(Icons.school)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('Question language'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => LanguagePage(student: widget.student),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Kankor guide'),
              onTap: () {
                Navigator.pop(context);
                _open(KankorGuide(language: widget.language));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                    (_) => false,
                  );
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not sign out. Please retry.'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${widget.student.firstName}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A little practice today. More confidence tomorrow.',
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () =>
                        _open(SubjectsScreen(language: widget.language)),
                    label: const Text('Start practising'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your preparation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _feature(
              Icons.quiz_outlined,
              'Subject practice',
              'Short quizzes across the Kankor subjects',
              () => _open(SubjectsScreen(language: widget.language)),
            ),
            _feature(
              Icons.timer_outlined,
              'Mock exam',
              '20 questions · 20 minutes',
              () => _open(
                QuizSplashScreen(
                  subject: 'all',
                  language: widget.language,
                  time: 1200,
                ),
              ),
            ),
            _feature(
              Icons.menu_book_outlined,
              'Study books',
              'Read subject materials and bundled books',
              () => _open(const BooksPage()),
            ),
            _feature(
              Icons.description_outlined,
              'Past papers',
              'Practise with previous exam papers',
              () => _open(const PastPaperPage()),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Saved on this device for your account.'),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _history,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Could not load result history.');
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  );
                }
                final attempts = snapshot.data!;
                if (attempts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Your first quiz result will appear here.'),
                  );
                }
                return Column(
                  children: attempts.take(10).map((attempt) {
                    final date = DateTime.parse(attempt['date'] as String)
                        .toLocal();
                    final total = attempt['total'] as int;
                    final correct = attempt['correct'] as int;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.insights),
                        title: Text('$correct / $total correct'),
                        subtitle: Text(
                          '${date.day}/${date.month}/${date.year}',
                        ),
                        trailing: Text(
                          '${total == 0 ? 0 : (correct / total * 100).round()}%',
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
  Widget _feature(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback tap,
  ) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: tap,
    ),
  );
}
