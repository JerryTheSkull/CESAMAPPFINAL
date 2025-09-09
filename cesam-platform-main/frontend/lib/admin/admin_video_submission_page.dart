import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service_video.dart'; // Import ton service API
import 'package:shared_preferences/shared_preferences.dart';

class AdminVideoSubmissionPage extends StatefulWidget {
  const AdminVideoSubmissionPage({super.key});

  @override
  State<AdminVideoSubmissionPage> createState() => _AdminVideoSubmissionPageState();
}

class _AdminVideoSubmissionPageState extends State<AdminVideoSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _title = '';
  String _videoUrl = '';
  String _description = '';
  String? _category;
  bool _isLive = false;
  bool _isLoading = false;
  String? _adminToken; // ✅ on remplace le token fixe

  final List<String> _categories = [
    'Chaîne TV étudiante'
  ];

  @override
  void initState() {
    super.initState();
    _initAuth(); // ✅ récupération du token au démarrage
  }

  // Récupérer le token d'auth depuis SharedPreferences
  Future<void> _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminToken = prefs.getString('auth_token'); // ✅ token stocké après login
    });
  }

  void _submitVideo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        if (_adminToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous devez être connecté en tant qu\'admin'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // ✅ Appel API avec token récupéré
        final result = await VideoApiService.createVideo(
          _adminToken!,
          titre: _title,
          description: _description.isNotEmpty ? _description : null,
          url: _videoUrl,
          theme: _category!,
          isLive: _isLive,
        );

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Vidéo '$_title' créée avec succès !"),
              backgroundColor: Colors.green,
            ),
          );

          // Reset formulaire
          _formKey.currentState!.reset();
          _titleController.clear();
          _urlController.clear();
          _descriptionController.clear();
          setState(() {
            _title = '';
            _videoUrl = '';
            _description = '';
            _category = null;
            _isLive = false;
          });
        } else {
          String errorMessage = result['message'] ?? 'Erreur lors de la création';

          if (result['errors'] != null) {
            Map<String, dynamic> errors = result['errors'];
            errorMessage += '\n' + errors.values.join('\n');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        title: const Text('Envoyer une vidéo', style: TextStyle(color: Colors.black)),
        backgroundColor: CesamColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la vidéo',
                  filled: true,
                  fillColor: CesamColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                onSaved: (val) => _title = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  filled: true,
                  fillColor: CesamColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                maxLines: 3,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la vidéo',
                  hintText: 'https://...',
                  filled: true,
                  fillColor: CesamColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Champ requis';
                  if (!VideoApiService.isValidVideoUrl(val)) {
                    return 'URL de vidéo non supportée';
                  }
                  return null;
                },
                onSaved: (val) => _videoUrl = val ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  filled: true,
                  fillColor: CesamColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                value: _category,
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                validator: (val) => val == null || val.isEmpty ? 'Veuillez choisir une catégorie' : null,
                onChanged: (val) => setState(() => _category = val),
                onSaved: (val) => _category = val,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Diffusion en direct (Live)'),
                subtitle: const Text('Activer si c\'est une diffusion en temps réel'),
                value: _isLive,
                onChanged: (value) => setState(() => _isLive = value),
                activeColor: CesamColors.primary,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitVideo,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                  label: Text(_isLoading ? 'Publication...' : 'Publier la vidéo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CesamColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Création de la vidéo en cours...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
