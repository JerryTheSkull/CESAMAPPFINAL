import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import '../models/cesam_user.dart'; // ✅ Import du modèle CesamUser
import 'main_screen.dart';
import '../../models/project.dart';

class StudentDashboard extends StatelessWidget {
  // ✅ MODIFICATION : Accepter soit RegistrationData, soit CesamUser, ou les données API avec le rôle
  final RegistrationData? registrationData;
  final CesamUser? user;
  final Map<String, dynamic>? apiUserData; // ✅ Nouvelles données API
  final String? userRole; // ✅ Rôle Spatie séparé

  // ✅ Constructor modifié pour accepter les données API
  const StudentDashboard({
    super.key, 
    this.registrationData, 
    this.user,
    this.apiUserData,
    this.userRole,
  }) : assert(registrationData != null || user != null || apiUserData != null, 
             'Au moins un des paramètres doit être fourni');

  @override
  Widget build(BuildContext context) {
    // ✅ Si on a déjà un CesamUser (venant de l'API login), on l'utilise directement
    if (user != null) {
      debugPrint('Utilisateur connecté via API : ${user!.name} | Admin : ${user!.isAdmin}');
      return MainScreen(user: user!);
    }
    
    // ✅ Si on a les données API brutes avec le rôle Spatie
    if (apiUserData != null) {
      final isAdmin = userRole == 'admin' || userRole == 'administrateur';
      debugPrint('Utilisateur connecté via API : ${apiUserData!['nom_complet']} | Rôle : $userRole | Admin : $isAdmin');
      
      final apiUser = CesamUser.fromApiData(apiUserData!, userRole: userRole);
      return MainScreen(user: apiUser);
    }
    
    // ✅ Sinon, conversion RegistrationData → CesamUser (pour la compatibilité)
    if (registrationData != null) {
      debugPrint('Étudiant connecté : ${registrationData!.fullName} | Rôle simulé');
      
      final convertedUser = registrationData!.toCesamUser(isAdmin: false);
      return MainScreen(user: convertedUser);
    }

    // ✅ Cas d'erreur (ne devrait jamais arriver avec l'assert)
    return const Scaffold(
      body: Center(
        child: Text('Erreur : Aucune donnée utilisateur disponible'),
      ),
    );
  }

  // ✅ Helper pour convertir les projets de RegistrationData (gardé pour compatibilité)
  String? _formatProjectsFromRegistration(List<Project> projects) {
    if (projects.isEmpty) return null;
    
    return projects.map((project) {
      String result = project.title;
      if (project.description.isNotEmpty) {
        result += ': ${project.description}';
      }
      if (project.link != null && project.link!.isNotEmpty) {
        result += ' (${project.link})';
      }
      return result;
    }).join('; ');
  }
}