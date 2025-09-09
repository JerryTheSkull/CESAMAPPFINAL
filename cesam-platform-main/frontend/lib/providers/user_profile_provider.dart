// providers/user_profile_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/cesam_user.dart';
import '../models/project.dart';
import '../services/api_service_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  CesamUser? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<String> _cities = [];
  List<String> _academicLevels = [];

  CesamUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUser => _user != null;
  bool get isInitialized => _isInitialized;
  List<String> get cities => _cities;
  List<String> get academicLevels => _academicLevels;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _setLoading(true);
      await Future.wait([
        loadOptions(),
        loadProfile(),
      ]);
      _isInitialized = true;
    } catch (e) {
      _setError('Erreur d\'initialisation: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOptions() async {
    try {
      final response = await ApiServiceProfile.getOptions();
      
      if (response['success'] == true) {
        final data = response['body']['data'];
        _cities = List<String>.from(data['villes'] ?? []);
        _academicLevels = List<String>.from(data['niveaux_etude'] ?? []);
      } else {
        throw Exception(response['body']['message'] ?? 'Erreur lors du chargement des options');
      }
    } catch (e) {
      debugPrint('Erreur chargement options: $e');
      // Valeurs par défaut en cas d'erreur
      _cities = ['Casablanca', 'Rabat', 'Marrakech', 'Fès'];
      _academicLevels = ['Licence 1', 'Licence 2', 'Licence 3', 'Master 1', 'Master 2'];
    }
  }

  Future<void> loadProfile() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await ApiServiceProfile.getProfile();
      
      if (response['success'] == true) {
        final userData = response['body']['data']['user'];
        _user = CesamUser.fromJson(userData);
        notifyListeners();
      } else {
        _setError(response['body']['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      _setError('Erreur lors du chargement: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadProfile();
  }

  Future<bool> updatePersonalInfo({
    String? telephone,
    String? ville,
    bool? affilieAmci,
    String? codeAmci,
    String? matriculeAmci,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.updatePersonalInfo(
        telephone: telephone,
        ville: ville,
        affilieAmci: affilieAmci,
        codeAmci: codeAmci,
        matriculeAmci: matriculeAmci,
      );
      
      if (response['success'] == true) {
        await loadProfile();
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de la mise à jour');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAcademicInfo({
    String? ecole,
    String? filiere,
    String? niveauEtude,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.updateAcademicInfo(
        ecole: ecole,
        filiere: filiere,
        niveauEtude: niveauEtude,
      );
      
      if (response['success'] == true) {
        await loadProfile();
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de la mise à jour');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addProject({
    required String title,
    required String description,
    String? link,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.addProject(
        title: title,
        description: description,
        link: link,
      );
      
      if (response['success'] == true) {
        final projectData = response['body']['data']['project'];
        final newProject = Project.fromJson(projectData);
        
        // Créer une nouvelle instance du user avec le projet ajouté
        if (_user != null) {
          final currentProjects = List<Project>.from(_user!.projects ?? []);
          currentProjects.add(newProject);
          _user = _user!.copyWith(projects: currentProjects);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de l\'ajout');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProject({
    required String projectId,
    required String title,
    required String description,
    String? link,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.updateProject(
        projectId: projectId,
        title: title,
        description: description,
        link: link,
      );
      
      if (response['success'] == true) {
        final updatedProjectData = response['body']['data']['project'];
        final updatedProject = Project.fromJson(updatedProjectData);
        
        if (_user != null && _user!.projects != null) {
          final currentProjects = List<Project>.from(_user!.projects!);
          final index = currentProjects.indexWhere((p) => p.id == projectId);
          if (index != -1) {
            currentProjects[index] = updatedProject;
            _user = _user!.copyWith(projects: currentProjects);
            notifyListeners();
          }
        }
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de la modification');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeProject(String projectId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.deleteProject(projectId);
      
      if (response['success'] == true) {
        if (_user != null && _user!.projects != null) {
          final currentProjects = List<Project>.from(_user!.projects!);
          currentProjects.removeWhere((p) => p.id == projectId);
          _user = _user!.copyWith(projects: currentProjects);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de la suppression');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Project>> getProjects() async {
    try {
      final response = await ApiServiceProfile.getProjects();
      
      if (response['success'] == true) {
        final projectsData = response['body']['data']['projects'] as List;
        return projectsData.map((p) => Project.fromJson(p)).toList();
      } else {
        throw Exception(response['body']['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des projets: $e');
    }
  }

  Future<bool> addSkill(String skill) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.addSkill(skill);
      
      if (response['success'] == true) {
        if (_user != null) {
          final currentSkills = List<String>.from(_user!.skills ?? []);
          final normalizedSkill = skill.toLowerCase().trim();
          if (!currentSkills.contains(normalizedSkill)) {
            currentSkills.add(normalizedSkill);
            _user = _user!.copyWith(skills: currentSkills);
            notifyListeners();
          }
        }
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de l\'ajout');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeSkill(String skill) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.removeSkill(skill);
      
      if (response['success'] == true) {
        if (_user != null && _user!.skills != null) {
          final currentSkills = List<String>.from(_user!.skills!);
          currentSkills.remove(skill.toLowerCase().trim());
          _user = _user!.copyWith(skills: currentSkills);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de la suppression');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAllSkills(List<String> skills) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.updateAllSkills(skills);
      
      if (response['success'] == true) {
        if (_user != null) {
          _user = _user!.copyWith(skills: skills);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de la mise à jour');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadProfilePhoto(File imageFile) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.uploadProfilePhoto(imageFile);
      
      if (response['success'] == true) {
        await loadProfile(); // Recharger pour obtenir la nouvelle URL de photo
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de l\'upload');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProfilePhoto() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.deleteProfilePhoto();
      
      if (response['success'] == true) {
        if (_user != null) {
          _user = _user!.copyWith(photoPath: null);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de la suppression');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadCV(File cvFile) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.uploadCV(cvFile);
      
      if (response['success'] == true) {
        await loadProfile(); // Recharger pour obtenir la nouvelle URL de CV
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de l\'upload');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCV() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.deleteCV();
      
      if (response['success'] == true) {
        if (_user != null) {
          _user = _user!.copyWith(cvUrl: null, hasCV: false);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['body']['message'] ?? 'Erreur lors de la suppression');
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<int>?> downloadCV() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await ApiServiceProfile.downloadCV();
      return response;
    } catch (e) {
      _setError('Erreur lors du téléchargement: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Méthode pour tester la connectivité
  Future<bool> testConnectivity() async {
    try {
      final result = await ApiServiceProfile.testConnectivity();
      return result['success'] == true;
    } catch (e) {
      debugPrint('Test connectivité échoué: $e');
      return false;
    }
  }

  // Méthode pour tester la validité du token
  Future<bool> testTokenValidity() async {
    try {
      final result = await ApiServiceProfile.testTokenValidity();
      return result['success'] == true;
    } catch (e) {
      debugPrint('Test token échoué: $e');
      return false;
    }
  }

  void clearUser() {
    _user = null;
    _isInitialized = false;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> syncProjects() async {
    try {
      final serverProjects = await getProjects();
      if (_user != null) {
        _user = _user!.copyWith(projects: serverProjects);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur sync projets: $e');
    }
  }

  // Méthode utilitaire pour valider si l'utilisateur peut être modifié
  bool canEditProfile() {
    return _user != null && !_isLoading;
  }

  // Méthode pour obtenir le pourcentage de completion du profil
  double get profileCompletionPercentage {
    return _user?.profileCompletionPercentage ?? 0.0;
  }

  // Méthode pour vérifier si le profil est complet
  bool get isProfileComplete {
    return _user?.isProfileComplete ?? false;
  }

  @override
  void dispose() {
    // Nettoyer les ressources si nécessaire
    super.dispose();
  }
}