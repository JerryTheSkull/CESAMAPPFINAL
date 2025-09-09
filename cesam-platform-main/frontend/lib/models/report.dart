import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Report {
  final int? id;
  final String title;
  final String type; // 'PFE' ou 'PFA'
  final String domain;
  final int defenseYear;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? description;
  final String? keywords;
  final String? pdfUrl;
  
  final String displayName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Report({
    this.id,
    required this.title,
    required this.type,
    required this.domain,
    required this.defenseYear,
    this.status = 'pending',
    this.description,
    this.keywords,
    this.pdfUrl,
    
    required this.displayName,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    try {
      if (kDebugMode) {
        debugPrint('=== DEBUT PARSING REPORT ===');
        debugPrint('JSON reçu: $json');
      }

      final report = Report(
        id: _parseInt(json['id']),
        title: json['title']?.toString() ?? 'Titre inconnu',
        type: json['type']?.toString() ?? 'PFE',
        domain: json['domain']?.toString() ?? 'Autres',
        defenseYear: _parseInt(json['defense_year']) ?? DateTime.now().year,
        status: json['status']?.toString() ?? 'pending',
        description: json['description']?.toString(),
        keywords: json['keywords']?.toString(),
        pdfUrl: json['pdf_url']?.toString(),
       
        displayName: json['user']?['name']?.toString() ?? 'Utilisateur inconnu',
        createdAt: _parseDate(json['created_at']),
        updatedAt: _parseDate(json['updated_at']),
      );

      if (kDebugMode) {
        debugPrint('Report créé - ID: ${report.id}, Titre: ${report.title}');
        debugPrint('Type: ${report.type}, Domaine: ${report.domain}');
        debugPrint('Status: ${report.status}, DisplayName: ${report.displayName}');
        debugPrint('=== FIN PARSING REPORT ===');
      }

      return report;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur parsing Report: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      return Report(
        id: _parseInt(json['id']),
        title: json['title']?.toString() ?? 'Titre inconnu',
        type: json['type']?.toString() ?? 'PFE',
        domain: json['domain']?.toString() ?? 'Autres',
        defenseYear: _parseInt(json['defense_year']) ?? DateTime.now().year,
        status: json['status']?.toString() ?? 'pending',
        displayName: 'Utilisateur inconnu',
      );
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'domain': domain,
      'defense_year': defenseYear,
      'status': status,
      'description': description,
      'keywords': keywords,
      'pdf_url': pdfUrl,
     
      'user': {'name': displayName},
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';

  bool get isPFE => type.toUpperCase() == 'PFE';
  bool get isPFA => type.toUpperCase() == 'PFA';

  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;

  String get finalPdfUrl {
    if (!hasPdf) return '';
    if (Uri.parse(pdfUrl!).isAbsolute) return pdfUrl!;
    return 'http://10.25.136.145:8080/storage/$pdfUrl';
  }

  String get authorInitials {
    final names = displayName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  String get formattedCreatedAt {
    if (createdAt == null) return 'Date inconnue';
    return '${createdAt!.day.toString().padLeft(2, '0')}/${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.year}';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepté';
      case 'rejected':
        return 'Rejeté';
      case 'pending':
      default:
        return 'En attente';
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.schedule;
    }
  }

  Color get typeColor {
    return isPFE ? Colors.blue : Colors.purple;
  }

  IconData get typeIcon {
    return isPFE ? Icons.school : Icons.work;
  }

  Color get domainColor {
    switch (domain.toLowerCase()) {
      case 'informatique & numérique':
        return Colors.blue;
      case 'génie & technologies':
        return Colors.orange;
      case 'sciences & mathématiques':
        return Colors.green;
      case 'économie & gestion':
        return Colors.teal;
      case 'droit & sciences politiques':
        return Colors.indigo;
      case 'médecine & santé':
        return Colors.red;
      case 'arts & lettres':
        return Colors.pink;
      case 'enseignement & pédagogie':
        return Colors.amber;
      case 'agronomie & environnement':
        return Colors.lightGreen;
      case 'tourisme & hôtellerie':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  bool canBeProcessed() => isPending;
  bool canBeResetToPending() => isAccepted || isRejected;
  bool canBeDeleted() => true;

  Report copyWith({
    int? id,
    String? title,
    String? type,
    String? domain,
    int? defenseYear,
    String? status,
    String? description,
    String? keywords,
    String? pdfUrl,
    String? comment,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      domain: domain ?? this.domain,
      defenseYear: defenseYear ?? this.defenseYear,
      status: status ?? this.status,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      pdfUrl: pdfUrl ?? this.pdfUrl,
     
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Report(id: $id, title: $title, type: $type, domain: $domain, status: $status, defenseYear: $defenseYear)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Report && runtimeType == other.runtimeType && id == other.id);

  @override
  int get hashCode => id.hashCode;

  void debugPrintReportData() {
    if (!kDebugMode) return;
    debugPrint('=== REPORT DEBUG INFO ===');
    debugPrint('ID: $id');
    debugPrint('Title: $title');
    debugPrint('Type: $type');
    debugPrint('Domain: $domain');
    debugPrint('Defense Year: $defenseYear');
    debugPrint('Status: $status');
    debugPrint('PDF URL: $pdfUrl');
    debugPrint('Display Name: $displayName');
  
    debugPrint('========================');
  }
}