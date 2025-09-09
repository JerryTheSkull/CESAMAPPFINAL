class ApiConstants {
  // Configuration de l'environnement
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'development');
  
  // URLs de base selon l'environnement
  static const Map<String, String> _baseUrls = {
    'development': 'http://localhost:8000/api',
    'staging': 'https://staging-api.cesam.com/api',
    'production': 'https://api.cesam.com/api',
  };

  /// URL de base de l'API selon l'environnement
  static String get baseUrl => _baseUrls[_env] ?? _baseUrls['development']!;

  // Endpoints d'authentification
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String verifyTokenEndpoint = '/auth/verify-token';

  // Endpoints utilisateur
  static const String profileEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/profile';
  static const String userRoleEndpoint = '/users/role';
  static const String uploadAvatarEndpoint = '/users/avatar';
  static const String academicLevelEndpoint = '/users/academic-level';
  static const String skillsEndpoint = '/users/skills';
  static const String projectsEndpoint = '/users/projects';
  static const String cvEndpoint = '/users/cv';

  // Endpoints offres d'emploi
  static const String jobOffersEndpoint = '/job-offers';
  static const String jobOfferDetailsEndpoint = '/job-offers';
  static const String applyJobEndpoint = '/job-offers';
  static const String myApplicationsEndpoint = '/job-applications/my-applications';

  // Endpoints entreprises
  static const String companiesEndpoint = '/companies';
  static const String companyDetailsEndpoint = '/companies';
  static const String companyJobsEndpoint = '/companies';

  // Endpoints candidatures
  static const String applicationsEndpoint = '/job-applications';
  static const String applicationDetailsEndpoint = '/job-applications';

  // Endpoints notifications
  static const String notificationsEndpoint = '/notifications';
  static const String markNotificationReadEndpoint = '/notifications';
  static const String markAllNotificationsReadEndpoint = '/notifications/mark-all-read';

  // Endpoints recherche
  static const String searchEndpoint = '/search';
  static const String suggestionsEndpoint = '/search/suggestions';

  // Endpoints statistiques
  static const String statsEndpoint = '/stats';
  static const String userStatsEndpoint = '/stats/user';
  static const String companyStatsEndpoint = '/stats/company';

  // Headers communs
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static const Map<String, String> multipartHeaders = {
    'Accept': 'application/json',
  };

  static Map<String, String> authMultipartHeaders(String token) => {
    ...multipartHeaders,
    'Authorization': 'Bearer $token',
  };

  // Configuration de timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Tailles de fichiers
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxCvSize = 10 * 1024 * 1024; // 10MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB

  // Types de fichiers acceptés
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedCvExtensions = ['pdf'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Status codes personnalisés
  static const int tokenExpired = 401;
  static const int accessDenied = 403;
  static const int notFound = 404;
  static const int validationError = 422;
  static const int serverError = 500;

  // Messages d'erreur par défaut
  static const Map<int, String> defaultErrorMessages = {
    400: 'Requête invalide',
    401: 'Non autorisé - Veuillez vous reconnecter',
    403: 'Accès refusé',
    404: 'Ressource non trouvée',
    422: 'Données invalides',
    429: 'Trop de requêtes - Veuillez patienter',
    500: 'Erreur serveur - Veuillez réessayer plus tard',
    502: 'Service temporairement indisponible',
    503: 'Service en maintenance',
  };

  // Configuration cache
  static const Duration cacheExpiration = Duration(minutes: 5);
  static const Duration longCacheExpiration = Duration(hours: 1);

  // Paramètres de recherche
  static const int minSearchLength = 2;
  static const int maxSearchLength = 100;
  static const int searchResultsLimit = 50;

  // Configuration de retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Types de contenu
  static const String jsonContentType = 'application/json';
  static const String formDataContentType = 'multipart/form-data';
  static const String urlEncodedContentType = 'application/x-www-form-urlencoded';

  // Clés de stockage local
  static const String tokenStorageKey = 'auth_token';
  static const String refreshTokenStorageKey = 'refresh_token';
  static const String userStorageKey = 'user_data';
  static const String settingsStorageKey = 'app_settings';

  // Configuration de logging (pour debug)
  static const bool enableApiLogging = true;
  static const bool logRequestBody = true;
  static const bool logResponseBody = true;

  // URLs complètes couramment utilisées
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get profileUrl => '$baseUrl$profileEndpoint';
  static String get jobOffersUrl => '$baseUrl$jobOffersEndpoint';
  
  // Méthodes utilitaires
  static String getJobOfferUrl(String jobId) => '$baseUrl$jobOfferDetailsEndpoint/$jobId';
  static String getCompanyUrl(String companyId) => '$baseUrl$companyDetailsEndpoint/$companyId';
  static String getApplicationUrl(String applicationId) => '$baseUrl$applicationDetailsEndpoint/$applicationId';
  static String getProjectUrl(String projectId) => '$baseUrl$projectsEndpoint/$projectId';
  static String getNotificationUrl(String notificationId) => '$baseUrl$markNotificationReadEndpoint/$notificationId/read';

  // Validation des URLs
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasAbsolutePath && (uri.hasScheme);
    } catch (e) {
      return false;
    }
  }

  // Construction d'URL avec paramètres de requête
  static String buildUrlWithParams(String baseEndpoint, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) {
      return '$baseUrl$baseEndpoint';
    }

    final uri = Uri.parse('$baseUrl$baseEndpoint');
    final newUri = uri.replace(queryParameters: params.map(
      (key, value) => MapEntry(key, value.toString()),
    ));

    return newUri.toString();
  }

  // Méthode pour obtenir le message d'erreur approprié
  static String getErrorMessage(int statusCode, [String? customMessage]) {
    return customMessage ?? defaultErrorMessages[statusCode] ?? 'Une erreur inattendue s\'est produite';
  }

  // Configuration spécifique à l'environnement
  static bool get isProduction => _env == 'production';
  static bool get isDevelopment => _env == 'development';
  static bool get isStaging => _env == 'staging';

  // URLs des services externes (si nécessaire)
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
  static const String firebaseConfig = String.fromEnvironment('FIREBASE_CONFIG', defaultValue: '');
  
  // Versions de l'API
  static const String apiVersion = 'v1';
  static const String minSupportedVersion = '1.0.0';
  static const String currentVersion = '1.0.0';
}