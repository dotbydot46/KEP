import 'package:flutter/material.dart';
import 'package:kep/Model/Student/student.dart';

class UpdatePage extends StatefulWidget {
  final Student student;
  const UpdatePage({super.key, required this.student});
  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _form = GlobalKey<FormState>();
  late final Student _draft;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _draft = Student()..load(widget.student.toMap());
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    _form.currentState!.save();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _draft.update();
      if (!mounted) return;
      widget.student.load(_draft.toMap());
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save your profile. Please retry.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(
    String label,
    String initial,
    void Function(String) save, {
    bool required = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      enabled: !_busy,
      initialValue: initial,
      decoration: InputDecoration(labelText: label),
      onSaved: (value) => save(value!.trim()),
      validator: (value) => required && (value == null || value.trim().isEmpty)
          ? 'Enter $label.'
          : null,
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your profile')),
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
                _field(
                  'First name',
                  _draft.firstName,
                  (v) => _draft.firstName = v,
                ),
                _field(
                  'Last name',
                  _draft.lastName,
                  (v) => _draft.lastName = v,
                ),
                _field('Province', _draft.province, (v) => _draft.province = v),
                _field(
                  'Favourite subject',
                  _draft.favoriteSubject,
                  (v) => _draft.favoriteSubject = v,
                  required: false,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_error!),
                  ),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Text(_busy ? 'Saving…' : 'Save profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
