// services/user_service.dart
import '../models/cesam_user.dart';
import '../models/project.dart';
import 'api_service.dart';
import 'api_service_profile.dart';

class UserService {
  static CesamUser? _currentUser;
  static final List<Function(CesamUser?)> _listeners = [];

  // ✅ Obtenir l'utilisateur actuel
  static CesamUser? get currentUser => _currentUser;

  // ✅ Écouter les changements d'utilisateur
  static void addListener(Function(CesamUser?) listener) {
    _listeners.add(listener);
  }

  // ✅ Supprimer un écouteur
  static void removeListener(Function(CesamUser?) listener) {
    _listeners.remove(listener);
  }

  // ✅ Notifier tous les écouteurs
  static void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener(_currentUser);
      } catch (e) {
        print('Erreur lors de la notification d\'un listener: $e');
      }
    }
  }

  // ✅ Charger l'utilisateur depuis l'API (utilise ApiServiceProfile)
  static Future<CesamUser?> loadCurrentUser() async {
    try {
      final response = await ApiServiceProfile.getProfile();
      
      if (response['success']) {
        final userData = response['body']['user'];
        final userRole = await ApiService.getUserRole();
        
        _currentUser = CesamUser.fromApiData(userData, userRole: userRole);
        
        // Sauvegarder en local
        await ApiService.saveUserData(response['body']);
        
        _notifyListeners();
        return _currentUser;
      } else {
        print('Erreur lors du chargement utilisateur: ${response['body']['message']}');
        return null;
      }
    } catch (e) {
      print('Erreur UserService.loadCurrentUser: $e');
      return null;
    }
  }

  // ✅ Charger l'utilisateur depuis les données locales
  static Future<CesamUser?> loadFromLocal() async {
    try {
      final userData = await ApiService.getUserData();
      final userRole = await ApiService.getUserRole();
      
      if (userData != null) {
        _currentUser = CesamUser.fromApiData(userData, userRole: userRole);
        _notifyListeners();
        return _currentUser;
      }
      
      return null;
    } catch (e) {
      print('Erreur UserService.loadFromLocal: $e');
      return null;
    }
  }

  // ✅ Mettre à jour l'utilisateur (utilise ApiServiceProfile)
  static Future<bool> updateUser({
    String? nomComplet,
    String? email,
    String? telephone,
    String? nationalite,
    String? niveauEtude,
    String? domaineEtude,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final response = await ApiServiceProfile.updateProfile(
        nomComplet: nomComplet,
        email: email,
        telephone: telephone,
        nationalite: nationalite,
        niveauEtude: niveauEtude,
        filiere: domaineEtude,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response['success']) {
        // Recharger les données utilisateur après mise à jour
        await loadCurrentUser();
        return true;
      } else {
        print('Erreur mise à jour utilisateur: ${response['body']['message']}');
        return false;
      }
    } catch (e) {
      print('Erreur UserService.updateUser: $e');
      return false;
    }
  }

  // ✅ Déconnecter l'utilisateur (utilise ApiService pour logout)
  static Future<void> logout() async {
    try {
      await ApiService.logout();
    } finally {
      _currentUser = null;
      _notifyListeners();
    }
  }

  // ✅ Vérifier si l'utilisateur est connecté
  static bool get isLoggedIn => _currentUser != null;

  // ✅ Vérifier si l'utilisateur est admin
  static bool get isAdmin => _currentUser?.isAdmin ?? false;

  // ✅ Supprimer le compte (utilise ApiServiceProfile)
  static Future<bool> deleteAccount() async {
    try {
      final response = await ApiServiceProfile.deleteAccount();
      
      if (response['success']) {
        _currentUser = null;
        _notifyListeners();
        return true;
      } else {
        print('Erreur suppression compte: ${response['body']['message']}');
        return false;
      }
    } catch (e) {
      print('Erreur UserService.deleteAccount: $e');
      return false;
    }
  }

  // ✅ Initialiser le service (à appeler au démarrage de l'app)
  static Future<void> initialize() async {
    // Essayer de charger depuis les données locales d'abord
    final localUser = await loadFromLocal();
    
    if (localUser != null) {
      // Si l'utilisateur existe localement, essayer de rafraîchir depuis l'API
      try {
        await loadCurrentUser();
      } catch (e) {
        // Si l'API échoue, garder les données locales
        print('Impossible de rafraîchir depuis l\'API, utilisation des données locales');
      }
    }
  }

  // ✅ Nettoyer le service
  static void dispose() {
    _listeners.clear();
    _currentUser = null;
  }

  // ✅ Méthodes utilitaires pour l'affichage
  static String get displayName => _currentUser?.name ?? 'Utilisateur';
  static String get displayEmail => _currentUser?.email ?? '';
  static bool get hasCV => _currentUser?.hasCV ?? false;
  static bool get isAmci => _currentUser?.isAmci ?? false;
  static List<String> get skills => _currentUser?.skills ?? [];
  static List<Project> get projects => _currentUser?.projects ?? [];
}