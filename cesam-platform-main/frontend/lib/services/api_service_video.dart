import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VideoApiService {
  static const String baseUrl = 'http://172.26.153.145:8080/api';
  
  // Headers par défaut
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers avec authentification
  static Map<String, String> _authHeaders(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  // ====================================
  // MÉTHODES PUBLIQUES (pour les étudiants)
  // ====================================

  /// Récupérer toutes les vidéos actives
  static Future<Map<String, dynamic>> getVideos({
    String? theme,
    bool includeLive = false,
  }) async {
    try {
      String url = '$baseUrl/videos';
      Map<String, String> queryParams = {};
      
      if (theme != null && theme.isNotEmpty) {
        queryParams['theme'] = theme;
      }
      
      if (includeLive) {
        queryParams['include_live'] = 'true';
      }

      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des vidéos',
          'error': 'Code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Récupérer une vidéo spécifique (incrémente les vues)
  static Future<Map<String, dynamic>> getVideo(int videoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos/$videoId'),
        headers: _headers,
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Récupérer le live en cours
  static Future<Map<String, dynamic>> getLiveVideo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos/live'),
        headers: _headers,
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Récupérer la liste des thèmes disponibles
  static Future<Map<String, dynamic>> getThemes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos/themes'),
        headers: _headers,
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  // ====================================
  // MÉTHODES ADMIN (nécessitent authentification)
  // ====================================

  /// Récupérer toutes les vidéos (admin) avec filtres
  static Future<Map<String, dynamic>> getAdminVideos(
    String token, {
    String? status, // 'active', 'inactive'
    String? search,
    String? sortBy = 'created_at',
    String? sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'sort_by': sortBy!,
        'sort_order': sortOrder!,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      String url = '$baseUrl/admin/videos?' + queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await http.get(
        Uri.parse(url),
        headers: _authHeaders(token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Créer une nouvelle vidéo (admin)
  static Future<Map<String, dynamic>> createVideo(
    String token, {
    required String titre,
    String? description,
    required String url,
    required String theme,
    bool isLive = false,
    int? duree,
    DateTime? datePublication,
  }) async {
    try {
      Map<String, dynamic> data = {
        'titre': titre,
        'url': url,
        'theme': theme,
        'is_live': isLive,
      };

      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      
      if (duree != null) {
        data['duree'] = duree;
      }
      
      if (datePublication != null) {
        data['date_publication'] = datePublication.toIso8601String();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/admin/videos'),
        headers: _authHeaders(token),
        body: json.encode(data),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Récupérer une vidéo pour édition (admin)
  static Future<Map<String, dynamic>> getAdminVideo(String token, int videoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/videos/$videoId'),
        headers: _authHeaders(token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Mettre à jour une vidéo (admin)
  static Future<Map<String, dynamic>> updateVideo(
    String token,
    int videoId, {
    String? titre,
    String? description,
    String? url,
    String? theme,
    bool? isLive,
    bool? isActive,
    int? duree,
    DateTime? datePublication,
  }) async {
    try {
      Map<String, dynamic> data = {};

      if (titre != null) data['titre'] = titre;
      if (description != null) data['description'] = description;
      if (url != null) data['url'] = url;
      if (theme != null) data['theme'] = theme;
      if (isLive != null) data['is_live'] = isLive;
      if (isActive != null) data['is_active'] = isActive;
      if (duree != null) data['duree'] = duree;
      if (datePublication != null) data['date_publication'] = datePublication.toIso8601String();

      final response = await http.put(
        Uri.parse('$baseUrl/admin/videos/$videoId'),
        headers: _authHeaders(token),
        body: json.encode(data),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Supprimer une vidéo (admin)
  static Future<Map<String, dynamic>> deleteVideo(String token, int videoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/videos/$videoId'),
        headers: _authHeaders(token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Activer/Désactiver une vidéo (admin)
  static Future<Map<String, dynamic>> toggleVideoStatus(String token, int videoId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/videos/$videoId/toggle-status'),
        headers: _authHeaders(token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Dupliquer une vidéo (admin)
  static Future<Map<String, dynamic>> duplicateVideo(String token, int videoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/videos/$videoId/duplicate'),
        headers: _authHeaders(token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Programmer la publication d'une vidéo (admin)
  static Future<Map<String, dynamic>> scheduleVideo(
    String token,
    int videoId,
    DateTime datePublication,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/videos/$videoId/schedule'),
        headers: _authHeaders(token),
        body: json.encode({
          'date_publication': datePublication.toIso8601String(),
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Upload d'une miniature (admin)
  static Future<Map<String, dynamic>> uploadThumbnail(
    String token,
    int videoId,
    File imageFile,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin/videos/$videoId/thumbnail'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'thumbnail',
        imageFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'upload',
        'error': e.toString()
      };
    }
  }

  /// Suppression en lot (admin)
  static Future<Map<String, dynamic>> bulkDeleteVideos(
    String token,
    List<int> videoIds,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/videos/bulk'),
        headers: _authHeaders(token),
        body: json.encode({
          'video_ids': videoIds,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Modifier le statut en lot (admin)
  static Future<Map<String, dynamic>> bulkUpdateStatus(
    String token,
    List<int> videoIds,
    bool isActive,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/videos/bulk-status'),
        headers: _authHeaders(token),
        body: json.encode({
          'video_ids': videoIds,
          'is_active': isActive,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Récupérer les statistiques (admin)
  static Future<Map<String, dynamic>> getVideoStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/videos/stats/dashboard'),
        headers: _authHeaders(token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Récupérer les thèmes avec compteurs (admin)
  static Future<Map<String, dynamic>> getAdminThemes(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/videos/themes/management'),
        headers: _authHeaders(token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  // ====================================
  // MÉTHODES UTILITAIRES
  // ====================================

  /// Valider une URL de vidéo
  static bool isValidVideoUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute) return false;
    
    // Vérifier les domaines supportés (YouTube, Vimeo, etc.)
    final supportedDomains = [
      'youtube.com',
      'youtu.be',
      'vimeo.com',
      'dailymotion.com',
      'facebook.com',
      'drive.google.com',
    ];
    
    return supportedDomains.any((domain) => 
        uri.host.contains(domain) || uri.host == domain);
  }

  /// Extraire l'ID d'une vidéo YouTube
  static String? extractYouTubeId(String url) {
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  /// Générer une URL de miniature YouTube
  static String? getYouTubeThumbnail(String url) {
    final videoId = extractYouTubeId(url);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return null;
  }

  /// Formater la durée en format lisible
  static String formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return 'Durée inconnue';
    
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    } else {
      return '${minutes}min ${secs.toString().padLeft(2, '0')}s';
    }
  }

  /// Formater le nombre de vues
  static String formatViews(int? views) {
    if (views == null || views == 0) return 'Aucune vue';
    
    if (views < 1000) {
      return '$views vue${views > 1 ? 's' : ''}';
    } else if (views < 1000000) {
      return '${(views / 1000).toStringAsFixed(1)}k vues';
    } else {
      return '${(views / 1000000).toStringAsFixed(1)}M vues';
    }
  }

  /// Vérifier si une vidéo est récente (moins de 7 jours)
  static bool isRecentVideo(String? datePublication) {
    if (datePublication == null) return false;
    
    try {
      final pubDate = DateTime.parse(datePublication);
      final now = DateTime.now();
      final difference = now.difference(pubDate).inDays;
      return difference <= 7;
    } catch (e) {
      return false;
    }
  }

  // ====================================
  // MÉTHODES DE GESTION D'ERREURS
  // ====================================

  /// Traiter la réponse API et extraire les erreurs
  static Map<String, dynamic> handleApiResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur inconnue',
          'errors': data['errors'] ?? {},
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de parsing JSON',
        'error': e.toString(),
        'status_code': response.statusCode,
      };
    }
  }

  /// Vérifier la connectivité au serveur
  static Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }

  // ====================================
  // MÉTHODES LIKES (nécessitent authentification)
  // ====================================

  /// Liker/Unliker une vidéo
  static Future<Map<String, dynamic>> toggleLike(String token, int videoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/videos/$videoId/toggle-like'),
        headers: _authHeaders(token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Vérifier le statut d'un like pour une vidéo
  static Future<Map<String, dynamic>> getLikeStatus(String token, int videoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos/$videoId/like-status'),
        headers: _authHeaders(token),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
        'error': e.toString()
      };
    }
  }

  /// Formater le nombre de likes
  static String formatLikes(int? likes) {
    if (likes == null || likes == 0) return 'Aucun like';
    
    if (likes < 1000) {
      return '$likes like${likes > 1 ? 's' : ''}';
    } else if (likes < 1000000) {
      return '${(likes / 1000).toStringAsFixed(1)}k likes';
    } else {
      return '${(likes / 1000000).toStringAsFixed(1)}M likes';
    }
  }
}