import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiServiceResetPassword {
  // URLs corrigées pour correspondre au backend Laravel
  static const String baseUrl = 'http://172.26.153.145:8080/api/password-reset';

  static Future<Map<String, dynamic>> sendResetCode(String email) async {
    final url = Uri.parse('$baseUrl/send-code');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    final url = Uri.parse('$baseUrl/verify-code');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
      String email, String code, String newPassword, String token) async {
    final url = Uri.parse('$baseUrl/reset');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': newPassword,
          // Suppression de password_confirmation - pas nécessaire
          'token': token,
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decoded, 'message': decoded['message']};
      } else {
        return {
          'success': false,
          'status': response.statusCode,
          'message': decoded['message'] ?? 'Erreur inconnue'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'status': response.statusCode,
        'message': 'Réponse invalide du serveur'
      };
    }
  }
}