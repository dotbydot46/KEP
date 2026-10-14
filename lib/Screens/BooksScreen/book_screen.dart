import 'package:flutter/material.dart';
import 'package:kep/Components/pdf_reader.dart';
import 'package:kep/Components/storage_library.dart';

class BooksPage extends StatelessWidget {
  const BooksPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Study books')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Bundled books • available offline'),
        ),
        for (final book in {
          'Grade 10 • Biology': 'assets/pdf/G10_Biology.pdf',
          'Grade 11 • Maths': 'assets/pdf/G11_Maths.pdf',
          'Grade 12 • Chemistry': 'assets/pdf/G12_Chemestry.pdf',
        }.entries)
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(book.key),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PDFReader(url: book.value, name: book.key, asset: true),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Online library'),
            subtitle: const Text('Additional books from KEP'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    const StorageLibrary(path: 'books', title: 'Online books'),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
