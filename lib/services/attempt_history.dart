import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttemptHistory {
  static String? get _key {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null ? null : 'attempts.$uid';
  }

  static Future<List<Map<String, dynamic>>> load() async {
    final key = _key;
    if (key == null) return [];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? [];
    return raw
        .map((item) => Map<String, dynamic>.from(jsonDecode(item) as Map))
        .toList();
  }

  static Future<void> save({
    required int correct,
    required int wrong,
    required int total,
  }) async {
    final key = _key;
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getStringList(key) ?? [];
    attempts.insert(
      0,
      jsonEncode({
        'date': DateTime.now().toIso8601String(),
        'correct': correct,
        'wrong': wrong,
        'total': total,
      }),
    );
    final saved = await prefs.setStringList(key, attempts.take(100).toList());
    if (!saved) throw StateError('Could not save attempt');
  }
}
