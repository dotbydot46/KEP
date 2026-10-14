import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kep/Model/Student/student.dart';

void main() {
  test(
    'registration uses the auth UID and never overwrites email-prefix profiles',
    () async {
      final db = FakeFirebaseFirestore();
      await db.collection('Students').doc('ali').set({
        'email': 'ali@yahoo.com',
        'firstName': 'Existing',
      });
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'new-uid', email: 'ali@gmail.com'),
      );
      final student = Student(auth: auth, firestore: db)
        ..email = 'ali@gmail.com'
        ..password = 'strong-password'
        ..firstName = 'New';
      expect(await student.register(), true);
      final newDoc = await db
          .collection('Students')
          .doc(auth.currentUser!.uid)
          .get();
      expect(newDoc.data()!['email'], 'ali@gmail.com');
      expect(
        (await db.collection('Students').doc('ali').get()).data()!['firstName'],
        'Existing',
      );
      expect(student.password, isEmpty);
    },
  );
  test(
    'legacy profile is copied only for the exact authenticated email',
    () async {
      final db = FakeFirebaseFirestore();
      await db.collection('Students').doc('ali').set({
        'email': 'ali@gmail.com',
        'firstName': 'Ali',
      });
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-ali', email: 'ali@gmail.com'),
      );
      final student = Student(auth: auth, firestore: db);
      expect(
        (await student.getStudentData('ali@gmail.com')).single['firstName'],
        'Ali',
      );
      expect(
        (await db.collection('Students').doc('uid-ali').get()).exists,
        true,
      );
      expect((await db.collection('Students').doc('ali').get()).exists, true);
    },
  );
  test(
    'same email prefix from another domain cannot inherit the legacy profile',
    () async {
      final db = FakeFirebaseFirestore();
      await db.collection('Students').doc('ali').set({
        'email': 'ali@yahoo.com',
        'firstName': 'Other',
      });
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-ali', email: 'ali@gmail.com'),
      );
      final student = Student(auth: auth, firestore: db);
      expect(await student.getStudentData('ali@gmail.com'), isEmpty);
      expect(
        (await db.collection('Students').doc('uid-ali').get()).exists,
        false,
      );
    },
  );
  test('signed-out and mismatched user reads are rejected', () async {
    final db = FakeFirebaseFirestore();
    final signedOut = Student(auth: MockFirebaseAuth(), firestore: db);
    expect(signedOut.getStudentData('ali@gmail.com'), throwsStateError);
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u', email: 'ali@gmail.com'),
    );
    expect(
      Student(auth: auth, firestore: db).getStudentData('other@gmail.com'),
      throwsStateError,
    );
  });
  test(
    'failed database writes roll back registration and do not report success',
    () async {
      final db = FakeFirebaseFirestore(
        securityRules: '''
      service cloud.firestore {
        match /databases/{database}/documents { match /{document=**} { allow write: if false; } }
      }
    ''',
      );
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'u', email: 'ali@gmail.com'),
      );
      final student = Student(auth: auth, firestore: db)
        ..email = 'ali@gmail.com'
        ..password = 'strong-password';
      expect(await student.register(), isNot(true));
      expect(auth.currentUser, isNull);
    },
  );
  test('updates use authenticated UID and auth email', () async {
    final db = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u', email: 'ali@gmail.com'),
    );
    final student = Student(auth: auth, firestore: db)
      ..email = 'spoofed@gmail.com'
      ..firstName = 'Updated';
    await student.update();
    final data = (await db.collection('Students').doc('u').get()).data()!;
    expect(data['email'], 'ali@gmail.com');
    expect(data['firstName'], 'Updated');
  });
}
