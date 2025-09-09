import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String? id;           // UUID au lieu d'int
  final String title;
  final String description;
  final String? link;
  final DateTime? createdAt;

  const Project({
    this.id,                  // Peut être null lors de la création
    required this.title,
    required this.description,
    this.link,
    this.createdAt,
  });

  // Factory constructor depuis JSON (données du serveur)
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      link: json['link'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  // Conversion vers JSON pour envoi au serveur
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
    };
    
    if (link != null && link!.isNotEmpty) {
      map['link'] = link;
    }
    
    // L'ID et created_at sont gérés côté serveur
    return map;
  }

  // Conversion complète (avec ID pour debug/affichage)
  Map<String, dynamic> toCompleteJson() {
    final map = toJson();
    
    if (id != null) {
      map['id'] = id;
    }
    
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    
    return map;
  }

  // Copie avec modifications
  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? link,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Validation
  bool get isValid {
    return title.trim().isNotEmpty && description.trim().isNotEmpty;
  }

  // Vérification si le projet a un lien
  bool get hasLink {
    return link != null && link!.isNotEmpty;
  }

  // Formatage de la date de création
  String get formattedCreatedAt {
    if (createdAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${createdAt!.day.toString().padLeft(2, '0')}/${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.year}';
    }
  }

  // Factory constructor pour créer un nouveau projet (sans ID)
  factory Project.create({
    required String title,
    required String description,
    String? link,
  }) {
    return Project(
      title: title.trim(),
      description: description.trim(),
      link: link?.trim().isEmpty == true ? null : link?.trim(),
      createdAt: DateTime.now(), // Date locale temporaire
    );
  }

  // Propriétés pour Equatable (comparaison d'objets)
  @override
  List<Object?> get props => [id, title, description, link, createdAt];

  // String representation pour debug
  @override
  String toString() {
    return 'Project(id: $id, title: "$title", description: "${description.length > 50 ? description.substring(0, 50) + '...' : description}", hasLink: $hasLink, createdAt: $createdAt)';
  }

  // Helpers statiques pour la validation
  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Le titre est requis';
    }
    if (title.trim().length > 200) {
      return 'Le titre ne peut pas dépasser 200 caractères';
    }
    return null;
  }

  static String? validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'La description est requise';
    }
    if (description.trim().length > 1000) {
      return 'La description ne peut pas dépasser 1000 caractères';
    }
    return null;
  }

  static String? validateLink(String? link) {
    if (link == null || link.trim().isEmpty) {
      return null; // Le lien est optionnel
    }
    
    final trimmedLink = link.trim();
    if (trimmedLink.length > 255) {
      return 'Le lien ne peut pas dépasser 255 caractères';
    }
    
    // Validation basique d'URL
    final urlPattern = RegExp(
      r'^https?:\/\/'  // http:// ou https://
      r'(?:[-\w.])+' // domaine
      r'(?:\:[0-9]+)?' // port optionnel
      r'(?:\/.*)?,' // chemin optionnel
      
    );
    
    String urlToTest = trimmedLink;
    if (!trimmedLink.startsWith('http://') && !trimmedLink.startsWith('https://')) {
      urlToTest = 'https://$trimmedLink';
    }
    
    if (!urlPattern.hasMatch(urlToTest)) {
      return 'Le lien doit être une URL valide';
    }
    
    return null;
  }

  // Helper pour normaliser un lien
  static String? normalizeLink(String? link) {
    if (link == null || link.trim().isEmpty) return null;
    
    final trimmed = link.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }
}