import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:convert'; // Added for jsonEncode
import '../../../models/project.dart';
import '../../../models/registration_data.dart';
import '../../../constants/colors.dart';
import '../../../components/auth_scaffold.dart';
import '../../app_routes.dart';
import '../../../services/api_service.dart';
import 'dart:async';

class Step3UploadCV extends StatefulWidget {
  final RegistrationData data;

  const Step3UploadCV({super.key, required this.data});

  @override
  State<Step3UploadCV> createState() => _Step3UploadCVState();
}

class _Step3UploadCVState extends State<Step3UploadCV> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedCvFile;
  String? _cvFileName;
  final List<String> _skills = [];
  final List<Project> _projects = [];
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _projectDescController = TextEditingController();
  final TextEditingController _projectLinkController = TextEditingController();
  int? _editingSkillIndex;
  int? _editingProjectIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize existing skills
    if (widget.data.skills.isNotEmpty) {
      _skills.addAll(widget.data.skillsList ?? []);
    }
    // Initialize existing projects
    if (widget.data.projects.isNotEmpty) {
      _projects.addAll(widget.data.projects);
    }
    print('📄 Step3 - Données reçues:');
    widget.data.printDebug();
  }

  Future<void> _selectCvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        // Check file size (5MB max)
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        if (fileSizeInMB > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Le fichier doit faire moins de 5 MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() {
          _selectedCvFile = file;
          _cvFileName = fileName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CV sélectionné: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection du fichier: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeCvFile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer le CV sélectionné ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCvFile = null;
                _cvFileName = null;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("CV supprimé avec succès."),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _addOrUpdateSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty) {
      // Validate skill length (max 100 characters)
      if (skill.length > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La compétence ne peut pas dépasser 100 caractères'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        if (_editingSkillIndex != null) {
          _skills[_editingSkillIndex!] = skill;
          _editingSkillIndex = null;
        } else {
          _skills.add(skill);
        }
        _skillController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une compétence valide'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editSkill(int index) {
    setState(() {
      _skillController.text = _skills[index];
      _editingSkillIndex = index;
    });
  }

  void _deleteSkill(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette compétence ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _skills.removeAt(index);
                if (_editingSkillIndex == index) {
                  _skillController.clear();
                  _editingSkillIndex = null;
                }
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _addOrUpdateProject() {
    final title = _projectTitleController.text.trim();
    final desc = _projectDescController.text.trim();
    final link = _projectLinkController.text.trim();

    // Validate project fields only when adding/updating a project
    final titleError = Project.validateTitle(title);
    final descError = Project.validateDescription(desc);
    final linkError = Project.validateLink(link);

    if (titleError != null || descError != null || linkError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            [titleError, descError, linkError]
                .where((e) => e != null)
                .join('\n'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      final project = Project(
        title: title,
        description: desc,
        link: link.isNotEmpty ? Project.normalizeLink(link) : null,
      );
      if (_editingProjectIndex != null) {
        _projects[_editingProjectIndex!] = project;
        _editingProjectIndex = null;
      } else {
        _projects.add(project);
      }
      _projectTitleController.clear();
      _projectDescController.clear();
      _projectLinkController.clear();
    });
  }

  void _editProject(int index) {
    setState(() {
      _projectTitleController.text = _projects[index].title;
      _projectDescController.text = _projects[index].description;
      _projectLinkController.text = _projects[index].link ?? '';
      _editingProjectIndex = index;
    });
  }

  void _deleteProject(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce projet ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _projects.removeAt(index);
                if (_editingProjectIndex == index) {
                  _projectTitleController.clear();
                  _projectDescController.clear();
                  _projectLinkController.clear();
                  _editingProjectIndex = null;
                }
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToNextStep() async {
    if (widget.data.sessionToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erreur: Token de session manquant. Veuillez recommencer l\'inscription.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare projects for API
      List<Map<String, dynamic>>? projectsJson;
      if (_projects.isNotEmpty) {
        projectsJson = _projects.map((p) => p.toJson()).toList();
        print('📋 Projets envoyés: ${jsonEncode(projectsJson)}');
      } else {
        print('📋 Aucun projet envoyé');
      }

      final response = await ApiService.registerStep3WithFile(
        sessionToken: widget.data.sessionToken!,
        cvFile: _selectedCvFile,
        competences: _skills.isNotEmpty ? _skills : null,
        projects: projectsJson,
      ).timeout(const Duration(seconds: 30));

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        widget.data
          ..cvFilePath = _cvFileName ?? ''
          ..skills = _skills.join(', ')
          ..skillsList = _skills // Sync skillsList
          ..projects = _projects;
        print('✅ Step3 réussi');
        widget.data.printDebug();
        Navigator.pushNamed(
          context,
          AppRoutes.registerStep4,
          arguments: widget.data,
        );
      } else {
        String errorMessage = 'Erreur inconnue';
        if (response['body'] != null) {
          final body = response['body'];
          if (body['errors'] != null) {
            final errors = body['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            errors.forEach((field, messages) {
              if (messages is List) {
                errorMessages.addAll(messages.cast<String>());
              } else if (messages is String) {
                errorMessages.add(messages);
              }
            });
            errorMessage = errorMessages.join('\n');
          } else if (body['message'] != null) {
            errorMessage = body['message'];
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        print('❌ Erreur API Step3: ${response['status']} - $errorMessage');
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Temps de réponse dépassé. Veuillez vérifier votre connexion.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('❌ Exception Step3: $e');
    }
  }

  Future<void> _goToPreviousStep() async {
    try {
      if (widget.data.sessionToken == null) {
        throw Exception('Session token manquant');
      }
      final response = await ApiService.getStepData(
        sessionToken: widget.data.sessionToken!,
        stepNumber: 2,
      );
      if (response['success'] && response['body']['data'] != null) {
        final stepData = RegistrationData.fromApiData(response['body']['data']);
        widget.data
          ..ecole = stepData.ecole
          ..filiere = stepData.filiere
          ..niveau = stepData.niveau
          ..ville = stepData.ville;
        Navigator.pushNamed(
          context,
          AppRoutes.registerStep2,
          arguments: widget.data,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erreur lors de la récupération des données de l\'étape précédente',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du retour: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('❌ Erreur retour Step2: $e');
    }
  }

  InputDecoration _customInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.black),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: CesamColors.primary, width: 2),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: 1),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Étape 3 - CV, Compétences et Projets',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step information
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: CesamColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Cette étape est optionnelle. Vous pouvez ajouter votre CV, vos compétences et vos projets pour enrichir votre profil.',
                  style: TextStyle(
                    color: CesamColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // CV Section
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: CesamColors.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'CV (Optionnel)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CesamColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _selectCvFile,
                          icon: Icon(
                            _selectedCvFile != null
                                ? Icons.check_circle
                                : Icons.upload_file,
                            color: _selectedCvFile != null
                                ? Colors.green
                                : CesamColors.primary,
                          ),
                          label: Text(
                            _selectedCvFile != null
                                ? 'CV sélectionné: $_cvFileName'
                                : 'Sélectionner un fichier PDF',
                            style: TextStyle(
                              color: _selectedCvFile != null
                                  ? Colors.green
                                  : CesamColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _selectedCvFile != null
                                  ? Colors.green
                                  : CesamColors.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      if (_selectedCvFile != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _removeCvFile,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Supprimer le CV sélectionné',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Formats acceptés: PDF uniquement (max 5 MB)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              // Skills Section
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Row(
                        children: [
                          Icon(
                            Icons.stars_outlined,
                            color: CesamColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Compétences',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CesamColors.primary,
                                ),
                              ),
                              const Text(
                                '(Optionnel)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CesamColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          TextFormField(
                            controller: _skillController,
                            decoration: _customInputDecoration(
                              'Ajouter une compétence',
                              Icons.add_circle_outline,
                            ),
                            onFieldSubmitted: (_) => _addOrUpdateSkill(),
                            validator: (value) {
                              if (value != null && value.trim().length > 100) {
                                return 'Max 100 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _addOrUpdateSkill,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CesamColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _editingSkillIndex != null
                                    ? 'Modifier la compétence'
                                    : 'Ajouter la compétence',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_skills.isNotEmpty) ...[
                        const Text(
                          'Compétences ajoutées:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _skills.asMap().entries.map((entry) {
                                final index = entry.key;
                                final skill = entry.value;
                                return Chip(
                                  label: Text(
                                    skill,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: _editingSkillIndex == index
                                      ? CesamColors.primary.withOpacity(0.2)
                                      : Colors.grey[100],
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 16,
                                  ),
                                  onDeleted: () => _deleteSkill(index),
                                  avatar: GestureDetector(
                                    onTap: () => _editSkill(index),
                                    child: const Icon(Icons.edit, size: 14),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Aucune compétence ajoutée. Ajoutez vos compétences techniques et soft skills.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Projects Section
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 32),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.work_outline, color: CesamColors.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Projets (Optionnel)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CesamColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          TextFormField(
                            controller: _projectTitleController,
                            decoration: _customInputDecoration(
                              'Titre du projet (requis pour ajouter un projet)',
                              Icons.title,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _projectDescController,
                            decoration: _customInputDecoration(
                              'Description du projet (requis pour ajouter un projet)',
                              Icons.description,
                            ),
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _projectLinkController,
                            decoration: _customInputDecoration(
                              'Lien du projet (optionnel)',
                              Icons.link,
                            ),
                            validator: Project.validateLink,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _addOrUpdateProject,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CesamColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _editingProjectIndex != null
                                    ? 'Modifier le projet'
                                    : 'Ajouter le projet',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_projects.isNotEmpty) ...[
                        const Text(
                          'Projets ajoutés:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: _projects.asMap().entries.map((entry) {
                            final index = entry.key;
                            final project = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                title: Text(
                                  project.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _editProject(index),
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      constraints: const BoxConstraints.tightFor(
                                        width: 32,
                                        height: 32,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteProject(index),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      constraints: const BoxConstraints.tightFor(
                                        width: 32,
                                        height: 32,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Aucun projet ajouté. Présentez vos réalisations et projets personnels.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(CesamColors.primary),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _goToNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CesamColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Suivant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              // Back Button
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: _goToPreviousStep,
                  child: const Text(
                    'Retour à l\'étape précédente',
                    style: TextStyle(color: CesamColors.primary, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _skillController.dispose();
    _projectTitleController.dispose();
    _projectDescController.dispose();
    _projectLinkController.dispose();
    super.dispose();
  }
}