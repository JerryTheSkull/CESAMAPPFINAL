// widgets/projects_management_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../models/project.dart';
import '../providers/user_profile_provider.dart';

class ProjectsManagementWidget extends StatefulWidget {
  final bool showTitle;
  final bool allowAdd;
  final bool allowEdit;
  final bool allowDelete;
  final int? maxProjects;

  const ProjectsManagementWidget({
    super.key,
    this.showTitle = true,
    this.allowAdd = true,
    this.allowEdit = true,
    this.allowDelete = true,
    this.maxProjects,
  });

  @override
  State<ProjectsManagementWidget> createState() => _ProjectsManagementWidgetState();
}

class _ProjectsManagementWidgetState extends State<ProjectsManagementWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        if (user == null) return const SizedBox.shrink();

        return Container(
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
              if (widget.showTitle) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Projets réalisés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CesamColors.primary,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.hasProjects)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: CesamColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${user.projectsCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: CesamColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (widget.allowAdd && _canAddMoreProjects(user.projectsCount))
                          IconButton(
                            onPressed: _isLoading ? null : () => _showAddProjectDialog(provider),
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
                const SizedBox(height: 16),
              ],

              // Liste des projets
              if (user.hasProjects) ...[
                Column(
                  children: user.projectsSortedByDate
                      .map((project) => _buildProjectCard(project, provider))
                      .toList(),
                ),
              ] else ...[
                _buildEmptyState(),
              ],

              // Indicateur de limite de projets
              if (widget.maxProjects != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Maximum ${widget.maxProjects} projets (${user.projectsCount}/${widget.maxProjects})',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(Project project, UserProfileProvider provider) {
    return Container(
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
          // Header avec titre et menu
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
              if (widget.allowEdit || widget.allowDelete)
                PopupMenuButton<String>(
                  onSelected: (value) => _handleProjectAction(value, project, provider),
                  itemBuilder: (context) => [
                    if (widget.allowEdit)
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
                    if (widget.allowDelete)
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

          // Description
          Text(
            project.description,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          // Lien si présent
          if (project.hasLink) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _openLink(project.link!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CesamColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CesamColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.link,
                      size: 16,
                      color: CesamColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        project.link!,
                        style: const TextStyle(
                          color: CesamColors.primary,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Date de création
          if (project.createdAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Créé ${project.formattedCreatedAt}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.work_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun projet renseigné',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos projets pour enrichir votre profil',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.allowAdd) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _showAddProjectDialog(
                Provider.of<UserProfileProvider>(context, listen: false)
              ),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un projet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CesamColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Actions sur les projets
  void _handleProjectAction(String action, Project project, UserProfileProvider provider) {
    switch (action) {
      case 'edit':
        _showEditProjectDialog(project, provider);
        break;
      case 'delete':
        _confirmDeleteProject(project, provider);
        break;
    }
  }

  // Dialog d'ajout de projet
  Future<void> _showAddProjectDialog(UserProfileProvider provider) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ProjectDialog(
        title: 'Ajouter un projet',
        actionLabel: 'Ajouter',
      ),
    );

    if (result != null) {
      await _addProject(result, provider);
    }
  }

  // Dialog d'édition de projet
  Future<void> _showEditProjectDialog(Project project, UserProfileProvider provider) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ProjectDialog(
        title: 'Modifier le projet',
        actionLabel: 'Modifier',
        initialTitle: project.title,
        initialDescription: project.description,
        initialLink: project.link,
      ),
    );

    if (result != null) {
      await _updateProject(project.id!, result, provider);
    }
  }

  // Confirmation de suppression
  Future<void> _confirmDeleteProject(Project project, UserProfileProvider provider) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87),
            children: [
              const TextSpan(text: 'Êtes-vous sûr de vouloir supprimer '),
              TextSpan(
                text: '"${project.title}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' ?\n\nCette action est irréversible.'),
            ],
          ),
        ),
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

    if (shouldDelete == true) {
      await _deleteProject(project.id!, provider);
    }
  }

  // Actions CRUD
  Future<void> _addProject(Map<String, String> data, UserProfileProvider provider) async {
    setState(() => _isLoading = true);
    
    try {
      final success = await provider.addProject(
        title: data['title']!,
        description: data['description']!,
        link: data['link']?.isEmpty == true ? null : data['link'],
      );
      
      if (success) {
        _showSnackBar('Projet ajouté avec succès', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de l\'ajout', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProject(String projectId, Map<String, String> data, UserProfileProvider provider) async {
    setState(() => _isLoading = true);
    
    try {
      final success = await provider.updateProject(
        projectId: projectId,
        title: data['title']!,
        description: data['description']!,
        link: data['link']?.isEmpty == true ? null : data['link'],
      );
      
      if (success) {
        _showSnackBar('Projet modifié avec succès', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de la modification', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProject(String projectId, UserProfileProvider provider) async {
    setState(() => _isLoading = true);
    
    try {
      final success = await provider.removeProject(projectId);
      
      if (success) {
        _showSnackBar('Projet supprimé avec succès', Colors.green);
      } else {
        _showSnackBar(provider.error ?? 'Erreur lors de la suppression', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Vérifications
  bool _canAddMoreProjects(int currentCount) {
    return widget.maxProjects == null || currentCount < widget.maxProjects!;
  }

  // Ouvrir un lien
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
      _showSnackBar('Erreur lors de l\'ouverture du lien: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Dialog réutilisable pour ajouter/modifier un projet
class _ProjectDialog extends StatefulWidget {
  final String title;
  final String actionLabel;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialLink;

  const _ProjectDialog({
    required this.title,
    required this.actionLabel,
    this.initialTitle,
    this.initialDescription,
    this.initialLink,
  });

  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _linkController;
  
  final _formKey = GlobalKey<FormState>();
  bool _isValidating = false;
  Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descController = TextEditingController(text: widget.initialDescription ?? '');
    _linkController = TextEditingController(text: widget.initialLink ?? '');
    
    // Validation en temps réel
    _titleController.addListener(_validateFields);
    _descController.addListener(_validateFields);
    _linkController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _validateFields() {
    if (!_isValidating) return;
    
    setState(() {
      _errors = _validateProjectData(
        title: _titleController.text,
        description: _descController.text,
        link: _linkController.text.isEmpty ? null : _linkController.text,
      );
    });
  }

  // Validation personnalisée des données du projet
  Map<String, String?> _validateProjectData({
    required String title,
    required String description,
    String? link,
  }) {
    return {
      'title': Project.validateTitle(title),
      'description': Project.validateDescription(description),
      'link': Project.validateLink(link),
    };
  }

  bool get _isFormValid {
    return _errors.values.every((error) => error == null) &&
           _titleController.text.trim().isNotEmpty &&
           _descController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre du projet*',
                  border: const OutlineInputBorder(),
                  hintText: 'Ex: Application mobile de gestion',
                  errorText: _errors['title'],
                  counterText: '${_titleController.text.length}/200',
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                validator: (value) => Project.validateTitle(value),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description*',
                  border: const OutlineInputBorder(),
                  hintText: 'Décrivez votre projet en quelques mots...',
                  errorText: _errors['description'],
                  counterText: '${_descController.text.length}/1000',
                ),
                maxLines: 4,
                inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                validator: (value) => Project.validateDescription(value),
              ),
              
              const SizedBox(height: 16),
              
              // Lien
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Lien (optionnel)',
                  border: const OutlineInputBorder(),
                  hintText: 'https://github.com/username/projet',
                  errorText: _errors['link'],
                  counterText: '${_linkController.text.length}/255',
                  prefixIcon: const Icon(Icons.link, size: 20),
                ),
                keyboardType: TextInputType.url,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
                validator: (value) => Project.validateLink(value),
              ),
              
              const SizedBox(height: 8),
              
              // Aide pour les liens
              Text(
                'Formats acceptés : https://example.com ou example.com',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isFormValid ? _submitForm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: CesamColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }

  void _submitForm() {
    setState(() => _isValidating = true);
    
    if (_formKey.currentState!.validate() && _isFormValid) {
      Navigator.pop(context, {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'link': _linkController.text.trim(),
      });
    }
  }
}