# KEP — Kankor Exam Preparation

A Flutter app for students preparing for Afghanistan's Kankor entrance exam.
This repository contains the mobile app. Its current backend is Firebase
Authentication, Cloud Firestore and Cloud Storage; there is no Django server
or admin dashboard in this repository.

## What's in version 2

- Material 3 screens with responsive, scrollable forms and accessible controls.
- Email sign-in, account creation, password reset and editable profiles.
- Authentication-based session restoration rather than a saved email flag.
- Student profiles keyed by Firebase Auth UID, with non-destructive legacy migration.
- Subject quizzes and timed mock exams with skip, expiry and answer review.
- Stable answer indices across translations, plus reviewed translations in Firestore.
- Actual result history for the signed-in account, stored on the current device
  (up to 100 attempts; it is not synced between devices).
- Offline bundled Biology, Maths and Chemistry books; online books and past papers.
- Retry and empty states for profile, quiz, library and PDF loading.
- Updated Android Gradle setup, iOS scene lifecycle, regression tests and CI.

## Development

Validated toolchain: Flutter **3.47.7**, Dart **3.13.5**.
The version is also recorded in `.fvmrc`. Use Java 17 and a current Android SDK.
Android supports API 24+; iOS targets iOS 15+ and requires macOS/Xcode to build.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

`pubspec.lock` is committed for reproducible application builds. Dependency
constraints were resolved against the pinned SDK. Newer transitive versions
may be constrained by Flutter or other packages; do not force overrides.

## Firebase setup and migration

The existing Android Firebase configuration and `com.example.fyp` application
ID are retained so this upgrade can use the existing app identity.
Firebase must have email/password authentication enabled, a `questions`
collection, and optional `books/` and `papers/` Cloud Storage directories.

The old app used the email prefix as a student document ID. Version 2 writes
`Students/{authUid}`. On sign-in it first reads the UID profile, then queries
legacy profiles by the **full authenticated email**, copies the matching profile
to the UID, and leaves the old document in place. A profile previously overwritten
by another account cannot be reconstructed by the app; the student is prompted
to complete a missing profile. New registrations do not collect identity numbers.
Existing profile fields are retained during migration.

`firestore.rules` and `storage.rules` are proposed rules, not deployed changes.
Review them with the existing content administration system before deploying:
student clients cannot edit question banks or upload library content; trusted
server/Admin SDK operations manage that content. Test the migration and rules
against a staging Firebase project before rolling out to existing users.

```sh
firebase deploy --only firestore:rules,storage --project YOUR_PROJECT_ID
```

There is **no iOS Firebase configuration** in the original repository. Before
running on iOS, register the existing iOS bundle ID `com.example.fyp` in the
intended Firebase project, download `GoogleService-Info.plist`, and add it to
the Runner target in Xcode. Do not reuse the Android app ID for iOS. The unsigned
iOS simulator CI build checks compilation; it does not confirm Firebase setup
or device behaviour. Web and desktop platforms are not configured here.

## Question format

Each `questions/{id}` document contains non-empty string fields:

```json
{
  "title": "2 + 2?",
  "option1": "3",
  "option2": "4",
  "option3": "5",
  "option4": "6",
  "answer": "4",
  "subject": "Maths",
  "translations": {
    "fa": {"title": "۲ + ۲؟", "option1": "۳", "option2": "۴", "option3": "۵", "option4": "۶"}
  }
}
```

Subjects: Maths, Physics, Chemistry, Biology, Geography, General Knowledge,
Geology, History, IslamicStudies, Pashto, Dari. Mathematics and Islamic Studies
are accepted aliases. `answer` must exactly match an original option.
Malformed questions are skipped. A subject quiz uses up to five valid questions;
a mock exam uses up to twenty. An empty bank shows an informative retry screen.

Reviewed `translations.fa` and `translations.ps` are preferred. If absent,
non-English quizzes use the translator package with a timeout; this depends on
an external service and automated translations need educational review.
English quizzes make no translation requests. Scoring uses the original correct
option index even when translated option text collides. Bundled books are offline;
authentication, quiz loading and the online library need connectivity.

## Release builds

For Android, copy `android/key.properties.example` to the ignored
`android/key.properties` and supply the correct existing upload keystore.
Then run `flutter build appbundle`. Without signing configuration, release
builds are unsigned; they are never silently signed with a debug key. Keep
keystores and passwords outside Git. Existing published apps must keep the
original application ID and compatible signing key.

For iOS, configure Firebase as above, choose the correct Apple development
team and signing settings, and build with Xcode on macOS. App store publication
and live Firebase rule deployment are separate release steps.

The PDF reader retains Syncfusion from the original app. Ensure your use is
covered by its commercial or Community licence before distributing the app.

## Verification

Tests cover email-prefix collisions, legacy profile migration, failed profile
writes, empty and malformed question banks, translated scoring, skipped answers,
timer expiry during the exit dialog, answer review and narrow/large-text layouts.
GitHub Actions runs formatting, analysis, tests, Android debug APK compilation,
and unsigned iOS simulator compilation. Firebase mocks do not replace staging
tests of real authentication, Firestore rules, Storage access and account migration.
