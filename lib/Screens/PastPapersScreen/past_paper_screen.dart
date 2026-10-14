import 'package:flutter/material.dart';
import 'package:kep/Components/storage_library.dart';

class PastPaperPage extends StatelessWidget {
  const PastPaperPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const StorageLibrary(path: 'papers', title: 'Past papers');
}
