import '../models/cesam_user.dart';
import 'project.dart';

class RegistrationData {
  String fullName;
  String email;
  String password;
  String? phoneNumber;
  String nationality;
  String? ecole;
  String? filiere;
  String niveau;
  String? ville;
  String cvFilePath;
  String skills;
  List<String> skillsList; // Changé de getter à propriété
  List<Project> projects;
  bool? isAmci;
  String? amciCode;
  String? sessionToken;

  RegistrationData({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.phoneNumber,
    this.nationality = '',
    this.ecole,
    this.filiere,
    this.niveau = '',
    this.ville,
    this.cvFilePath = '',
    this.skills = '',
    this.skillsList = const [], // Ajouté comme propriété
    this.projects = const [],
    this.isAmci,
    this.amciCode,
    this.sessionToken,
  });

  // Factory constructor pour créer depuis les données API Laravel
  factory RegistrationData.fromApiData(Map<String, dynamic> userData) {
    print('📥 Parsing API data: $userData');
    
    try {
      final skillsData = _parseSkillsFromApi(userData['competences']);
      return RegistrationData(
        fullName: _parseString(userData['nom_complet']),
        email: _parseString(userData['email']),
        password: '', // Pas disponible depuis l'API (sécurité)
        phoneNumber: _parseStringOrNull(userData['telephone']),
        nationality: _parseString(userData['nationalite']),
        ecole: _parseStringOrNull(userData['ecole']),
        filiere: _parseStringOrNull(userData['filiere']),
        niveau: _parseString(userData['niveau_etude']),
        ville: _parseStringOrNull(userData['ville']),
        cvFilePath: _parseString(userData['cv_url']),
        skills: skillsData, // String format
        skillsList: _parseSkillsListFromApi(userData['competences']), // List format
        projects: _parseProjectsFromApi(userData['projects']),
        isAmci: userData['affilie_amci'] as bool?,
        amciCode: _parseStringOrNull(userData['code_amci']),
        sessionToken: _parseStringOrNull(userData['session_token']),
      );
    } catch (e) {
      print('❌ Erreur parsing API data: $e');
      print('❌ Data received: $userData');
      rethrow;
    }
  }

  // Helper methods pour parser les données
  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String? _parseStringOrNull(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString().trim();
    return parsed.isEmpty ? null : parsed;
  }

  // Helper pour parser les compétences depuis l'API Laravel (format String)
  static String _parseSkillsFromApi(dynamic competences) {
    if (competences == null) return '';
    
    try {
      if (competences is List) {
        return competences.map((c) => c.toString().trim()).where((c) => c.isNotEmpty).join(', ');
      } else if (competences is String) {
        return competences.trim();
      }
      return competences.toString().trim();
    } catch (e) {
      print('❌ Erreur parsing skills: $e');
      return '';
    }
  }

  // Helper pour parser les compétences depuis l'API Laravel (format List)
  static List<String> _parseSkillsListFromApi(dynamic competences) {
    if (competences == null) return [];
    
    try {
      if (competences is List) {
        return competences.map((c) => c.toString().trim()).where((c) => c.isNotEmpty).toList();
      } else if (competences is String && competences.trim().isNotEmpty) {
        return competences.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur parsing skills list: $e');
      return [];
    }
  }

  // Helper pour parser les projets depuis l'API Laravel
  static List<Project> _parseProjectsFromApi(dynamic projects) {
    if (projects == null) return [];
    
    try {
      if (projects is List) {
        return projects.map<Project>((projectData) {
          try {
            if (projectData is Map<String, dynamic>) {
              return Project.fromJson(projectData);
            } else {
              return Project(
                title: projectData.toString(),
                description: '',
              );
            }
          } catch (e) {
            print('❌ Erreur parsing project: $e');
            return Project(
              title: projectData.toString(),
              description: 'Erreur de chargement',
            );
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur parsing projects: $e');
      return [];
    }
  }

  // Convertir vers CesamUser
  CesamUser toCesamUser({bool isAdmin = false}) {
    return CesamUser(
      name: fullName,
      email: email,
      isAdmin: isAdmin,
      phone: phoneNumber,
      nationality: nationality,
      academicLevel: niveau,
      studyField: filiere,
      school: ecole,
      city: ville,
      isAmci: isAmci,
      amciCode: amciCode,
      skills: skillsList,
      projects: projects,
      hasCV: cvFilePath.isNotEmpty,
      cvUrl: cvFilePath.isNotEmpty ? cvFilePath : null,
    );
  }

  // Synchroniser skills et skillsList
  void syncSkills() {
    if (skillsList.isNotEmpty) {
      skills = skillsList.join(', ');
    } else if (skills.isNotEmpty) {
      skillsList = skills.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
  }

  // Conversion vers JSON pour l'API
  Map<String, dynamic> toApiStep1() {
    return {
      'nom_complet': fullName.trim(),
      'email': email.trim(),
      'password': password,
      'telephone': phoneNumber?.trim(),
      'nationalite': nationality.trim(),
      if (sessionToken != null) 'session_token': sessionToken,
    };
  }

  Map<String, dynamic> toApiStep2() {
    return {
      'session_token': sessionToken!,
      'ecole': ecole?.trim(),
      'filiere': filiere?.trim(),
      'niveau_etude': niveau.trim(),
      'ville': ville?.trim(),
    };
  }

  Map<String, dynamic> toApiStep3() {
    final Map<String, dynamic> data = {
      'session_token': sessionToken!,
    };

    if (cvFilePath.trim().isNotEmpty) {
      data['cv_url'] = cvFilePath.trim();
    }

    if (skillsList.isNotEmpty) {
      data['competences'] = skillsList;
    }

    if (projects.isNotEmpty) {
      data['projects'] = projects.map((p) => {
        'title': p.title.trim(),
        'description': p.description.trim(),
        if (p.link != null && p.link!.trim().isNotEmpty) 'link': p.link!.trim(),
      }).toList();
    }

    return data;
  }

  Map<String, dynamic> toApiStep4() {
    final Map<String, dynamic> data = {
      'session_token': sessionToken!,
      'affilie_amci': isAmci ?? false,
    };

    if (isAmci == true && amciCode != null && amciCode!.trim().isNotEmpty) {
      data['code_amci'] = amciCode!.trim();
    }

    return data;
  }

  Map<String, dynamic> toApiStep5(String verificationCode) {
    return {
      'session_token': sessionToken!,
      'verification_code': verificationCode.trim(),
    };
  }

  // Nouvelle méthode pour préparer les données pour registerStep3WithFile
  Map<String, dynamic> toApiStep3WithFile() {
    final Map<String, dynamic> data = {
      'session_token': sessionToken!,
      'competences': skillsList,
      'projects': projects.map((p) => {
        'title': p.title.trim(),
        'description': p.description.trim(),
        if (p.link != null && p.link!.trim().isNotEmpty) 'link': p.link!.trim(),
      }).toList(),
    };

    if (cvFilePath.trim().isNotEmpty) {
      data['cv_file'] = cvFilePath.trim();
    }

    return data;
  }

  // Conversion générale vers JSON
  Map<String, dynamic> toJson() {
    return {
      'nom_complet': fullName,
      'email': email,
      'password': password,
      'telephone': phoneNumber,
      'nationalite': nationality,
      'ecole': ecole,
      'filiere': filiere,
      'niveau_etude': niveau,
      'ville': ville,
      'cv_url': cvFilePath,
      'competences': skillsList,
      'projects': projects.map((p) => p.toJson()).toList(),
      'affilie_amci': isAmci,
      'code_amci': amciCode,
      'session_token': sessionToken,
    };
  }

  // Factory constructor depuis JSON
  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    try {
      return RegistrationData(
        fullName: _parseString(json['nom_complet'] ?? json['fullName']),
        email: _parseString(json['email']),
        password: _parseString(json['password']),
        phoneNumber: _parseStringOrNull(json['telephone'] ?? json['phoneNumber']),
        nationality: _parseString(json['nationalite'] ?? json['nationality']),
        ecole: _parseStringOrNull(json['ecole']),
        filiere: _parseStringOrNull(json['filiere']),
        niveau: _parseString(json['niveau_etude'] ?? json['niveau']),
        ville: _parseStringOrNull(json['ville']),
        cvFilePath: _parseString(json['cv_url'] ?? json['cvFilePath']),
        skills: _parseString(json['skills']),
        skillsList: _parseSkillsListFromJson(json['competences'] ?? json['skillsList']),
        projects: _parseProjectsFromJson(json['projects']),
        isAmci: json['affilie_amci'] ?? json['isAmci'],
        amciCode: _parseStringOrNull(json['code_amci'] ?? json['amciCode']),
        sessionToken: _parseStringOrNull(json['session_token']),
      );
    } catch (e) {
      print('❌ Erreur fromJson: $e');
      rethrow;
    }
  }

  static List<String> _parseSkillsListFromJson(dynamic skills) {
    if (skills == null) return [];
    
    try {
      if (skills is List) {
        return skills.map((s) => s.toString().trim()).where((s) => s.isNotEmpty).toList();
      } else if (skills is String && skills.trim().isNotEmpty) {
        return skills.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur parsing skills list from JSON: $e');
      return [];
    }
  }

  static List<Project> _parseProjectsFromJson(dynamic projects) {
    if (projects == null) return [];
    
    try {
      if (projects is List) {
        return projects.map<Project>((p) {
          if (p is Map<String, dynamic>) {
            return Project.fromJson(p);
          }
          return Project(title: p.toString(), description: '');
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur parsing projects from JSON: $e');
      return [];
    }
  }

  // Méthode pour déboguer les données
  void printDebug() {
    print('=== REGISTRATION DATA DEBUG ===');
    print('session_token: ${sessionToken ?? "null"}');
    print('fullName: "$fullName"');
    print('email: "$email"');
    print('password: ${password.isEmpty ? "empty" : "*****"}');
    print('phoneNumber: ${phoneNumber ?? "null"}');
    print('nationality: "$nationality"');
    print('ecole: ${ecole ?? "null"}');
    print('filiere: ${filiere ?? "null"}');
    print('niveau: "$niveau"');
    print('ville: ${ville ?? "null"}');
    print('cvFilePath: "$cvFilePath"');
    print('skills: "$skills"');
    print('skillsList: $skillsList');
    print('projects count: ${projects.length}');
    if (projects.isNotEmpty) {
      for (int i = 0; i < projects.length; i++) {
        print('  project[$i]: ${projects[i].title}');
      }
    }
    print('isAmci: ${isAmci ?? "null"}');
    print('amciCode: ${amciCode ?? "null"}');
    print('================================');
  }

  // Vérifier si les données minimales sont présentes
  bool get hasMinimalData {
    return fullName.trim().isNotEmpty && 
           email.trim().isNotEmpty && 
           password.isNotEmpty;
  }

  // Vérifier si la session est valide
  bool get hasValidSession {
    return sessionToken != null && sessionToken!.trim().isNotEmpty;
  }

  // Vérifier si l'étape 1 est complète
  bool get isStep1Complete {
    return fullName.trim().isNotEmpty &&
           email.trim().isNotEmpty &&
           password.isNotEmpty &&
           phoneNumber != null &&
           phoneNumber!.trim().isNotEmpty &&
           nationality.trim().isNotEmpty &&
           hasValidSession;
  }

  // Vérifier si l'étape 2 est complète
  bool get isStep2Complete {
    return isStep1Complete &&
           ecole != null &&
           ecole!.trim().isNotEmpty &&
           filiere != null &&
           filiere!.trim().isNotEmpty &&
           niveau.trim().isNotEmpty &&
           ville != null &&
           ville!.trim().isNotEmpty;
  }

  // Copier les données d'une autre instance
  void copyFrom(RegistrationData other) {
    fullName = other.fullName;
    email = other.email;
    password = other.password;
    phoneNumber = other.phoneNumber;
    nationality = other.nationality;
    ecole = other.ecole;
    filiere = other.filiere;
    niveau = other.niveau;
    ville = other.ville;
    cvFilePath = other.cvFilePath;
    skills = other.skills;
    skillsList = List<String>.from(other.skillsList);
    projects = List<Project>.from(other.projects);
    isAmci = other.isAmci;
    amciCode = other.amciCode;
    sessionToken = other.sessionToken;
  }

  // Reset des données
  void reset() {
    fullName = '';
    email = '';
    password = '';
    phoneNumber = null;
    nationality = '';
    ecole = null;
    filiere = null;
    niveau = '';
    ville = null;
    cvFilePath = '';
    skills = '';
    skillsList = [];
    projects = [];
    isAmci = null;
    amciCode = null;
    sessionToken = null;
  }

  // Reset seulement les données de session
  void resetSession() {
    sessionToken = null;
  }
}