import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cesam_user.dart';
import '../models/registration_data.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';
import 'package:http_parser/http_parser.dart' show MediaType;

class ApiService {
  static const String baseUrl = 'http://172.26.153.145:8080/api';
  static const String registrationUrl = '$baseUrl/register/v2';
  static final Logger _logger = Logger();

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  // Sauvegarder le token d'authentification
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _logger.d('✅ Token d\'authentification sauvegardé');
  }

  // Récupérer le token d'authentification
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    _logger.d('🔍 Récupération token: ${token != null ? "présent" : "absent"}');
    return token;
  }

  // Sauvegarder le session_token
  static Future<void> saveSessionToken(String sessionToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', sessionToken);
    _logger.d('✅ Session token sauvegardé: ${sessionToken.substring(0, 8)}...');
  }

  // Récupérer le session_token
  static Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('session_token');
    _logger.d('🔍 Récupération session token: ${sessionToken != null ? "${sessionToken.substring(0, 8)}..." : "absent"}');
    return sessionToken;
  }

  // Nettoyer toutes les données utilisateur
  static Future<void> _clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('session_token');
    await prefs.remove('user_data');
    await prefs.remove('user_role');
    _logger.d('✅ Toutes les données utilisateur supprimées');
  }

  // Étape 1 : Informations personnelles
  static Future<Map<String, dynamic>> registerStep1({
    required String nomComplet,
    required String email,
    required String password,
    String? telephone,
    String? nationalite,
    String? sessionToken,
  }) async {
    try {
      _logger.d('🚀 API Step1 - URL: $registrationUrl/step1');
      final body = {
        'nom_complet': nomComplet,
        'email': email,
        'password': password,
        'telephone': telephone,
        'nationalite': nationalite,
        if (sessionToken != null) 'session_token': sessionToken,
      };
      _logger.d('📤 Step1 Request Body: $body');
      final response = await http.post(
        Uri.parse('$registrationUrl/step1'),
        headers: _defaultHeaders,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      _logger.d('📥 Step1 Response: ${response.statusCode}');

      final result = _handleResponse(response);
      if (result['success'] && result['body']['session_token'] != null) {
        await saveSessionToken(result['body']['session_token']);
      }
      return result;
    } catch (e) {
      _logger.e('❌ Erreur Step1: $e');
      rethrow;
    }
  }

  // Étape 2 : Éducation
  static Future<Map<String, dynamic>> registerStep2({
    required String sessionToken,
    required String ecole,
    required String filiere,
    required String niveauEtude,
    required String ville,
  }) async {
    try {
      _logger.d('🚀 API Step2 - URL: $registrationUrl/step2');
      final body = {
        'session_token': sessionToken,
        'ecole': ecole,
        'filiere': filiere,
        'niveau_etude': niveauEtude,
        'ville': ville,
      };
      _logger.d('📤 Step2 Request Body: $body');
      final response = await http.post(
        Uri.parse('$registrationUrl/step2'),
        headers: _defaultHeaders,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      _logger.d('📥 Step2 Response: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      _logger.e('❌ Erreur Step2: $e');
      rethrow;
    }
  }

  // Étape 3 : Profil académique avec upload de fichier - VERSION CORRIGÉE
  static Future<Map<String, dynamic>> registerStep3WithFile({
    required String sessionToken,
    File? cvFile,
    List<String>? competences,
    List<Map<String, dynamic>>? projects,
  }) async {
    final url = Uri.parse('$baseUrl/register/v2/step3');
    _logger.d('🚀 API Step3WithFile - URL: $url');

    final request = http.MultipartRequest('POST', url);
    request.headers['Accept'] = 'application/json';
    request.fields['session_token'] = sessionToken;

    // Add CV file if provided
    if (cvFile != null && await cvFile.exists()) {
      _logger.d('📄 Ajout du fichier CV: ${cvFile.path}');
      request.files.add(
        await http.MultipartFile.fromPath(
          'cv_file',
          cvFile.path,
          filename: path.basename(cvFile.path),
        ),
      );
    }

    // ✅ CORRECTION : Envoyer les compétences comme un tableau PHP
    if (competences != null && competences.isNotEmpty) {
      for (int i = 0; i < competences.length; i++) {
        request.fields['competences[$i]'] = competences[i];
      }
      _logger.d('📋 Compétences envoyées comme tableau: $competences');
    }

    // ✅ CORRECTION : Envoyer les projets comme un tableau PHP
    if (projects != null && projects.isNotEmpty) {
      for (int i = 0; i < projects.length; i++) {
        final project = projects[i];
        request.fields['projects[$i][title]'] = project['title']?.toString() ?? '';
        request.fields['projects[$i][description]'] = project['description']?.toString() ?? '';
        
        // Ajouter le lien seulement s'il existe et n'est pas vide
        if (project['link'] != null && 
            project['link'].toString().trim().isNotEmpty) {
          request.fields['projects[$i][link]'] = project['link'].toString().trim();
        }
      }
      _logger.d('📋 Projets envoyés comme tableau: $projects');
    }

    _logger.d('📤 Champs de la requête multipart: ${request.fields.keys.toList()}');
    _logger.d('📤 Valeurs des champs: ${request.fields}');
    
    try {
      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();
      
      _logger.d('📥 Step3WithFile Response Status: ${response.statusCode}');
      _logger.d('📥 Step3WithFile Response Body: $responseBody');
      
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(responseBody);
      } catch (e) {
        _logger.e('❌ Erreur décodage JSON Step3: $e');
        responseData = {'message': responseBody};
      }

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'status': response.statusCode,
        'body': responseData,
      };
    } catch (e) {
      _logger.e('❌ Erreur réseau Step3: $e');
      rethrow;
    }
  }

  // Étape 4 : AMCI
  static Future<Map<String, dynamic>> registerStep4({
    required String sessionToken,
    String? codeAmci,
    required bool affilieAmci,
  }) async {
    try {
      _logger.d('🚀 API Step4 - URL: $registrationUrl/step4');
      final response = await http.post(
        Uri.parse('$registrationUrl/step4'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'session_token': sessionToken,
          'code_amci': codeAmci,
          'affilie_amci': affilieAmci,
        }),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      _logger.e('❌ Erreur Step4: $e');
      rethrow;
    }
  }

  // Étape 5 : Vérification
  static Future<Map<String, dynamic>> registerStep5({
    required String sessionToken,
    required String code,
  }) async {
    try {
      _logger.d('🚀 API Step5 - URL: $registrationUrl/step5');
      final response = await http.post(
        Uri.parse('$registrationUrl/step5'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'session_token': sessionToken,
          'verification_code': code,
        }),
      ).timeout(const Duration(seconds: 15));

      final result = _handleResponse(response);
      if (result['success']) await _clearAllUserData();
      return result;
    } catch (e) {
      _logger.e('❌ Erreur Step5: $e');
      rethrow;
    }
  }

  // Renvoyer le code de vérification
  static Future<Map<String, dynamic>> resendVerificationCode({
    required String sessionToken,
  }) async {
    try {
      _logger.d('🚀 API Resend Code - URL: $registrationUrl/resend-code');
      final response = await http.post(
        Uri.parse('$registrationUrl/resend-code'),
        headers: _defaultHeaders,
        body: jsonEncode({'session_token': sessionToken}),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      _logger.e('❌ Erreur resend code: $e');
      rethrow;
    }
  }

  // Récupérer les données d'une étape
  static Future<Map<String, dynamic>> getStepData({
    required String sessionToken,
    required int stepNumber,
  }) async {
    try {
      _logger.d('🚀 API GetStepData - URL: $registrationUrl/step-data/$stepNumber');
      final response = await http.get(
        Uri.parse('$registrationUrl/step-data/$stepNumber?session_token=$sessionToken'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      _logger.e('❌ Erreur getStepData: $e');
      rethrow;
    }
  }

  // Obtenir l'état du processus d'inscription
  static Future<Map<String, dynamic>> getProcessStatus({
    required String sessionToken,
  }) async {
    try {
      _logger.d('🚀 API GetProcessStatus - URL: $registrationUrl/status');
      final response = await http.get(
        Uri.parse('$registrationUrl/status?session_token=$sessionToken'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      _logger.e('❌ Erreur getProcessStatus: $e');
      rethrow;
    }
  }

  // Abandonner une inscription
  static Future<Map<String, dynamic>> abandonRegistration({
    required String sessionToken,
  }) async {
    try {
      _logger.d('🚀 API AbandonRegistration - URL: $registrationUrl/abandon');
      final response = await http.post(
        Uri.parse('$registrationUrl/abandon'),
        headers: _defaultHeaders,
        body: jsonEncode({'session_token': sessionToken}),
      ).timeout(const Duration(seconds: 15));

      final result = _handleResponse(response);
      if (result['success']) await _clearAllUserData();
      return result;
    } catch (e) {
      _logger.e('❌ Erreur abandonRegistration: $e');
      rethrow;
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.d('🚀 API Login - URL: $baseUrl/login');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _defaultHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final result = _handleResponse(response);
      if (result['success'] && result['body']['access_token'] != null) {
        await saveToken(result['body']['access_token']);
        await saveUserData(result['body']);
      }
      return result;
    } catch (e) {
      _logger.e('❌ Erreur login: $e');
      rethrow;
    }
  }

  // Déconnexion
  static Future<Map<String, dynamic>> logout() async {
    try {
      _logger.d('🚪 API Logout - URL: $baseUrl/logout');
      final token = await getToken();
      if (token == null) {
        _logger.w('⚠️ Aucun token trouvé, déconnexion locale uniquement');
        await _clearAllUserData();
        return {
          'success': true,
          'status': 200,
          'body': {'message': 'Déconnecté localement'}
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      await _clearAllUserData();
      return _handleResponse(response);
    } catch (e) {
      _logger.e('❌ Erreur logout API: $e');
      await _clearAllUserData();
      return {
        'success': true,
        'status': 0,
        'body': {'message': 'Déconnecté localement (erreur serveur)'}
      };
    }
  }

  // Sauvegarder données utilisateur
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData['user'] ?? userData));
    if (userData['role'] != null) {
      await prefs.setString('user_role', userData['role']);
    }
    _logger.d('✅ Données utilisateur sauvegardées');
  }

  // Récupérer données utilisateur
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      try {
        return jsonDecode(userDataString);
      } catch (e) {
        _logger.e('❌ Erreur décodage données utilisateur: $e');
        return null;
      }
    }
    return null;
  }

  // Récupérer rôle utilisateur
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    _logger.d('🔍 Récupération rôle utilisateur: ${role ?? "absent"}');
    return role;
  }

  // Vérifier si connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final isLogged = token != null && token.isNotEmpty;
    _logger.d('🔍 État connexion: ${isLogged ? "connecté" : "non connecté"}');
    return isLogged;
  }

  // Gestion des réponses HTTP
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      return {
        'status': response.statusCode,
        'body': body,
        'success': response.statusCode >= 200 && response.statusCode < 300,
      };
    } catch (e) {
      _logger.e('❌ Erreur décodage réponse: $e');
      return {
        'status': response.statusCode,
        'body': {'message': response.body},
        'success': false,
      };
    }
  }

  // Test de connexion
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      _logger.d('🔌 API testConnection - URL: $baseUrl');
      final response = await http.get(
        Uri.parse('$baseUrl'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return {
        'success': true,
        'status': response.statusCode,
        'body': response.body,
      };
    } catch (e) {
      _logger.e('❌ Erreur testConnection: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}