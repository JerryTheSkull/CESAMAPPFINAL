import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../constants/colors.dart';
import '../components/cesam_app_bar.dart';
import '../models/cesam_user.dart';
import '../models/project.dart';
import '../providers/user_profile_provider.dart';

class ProfileAcadPage extends StatefulWidget {
  final CesamUser? initialUser;
  final bool showSkillsSectionOnly;

  const ProfileAcadPage({
    super.key,
    this.initialUser,
    this.showSkillsSectionOnly = false,
  });

  @override
  State<ProfileAcadPage> createState() => _ProfileAcadPageState();
}

class _ProfileAcadPageState extends State<ProfileAcadPage> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedCVFileName;

  @override
  void initState() {
    super.initState();
    // Initialiser le provider si pas encore fait
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().initialize();
    });
  }

  // Gestion photo de profil
  Future<void> _showPhotoOptions(UserProfileProvider provider) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, provider);
              },
            ),
            if (provider.user?.photoPath != null && provider.user!.photoPath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Supprimer la photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfilePhoto(provider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, UserProfileProvider provider) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final success = await provider.uploadProfilePhoto(File(image.path));
        if (success) {
          _showSnackBar('Photo de profil mise à jour', Colors.green);
        } else {
          _showSnackBar(provider.error ?? 'Erreur lors de l\'upload', Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection de l\'image: $e', Colors.red);
    }
  }

  Future<void> _deleteProfilePhoto(UserProfileProvider provider) async {
    final success = await provider.deleteProfilePhoto();
    if (success) {
      _showSnackBar('Photo de profil supprimée', Colors.green);
    } else {
      _showSnackBar(provider.error ?? 'Erreur lors de la suppression', Colors.red);
    }
  }

  // Gestion des informations académiques
  Future<void> _editSchool(UserProfileProvider provider) async {
    final controller = TextEditingController(text: provider.user?.school ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'école'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'École/Université',
            hintText: 'Ex: Université Mohammed V',
          ),
          maxLines: 2,
          inputFormatters: [LengthLimitingTextInputFormatter(200)],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final success = await provider.updateAcademicInfo(ecole: result);
      if (success) {
        _showSnackBar('École mise à jour', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de la mise à jour', Colors.red);
      }
    }
  }

  Future<void> _editStudyField(UserProfileProvider provider) async {
    final controller = TextEditingController(text: provider.user?.studyField ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la filière'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Filière d\'étude',
            hintText: 'Ex: Informatique, Génie Civil...',
          ),
          maxLines: 2,
          inputFormatters: [LengthLimitingTextInputFormatter(200)],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final success = await provider.updateAcademicInfo(filiere: result);
      if (success) {
        _showSnackBar('Filière mise à jour', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de la mise à jour', Colors.red);
      }
    }
  }

  Future<void> _editAcademicLevel(UserProfileProvider provider) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le niveau académique'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: provider.academicLevels.contains(provider.user?.academicLevel) 
                    ? provider.user?.academicLevel 
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Niveau académique',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: provider.academicLevels
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) => Navigator.pop(context, value),
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.academicLevels.length} niveaux disponibles',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (result != null) {
      final success = await provider.updateAcademicInfo(niveauEtude: result);
      if (success) {
        _showSnackBar('Niveau académique mis à jour', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de la mise à jour', Colors.red);
      }
    }
  }

  // Gestion des compétences
  Future<void> _addSkill(UserProfileProvider provider) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une compétence'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nouvelle compétence',
            hintText: 'Ex: Java, Leadership, Photoshop...',
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final success = await provider.addSkill(result.trim());
      if (success) {
        _showSnackBar('Compétence ajoutée', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de l\'ajout', Colors.red);
      }
    }
  }

  Future<void> _removeSkill(String skill, UserProfileProvider provider) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la compétence'),
        content: Text('Êtes-vous sûr de vouloir supprimer "$skill" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      final success = await provider.removeSkill(skill);
      if (success) {
        _showSnackBar('Compétence supprimée', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de la suppression', Colors.red);
      }
    }
  }

  // Gestion des projets - VERSION MISE À JOUR POUR JSON
  Future<void> _addProject(UserProfileProvider provider) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final linkController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un projet'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du projet*',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Application mobile de gestion',
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                  hintText: 'Décrivez votre projet en quelques mots...',
                ),
                maxLines: 3,
                inputFormatters: [LengthLimitingTextInputFormatter(1000)],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Lien (optionnel)',
                  border: OutlineInputBorder(),
                  hintText: 'https://github.com/username/projet',
                ),
                keyboardType: TextInputType.url,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  descController.text.trim().isEmpty) {
                _showSnackBar('Le titre et la description sont requis', Colors.red);
                return;
              }
              Navigator.pop(context, {
                'title': titleController.text.trim(),
                'description': descController.text.trim(),
                'link': linkController.text.trim(),
              });
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result != null) {
      final success = await provider.addProject(
        title: result['title']!,
        description: result['description']!,
        link: result['link']!.isEmpty ? null : result['link'],
      );
      if (success) {
        _showSnackBar('Projet ajouté', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de l\'ajout', Colors.red);
      }
    }
  }

  // NOUVEAU: Éditer un projet existant
  Future<void> _editProject(Project project, UserProfileProvider provider) async {
    final titleController = TextEditingController(text: project.title);
    final descController = TextEditingController(text: project.description);
    final linkController = TextEditingController(text: project.link ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le projet'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du projet*',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                inputFormatters: [LengthLimitingTextInputFormatter(1000)],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Lien (optionnel)',
                  border: OutlineInputBorder(),
                  hintText: 'https://github.com/username/projet',
                ),
                keyboardType: TextInputType.url,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  descController.text.trim().isEmpty) {
                _showSnackBar('Le titre et la description sont requis', Colors.red);
                return;
              }
              Navigator.pop(context, {
                'title': titleController.text.trim(),
                'description': descController.text.trim(),
                'link': linkController.text.trim(),
              });
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );

    if (result != null) {
      final success = await provider.updateProject(
        projectId: project.id!, // Utilise l'UUID du projet
        title: result['title']!,
        description: result['description']!,
        link: result['link']!.isEmpty ? null : result['link'],
      );
      if (success) {
        _showSnackBar('Projet modifié', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de la modification', Colors.red);
      }
    }
  }

  Future<void> _removeProject(Project project, UserProfileProvider provider) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${project.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      if (project.id == null || project.id!.isEmpty) {
        _showSnackBar('Erreur : L\'identifiant du projet est manquant', Colors.red);
        return;
      }
      
      final success = await provider.removeProject(project.id!);
      if (success) {
        _showSnackBar('Projet supprimé', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de la suppression', Colors.red);
      }
    }
  }

  // Gestion du CV
  Future<void> _pickCV(UserProfileProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.first.path != null) {
        setState(() {
          _selectedCVFileName = result.files.first.name;
        });
        
        final success = await provider.uploadCV(File(result.files.first.path!));
        if (success) {
          _showSnackBar('CV téléchargé avec succès', Colors.green);
        } else {
          _showSnackBar(provider.error ?? 'Erreur lors du téléchargement', Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    }
  }

  Future<void> _viewCV(UserProfileProvider provider) async {
    if (provider.user?.cvUrl != null) {
      try {
        final uri = Uri.parse(provider.user!.cvUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Impossible d\'ouvrir le CV');
        }
      } catch (e) {
        _showSnackBar('Erreur: $e', Colors.red);
      }
    }
  }

  Future<void> _openLink(String url) async {
    try {
      Uri uri;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        uri = Uri.parse('https://$url');
      } else {
        uri = Uri.parse(url);
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Impossible d\'ouvrir le lien');
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: const CesamAppBar(title: ''),
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
      ),
    );
  }

  Widget _buildBody(UserProfileProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: CesamColors.primary),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadProfile(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (!provider.hasUser) {
      return const Center(child: Text('Aucune donnée utilisateur disponible'));
    }

    final user = provider.user!;

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Avatar et nom
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: [
                            CesamColors.primary,
                            CesamColors.accent,
                            CesamColors.primary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CesamColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: (user.photoPath != null && user.photoPath!.isNotEmpty)
                            ? NetworkImage(user.photoUrlWithTimestamp!) as ImageProvider
                            : null,
                        child: (user.photoPath == null || user.photoPath!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showPhotoOptions(provider),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: CesamColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CesamColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user.email,
                  style: const TextStyle(fontSize: 14, color: Colors.black45),
                ),
              ),
              const SizedBox(height: 32),

              // Section Informations académiques
              if (!widget.showSkillsSectionOnly)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CesamColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations académiques',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CesamColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _editableInfoRow(
                        Icons.school,
                        'École/Université',
                        user.school ?? 'Non renseignée',
                        () => _editSchool(provider),
                      ),
                      _editableInfoRow(
                        Icons.category,
                        'Filière',
                        user.studyField ?? 'Non renseignée',
                        () => _editStudyField(provider),
                      ),
                      _editableInfoRow(
                        Icons.school_outlined,
                        'Niveau académique',
                        user.academicLevel ?? 'Non renseigné',
                        () => _editAcademicLevel(provider),
                      ),
                    ],
                  ),
                ),

              if (!widget.showSkillsSectionOnly) const SizedBox(height: 24),

              // Section Compétences
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CesamColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Compétences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CesamColors.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _addSkill(provider),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: CesamColors.primary,
                          ),
                          tooltip: 'Ajouter une compétence',
                        ),
                      ],
                    ),
                    if (user.hasSkills) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.skills!
                            .map((skill) => Chip(
                                  label: Text(skill),
                                  backgroundColor: CesamColors.primary.withOpacity(0.1),
                                  labelStyle: const TextStyle(
                                    color: CesamColors.primary,
                                  ),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  onDeleted: () => _removeSkill(skill, provider),
                                ))
                            .toList(),
                      ),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Aucune compétence renseignée',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Projets - MISE À JOUR POUR JSON
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CesamColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Projets réalisés',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CesamColors.primary,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (user.hasProjects)
                              Text(
                                '${user.projects!.length}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CesamColors.primary.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            IconButton(
                              onPressed: () => _addProject(provider),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: CesamColors.primary,
                              ),
                              tooltip: 'Ajouter un projet',
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (user.hasProjects) ...[
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: user.projects!
                            .map((project) => Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: CesamColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: CesamColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              project.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: CesamColors.primary,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              switch (value) {
                                                case 'edit':
                                                  _editProject(project, provider);
                                                  break;
                                                case 'delete':
                                                  _removeProject(project, provider);
                                                  break;
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 16),
                                                    SizedBox(width: 8),
                                                    Text('Modifier'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, size: 16, color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            child: Icon(
                                              Icons.more_vert,
                                              color: CesamColors.primary.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        project.description,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (project.link != null && project.link!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => _openLink(project.link!),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: CesamColors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.link,
                                                  size: 16,
                                                  color: CesamColors.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    project.link!,
                                                    style: const TextStyle(
                                                      color: CesamColors.primary,
                                                      fontSize: 12,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (project.createdAt != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Créé le ${_formatDate(project.createdAt!)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Aucun projet renseigné',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section CV
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CesamColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Curriculum Vitae',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CesamColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          user.hasCV == true
                              ? Icons.picture_as_pdf
                              : Icons.picture_as_pdf_outlined,
                          color: user.hasCV == true ? CesamColors.primary : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.hasCV == true ? "CV fourni" : "Aucun CV fourni",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: user.hasCV == true ? Colors.black87 : Colors.grey,
                                ),
                              ),
                              if (_selectedCVFileName != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _selectedCVFileName!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (user.hasCV == true && user.cvUrl != null)
                              IconButton(
                                onPressed: () => _viewCV(provider),
                                icon: const Icon(
                                  Icons.visibility,
                                  color: CesamColors.primary,
                                ),
                                tooltip: 'Voir le CV',
                              ),
                            IconButton(
                              onPressed: () => _pickCV(provider),
                              icon: const Icon(
                                Icons.upload_file,
                                color: CesamColors.primary,
                              ),
                              tooltip: user.hasCV == true ? 'Remplacer le CV' : 'Télécharger un CV',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Helper pour formater les dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Widgets utilitaires
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: CesamColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableInfoRow(IconData icon, String label, String value, VoidCallback onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: CesamColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: CesamColors.primary, size: 18),
            tooltip: 'Modifier',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}