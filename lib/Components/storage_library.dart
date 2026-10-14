import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kep/Components/pdf_reader.dart';

class StorageLibrary extends StatefulWidget {
  final String path;
  final String title;
  const StorageLibrary({super.key, required this.path, required this.title});
  @override
  State<StorageLibrary> createState() => _StorageLibraryState();
}

class _StorageLibraryState extends State<StorageLibrary> {
  late Future<ListResult> _files;
  String? _opening;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _files = FirebaseStorage.instance.ref(widget.path).listAll();
  }

  Future<void> _open(Reference file) async {
    if (_opening != null) return;
    setState(() => _opening = file.fullPath);
    try {
      final url = await file.getDownloadURL();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => PDFReader(url: url, name: file.name),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open this file. Please retry.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = null);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: FutureBuilder<ListResult>(
      future: _files,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load the library.'),
                FilledButton(
                  onPressed: () => setState(_reload),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final files =
            snapshot.data!.items
                .where((file) => file.name.toLowerCase().endsWith('.pdf'))
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));
        if (files.isEmpty) {
          return const Center(child: Text('No PDF files available yet.'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: files
              .map(
                (file) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: Text(file.name),
                    trailing: _opening == file.fullPath
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _opening == null ? () => _open(file) : null,
                  ),
                ),
              )
              .toList(),
        );
      },
    ),
  );
}
