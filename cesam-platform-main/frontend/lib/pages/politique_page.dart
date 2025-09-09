import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PolitiquePage extends StatelessWidget {
  const PolitiquePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Politique de Confidentialité")),
      body: SfPdfViewer.asset("assets/pdfs/politique.pdf"),
    );
  }
}
