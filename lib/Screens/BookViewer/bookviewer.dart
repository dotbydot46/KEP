import 'package:flutter/material.dart';
import 'package:kep/Components/pdf_reader.dart';

class BookViewer extends StatelessWidget {
  final String bookPath;
  final String subject;
  const BookViewer({super.key, required this.bookPath, required this.subject});
  @override
  Widget build(BuildContext context) =>
      PDFReader(url: bookPath, name: subject, asset: true);
}
