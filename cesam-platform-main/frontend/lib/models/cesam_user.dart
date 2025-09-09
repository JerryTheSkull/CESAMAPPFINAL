// models/cesam_user.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'project.dart';

class CesamUser {
  bool get hasSkills => skills != null && skills!.isNotEmpty;
  bool get hasProjects => projects != null && projects!.isNotEmpty;

  final int? id;
  final String name;
  final String email;

  // Propriétés de base
  final bool isAdmin;
  final String? phone;
  final String? nationality;
  final String? academicLevel;
  final String? studyField;
  final String? school;
  final String? city;
  final bool? isAmci;
  final String? amciCode;
  final String? amciMatricule;  // Ajout du matricule AMCI
  final String? emergencyContact;
  final List<String>? skills;
  final List<Project>? projects;
  final bool? hasCV;
  final String? cvUrl;
  final String? photoPath;

  // Statuts et rôles
  final DateTime? emailVerifiedAt;
  final bool? isApproved;
  final String? role;
  final String? status;
  final bool? isActive;
  final DateTime? suspensionEndDate;
  final String? profileImageUrl;
  final Map<String, dynamic>? additionalData;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CesamUser({
    this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.phone,
    this.nationality,
    this.academicLevel,
    this.studyField,
    this.school,
    this.city,
    this.isAmci,
    this.amciCode,
    this.amciMatricule,
    this.emergencyContact,
    this.skills,
    this.projects,
    this.hasCV,
    this.cvUrl,
    this.photoPath,
    this.emailVerifiedAt,
    this.isApproved,
    this.role,
    this.status,
    this.isActive,
    this.suspensionEndDate,
    this.profileImageUrl,
    this.additionalData,
    this.createdAt,
    this.updatedAt,
  });

  // -----------------------------
  // Factory depuis API - ADAPTÉ POUR LA NOUVELLE STRUCTURE JSON
  factory CesamUser.fromJson(Map<String, dynamic> json) {
    return CesamUser.fromApiData(json);
  }

  factory CesamUser.fromApiData(Map<String, dynamic> userData, {String? userRole}) {
  try {
    if (kDebugMode) {
      debugPrint('=== DEBUT DEBUG USER DATA ===');
      debugPrint('Données complètes reçues: $userData');
    }

    // Parse projects
    List<Project>? projectsList;
    final projectsData = userData['projects'];
    if (projectsData is List) {
      projectsList = projectsData
          .whereType<Map<String, dynamic>>()
          .map((p) => Project.fromJson(p)) // Use fromJson consistently
          .toList();
    }

    

      // Parse skills - INCHANGÉ
      List<String>? skillsList;
      if (userData['competences'] is List) {
        skillsList = (userData['competences'] as List)
            .where((s) => s != null)
            .map((s) => s.toString())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (userData['competences'] is String && userData['competences'].toString().isNotEmpty) {
        skillsList = [userData['competences'].toString()];
      }

      // Academic level - support des deux formats
      final academicLevelValue = userData['niveau_etude']?.toString() ??
          userData['academic_level']?.toString() ??
          userData['study_level']?.toString() ??
          userData['niveauEtude']?.toString() ??
          userData['niveau']?.toString();

      // Photo path - support nouveau format backend
      final photoPathValue = userData['photo_path']?.toString() ??
          userData['profile_photo_url']?.toString() ??
          userData['photo_url']?.toString() ??
          userData['photoPath']?.toString() ??
          userData['avatar']?.toString() ??
          userData['profile_photo']?.toString() ??
          userData['image_url']?.toString() ??
          userData['profile_image']?.toString();

      // CV URL - support nouveau format
      final cvUrlValue = userData['cv_url']?.toString() ??
          userData['cvUrl']?.toString() ??
          userData['cv_path']?.toString();

      // Role
      String? finalRole = userRole ?? userData['role']?.toString();
      bool isAdminUser = finalRole == 'admin' ||
          finalRole == 'administrateur' ||
          userData['isAdmin'] == true;

      // AMCI - support des deux champs
      final amciCodeValue = userData['code_amci']?.toString() ??
          userData['amci_code']?.toString();
      final amciMatriculeValue = userData['matricule_amci']?.toString() ??
          userData['amci_matricule']?.toString();

      final user = CesamUser(
        id: _parseInt(userData['id']),
        name: userData['nom_complet']?.toString() ??
            userData['name']?.toString() ??
            userData['full_name']?.toString() ??
            userData['fullName']?.toString() ??
            '',
        email: userData['email']?.toString() ?? '',
        isAdmin: isAdminUser,

        // Infos perso
        phone: userData['telephone']?.toString() ?? userData['phone']?.toString(),
        nationality: userData['nationalite']?.toString() ?? userData['nationality']?.toString(),
        academicLevel: academicLevelValue,
        studyField: userData['filiere']?.toString() ??
            userData['study_field']?.toString() ??
            userData['studyField']?.toString(),
        school: userData['ecole']?.toString() ??
            userData['school']?.toString() ??
            userData['etablissement']?.toString(),
        city: userData['ville']?.toString() ?? userData['city']?.toString(),

        // AMCI - SUPPORT COMPLET
        isAmci: _parseBool(userData['affilie_amci'] ??
            userData['isAmci'] ??
            userData['is_amci'] ??
            userData['amci']),
        amciCode: amciCodeValue,
        amciMatricule: amciMatriculeValue,

        // Skills & projets
        skills: skillsList,
        projects: projectsList,

        // CV & photo - NOUVEAU FORMAT
        hasCV: _parseBool(userData['has_cv']) ?? 
               (cvUrlValue != null && cvUrlValue.isNotEmpty),
        cvUrl: cvUrlValue,
        photoPath: photoPathValue,

        // Statuts
        emailVerifiedAt: _parseDate(userData['email_verified_at']),
        isApproved: _parseBool(userData['is_approved'] ?? userData['isApproved']),
        role: finalRole,
        status: userData['status']?.toString(),
        isActive: _parseBool(userData['is_active'] ?? userData['isActive']),
        suspensionEndDate: _parseDate(userData['suspension_end_date'] ?? userData['suspensionEndDate']),
        createdAt: _parseDate(userData['created_at'] ?? userData['createdAt']),
        updatedAt: _parseDate(userData['updated_at'] ?? userData['updatedAt']),

        profileImageUrl: userData['profile_image_url']?.toString() ?? userData['profileImageUrl']?.toString(),
        additionalData: userData['additional_data'] ?? userData['additionalData'],
      );

      if (kDebugMode) {
        debugPrint('User créé - projects count: ${user.projects?.length ?? 0}');
        debugPrint('User créé - academicLevel: "${user.academicLevel}"');
        debugPrint('User créé - photoPath: "${user.photoPath}"');
        debugPrint('User créé - hasCV: ${user.hasCV}');
        debugPrint('User créé - cvUrl: "${user.cvUrl}"');
        debugPrint('=== FIN DEBUG USER DATA ===');
      }

      return user;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur parsing CesamUser: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      return CesamUser(
        id: _parseInt(userData['id']),
        name: userData['name']?.toString() ?? userData['nom_complet']?.toString() ?? 'Utilisateur inconnu',
        email: userData['email']?.toString() ?? '',
      );
    }
  }

  // -----------------------------
  // NOUVELLES MÉTHODES POUR GESTION DES PROJETS JSON

  // Trouver un projet par son UUID
  Project? getProjectById(String projectId) {
    if (!hasProjects) return null;
    try {
      return projects!.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  // Rechercher des projets
  List<Project> searchProjects(String query) {
    if (!hasProjects || query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return projects!.where((project) =>
        project.title.toLowerCase().contains(lowercaseQuery) ||
        project.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Vérifier si un projet existe
  bool hasProjectWithId(String projectId) {
    return getProjectById(projectId) != null;
  }

  // Obtenir les projets triés par date de création
  List<Project> get projectsSortedByDate {
    if (!hasProjects) return [];
    
    final sortedProjects = List<Project>.from(projects!);
    sortedProjects.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!); // Plus récent en premier
    });
    
    return sortedProjects;
  }

  // Statistiques des projets
  int get projectsCount => projects?.length ?? 0;
  int get projectsWithLinksCount => projects?.where((p) => p.hasLink).length ?? 0;

  // -----------------------------
  // NOUVELLES MÉTHODES POUR GESTION DES COMPÉTENCES

  // Vérifier si une compétence existe
  bool hasSkill(String skill) {
    if (!hasSkills) return false;
    return skills!.contains(skill.toLowerCase().trim());
  }

  // Obtenir les compétences triées
  List<String> get skillsSorted {
    if (!hasSkills) return [];
    final sortedSkills = List<String>.from(skills!);
    sortedSkills.sort();
    return sortedSkills;
  }

  // Statistiques des compétences
  int get skillsCount => skills?.length ?? 0;

  // -----------------------------
  // Helpers parsing - INCHANGÉ
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final str = value.toLowerCase();
      return str == 'true' || str == '1' || str == 'yes';
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  // -----------------------------
  // Gestion des URLs photo - AMÉLIORÉ
  String? get photoUrlWithTimestamp {
    if (photoPath == null || photoPath!.isEmpty) return null;
    
    // Si l'URL contient déjà un timestamp, on la retourne telle quelle
    if (photoPath!.contains('?t=')) return photoPath;
    
    final separator = photoPath!.contains('?') ? '&' : '?';
    return '$photoPath${separator}t=${DateTime.now().millisecondsSinceEpoch}';
  }

  String? get photoUrlWithCache => photoPath;

  // URL complète pour la photo (si nécessaire)
  String? get fullPhotoUrl {
    if (photoPath == null || photoPath!.isEmpty) return null;
    
    // Si c'est déjà une URL complète, la retourner
    if (photoPath!.startsWith('http')) return photoPath;
    
    // Sinon, construire l'URL complète (à adapter selon votre config)
    return photoPath!.startsWith('/') 
        ? photoPath 
        : '/$photoPath';
  }

  // -----------------------------
  // Gestion du CV - AMÉLIORÉ
  String? get fullCvUrl {
    if (cvUrl == null || cvUrl!.isEmpty) return null;
    
    // Si c'est déjà une URL complète, la retourner
    if (cvUrl!.startsWith('http')) return cvUrl;
    
    // Sinon, construire l'URL complète
    return cvUrl!.startsWith('/') 
        ? cvUrl 
        : '/$cvUrl';
  }

  bool get hasValidCV => hasCV == true && cvUrl != null && cvUrl!.isNotEmpty;

  // -----------------------------
  // Conversion en JSON - ADAPTÉ POUR NOUVEAU FORMAT
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_complet': name,
      'email': email,
      'telephone': phone,
      'nationalite': nationality,
      'niveau_etude': academicLevel,
      'filiere': studyField,
      'ecole': school,
      'ville': city,
      'affilie_amci': isAmci,
      'code_amci': amciCode,
      'matricule_amci': amciMatricule,
      'competences': skills,
      'projects': projects?.map((p) => p.toCompleteJson()).toList(),
      'has_cv': hasCV,
      'cv_url': cvUrl,
      'photo_path': photoPath,
      'role': role,
      'status': status,
      'is_active': isActive,
      'is_approved': isApproved,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'additional_data': additionalData,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // -----------------------------
  // Getters pratiques - INCHANGÉ
  bool get isVerified => emailVerifiedAt != null;
  bool get isPending => status?.toLowerCase() == 'pending' || status?.toLowerCase() == 'pending_approval';
  bool get isSuspended => status?.toLowerCase() == 'suspended';
  bool get isActiveUser => status?.toLowerCase() == 'active' && (isActive ?? false);
  bool get isRejected => status?.toLowerCase() == 'rejected';

  bool get needsApproval => isApproved != true && status != 'rejected';
  bool get needsVerification => !isVerified && status != 'rejected';

  String getDisplayName() => name.isNotEmpty ? name : email.split('@').first;

  String getInitials() {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
  }

  bool get isValidForApproval => name.isNotEmpty && email.isNotEmpty && email.contains('@') && (school?.isNotEmpty ?? false);

  // -----------------------------
  // NOUVEAU : Propriétés de complétude du profil
  bool get isProfileComplete {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phone != null &&
        school != null &&
        studyField != null &&
        academicLevel != null &&
        city != null;
  }

  double get profileCompletionPercentage {
    int completed = 0;
    int total = 10; // Nombre total de champs importants

    if (name.isNotEmpty) completed++;
    if (email.isNotEmpty) completed++;
    if (phone != null && phone!.isNotEmpty) completed++;
    if (school != null && school!.isNotEmpty) completed++;
    if (studyField != null && studyField!.isNotEmpty) completed++;
    if (academicLevel != null && academicLevel!.isNotEmpty) completed++;
    if (city != null && city!.isNotEmpty) completed++;
    if (photoPath != null && photoPath!.isNotEmpty) completed++;
    if (hasValidCV) completed++;
    if (hasSkills) completed++;

    return completed / total;
  }

  String get completionStatus {
    if (!isProfileComplete) return 'Profil incomplet';
    if (!isVerified) return 'Email non vérifié';
    if (!needsApproval) return 'En attente d\'approbation';
    return 'Actif';
  }

  // Couleurs statut
  Color get statusColor {
    if (isSuspended) return Colors.red;
    if (isRejected) return Colors.red.shade800;
    if (!isVerified && needsApproval) return Colors.orange.shade300;
    if (needsVerification) return Colors.blue;
    if (needsApproval) return Colors.orange;
    if (isActiveUser) return Colors.green;
    return Colors.grey;
  }

  String get statusDisplay {
    if (isSuspended) return 'Suspendu';
    if (isRejected) return 'Rejeté';
    if (!isVerified && needsApproval) return 'En attente de vérification et d\'approbation';
    if (needsVerification) return 'En attente de vérification email';
    if (needsApproval) return 'En attente d\'approbation';
    if (isActiveUser) return 'Actif';
    return 'Statut inconnu';
  }

  String get roleDisplay {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'Administrateur';
      case 'moderator':
        return 'Modérateur';
      case 'etudiant':
      default:
        return 'Étudiant';
    }
  }

  IconData get roleIcon {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'moderator':
        return Icons.shield;
      case 'etudiant':
      default:
        return Icons.person;
    }
  }

  Color get roleColor {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.orange;
      case 'moderator':
        return Colors.purple;
      case 'etudiant':
      default:
        return Colors.blue;
    }
  }

  // -----------------------------
  // Méthodes admin - INCHANGÉ
  bool canBeApproved() => needsApproval && isValidForApproval;
  bool canBeRejected() => !isRejected;
  bool canChangeRole() => !isSuspended && !isRejected;
  bool canBeSuspended() => !isSuspended && !isRejected;

  // -----------------------------
  // copyWith - ADAPTÉ POUR NOUVELLES PROPRIÉTÉS
  CesamUser copyWith({
    int? id,
    String? name,
    String? email,
    bool? isAdmin,
    String? phone,
    String? nationality,
    String? academicLevel,
    String? studyField,
    String? school,
    String? city,
    bool? isAmci,
    String? amciCode,
    String? amciMatricule,
    String? emergencyContact,
    List<String>? skills,
    List<Project>? projects,
    bool? hasCV,
    String? cvUrl,
    String? photoPath,
    DateTime? emailVerifiedAt,
    bool? isApproved,
    String? role,
    String? status,
    bool? isActive,
    DateTime? suspensionEndDate,
    String? profileImageUrl,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CesamUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      academicLevel: academicLevel ?? this.academicLevel,
      studyField: studyField ?? this.studyField,
      school: school ?? this.school,
      city: city ?? this.city,
      isAmci: isAmci ?? this.isAmci,
      amciCode: amciCode ?? this.amciCode,
      amciMatricule: amciMatricule ?? this.amciMatricule,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      hasCV: hasCV ?? this.hasCV,
      cvUrl: cvUrl ?? this.cvUrl,
      photoPath: photoPath ?? this.photoPath,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      isApproved: isApproved ?? this.isApproved,
      role: role ?? this.role,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      suspensionEndDate: suspensionEndDate ?? this.suspensionEndDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // -----------------------------
  // Debug & toString
  void debugPrintUserData() {
    if (!kDebugMode) return;
    debugPrint('=== USER DEBUG INFO ===');
    debugPrint('ID: $id');
    debugPrint('Name: $name');
    debugPrint('Email: $email');
    debugPrint('Academic Level: $academicLevel');
    debugPrint('Photo Path: $photoPath');
    debugPrint('Phone: $phone');
    debugPrint('City: $city');
    debugPrint('School: $school');
    debugPrint('Study Field: $studyField');
    debugPrint('Skills count: $skillsCount');
    debugPrint('Projects count: $projectsCount');
    debugPrint('Has CV: $hasCV');
    debugPrint('CV URL: $cvUrl');
    debugPrint('Is AMCI: $isAmci');
    debugPrint('AMCI Code: $amciCode');
    debugPrint('AMCI Matricule: $amciMatricule');
    debugPrint('Profile completion: ${(profileCompletionPercentage * 100).toStringAsFixed(1)}%');
    debugPrint('======================');
  }

  @override
  String toString() =>
      'CesamUser(id: $id, name: $name, email: $email, status: $status, role: $role, verified: $isVerified, approved: $isApproved, academicLevel: $academicLevel, photoPath: $photoPath, projectsCount: $projectsCount, skillsCount: $skillsCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CesamUser && runtimeType == other.runtimeType && id == other.id);

  @override
  int get hashCode => id.hashCode;
}