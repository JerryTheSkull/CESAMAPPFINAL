import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AmciBourseService {
  // ⚠️ adapte si besoin
  static const String baseUrl = 'http://172.26.153.145:8080/api';

  // Headers JSON par défaut (on y rajoute Authorization si token présent)
  Future<Map<String, String>> _jsonHeaders() async {
    final token = await _getAuthToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Headers pour multipart (NE PAS fixer Content-Type manuellement)
  Future<Map<String, String>> _multipartHeaders() async {
    final token = await _getAuthToken();
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Récupération du token depuis SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    // garde la même clé que le reste de ton app
    return prefs.getString('auth_token');
  }

  /// 🔎 Rechercher une bourse par matricule
  /// Retourne **uniquement** l'objet `data` (comme ton ancien service)
  Future<Map<String, dynamic>> getScholarshipByMatricule(String matricule) async {
    try {
      final uri = Uri.parse('$baseUrl/amci/scholarship/$matricule');
      final headers = await _jsonHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      final result = _handleResponse(response);

      if (result['success'] == true) {
        // renvoie seulement les données utiles
        return Map<String, dynamic>.from(result['body']['data'] ?? {});
      } else {
        throw Exception(result['message'] ?? 'Erreur lors de la recherche');
      }
    } catch (e) {
      // remonte une erreur claire à l’appelant
      throw Exception('Impossible de récupérer la bourse: $e');
    }
  }

  /// 📤 Importer un fichier Excel (ou CSV si autorisé côté backend)
  /// Retourne l'objet standard { success, status, body/message }
  Future<Map<String, dynamic>> importExcel(File file) async {
    try {
      final uri = Uri.parse('$baseUrl/amci/import-excel');
      final headers = await _multipartHeaders();

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(
          await http.MultipartFile.fromPath('file', file.path),
        );

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      // on uniformise la sortie comme les autres appels
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'status': 0,
        'message': 'Erreur lors de l\'upload: $e',
      };
    }
  }

  /// ⚙️ Gestion standardisée des réponses HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      // messages plus parlants pour 401/403
      String? message = body is Map<String, dynamic> ? body['message'] : null;
      if (response.statusCode == 401 && (message == null || message.isEmpty)) {
        message = 'Non authentifié. Veuillez vous reconnecter.';
      }
      if (response.statusCode == 403 && (message == null || message.isEmpty)) {
        message = 'Accès refusé. Droits administrateur requis.';
      }

      return {
        'status': response.statusCode,
        'body': body,
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': message ?? '',
      };
    } catch (_) {
      // Réponse non-JSON (ex: HTML d’erreur Nginx/Apache)
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'status': response.statusCode,
        'message': response.body.isNotEmpty
            ? 'Réponse non valide: ${response.body}'
            : 'Réponse vide (code ${response.statusCode})',
      };
    }
  }
}
