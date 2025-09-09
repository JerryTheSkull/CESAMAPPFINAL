import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/api_service_pfe.dart';

class SubmitPfeFormPage extends StatefulWidget {
  const SubmitPfeFormPage({super.key});

  @override
  State<SubmitPfeFormPage> createState() => _SubmitPfeFormPageState();
}

class _SubmitPfeFormPageState extends State<SubmitPfeFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _type, _title, _author, _domain, _pdfPath;
  int? _year;
  bool _isLoading = false;
  File? _selectedFile;
  int _fileSize = 0;

  final List<String> _domains = [
    'Informatique & Numérique',
    'Génie & Technologies',
    'Sciences & Mathématiques',
    'Économie & Gestion',
    'Droit & Sciences politiques',
    'Médecine & Santé',
    'Arts & Lettres',
    'Enseignement & Pédagogie',
    'Agronomie & Environnement',
    'Tourisme & Hôtellerie',
    'Autres'
  ];

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final size = await file.length();
        
        // Vérifier la taille (10 MB max = 10 * 1024 * 1024 bytes)
        if (size > 10 * 1024 * 1024) {
          _showErrorSnackBar("Le fichier PDF doit faire moins de 10 MB");
          return;
        }
        
        setState(() {
          _pdfPath = result.files.single.path;
          _selectedFile = file;
          _fileSize = size;
        });
      }
    } catch (e) {
      _showErrorSnackBar("Erreur lors de la sélection du fichier: $e");
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_pdfPath == null) {
      _showErrorSnackBar("Veuillez sélectionner un fichier PDF");
      return;
    }

    setState(() => _isLoading = true);
    _formKey.currentState!.save();

    try {
      // ✅ Utiliser la nouvelle version améliorée qui retourne des détails
      final result = await ApiServicePfe.submitReport({
        "type": _type!,
        "title": _title!,
        "author_name": _author!,
        "defense_year": _year.toString(),
        "domain": _domain!,
        "pdf_path": _pdfPath!,
      });

      setState(() => _isLoading = false);

      if (result != null) {
        // ✅ Succès avec plus de détails
        _showSuccessDialog(result);
        _resetForm();
      } else {
        // ✅ Erreur avec message plus informatif
        _showErrorSnackBar("Erreur lors de la soumission. Vérifiez votre connexion et réessayez.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Erreur inattendue: $e");
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _type = null;
      _title = null;
      _author = null;
      _domain = null;
      _pdfPath = null;
      _year = null;
      _selectedFile = null;
      _fileSize = 0;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text("Rapport soumis avec succès !"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result['message'] ?? "Votre rapport a été soumis avec succès."),
            const SizedBox(height: 12),
            const Text(
              "Il sera examiné par un administrateur et vous serez notifié du résultat.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (result['report'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ID: ${result['report']['id']}"),
                    Text("Statut: ${result['report']['status']}"),
                    Text("Soumis le: ${result['report']['submitted_at']}"),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soumettre un PFE/PFA"),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ✅ En-tête informatif
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Soumettez votre rapport PFE ou PFA pour validation par un administrateur.",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Informations du rapport
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            "Informations du rapport",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Type de rapport *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: _type,
                        items: ["PFE", "PFA"]
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _type = val),
                        validator: (val) => val == null ? "Veuillez choisir un type" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Titre du rapport *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                          helperText: "Maximum 500 caractères",
                        ),
                        maxLength: 500,
                        maxLines: 2,
                        onSaved: (val) => _title = val,
                        validator: (val) {
                          if (val?.isEmpty == true) return "Titre requis";
                          if (val!.length < 5) return "Le titre doit faire au moins 5 caractères";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Nom de l'auteur *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          helperText: "Nom complet de l'auteur du rapport",
                        ),
                        maxLength: 255,
                        onSaved: (val) => _author = val,
                        validator: (val) {
                          if (val?.isEmpty == true) return "Nom de l'auteur requis";
                          if (val!.length < 2) return "Le nom doit faire au moins 2 caractères";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Année de soutenance *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                          helperText: "Ex: 2024",
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (val) => _year = int.tryParse(val ?? ''),
                        validator: (val) {
                          if (val?.isEmpty == true) return "Année requise";
                          final year = int.tryParse(val!);
                          if (year == null || year < 2000 || year > 2100) {
                            return "Année invalide (2000-2100)";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Domaine d'étude *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                        value: _domain,
                        items: _domains
                            .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14))))
                            .toList(),
                        onChanged: (val) => setState(() => _domain = val),
                        validator: (val) => val == null ? "Veuillez choisir un domaine" : null,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Fichier PDF
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            "Fichier PDF",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // ✅ Bouton de sélection amélioré
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickPdf,
                          icon: Icon(_pdfPath == null ? Icons.upload_file : Icons.check_circle),
                          label: Text(_pdfPath == null 
                              ? "Choisir un fichier PDF *" 
                              : "PDF sélectionné ✓"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pdfPath == null ? null : Colors.green,
                            foregroundColor: _pdfPath == null ? null : Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      
                      if (_pdfPath != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.description, color: Colors.green.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _pdfPath!.split('/').last,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => setState(() {
                                      _pdfPath = null;
                                      _selectedFile = null;
                                      _fileSize = 0;
                                    }),
                                    tooltip: "Supprimer le fichier",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Taille: ${_formatFileSize(_fileSize)}",
                                style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Text(
                          "• Format accepté: PDF uniquement\n• Taille maximum: 10 MB\n• Assurez-vous que le document est lisible",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ✅ Bouton de soumission amélioré
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text("Soumission en cours..."),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send),
                            SizedBox(width: 8),
                            Text(
                              "Soumettre le rapport",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // ✅ Note informative
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Votre rapport sera examiné par un administrateur avant d'être publié. Vous recevrez une notification du résultat.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}