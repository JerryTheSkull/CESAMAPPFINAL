import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../constants/colors.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;

  const PdfViewerPage({super.key, required this.url});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        title: const Text(
          "Lecture du PFE",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: CesamColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.url,
            key: _pdfViewerKey,
            onDocumentLoaded: (details) {
              setState(() => _isLoading = false);
            },
            onDocumentLoadFailed: (details) {
              setState(() {
                _isLoading = false;
                _errorMessage = "Impossible de charger le document.\n${details.description}";
              });
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
