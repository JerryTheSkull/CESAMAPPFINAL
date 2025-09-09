import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../constants/colors.dart';
import '../components/cesam_app_bar.dart';
import '../models/cesam_user.dart';
import '../providers/user_profile_provider.dart';
import '../services/api_service.dart';
import 'reset_password_screen.dart';

class ProfileUtilPage extends StatefulWidget {
  final CesamUser? initialUser;

  const ProfileUtilPage({super.key, this.initialUser});

  @override
  State<ProfileUtilPage> createState() => _ProfileUtilPageState();
}

class _ProfileUtilPageState extends State<ProfileUtilPage> {
  final ImagePicker _imagePicker = ImagePicker();

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
      builder:
          (context) => SafeArea(
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
                if (provider.user?.photoPath != null &&
                    provider.user!.photoPath!.isNotEmpty)
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

  Future<void> _pickImage(
    ImageSource source,
    UserProfileProvider provider,
  ) async {
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
          _showSnackBar(
            provider.error ?? 'Erreur lors de l\'upload',
            Colors.red,
          );
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
      _showSnackBar(
        provider.error ?? 'Erreur lors de la suppression',
        Colors.red,
      );
    }
  }

  // Gestion des informations personnelles
  Future<void> _editPhone(UserProfileProvider provider) async {
    final controller = TextEditingController(text: provider.user?.phone ?? '');
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifier le téléphone'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                prefixText: '+212 ',
                hintText: 'Ex: 612345678',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-\+]')),
                LengthLimitingTextInputFormatter(20),
              ],
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

    if (result != null) {
      final success = await provider.updatePersonalInfo(telephone: result);
      if (success) {
        _showSnackBar('Téléphone mis à jour', Colors.green);
      } else {
        _showSnackBar(
          provider.error ?? 'Erreur lors de la mise à jour',
          Colors.red,
        );
      }
    }
  }

  Future<void> _editCity(UserProfileProvider provider) async {
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifier la ville'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value:
                        provider.cities.contains(provider.user?.city)
                            ? provider.user?.city
                            : null,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    items:
                        provider.cities
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => Navigator.pop(context, value),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.cities.length} villes disponibles',
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
      final success = await provider.updatePersonalInfo(ville: result);
      if (success) {
        _showSnackBar('Ville mise à jour', Colors.green);
      } else {
        _showSnackBar(
          provider.error ?? 'Erreur lors de la mise à jour',
          Colors.red,
        );
      }
    }
  }

  Future<void> _editAmciStatus(UserProfileProvider provider) async {
    final isAmci = provider.user?.isAmci ?? false;
    final matriculeController = TextEditingController(
      text: provider.user?.amciCode ?? '',
    );
    bool newIsAmci = isAmci;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Modifier le statut AMCI'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: const Text('Affilié AMCI'),
                        value: newIsAmci,
                        onChanged: (value) {
                          setDialogState(() => newIsAmci = value);
                        },
                      ),
                      if (newIsAmci) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: matriculeController,
                          decoration: const InputDecoration(
                            labelText: 'Matricule AMCI',
                            hintText: 'Ex: ABC123-2024 ou MA/2024/001',
                            border: OutlineInputBorder(),
                            helperText:
                                'Lettres, chiffres, tirets et / autorisés',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9\-\/]'),
                            ),
                            LengthLimitingTextInputFormatter(50),
                          ],
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.pop(context, {
                            'isAmci': newIsAmci,
                            'matricule':
                                newIsAmci ? matriculeController.text : null,
                          }),
                      child: const Text('Sauvegarder'),
                    ),
                  ],
                ),
          ),
    );

    if (result != null) {
      final success = await provider.updatePersonalInfo(
        affilieAmci: result['isAmci'],
        matriculeAmci: result['matricule'],
      );
      if (success) {
        _showSnackBar('Statut AMCI mis à jour', Colors.green);
      } else {
        _showSnackBar(
          provider.error ?? 'Erreur lors de la mise à jour',
          Colors.red,
        );
      }
    }
  }

  Future<void> _showLogoutDialog(UserProfileProvider provider) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Déconnexion'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await _logout(provider);
    }
  }

  Future<void> _logout(UserProfileProvider provider) async {
    try {
      final response = await ApiService.logout();
      provider.clearUser(); // Nettoyer les données du provider
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
        _showSnackBar('Déconnexion réussie', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors de la déconnexion: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
                        backgroundImage:
                            (user.photoPath != null &&
                                    user.photoPath!.isNotEmpty)
                                ? NetworkImage(user.photoUrlWithTimestamp!)
                                    as ImageProvider
                                : null,
                        child:
                            (user.photoPath == null || user.photoPath!.isEmpty)
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

              // Section Informations personnelles
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
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CesamColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _editableInfoRow(
                      Icons.phone,
                      'Téléphone',
                      user.phone ?? 'Non renseigné',
                      () => _editPhone(provider),
                    ),
                    _editableInfoRow(
                      Icons.location_city,
                      'Ville',
                      user.city ?? 'Non renseignée',
                      () => _editCity(provider),
                    ),
                    if (user.nationality != null)
                      _infoRow(Icons.flag, 'Nationalité', user.nationality!),
                    _editableInfoRow(
                      Icons.verified_user,
                      'Statut AMCI',
                      user.isAmci == true
                          ? 'Affilié AMCI${user.amciCode != null ? " - ${user.amciCode}" : ""}'
                          : 'Non affilié AMCI',
                      () => _editAmciStatus(provider),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions du profil
              _flatActionTile(
                Icons.lock_outline,
                'Modifier le mot de passe',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordScreen(),
                    ),
                  );
                },
              ),

              _flatActionTile(Icons.help_outline, 'Aide / Contact CESAM', () {
                _showSnackBar('Fonctionnalité à venir', Colors.orange);
              }),
              _flatActionTile(
                Icons.logout,
                'Déconnexion',
                () => _showLogoutDialog(provider),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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

  Widget _editableInfoRow(
    IconData icon,
    String label,
    String value,
    VoidCallback onEdit,
  ) {
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

  Widget _flatActionTile(IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: CesamColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
