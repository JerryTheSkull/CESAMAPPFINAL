import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceNotification {
  final String token;
  final String baseUrl = 'http://172.26.153.145:8080/api';

  ApiServiceNotification({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Liste toutes les notifications (avec pagination)
  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final res = await http.get(Uri.parse('$baseUrl/notifications?page=$page'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur récupération notifications');
  }

  // Notifications non lues
  Future<Map<String, dynamic>> getUnreadNotifications() async {
    final res = await http.get(Uri.parse('$baseUrl/notifications/unread'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur récupération notifications non lues');
  }

  // Nombre de notifications non lues (pour badge)
  Future<int> getUnreadCount() async {
    final res = await http.get(Uri.parse('$baseUrl/notifications/unread-count'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body)['count'];
    throw Exception('Erreur récupération nombre notifications non lues');
  }

  // Marquer une notification comme lue
  Future<void> markAsRead(String id) async {
    final res = await http.patch(Uri.parse('$baseUrl/notifications/$id/read'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Erreur marquage notification comme lue');
  }

  // Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    final res = await http.patch(Uri.parse('$baseUrl/notifications/mark-all-read'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Erreur marquage toutes notifications comme lues');
  }

  // Supprimer une notification
  Future<void> deleteNotification(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/notifications/$id'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Erreur suppression notification');
  }
}
