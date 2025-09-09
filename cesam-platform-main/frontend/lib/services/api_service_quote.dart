// services/api_service_quote.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class ApiServiceQuote {
  static const String baseUrl = 'http://172.26.153.145:8080/api';

  // Récupération du token depuis SharedPreferences
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

  // Headers publics (sans token)
  static Map<String, String> get _publicHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // =============== GESTION STANDARDISÉE DES RÉPONSES ===============

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

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
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'status': response.statusCode,
        'message': response.body.isNotEmpty
            ? 'Réponse non valide: ${response.body}'
            : 'Réponse vide (code ${response.statusCode})',
      };
    }
  }

  // =============== ROUTES PUBLIQUES ===============

  /// Récupère la dernière citation publiée (route publique)
  static Future<Quote?> getLatestQuote() async {
    try {
      debugPrint("🔄 [PUBLIC] Récupération de la dernière citation...");
      
      final response = await http.get(
        Uri.parse('$baseUrl/quote/latest'),
        headers: _publicHeaders,
      );

      final result = _handleResponse(response);
      
      if (result['success'] == true && result['body'] != null) {
        final data = result['body'];
        if (data['success'] == true && data['data'] != null) {
          debugPrint("✅ Citation récupérée");
          return Quote.fromJson(data['data']);
        }
      }
      
      debugPrint("ℹ️ Aucune citation disponible");
      return null;
    } catch (e) {
      debugPrint("❌ Erreur getLatestQuote: $e");
      return null; // ne doit pas planter l'app
    }
  }

  // =============== ROUTES ADMIN ===============

  /// Récupère toutes les citations (publiées et non publiées) - Admin seulement
  static Future<Map<String, dynamic>?> getQuotes() async {
    try {
      debugPrint("🔄 [ADMIN] Récupération des citations...");
      
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/quotes'),
        headers: headers,
      );

      final result = _handleResponse(response);
      
      if (result['success'] == true) {
        final data = result['body'];
        debugPrint("✅ Citations publiées: ${data['published']?.length ?? 0}");
        debugPrint("✅ Citations en attente: ${data['unpublished']?.length ?? 0}");
        return data;
      } else {
        throw Exception(result['message'] ?? 'Erreur lors de la récupération des citations');
      }
    } catch (e) {
      debugPrint("❌ Erreur getQuotes: $e");
      throw Exception("Impossible de récupérer les citations: $e");
    }
  }

  /// Crée une nouvelle citation - Admin seulement
  static Future<Quote?> createQuote(String text, String author) async {
    try {
      debugPrint("🔄 [ADMIN] Création citation...");
      
      final headers = await _getAuthHeaders();
      final body = jsonEncode({'text': text, 'author': author});

      final response = await http.post(
        Uri.parse('$baseUrl/admin/quotes'),
        headers: headers,
        body: body,
      );

      final result = _handleResponse(response);
      
      if (result['success'] == true) {
        debugPrint("✅ Citation créée avec succès");
        return Quote.fromJson(result['body']);
      } else {
        throw Exception(result['message'] ?? 'Erreur lors de la création');
      }
    } catch (e) {
      debugPrint("❌ Erreur createQuote: $e");
      throw Exception("Impossible de créer la citation: $e");
    }
  }

  /// Met à jour une citation existante - Admin seulement
  static Future<Quote?> updateQuote(int id, {String? text, String? author}) async {
    try {
      debugPrint("🔄 [ADMIN] Modification citation $id...");
      
      final Map<String, dynamic> updateData = {};
      if (text != null) updateData['text'] = text;
      if (author != null) updateData['author'] = author;

      final headers = await _getAuthHeaders();
      final body = jsonEncode(updateData);

      final response = await http.put(
        Uri.parse('$baseUrl/admin/quotes/$id'),
        headers: headers,
        body: body,
      );

      final result = _handleResponse(response);
      
      if (result['success'] == true) {
        debugPrint("✅ Citation modifiée");
        return Quote.fromJson(result['body']);
      } else {
        throw Exception(result['message'] ?? 'Erreur lors de la modification');
      }
    } catch (e) {
      debugPrint("❌ Erreur updateQuote: $e");
      throw Exception("Impossible de modifier la citation: $e");
    }
  }

  /// Supprime une citation - Admin seulement
  static Future<bool> deleteQuote(int id) async {
    try {
      debugPrint("🔄 [ADMIN] Suppression citation $id...");
      
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/quotes/$id'),
        headers: headers,
      );

      final result = _handleResponse(response);
      
      if (result['success'] == true) {
        debugPrint("✅ Citation supprimée");
        return true;
      } else {
        debugPrint("❌ Erreur suppression: ${result['message']}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Erreur deleteQuote: $e");
      return false;
    }
  }

  /// Publie une citation - Admin seulement
  static Future<Quote?> publishQuote(int id) async {
    try {
      debugPrint("🔄 [ADMIN] Publication citation $id...");
      
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/quotes/$id/publish'),
        headers: headers,
      );

      final result = _handleResponse(response);
      
      if (result['success'] == true) {
        debugPrint("✅ Citation publiée");
        final data = result['body'];
        if (data['quote'] != null) {
          return Quote.fromJson(data['quote']);
        }
        return null;
      } else {
        throw Exception(result['message'] ?? 'Erreur lors de la publication');
      }
    } catch (e) {
      debugPrint("❌ Erreur publishQuote: $e");
      throw Exception("Impossible de publier la citation: $e");
    }
  }

  /// Dépublie une citation - Admin seulement
  static Future<Quote?> unpublishQuote(int id) async {
    try {
      debugPrint("🔄 [ADMIN] Dépublication citation $id...");
      
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/quotes/$id/unpublish'),
        headers: headers,
      );

      final result = _handleResponse(response);
      
      if (result['success'] == true) {
        debugPrint("✅ Citation dépubliée");
        final data = result['body'];
        if (data['quote'] != null) {
          return Quote.fromJson(data['quote']);
        }
        return null;
      } else {
        throw Exception(result['message'] ?? 'Erreur lors de la dépublication');
      }
    } catch (e) {
      debugPrint("❌ Erreur unpublishQuote: $e");
      throw Exception("Impossible de dépublier la citation: $e");
    }
  }

  // =============== DEBUG ===============

  /// Debug des citations - Développement seulement
  static Future<Map<String, dynamic>?> debugQuotes() async {
    try {
      debugPrint("🔧 [DEBUG] Récupération des informations de debug...");
      
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/debug/quotes-debug'),
        headers: headers,
      );

      final result = _handleResponse(response);
      
      if (result['success'] == true) {
        final data = result['body'];
        debugPrint("✅ Debug quotes récupéré:");
        debugPrint("  Total: ${data['total_quotes']}");
        debugPrint("  Publiées: ${data['published_quotes']}");
        debugPrint("  Non publiées: ${data['unpublished_quotes']}");
        return data;
      }
      return null;
    } catch (e) {
      debugPrint("❌ Erreur debugQuotes: $e");
      return null;
    }
  }

  // =============== MÉTHODES UTILITAIRES ===============

  /// Valide les données avant envoi
  static bool validateQuoteData(String text, String author) {
    if (text.trim().isEmpty) {
      debugPrint("⚠️ Validation: Le texte de la citation est vide");
      return false;
    }
    if (author.trim().isEmpty) {
      debugPrint("⚠️ Validation: L'auteur de la citation est vide");
      return false;
    }
    if (text.length > 1000) {
      debugPrint("⚠️ Validation: Le texte de la citation est trop long (max 1000 caractères)");
      return false;
    }
    if (author.length > 255) {
      debugPrint("⚠️ Validation: Le nom de l'auteur est trop long (max 255 caractères)");
      return false;
    }
    return true;
  }

  /// Crée une citation avec validation
  static Future<Quote?> createQuoteWithValidation(String text, String author) async {
    if (!validateQuoteData(text, author)) {
      throw Exception("Données de citation invalides");
    }
    return await createQuote(text.trim(), author.trim());
  }

  /// Met à jour une citation avec validation
  static Future<Quote?> updateQuoteWithValidation(int id, {String? text, String? author}) async {
    if (text != null && text.trim().isEmpty) {
      throw Exception("Le texte de la citation ne peut pas être vide");
    }
    if (author != null && author.trim().isEmpty) {
      throw Exception("L'auteur ne peut pas être vide");
    }
    if (text != null && text.length > 1000) {
      throw Exception("Le texte de la citation est trop long (max 1000 caractères)");
    }
    if (author != null && author.length > 255) {
      throw Exception("Le nom de l'auteur est trop long (max 255 caractères)");
    }

    return await updateQuote(
      id,
      text: text?.trim(),
      author: author?.trim(),
    );
  }

  /// Test de connexion aux routes citations
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{};

    try {
      debugPrint("🔧 Test de connexion aux routes citations...");

      // Test route publique
      try {
        final publicRes = await http.get(
          Uri.parse('$baseUrl/quote/latest'),
          headers: _publicHeaders,
        );
        results['public_route'] = {
          'status': publicRes.statusCode,
          'success': publicRes.statusCode >= 200 && publicRes.statusCode < 300,
        };
        debugPrint("📡 Route publique: ${publicRes.statusCode}");
      } catch (e) {
        results['public_route'] = {'status': -1, 'success': false, 'error': e.toString()};
      }

      // Test route admin
      try {
        final headers = await _getAuthHeaders();
        final adminRes = await http.get(
          Uri.parse('$baseUrl/admin/quotes'),
          headers: headers,
        );
        results['admin_route'] = {
          'status': adminRes.statusCode,
          'success': adminRes.statusCode >= 200 && adminRes.statusCode < 300,
        };
        debugPrint("📡 Route admin: ${adminRes.statusCode}");
      } catch (e) {
        results['admin_route'] = {'status': -1, 'success': false, 'error': e.toString()};
      }

      return results;
    } catch (e) {
      debugPrint("❌ Erreur testConnection: $e");
      results['general_error'] = e.toString();
      return results;
    }
  }

  /// Vérifier si l'utilisateur est admin
  static Future<bool> isAdmin() async {
    final token = await _getAuthToken();
    if (token == null) return false;

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/quotes'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erreur vérification admin: $e");
      return false;
    }
  }

  /// Obtenir tous les endpoints disponibles
  static Map<String, String> getAvailableEndpoints() {
    return {
      // Route publique
      'Latest Quote': '$baseUrl/quote/latest',
      
      // Routes admin
      'Admin Quotes': '$baseUrl/admin/quotes',
      'Admin Create Quote': '$baseUrl/admin/quotes',
      'Admin Update Quote': '$baseUrl/admin/quotes/{id}',
      'Admin Delete Quote': '$baseUrl/admin/quotes/{id}',
      'Admin Publish Quote': '$baseUrl/admin/quotes/{id}/publish',
      'Admin Unpublish Quote': '$baseUrl/admin/quotes/{id}/unpublish',
      
      // Route debug
      'Debug Quotes': '$baseUrl/debug/quotes-debug',
    };
  }
}