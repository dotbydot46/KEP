import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Student {
  Student({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _authOverride = auth,
      _firestoreOverride = firestore;
  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String profilePic = '1';
  String favoriteSubject = '';
  String province = '';
  String tazkiraNumber = '';

  Map<String, dynamic> toMap() => {
    'email': email.trim(),
    'firstName': firstName.trim(),
    'lastName': lastName.trim(),
    'favoriteSubject': favoriteSubject.trim(),
    'province': province.trim(),
    'profilePic': profilePic,
    'tazkiraNumber': tazkiraNumber.trim(),
  };

  void load(Map<String, dynamic> data) {
    firstName = data['firstName'] as String? ?? '';
    lastName = data['lastName'] as String? ?? '';
    email = data['email'] as String? ?? '';
    favoriteSubject = data['favoriteSubject'] as String? ?? '';
    province = data['province'] as String? ?? '';
    profilePic = data['profilePic'] as String? ?? '1';
    tazkiraNumber = data['tazkiraNumber'] as String? ?? '';
  }

  Future<dynamic> register() async {
    User? createdUser;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      createdUser = credential.user!;
      await _firestore.collection('Students').doc(createdUser.uid).set(toMap());
      password = '';
      return true;
    } catch (error) {
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {
          // If rollback fails, profile setup can be retried after sign-in.
        }
        await _auth.signOut();
      }
      return error is FirebaseException
          ? error.message ?? 'Unable to create your account. Please try again.'
          : 'Unable to save your profile. Please try again.';
    }
  }

  Future<List<Map<String, dynamic>>> getStudentData(String stuEmail) async {
    final user = _auth.currentUser;
    if (user == null || user.email?.toLowerCase() != stuEmail.toLowerCase()) {
      throw StateError('Please sign in again.');
    }
    final students = _firestore.collection('Students');
    final current = await students.doc(user.uid).get();
    if (current.exists) return [current.data()!];
    // Match the full email before copying a legacy profile to a unique UID.
    // Keep the original document for rollback; never overwrite another profile.
    final legacy = await students
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (legacy.docs.isEmpty) return [];
    final data = legacy.docs.first.data();
    await students.doc(user.uid).set(data);
    return [data];
  }

  Future<void> update() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Please sign in again.');
    email = user.email ?? email;
    await _firestore
        .collection('Students')
        .doc(user.uid)
        .set(toMap(), SetOptions(merge: true));
  }

  Future<dynamic> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (error) {
      return error.message ?? 'Unable to sign in. Please try again.';
    }
  }
}
