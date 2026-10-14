import 'package:flutter/material.dart';
import 'package:kep/Model/Student/student.dart';
import 'package:kep/Screens/UpdateScreen/update_page.dart';
import 'package:kep/Screens/ResetPasswordScreen/reset_password_page.dart';

class ProfilePage extends StatefulWidget {
  final Student student;
  const ProfilePage({super.key, required this.student});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your profile')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 48)),
        const SizedBox(height: 24),
        Text(
          '${widget.student.firstName} ${widget.student.lastName}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        ListTile(
          title: const Text('Email'),
          subtitle: Text(widget.student.email),
        ),
        ListTile(
          title: const Text('Province'),
          subtitle: Text(widget.student.province),
        ),
        ListTile(
          title: const Text('Favourite subject'),
          subtitle: Text(
            widget.student.favoriteSubject.isEmpty
                ? 'Not selected'
                : widget.student.favoriteSubject,
          ),
        ),
        FilledButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => UpdatePage(student: widget.student),
              ),
            );
            if (mounted) setState(() {});
          },
          child: const Text('Edit profile'),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const ResetPasswordPage()),
          ),
          child: const Text('Reset password'),
        ),
      ],
    ),
  );
}
