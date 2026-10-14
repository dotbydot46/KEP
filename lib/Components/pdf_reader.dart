import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFReader extends StatefulWidget {
  final String url;
  final String name;
  final bool asset;
  const PDFReader({
    super.key,
    required this.url,
    required this.name,
    this.asset = false,
  });
  @override
  State<PDFReader> createState() => _PDFReaderState();
}

class _PDFReaderState extends State<PDFReader> {
  String? _error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.name)),
    body: _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() => _error = null),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        : widget.asset
        ? SfPdfViewer.asset(
            widget.url,
            onDocumentLoadFailed: (_) =>
                setState(() => _error = 'Could not open this book.'),
          )
        : SfPdfViewer.network(
            widget.url,
            onDocumentLoadFailed: (_) => setState(
              () => _error =
                  'Could not load this PDF. Check your connection and retry.',
            ),
          ),
  );
}
