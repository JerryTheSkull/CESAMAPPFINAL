import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/colors.dart';
import '../services/api_service_bourse_amci.dart';

class AdminExcelUploadPage extends StatefulWidget {
  const AdminExcelUploadPage({super.key});

  @override
  State<AdminExcelUploadPage> createState() => _AdminExcelUploadPageState();
}

class _AdminExcelUploadPageState extends State<AdminExcelUploadPage> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  final _amciService = AmciBourseService();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'], // ✅ ajuste selon ce que ton backend accepte
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!); // ✅ bien un File
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un fichier")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final result = await _amciService.importExcel(_selectedFile!); // ✅ correction appliquée
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success']
              ? "Fichier $_fileName uploadé avec succès !"
              : "Erreur: ${result['message']}"),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        setState(() {
          _selectedFile = null;
          _fileName = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        title: const Text('Envoyer fichier Excel bourse', style: TextStyle(color: Colors.black)),
        backgroundColor: CesamColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Sélection du fichier Excel"),
            const SizedBox(height: 12),
            _buildFileCard(),
            const SizedBox(height: 24),
            _buildSectionTitle("Envoi vers la base de données"),
            const SizedBox(height: 12),
            const Text(
              "Ce fichier doit contenir la liste des étudiants boursiers au format .xlsx. Il sera traité automatiquement côté serveur.",
              style: TextStyle(fontSize: 15, color: CesamColors.textSecondary),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _isUploading ? null : _uploadFile,
            icon: _isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.upload_file, color: Colors.white),
            label: const Text(
              'Uploader le fichier',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: CesamColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: CesamColors.textPrimary,
        ),
      );

  Widget _buildFileCard() => Card(
        color: CesamColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Icon(Icons.insert_drive_file, color: CesamColors.primary),
          title: Text(
            _fileName ?? 'Aucun fichier sélectionné',
            style: const TextStyle(color: CesamColors.textPrimary),
          ),
          trailing: TextButton(
            onPressed: _pickFile,
            style: TextButton.styleFrom(foregroundColor: CesamColors.primary),
            child: const Text('Parcourir'),
          ),
        ),
      );
}
