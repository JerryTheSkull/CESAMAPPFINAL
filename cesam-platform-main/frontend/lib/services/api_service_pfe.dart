import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServicePfe {
  static const String baseUrl = "http://172.26.153.145:8080/api";
  
  // Récupérer le token d'authentification
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Headers avec authentification
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ====================================
  // SOUMISSION DE RAPPORTS
  // ====================================

  // Soumettre un rapport (PFE/PFA) - NÉCESSITE AUTHENTIFICATION
  static Future<Map<String, dynamic>?> submitReport(Map<String, String> data) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/reports"));
      
      // Ajouter le token d'authentification
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      
      // Ajouter les champs
      data.forEach((key, value) {
        if (key != "pdf_path") {
          request.fields[key] = value;
        }
      });

      // Ajouter le fichier PDF
      if (data["pdf_path"] != null) {
        request.files.add(await http.MultipartFile.fromPath(
          "pdf_path", // Correspond au nom attendu par Laravel
          data["pdf_path"]!,
        ));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else {
        print("Erreur soumission: ${response.statusCode} - $responseBody");
        return null;
      }
    } catch (e) {
      print("Erreur lors de la soumission: $e");
      return null;
    }
  }
  
  
  // ====================================
  // RÉCUPÉRATION PUBLIQUE DES RAPPORTS (UTILISATEURS)
  // ====================================

  // Récupérer les rapports acceptés (PUBLIC - pas besoin d'auth)
  static Future<List<dynamic>> fetchAcceptedReports({String? domain, int? year}) async {
    try {
      var url = "$baseUrl/reports"; // Route publique correcte
      List<String> params = [];
      
      if (domain != null) params.add("domain=$domain");
      if (year != null) params.add("defense_year=$year");
      
      if (params.isNotEmpty) {
        url += "?${params.join('&')}";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Erreur lors de la récupération des rapports: $e");
      return [];
    }
  }

  // Récupérer les détails d'un rapport (PUBLIC)
  static Future<Map<String, dynamic>?> getReportDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/reports/$id"),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération des détails: $e");
      return null;
    }
  }

  // URL pour télécharger un PDF (PUBLIC)
  static String getDownloadUrl(int reportId) {
    return "$baseUrl/reports/$reportId/download";
  }

  // URL pour visualiser un PDF (PUBLIC)
  static String getViewUrl(int reportId) {
    return "$baseUrl/reports/$reportId/view";
  }

  // URL pour stream un PDF (PUBLIC)
  static String getStreamUrl(int reportId) {
    return "$baseUrl/reports/$reportId/stream";
  }

  // ====================================
  // GESTION ADMIN DES RAPPORTS - AMÉLIORATIONS
  // ====================================

  // Récupérer tous les rapports avec filtres (ADMIN SEULEMENT)
  static Future<Map<String, dynamic>?> fetchReports({String status = 'all'}) async {
    try {
      final headers = await _getAuthHeaders();
      var url = "$baseUrl/admin/reports";
      
      if (status != 'all') {
        url += "?status=$status";
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print("🔍 Réponse fetchReports: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Format attendu du nouveau contrôleur: {success: true, data: [...], stats: {...}}
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          return {
            'success': jsonResponse['success'] ?? true,
            'data': jsonResponse['data'] ?? [],
            'stats': jsonResponse['stats'] ?? {},
          };
        }
        
        // Fallback pour ancien format
        if (jsonResponse is List) {
          return {
            'success': true,
            'data': jsonResponse,
            'stats': {},
          };
        }
        
        return {
          'success': false,
          'data': [],
          'stats': {},
        };
      }
      
      print("❌ Erreur HTTP: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Erreur lors de la récupération des rapports: $e");
      return null;
    }
  }

  // Récupérer les rapports en attente (ADMIN SEULEMENT) - Format amélioré
  static Future<Map<String, dynamic>?> fetchPendingReports() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/admin/reports/pending"),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Nouveau format avec meta et data
        if (jsonResponse is Map) {
          return {
            'success': jsonResponse['success'] ?? true,
            'data': jsonResponse['data'] ?? [],
            'meta': jsonResponse['meta'] ?? {},
          };
        }
        
        // Fallback ancien format
        return {
          'success': true,
          'data': jsonResponse is List ? jsonResponse : [],
          'meta': {},
        };
      }
      
      return null;
    } catch (e) {
      print("Erreur lors de la récupération des rapports en attente: $e");
      return null;
    }
  }

  // NOUVEAU: Récupérer les détails d'un rapport (ADMIN - peut voir tous les statuts)
  static Future<Map<String, dynamic>?> getAdminReportDetails(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/admin/reports/$id"),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération des détails admin: $e");
      return null;
    }
  }

  // Mettre à jour le statut d'un rapport (ADMIN SEULEMENT)
  static Future<Map<String, dynamic>?> updateReportStatus(int id, String status, {String? adminComment}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/admin/reports/$id"),
        headers: headers,
        body: jsonEncode({
          "status": status,
          if (adminComment != null) "admin_comment": adminComment,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      print("Erreur updateReportStatus: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Erreur lors de la mise à jour du statut: $e");
      return null;
    }
  }

  // Accepter un rapport directement (ADMIN SEULEMENT)
  static Future<Map<String, dynamic>?> acceptReport(int id, {String? adminComment}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse("$baseUrl/admin/reports/$id/accept"),
        headers: headers,
        body: jsonEncode({
          if (adminComment != null) "admin_comment": adminComment,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      print("Erreur acceptReport: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Erreur lors de l'acceptation: $e");
      return null;
    }
  }

  // Rejeter un rapport directement (ADMIN SEULEMENT)
  static Future<Map<String, dynamic>?> rejectReport(int id, String adminComment) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse("$baseUrl/admin/reports/$id/reject"),
        headers: headers,
        body: jsonEncode({
          "admin_comment": adminComment,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      print("Erreur rejectReport: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Erreur lors du rejet: $e");
      return null;
    }
  }

  // Annuler l'acceptation d'un rapport (ADMIN SEULEMENT)
  static Future<Map<String, dynamic>?> cancelAcceptance(int id, {String? adminComment}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse("$baseUrl/admin/reports/$id/cancel-acceptance"),
        headers: headers,
        body: jsonEncode({
          if (adminComment != null) "admin_comment": adminComment,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      print("Erreur cancelAcceptance: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Erreur lors de l'annulation de l'acceptation: $e");
      return null;
    }
  }

  // Annuler le rejet d'un rapport (ADMIN SEULEMENT)
  static Future<Map<String, dynamic>?> cancelRejection(int id, {String? adminComment}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse("$baseUrl/admin/reports/$id/cancel-rejection"),
        headers: headers,
        body: jsonEncode({
          if (adminComment != null) "admin_comment": adminComment,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      print("Erreur cancelRejection: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Erreur lors de l'annulation du rejet: $e");
      return null;
    }
  }

  // Récupérer l'historique d'un rapport (ADMIN SEULEMENT)
  static Future<Map<String, dynamic>?> getReportHistory(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/admin/reports/$id/history"),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de l'historique: $e");
      return null;
    }
  }

  // ====================================
  // MÉTHODES ADMIN POUR LES PDFs - CORRIGÉES
  // ====================================

  // URL admin pour télécharger un PDF (avec auth)
  static String getAdminDownloadUrl(int reportId) {
    return "$baseUrl/admin/reports/$reportId/download";
  }

  // URL admin pour visualiser un PDF (avec auth)
  static String getAdminViewUrl(int reportId) {
    return "$baseUrl/admin/reports/$reportId/view";
  }

  // URL admin pour stream un PDF (avec auth)
  static String getAdminStreamUrl(int reportId) {
    return "$baseUrl/admin/reports/$reportId/stream";
  }

  // NOUVEAU: Créer une URL avec token pour url_launcher (admin)
  static Future<String?> getAdminPdfUrlWithAuth(int reportId, {String action = 'view'}) async {
    final token = await _getAuthToken();
    if (token == null) return null;
    
    String baseRoute;
    switch (action) {
      case 'download':
        baseRoute = getAdminDownloadUrl(reportId);
        break;
      case 'stream':
        baseRoute = getAdminStreamUrl(reportId);
        break;
      default:
        baseRoute = getAdminViewUrl(reportId);
    }
    
    // Ajouter le token comme paramètre d'URL (vous devrez peut-être ajuster selon votre backend)
    return "$baseRoute?token=$token";
  }

  // Télécharger un fichier PDF (admin avec auth)
  static Future<List<int>?> downloadAdminPdf(int reportId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(getAdminDownloadUrl(reportId)),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      print("Erreur téléchargement admin PDF: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Erreur lors du téléchargement admin: $e");
      return null;
    }
  }

  // NOUVEAU: Vérifier si un PDF admin existe
  static Future<bool> adminPdfExists(int reportId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.head(
        Uri.parse(getAdminViewUrl(reportId)),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur vérification PDF admin: $e");
      return false;
    }
  }

  // ====================================
  // MÉTHODES UTILITAIRES AMÉLIORÉES
  // ====================================

  // Vérifier si l'utilisateur est admin (vous pouvez améliorer cette méthode)
  static Future<bool> isAdmin() async {
    final token = await _getAuthToken();
    if (token == null) return false;
    
    // Option 1: Vérifier via une route admin simple
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/admin/reports?status=pending&limit=1"),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur vérification admin: $e");
      return false;
    }
  }

  // Télécharger un fichier PDF (PUBLIC)
  static Future<List<int>?> downloadPdf(int reportId) async {
    try {
      final response = await http.get(
        Uri.parse(getDownloadUrl(reportId)),
        headers: {'Accept': 'application/pdf'},
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print("Erreur lors du téléchargement: $e");
      return null;
    }
  }

  // Obtenir les statistiques des rapports (pour admin)
  static Future<Map<String, dynamic>?> getReportsStats() async {
    try {
      final result = await fetchReports();
      return result?['stats'];
    } catch (e) {
      print("Erreur lors de la récupération des stats: $e");
      return null;
    }
  }

  // NOUVEAU: Test de connectivité avec le serveur
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/reports"),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur test de connexion: $e");
      return false;
    }
  }

  // NOUVEAU: Méthode pour debug - voir tous les endpoints disponibles
  static Map<String, String> getAvailableEndpoints() {
    return {
      // Public endpoints
      'Public Reports': '$baseUrl/reports',
      'Public Report Details': '$baseUrl/reports/{id}',
      'Public PDF Download': '$baseUrl/reports/{id}/download',
      'Public PDF View': '$baseUrl/reports/{id}/view',
      'Public PDF Stream': '$baseUrl/reports/{id}/stream',
      
      // Admin endpoints
      'Admin Reports': '$baseUrl/admin/reports',
      'Admin Pending': '$baseUrl/admin/reports/pending',
      'Admin Report Details': '$baseUrl/admin/reports/{id}',
      'Admin PDF Download': '$baseUrl/admin/reports/{id}/download',
      'Admin PDF View': '$baseUrl/admin/reports/{id}/view',
      'Admin PDF Stream': '$baseUrl/admin/reports/{id}/stream',
      'Admin Update Status': '$baseUrl/admin/reports/{id}',
      'Admin Accept': '$baseUrl/admin/reports/{id}/accept',
      'Admin Reject': '$baseUrl/admin/reports/{id}/reject',
      'Admin Cancel Acceptance': '$baseUrl/admin/reports/{id}/cancel-acceptance',
      'Admin Cancel Rejection': '$baseUrl/admin/reports/{id}/cancel-rejection',
      'Admin History': '$baseUrl/admin/reports/{id}/history',
      
      // User endpoints
      'Submit Report': '$baseUrl/reports',
    };
  }
}