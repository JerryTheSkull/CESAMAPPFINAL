import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ==========================
  // HEADERS
  // ==========================
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ==========================
  // AUTH METHODS
  // ==========================

  /// Connexion utilisateur
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null) await _saveToken(data['token']);
        if (data['refresh_token'] != null) await _saveRefreshToken(data['refresh_token']);
        if (data['user'] != null) await _saveUserInfo(data['user']);

        return {
          'success': true,
          'message': 'Connexion réussie',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur de connexion',
          'error': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Inscription utilisateur
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nomComplet,
    String? telephone,
    String? nationalite,
    String? niveauEtude,
    String? domaineEtude,
    bool? isAmci,
    String? amciCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'nom_complet': nomComplet,
          if (telephone != null) 'telephone': telephone,
          if (nationalite != null) 'nationalite': nationalite,
          if (niveauEtude != null) 'niveau_etude': niveauEtude,
          if (domaineEtude != null) 'domaine_etude': domaineEtude,
          if (isAmci != null) 'is_amci': isAmci,
          if (amciCode != null) 'amci_code': amciCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Inscription réussie',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'inscription',
          'error': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'inscription: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Déconnexion
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/logout'),
        headers: await _getHeaders(),
      );

      await clearAuthData();

      return {
        'success': true,
        'message': 'Déconnexion réussie',
      };
    } catch (e) {
      await clearAuthData();
      return {
        'success': true,
        'message': 'Déconnexion réussie',
      };
    }
  }

  /// Rafraîchir le token
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      
      if (refreshToken == null) {
        return {
          'success': false,
          'message': 'Aucun refresh token disponible',
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/refresh'),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null) await _saveToken(data['token']);
        if (data['refresh_token'] != null) await _saveRefreshToken(data['refresh_token']);

        return {
          'success': true,
          'message': 'Token rafraîchi',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors du rafraîchissement',
          'error': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors du rafraîchissement: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Réinitialiser le mot de passe
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({'email': email.trim().toLowerCase()}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email de réinitialisation envoyé',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la réinitialisation',
          'error': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la réinitialisation: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Changer le mot de passe
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/auth/change-password'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Mot de passe modifié avec succès',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors du changement de mot de passe',
          'error': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors du changement de mot de passe: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Vérifier la validité du token
  static Future<bool> isTokenValid() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/auth/verify-token'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la vérification du token: $e');
      return false;
    }
  }

  // ==========================
  // LOCAL STORAGE
  // ==========================

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      print('Erreur lors de la récupération du refresh token: $e');
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('Erreur lors de la récupération de l\'ID utilisateur: $e');
      return null;
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('Erreur lors de la récupération de l\'email utilisateur: $e');
      return null;
    }
  }

  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Erreur lors de la sauvegarde du token: $e');
    }
  }

  static Future<void> _saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
    } catch (e) {
      print('Erreur lors de la sauvegarde du refresh token: $e');
    }
  }

  static Future<void> _saveUserInfo(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user['id'] != null) {
        await prefs.setString(_userIdKey, user['id'].toString());
      }
      if (user['email'] != null) {
        await prefs.setString(_userEmailKey, user['email'].toString());
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde des infos utilisateur: $e');
    }
  }

  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
    } catch (e) {
      print('Erreur lors du nettoyage des données d\'authentification: $e');
    }
  }
}
