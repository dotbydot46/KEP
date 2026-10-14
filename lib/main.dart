import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kep/Screens/SplashScreen/splash_screen.dart';
import 'package:kep/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(const Kankor());
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'KEP could not start. Check your connection and try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: main, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Kankor extends StatelessWidget {
  const Kankor({super.key, this.home});
  final Widget? home;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'KEP • Kankor preparation',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
    home: home ?? const SplashScreen(),
  );
}
