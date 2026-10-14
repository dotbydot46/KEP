import 'package:flutter/material.dart';
import 'package:kep/Model/Student/student.dart';
import 'package:kep/Screens/LoginScreen/loading_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _form = GlobalKey<FormState>();
  final _student = Student();
  bool _busy = false;
  String? _error;
  Future<void> _register() async {
    if (_busy || !_form.currentState!.validate()) return;
    _form.currentState!.save();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await _student.register();
      if (!mounted) return;
      if (response == true) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => LoadingPage(email: _student.email.trim()),
          ),
          (_) => false,
        );
      } else {
        setState(() => _error = response.toString());
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not create your account. Check your connection and retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(
    String label,
    void Function(String) save, {
    bool optional = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      enabled: !_busy,
      decoration: InputDecoration(labelText: label),
      textInputAction: TextInputAction.next,
      onSaved: (value) => save(value?.trim() ?? ''),
      validator: (value) => !optional && (value == null || value.trim().isEmpty)
          ? 'Enter $label.'
          : null,
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Start your preparation',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                _field('First name', (value) => _student.firstName = value),
                _field('Last name', (value) => _student.lastName = value),
                _field('Province', (value) => _student.province = value),
                _field(
                  'Favourite subject (optional)',
                  (value) => _student.favoriteSubject = value,
                  optional: true,
                ),
                TextFormField(
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onSaved: (value) => _student.email = value!.trim(),
                  validator: (value) =>
                      value == null ||
                          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                              .hasMatch(value.trim())
                      ? 'Enter a valid email address.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: !_busy,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    helperText: 'Use at least 8 characters.',
                  ),
                  onSaved: (value) => _student.password = value!,
                  validator: (value) => value == null || value.length < 8
                      ? 'Use at least 8 characters.'
                      : null,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                FilledButton(
                  onPressed: _busy ? null : _register,
                  child: Text(_busy ? 'Creating account…' : 'Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
