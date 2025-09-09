import 'package:flutter/material.dart';

// ================ CONSTANTES ================

class UserManagementConstants {
  // Statuts des utilisateurs
  static const String statusActive = 'active';
  static const String statusPending = 'pending';
  static const String statusSuspended = 'suspended';
  static const String statusRejected = 'rejected';
  static const String statusInactive = 'inactive';

  // Rôles des utilisateurs
  static const String roleAdmin = 'admin';
  static const String roleStudent = 'etudiant';
  static const String roleModerator = 'moderator';

  // Actions possibles
  static const String actionApprove = 'approve';
  static const String actionReject = 'reject';
  static const String actionSuspend = 'suspend';
  static const String actionReactivate = 'reactivate';
  static const String actionDelete = 'delete';
  static const String actionChangeRole = 'change_role';

  // Durées de suspension prédéfinies
  static const Map<int, String> suspensionDurations = {
    1: '1 jour',
    3: '3 jours',
    7: '1 semaine',
    14: '2 semaines',
    30: '1 mois',
  };

  // Formats d'export
  static const String exportFormatCsv = 'csv';
  static const String exportFormatExcel = 'excel';

  // Templates d'emails
  static const Map<String, Map<String, String>> emailTemplates = {
    'welcome': {
      'subject': 'Bienvenue sur CESAM',
      'template': 'welcome_template',
    },
    'approval': {
      'subject': 'Votre compte a été approuvé',
      'template': 'approval_template',
    },
    'rejection': {
      'subject': 'Votre demande d\'inscription',
      'template': 'rejection_template',
    },
    'suspension': {
      'subject': 'Suspension temporaire de votre compte',
      'template': 'suspension_template',
    },
    'reactivation': {
      'subject': 'Réactivation de votre compte',
      'template': 'reactivation_template',
    },
  };
}

// ================ EXTENSIONS ================

extension UserStatusExtension on String {
  Color get statusColor {
    switch (this.toLowerCase()) {
      case UserManagementConstants.statusActive:
        return Colors.green;
      case UserManagementConstants.statusPending:
        return Colors.orange;
      case UserManagementConstants.statusSuspended:
        return Colors.red;
      case UserManagementConstants.statusRejected:
        return Colors.red.shade800;
      case UserManagementConstants.statusInactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String get statusDisplayName {
    switch (this.toLowerCase()) {
      case UserManagementConstants.statusActive:
        return 'Actif';
      case UserManagementConstants.statusPending:
        return 'En attente';
      case UserManagementConstants.statusSuspended:
        return 'Suspendu';
      case UserManagementConstants.statusRejected:
        return 'Rejeté';
      case UserManagementConstants.statusInactive:
        return 'Inactif';
      default:
        return 'Inconnu';
    }
  }

  IconData get statusIcon {
    switch (this.toLowerCase()) {
      case UserManagementConstants.statusActive:
        return Icons.check_circle;
      case UserManagementConstants.statusPending:
        return Icons.pending;
      case UserManagementConstants.statusSuspended:
        return Icons.block;
      case UserManagementConstants.statusRejected:
        return Icons.cancel;
      case UserManagementConstants.statusInactive:
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }
}

extension UserRoleExtension on String {
  Color get roleColor {
    switch (this.toLowerCase()) {
      case UserManagementConstants.roleAdmin:
        return Colors.orange;
      case UserManagementConstants.roleModerator:
        return Colors.purple;
      case UserManagementConstants.roleStudent:
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  String get roleDisplayName {
    switch (this.toLowerCase()) {
      case UserManagementConstants.roleAdmin:
        return 'Administrateur';
      case UserManagementConstants.roleModerator:
        return 'Modérateur';
      case UserManagementConstants.roleStudent:
        return 'Étudiant';
      default:
        return 'Étudiant';
    }
  }

  IconData get roleIcon {
    switch (this.toLowerCase()) {
      case UserManagementConstants.roleAdmin:
        return Icons.admin_panel_settings;
      case UserManagementConstants.roleModerator:
        return Icons.shield;
      case UserManagementConstants.roleStudent:
        return Icons.person;
      default:
        return Icons.person;
    }
  }
}

// ================ UTILITAIRES ================

class UserManagementUtils {
  // Validation d'email
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Validation de téléphone
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone);
  }

  // Génération d'initiales à partir du nom
  static String generateInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  // Formatage de date relative
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      }
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  // Formatage de date standard
  static String formatStandardDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Génération de couleur à partir du nom
  static Color generateColorFromName(String name) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];
    
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }

  // Masquage d'email pour la confidentialité
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return email;
    
    final maskedUsername = username[0] + '*' * (username.length - 2) + username[username.length - 1];
    return '$maskedUsername@$domain';
  }

  // Masquage de téléphone
  static String maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'Non renseigné';
    if (phone.length <= 4) return phone;
    
    return phone.substring(0, 2) + '*' * (phone.length - 4) + phone.substring(phone.length - 2);
  }

  // Validation des données utilisateur
  static Map<String, String> validateUserData(Map<String, dynamic> userData) {
    final errors = <String, String>{};
    
    // Validation du nom
    final name = userData['name']?.toString().trim() ?? '';
    if (name.isEmpty) {
      errors['name'] = 'Le nom est requis';
    } else if (name.length < 2) {
      errors['name'] = 'Le nom doit contenir au moins 2 caractères';
    }
    
    // Validation de l'email
    final email = userData['email']?.toString().trim() ?? '';
    if (email.isEmpty) {
      errors['email'] = 'L\'email est requis';
    } else if (!isValidEmail(email)) {
      errors['email'] = 'L\'email n\'est pas valide';
    }
    
    // Validation du téléphone (optionnel)
    final phone = userData['phone']?.toString().trim();
    if (phone != null && phone.isNotEmpty && !isValidPhone(phone)) {
      errors['phone'] = 'Le numéro de téléphone n\'est pas valide';
    }
    
    // Validation de l'école
    final school = userData['school']?.toString().trim() ?? '';
    if (school.isEmpty) {
      errors['school'] = 'L\'école est requise';
    }
    
    return errors;
  }

  // Génération de message d'action
  static String generateActionMessage(String action, String userName, {Map<String, dynamic>? additionalData}) {
    switch (action) {
      case UserManagementConstants.actionApprove:
        final role = additionalData?['role'] ?? 'étudiant';
        return 'Utilisateur "$userName" approuvé avec le rôle $role';
      case UserManagementConstants.actionReject:
        final reason = additionalData?['reason'] ?? '';
        return 'Utilisateur "$userName" rejeté${reason.isNotEmpty ? ' - Raison: $reason' : ''}';
      case UserManagementConstants.actionSuspend:
        final days = additionalData?['days'] ?? 'indéterminée';
        return 'Utilisateur "$userName" suspendu pour $days jour${days != 1 ? 's' : ''}';
      case UserManagementConstants.actionReactivate:
        return 'Utilisateur "$userName" réactivé';
      case UserManagementConstants.actionDelete:
        return 'Utilisateur "$userName" supprimé définitivement';
      case UserManagementConstants.actionChangeRole:
        final newRole = additionalData?['role'] ?? 'étudiant';
        return 'Rôle de "$userName" modifié vers $newRole';
      default:
        return 'Action "$action" effectuée sur "$userName"';
    }
  }

  // Calcul de statistiques utilisateur
  static Map<String, int> calculateUserStats(List<dynamic> users) {
    int total = users.length;
    int active = 0;
    int pending = 0;
    int suspended = 0;
    int admins = 0;
    int students = 0;
    int verified = 0;
    int approved = 0;

    for (final user in users) {
      if (user is Map<String, dynamic>) {
        final status = user['status']?.toString().toLowerCase();
        final role = user['role']?.toString().toLowerCase();
        final isVerified = user['is_verified'] == true;
        final isApproved = user['is_approved'] == true;

        // Comptage par statut
        switch (status) {
          case UserManagementConstants.statusActive:
            active++;
            break;
          case UserManagementConstants.statusPending:
            pending++;
            break;
          case UserManagementConstants.statusSuspended:
            suspended++;
            break;
        }

        // Comptage par rôle
        switch (role) {
          case UserManagementConstants.roleAdmin:
            admins++;
            break;
          case UserManagementConstants.roleStudent:
            students++;
            break;
        }

        if (isVerified) verified++;
        if (isApproved) approved++;
      }
    }

    return {
      'total': total,
      'active': active,
      'pending': pending,
      'suspended': suspended,
      'admins': admins,
      'students': students,
      'verified': verified,
      'approved': approved,
      'rejected': total - approved,
    };
  }

  // Génération de rapport CSV
  static String generateCSVReport(List<Map<String, dynamic>> users) {
    final buffer = StringBuffer();
    
    // En-têtes
    buffer.writeln('ID,Nom,Email,Téléphone,École,Filière,Ville,Statut,Rôle,Vérifié,Approuvé,Date d\'inscription');
    
    // Données
    for (final user in users) {
      final row = [
        user['id']?.toString() ?? '',
        user['name']?.toString() ?? '',
        user['email']?.toString() ?? '',
        user['phone']?.toString() ?? '',
        user['school']?.toString() ?? '',
        user['study_field']?.toString() ?? '',
        user['city']?.toString() ?? '',
        user['status']?.toString() ?? '',
        user['role']?.toString() ?? '',
        user['is_verified']?.toString() ?? '',
        user['is_approved']?.toString() ?? '',
        user['created_at']?.toString() ?? '',
      ].map((field) => '"${field.replaceAll('"', '""')}"').join(',');
      
      buffer.writeln(row);
    }
    
    return buffer.toString();
  }
}

// ================ WIDGETS UTILITAIRES ================

class UserStatusChip extends StatelessWidget {
  final String status;
  final bool showIcon;

  const UserStatusChip({
    Key? key,
    required this.status,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(status.statusIcon, size: 14, color: status.statusColor),
            const SizedBox(width: 4),
          ],
          Text(
            status.statusDisplayName,
            style: TextStyle(
              color: status.statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class UserRoleChip extends StatelessWidget {
  final String role;
  final bool showIcon;

  const UserRoleChip({
    Key? key,
    required this.role,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: role.roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: role.roleColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(role.roleIcon, size: 14, color: role.roleColor),
            const SizedBox(width: 4),
          ],
          Text(
            role.roleDisplayName,
            style: TextStyle(
              color: role.roleColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}