// services/project_service.dart
import '../models/project.dart';
import 'api_service_profile.dart';

class ProjectService {
  static const String _baseUrl = '/profile/projects';

  static Future<List<Project>> getProjects() async {
    try {
      final response = await ApiServiceProfile.getProjects();
      
      if (response['success'] == true) {
        final projectsData = response['body']['data']['projects'] as List;
        return projectsData.map((projectJson) => Project.fromJson(projectJson)).toList();
      } else {
        throw Exception(response['body']['message'] ?? 'Erreur lors de la récupération des projets');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des projets: $e');
    }
  }

  static Future<Project> getProject(String projectId) async {
    try {
      final response = await ApiServiceProfile.getProject(projectId);
      
      if (response['success'] == true) {
        return Project.fromJson(response['body']['data']['project']);
      } else {
        throw Exception(response['body']['message'] ?? 'Projet non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du projet: $e');
    }
  }

  static Future<Project> addProject({
    required String title,
    required String description,
    String? link,
  }) async {
    try {
      final response = await ApiServiceProfile.addProject(
        title: title,
        description: description,
        link: link,
      );
      
      if (response['success'] == true) {
        return Project.fromJson(response['body']['data']['project']);
      } else {
        throw Exception(response['body']['message'] ?? 'Erreur lors de l\'ajout du projet');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du projet: $e');
    }
  }

  static Future<Project> updateProject({
    required String projectId,
    required String title,
    required String description,
    String? link,
  }) async {
    try {
      final response = await ApiServiceProfile.updateProject(
        projectId: projectId,
        title: title,
        description: description,
        link: link,
      );
      
      if (response['success'] == true) {
        return Project.fromJson(response['body']['data']['project']);
      } else {
        throw Exception(response['body']['message'] ?? 'Erreur lors de la modification du projet');
      }
    } catch (e) {
      throw Exception('Erreur lors de la modification du projet: $e');
    }
  }

  static Future<void> deleteProject(String projectId) async {
    try {
      final response = await ApiServiceProfile.deleteProject(projectId);
      
      if (response['success'] != true) {
        throw Exception(response['body']['message'] ?? 'Erreur lors de la suppression du projet');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du projet: $e');
    }
  }
}