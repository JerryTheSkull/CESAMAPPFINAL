import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Offer {
  final int? id;
  final String title;
  final String type; // 'stage' ou 'emploi'
  final String? description;
  final List<String>? images;
  final List<String>? links;
  final List<String>? pdfs;
  final bool isActive;
  final DateTime? createdAt;
  final int? applicationsCount;
  final bool? userHasApplied;

  Offer({
    this.id,
    required this.title,
    required this.type,
    this.description,
    this.images,
    this.links,
    this.pdfs,
    this.isActive = true,
    this.createdAt,
    this.applicationsCount,
    this.userHasApplied,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      title: json['title'] ?? '',
      type: json['type'] ?? 'stage',
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      links: json['links'] != null ? List<String>.from(json['links']) : null,
      pdfs: json['pdfs'] != null ? List<String>.from(json['pdfs']) : null,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      applicationsCount: json['applications_count'],
      userHasApplied: json['user_has_applied'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'description': description,
      'images': images,
      'links': links,
      'pdfs': pdfs,
      'is_active': isActive,
    };
  }
}

class Application {
  final int id;
  final Offer offer;
  final DateTime appliedAt;

  Application({
    required this.id,
    required this.offer,
    required this.appliedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      offer: Offer.fromJson(json['offer']),
      appliedAt: DateTime.parse(json['applied_at']),
    );
  }
}

class Applicant {
  final String nomComplet;
  final List<String> competences;
  final List<Map<String, dynamic>> projects;
  final DateTime appliedAt;

  Applicant({
    required this.nomComplet,
    required this.competences,
    required this.projects,
    required this.appliedAt,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      nomComplet: json['nom_complet'] ?? '',
      competences: List<String>.from(json['competences'] ?? []),
      projects: List<Map<String, dynamic>>.from(json['projects'] ?? []),
      appliedAt: DateTime.parse(json['applied_at']),
    );
  }
}

class ApiServiceStage {
  static const String baseUrl = 'http://172.26.153.145:8080/api';
  
  // Headers avec token d'authentification
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ================ API PUBLIQUE (UTILISATEURS) ================

  /// Récupère toutes les offres actives
  static Future<List<Offer>> getOffers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/offers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Offer.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des offres: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Récupère une offre spécifique par ID
  static Future<Offer> getOffer(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/offers/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Offer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors du chargement de l\'offre: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Postuler à une offre
  static Future<Map<String, dynamic>> applyToOffer(int offerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/offers/$offerId/apply'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Candidature envoyée avec succès'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors de la candidature'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e'
      };
    }
  }

  /// Récupère les candidatures de l'utilisateur connecté
  static Future<List<Application>> getMyApplications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/offers/my-applications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des candidatures: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Annuler une candidature
  static Future<Map<String, dynamic>> cancelApplication(int applicationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/offers/applications/$applicationId'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Candidature annulée avec succès'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors de l\'annulation'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e'
      };
    }
  }

  // ================ API ADMIN ================

  /// Récupère toutes les offres (admin)
  static Future<List<Offer>> getAdminOffers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/offers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Offer.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des offres admin: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Créer une nouvelle offre (admin)
  static Future<Map<String, dynamic>> createOffer(Offer offer) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/offers'),
        headers: headers,
        body: json.encode(offer.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Offre créée avec succès',
          'offer': Offer.fromJson(responseData['offer'])
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors de la création'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e'
      };
    }
  }

  /// Récupère une offre avec ses candidatures (admin)
  static Future<Offer> getAdminOffer(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/offers/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Offer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors du chargement de l\'offre admin: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Supprimer une offre (admin)
  static Future<Map<String, dynamic>> deleteOffer(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/offers/$id'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Offre supprimée avec succès'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors de la suppression'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e'
      };
    }
  }

  /// Changer le statut d'une offre (admin)
  static Future<Map<String, dynamic>> toggleOfferStatus(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/offers/$id/toggle-status'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Statut modifié avec succès',
          'is_active': responseData['is_active']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors du changement de statut'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur réseau: $e'
      };
    }
  }

  /// Récupère les candidatures d'une offre (admin)
  static Future<Map<String, dynamic>> getOfferApplications(int offerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/offers/$offerId/applications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'offer_title': data['offer_title'],
          'total_applicants': data['total_applicants'],
          'applicants': (data['applicants'] as List)
              .map((json) => Applicant.fromJson(json))
              .toList(),
        };
      } else {
        throw Exception('Erreur lors du chargement des candidatures: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Télécharger les données Excel des candidatures (admin)
  static Future<Map<String, dynamic>> downloadExcelData(int offerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/offers/$offerId/download-excel'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors du téléchargement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}