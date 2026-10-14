import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kep/Screens/LoginScreen/loading_page.dart';
import 'package:kep/Screens/LoginScreen/login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => FutureBuilder<User?>(
    future: FirebaseAuth.instance.authStateChanges().first,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final user = snapshot.data;
      return user?.email == null
          ? const LoginPage()
          : LoadingPage(email: user!.email!);
    },
  );
}
