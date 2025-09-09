import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cesam_user.dart';
import '../services/auth_service.dart';

class UserManagementService {
  static const String baseUrl = 'http://172.26.153.145:8080/api';
  
  // Headers avec authentification
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Gestion centralisée des erreurs HTTP
  static void _handleHttpError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage;
      try {
        final jsonData = json.decode(response.body);
        errorMessage = jsonData['message'] ?? 'Erreur HTTP ${response.statusCode}';
      } catch (e) {
        errorMessage = 'Erreur HTTP ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }

  /// GET /admin/users - Lister les utilisateurs avec filtres
  static Future<List<CesamUser>> getAllUsers({
    bool? verified,
    bool? approved,
    String? role,
    String? search,
  }) async {
    try {
      final headers = await _getHeaders();
      
      String url = '$baseUrl/admin/users';
      List<String> queryParams = [];
      
      if (verified != null) queryParams.add('verified=${verified ? 1 : 0}');
      if (approved != null) queryParams.add('approved=${approved ? 1 : 0}');
      if (role != null) queryParams.add('role=$role');
      if (search != null && search.isNotEmpty) queryParams.add('search=$search');
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      final response = await http.get(Uri.parse(url), headers: headers);
      _handleHttpError(response);
      
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        final List<dynamic> usersJson = jsonData['data'];
        return usersJson.map((json) => CesamUser.fromJson(json)).toList();
      } else {
        throw Exception(jsonData['message'] ?? 'Erreur lors du chargement');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  /// Récupérer seulement les utilisateurs vérifiés en attente d'approbation
  static Future<List<CesamUser>> getPendingUsers() async {
    return getAllUsers(verified: true, approved: false);
  }

  /// Récupérer seulement les utilisateurs approuvés
  static Future<List<CesamUser>> getApprovedUsers() async {
    return getAllUsers(approved: true);
  }

  /// GET /admin/stats - Statistiques des utilisateurs (CORRIGÉ)
  static Future<Map<String, dynamic>> getUsersStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'), // ✅ Endpoint corrigé
        headers: headers,
      );
      
      _handleHttpError(response);
      
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        return jsonData['data'] ?? jsonData['stats'] ?? {}; // Flexible selon votre retour API
      } else {
        throw Exception(jsonData['message'] ?? 'Erreur lors du chargement des stats');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des statistiques: $e');
    }
  }

  /// PATCH /admin/users/{id}/approval - Approuver/Désapprouver un utilisateur
  static Future<Map<String, dynamic>> approveUser(
    int userId, {
    required String action,
    String? reason,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'action': action,
        if (reason != null) 'reason': reason,
      });
      
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/approval'),
        headers: headers,
        body: body,
      );
      
      final jsonData = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200 && (jsonData['success'] ?? false),
        'message': jsonData['message'] ?? (response.statusCode == 200 ? 'Succès' : 'Erreur')
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'opération: $e'
      };
    }
  }

  /// PATCH /admin/users/{id}/role - Changer le rôle d'un utilisateur
  static Future<Map<String, dynamic>> changeUserRole(
    int userId, {
    required String role,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({'role': role});
      
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/role'),
        headers: headers,
        body: body,
      );
      
      final jsonData = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200 && (jsonData['success'] ?? false),
        'message': jsonData['message'] ?? (response.statusCode == 200 ? 'Succès' : 'Erreur')
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors du changement de rôle: $e'
      };
    }
  }

  /// DELETE /admin/users/{id} - Supprimer un utilisateur
  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: headers,
      );
      
      final jsonData = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200 && (jsonData['success'] ?? false),
        'message': jsonData['message'] ?? (response.statusCode == 200 ? 'Supprimé avec succès' : 'Erreur')
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la suppression: $e'
      };
    }
  }

  // ================ MÉTHODE DE DEBUG (optionnelle) ================
  
  /// Test de connexion à l'API admin
  static Future<bool> testAdminConnection() async {
    try {
      await getUsersStats();
      return true;
    } catch (e) {
      print('Erreur de connexion admin: $e');
      return false;
    }
  }
}