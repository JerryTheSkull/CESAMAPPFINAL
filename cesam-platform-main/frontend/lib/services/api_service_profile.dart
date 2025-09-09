// services/api_service_profile.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceProfile {
  static const String baseUrl = 'http://172.26.153.145:8080/api';
  
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  // Utility to get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Profile CRUD
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      print('🔍 API getProfile - URL: $baseUrl/profile');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur récupération profil: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? nomComplet,
    String? email,
    String? telephone,
    String? nationalite,
    String? ecole,
    String? filiere,
    String? niveauEtude,
    String? ville,
    bool? affilieAmci,
    String? codeAmci,
    String? matriculeAmci,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      print('✏️ API updateProfile - URL: $baseUrl/profile');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final Map<String, dynamic> body = {};
      if (nomComplet != null && nomComplet.isNotEmpty) body['nom_complet'] = nomComplet;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (telephone != null) body['telephone'] = telephone;
      if (nationalite != null) body['nationalite'] = nationalite;
      if (ecole != null) body['ecole'] = ecole;
      if (filiere != null) body['filiere'] = filiere;
      if (niveauEtude != null) body['niveau_etude'] = niveauEtude;
      if (ville != null) body['ville'] = ville;
      if (affilieAmci != null) body['affilie_amci'] = affilieAmci;
      if (codeAmci != null) body['code_amci'] = codeAmci;
      if (matriculeAmci != null) body['matricule_amci'] = matriculeAmci;
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
        body['password_confirmation'] = passwordConfirmation ?? password;
      }

      print('📤 Données envoyées: $body');

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur mise à jour profil: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      print('🗑️ API deleteAccount - URL: $baseUrl/profile');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/profile'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await _clearAllUserData();
      }

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur suppression compte: $e');
      rethrow;
    }
  }

  // Personal Info
  static Future<Map<String, dynamic>> updatePersonalInfo({
    String? telephone,
    String? ville,
    bool? affilieAmci,
    String? codeAmci,
    String? matriculeAmci,
  }) async {
    try {
      print('✏️ API updatePersonalInfo - URL: $baseUrl/profile/personal-info');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final Map<String, dynamic> body = {};
      if (telephone != null) body['telephone'] = telephone;
      if (ville != null) body['ville'] = ville;
      if (affilieAmci != null) body['affilie_amci'] = affilieAmci;
      if (codeAmci != null) body['code_amci'] = codeAmci;
      if (matriculeAmci != null) body['matricule_amci'] = matriculeAmci;

      print('📤 Données personnelles envoyées: $body');

      final response = await http.put(
        Uri.parse('$baseUrl/profile/personal-info'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur mise à jour infos personnelles: $e');
      rethrow;
    }
  }

  // Academic Info
  static Future<Map<String, dynamic>> updateAcademicInfo({
    String? ecole,
    String? filiere,
    String? niveauEtude,
  }) async {
    try {
      print('✏️ API updateAcademicInfo - URL: $baseUrl/profile/academic-info');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final Map<String, dynamic> body = {};
      if (ecole != null) body['ecole'] = ecole;
      if (filiere != null) body['filiere'] = filiere;
      if (niveauEtude != null) body['niveau_etude'] = niveauEtude;

      print('📤 Données académiques envoyées: $body');

      final response = await http.put(
        Uri.parse('$baseUrl/profile/academic-info'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur mise à jour infos académiques: $e');
      rethrow;
    }
  }

  // Skills
  static Future<Map<String, dynamic>> addSkill(String skill) async {
    try {
      print('➕ API addSkill - URL: $baseUrl/profile/skills');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/profile/skills'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'skill': skill}),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur ajout compétence: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateAllSkills(List<String> skills) async {
    try {
      print('✏️ API updateAllSkills - URL: $baseUrl/profile/skills');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/profile/skills'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'skills': skills}),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur mise à jour compétences: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> removeSkill(String skill) async {
    try {
      print('❌ API removeSkill - URL: $baseUrl/profile/skills');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/profile/skills'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'skill': skill}),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur suppression compétence: $e');
      rethrow;
    }
  }

  // File Uploads
  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      print('📸 API uploadProfilePhoto - URL: $baseUrl/profile/photo');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/photo'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur upload photo: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteProfilePhoto() async {
    try {
      print('🗑️ API deleteProfilePhoto - URL: $baseUrl/profile/photo');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/profile/photo'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur suppression photo: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> uploadCV(File pdfFile) async {
    try {
      print('📄 API uploadCV - URL: $baseUrl/profile/cv');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/cv'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('cv', pdfFile.path),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur upload CV: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteCV() async {
    try {
      print('🗑️ API deleteCV - URL: $baseUrl/profile/cv');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/profile/cv'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur suppression CV: $e');
      rethrow;
    }
  }

  static Future<List<int>> downloadCV() async {
    try {
      print('⬇️ API downloadCV - URL: $baseUrl/profile/cv/download');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/cv/download'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Erreur téléchargement CV');
      }
    } catch (e) {
      print('❌ Erreur téléchargement CV: $e');
      rethrow;
    }
  }

  // Project Methods
  static Future<Map<String, dynamic>> getProjects() async {
    try {
      print('📋 API getProjects - URL: $baseUrl/profile/projects');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/projects'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur récupération projets: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProject(String projectId) async {
    try {
      print('📋 API getProject - URL: $baseUrl/profile/projects/$projectId');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/projects/$projectId'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur récupération projet: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> addProject({
    required String title,
    required String description,
    String? link,
  }) async {
    try {
      print('➕ API addProject - URL: $baseUrl/profile/projects');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final data = {
        'title': title.trim(),
        'description': description.trim(),
        if (link != null && link.trim().isNotEmpty) 'link': link,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/profile/projects'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur ajout projet: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateProject({
    required String projectId,
    required String title,
    required String description,
    String? link,
  }) async {
    try {
      print('✏️ API updateProject - URL: $baseUrl/profile/projects/$projectId');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final data = {
        'title': title.trim(),
        'description': description.trim(),
        if (link != null && link.trim().isNotEmpty) 'link': link,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/profile/projects/$projectId'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur mise à jour projet: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteProject(String projectId) async {
    try {
      print('🗑️ API deleteProject - URL: $baseUrl/profile/projects/$projectId');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/profile/projects/$projectId'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur suppression projet: $e');
      rethrow;
    }
  }

  // Options
  static Future<Map<String, dynamic>> getOptions() async {
    try {
      print('📋 API getOptions - URL: $baseUrl/profile/options');
      
      final response = await http.get(
        Uri.parse('$baseUrl/profile/options'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur récupération options: $e');
      rethrow;
    }
  }

  // Debug Methods
  static Future<Map<String, dynamic>> testConnectivity() async {
    try {
      print('🌐 Test de connectivité API...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      return {
        'success': response.statusCode == 200,
        'status': response.statusCode,
        'message': response.statusCode == 200 ? 'Connectivité OK' : 'Erreur de connectivité',
      };
    } catch (e) {
      print('❌ Erreur de connectivité: $e');
      return {
        'success': false,
        'status': 0,
        'message': 'Impossible de se connecter au serveur: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> testTokenValidity() async {
    try {
      print('🔑 Test de validité du token...');
      
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token manquant',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return {
        'success': response.statusCode == 200,
        'status': response.statusCode,
        'message': response.statusCode == 200 ? 'Token valide' : 'Token invalide ou expiré',
      };
    } catch (e) {
      print('❌ Erreur test token: $e');
      return {
        'success': false,
        'message': 'Erreur lors du test du token: $e',
      };
    }
  }

  // Private Methods
  static Future<void> _clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('session_token');
    await prefs.remove('user_data');
    await prefs.remove('user_role');
    print('✅ Toutes les données utilisateur supprimées');
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      print('📥 ========== RÉPONSE API ==========');
      print('📥 Status Code: ${response.statusCode}');
      print('📥 Headers: ${response.headers}');
      print('📥 Content-Length: ${response.contentLength ?? 'N/A'}');
      print('📥 Body: ${response.body}');
      print('📥 ================================');
      
      final body = jsonDecode(response.body);
      
      final result = {
        'status': response.statusCode,
        'body': body,
        'success': response.statusCode >= 200 && response.statusCode < 300,
      };
      
      if (!result['success']) {
        print('❌ ========== ERREUR API ==========');
        print('❌ Status: ${response.statusCode}');
        print('❌ Message: ${body['message'] ?? body['error'] ?? 'Erreur inconnue'}');
        if (body['errors'] != null) {
          print('❌ Détails: ${body['errors']}');
        }
        print('❌ ================================');
      } else {
        print('✅ Requête réussie: ${response.statusCode}');
      }
      
      return result;
    } catch (e) {
      print('❌ ========== ERREUR PARSING ==========');
      print('❌ Erreur JSON: $e');
      print('❌ Status Code: ${response.statusCode}');
      print('❌ Body brut: ${response.body}');
      print('❌ =====================================');
      
      return {
        'status': response.statusCode,
        'body': {'message': response.body.isEmpty ? 'Réponse vide' : response.body},
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'parseError': true,
      };
    }
  }
}

class ValidationException implements Exception {
  final String message;
  
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}