import 'package:flutter/material.dart';
import '../../../models/registration_data.dart';
import '../../../constants/colors.dart';
import '../../../components/auth_scaffold.dart';
import '../../app_routes.dart';
import '../../../services/api_service.dart';
import 'dart:async';

class Step2AcademicInfo extends StatefulWidget {
  final RegistrationData data;

  const Step2AcademicInfo({super.key, required this.data});

  @override
  State<Step2AcademicInfo> createState() => _Step2AcademicInfoState();
}

class _Step2AcademicInfoState extends State<Step2AcademicInfo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ecoleController;
  late TextEditingController _filiereController;
  String? _niveauSelectionne;
  String? _villeSelectionnee;
  bool _isLoading = false;

  final List<String> _niveaux = [
    'Licence 1', 'Licence 2', 'Licence 3',
    'Master 1', 'Master 2', 'Doctorat',
    'Ingénieur', 'DUT', 'BTS', 'Autre',
  ];

  final List<String> _villesMaroc = [
    'Agadir', 'Al Hoceima', 'Azrou', 'Beni Mellal', 'Berrechid',
    'Casablanca', 'Chefchaouen', 'Dakhla', 'El Jadida', 'Errachidia',
    'Essaouira', 'Fès', 'Guelmim', 'Ifrane', 'Kénitra', 'Khouribga',
    'Ksar El Kebir', 'Laâyoune', 'Larache', 'Marrakech', 'Meknès',
    'Mohammedia', 'Nador', 'Ouarzazate', 'Oujda', 'Rabat', 'Safi',
    'Salé', 'Settat', 'Sidi Ifni', 'Tanger', 'Taourirt', 'Taroudant',
    'Taza', 'Témara', 'Tétouan', 'Tiznit'
  ];

  @override
  void initState() {
    super.initState();
    _ecoleController = TextEditingController(text: widget.data.ecole ?? '');
    _filiereController = TextEditingController(text: widget.data.filiere ?? '');
    _niveauSelectionne = widget.data.niveau.isNotEmpty ? widget.data.niveau : null;
    _villeSelectionnee = widget.data.ville?.isNotEmpty == true ? widget.data.ville : null;

    print('📚 Step2 - Init with sessionToken: ${widget.data.sessionToken ?? "null"}');
    print('📚 Step2 - Données reçues:');
    widget.data.printDebug();

    _loadExistingProcess();
  }

  Future<void> _loadExistingProcess() async {
    final token = await ApiService.getSessionToken();
    if (token != null && widget.data.sessionToken != null) {
      try {
        final response = await ApiService.getStepData(sessionToken: token, stepNumber: 2);
        if (response['success'] && response['body']['data'] != null) {
          final stepData = RegistrationData.fromApiData(response['body']['data']);
          setState(() {
            _ecoleController.text = stepData.ecole ?? '';
            _filiereController.text = stepData.filiere ?? '';
            _niveauSelectionne = stepData.niveau.isNotEmpty ? stepData.niveau : null;
            _villeSelectionnee = stepData.ville?.isNotEmpty == true ? stepData.ville : null;
            widget.data
              ..ecole = stepData.ecole
              ..filiere = stepData.filiere
              ..niveau = stepData.niveau
              ..ville = stepData.ville;
          });
          print('✅ Données Step2 chargées depuis le serveur: $stepData');
        }
      } catch (e) {
        print('❌ Erreur chargement Step2: $e');
        _showError('Impossible de charger les données précédentes: $e');
      }
    }
  }

  Future<void> _goToNextStep() async {
    if (_formKey.currentState!.validate()) {
      if (widget.data.sessionToken == null) {
        _showError('Erreur: Token de session manquant.');
        return;
      }

      setState(() => _isLoading = true);

      try {
        final response = await ApiService.registerStep2(
          sessionToken: widget.data.sessionToken!,
          ecole: _ecoleController.text.trim(),
          filiere: _filiereController.text.trim(),
          niveauEtude: _niveauSelectionne!,
          ville: _villeSelectionnee!,
        ).timeout(const Duration(seconds: 10));

        setState(() => _isLoading = false);

        if (response['success'] == true) {
          widget.data
            ..ecole = _ecoleController.text.trim()
            ..filiere = _filiereController.text.trim()
            ..niveau = _niveauSelectionne ?? ''
            ..ville = _villeSelectionnee;

          print('✅ Step2 réussi');
          widget.data.printDebug();

          Navigator.pushNamed(
            context,
            AppRoutes.registerStep3,
            arguments: widget.data,
          );
        } else {
          String errorMessage = 'Erreur inconnue';
          if (response['body'] != null) {
            final body = response['body'];
            if (body['errors'] != null) {
              final errors = body['errors'] as Map<String, dynamic>;
              errorMessage = errors.values.expand((e) => e as List<dynamic>).join('\n');
            } else if (body['message'] != null) {
              errorMessage = body['message'];
            }
          }
          _showError(errorMessage);
          print('❌ Erreur API Step2: ${response['status']} - $errorMessage');
        }
      } on TimeoutException {
        setState(() => _isLoading = false);
        _showError('Temps de réponse dépassé. Veuillez vérifier votre connexion.');
      } catch (e) {
        setState(() => _isLoading = false);
        _showError('Erreur de connexion: ${e.toString()}');
        print('❌ Exception Step2: $e');
      }
    }
  }

  Future<void> _goToPreviousStep() async {
    try {
      if (widget.data.sessionToken == null) throw Exception('Session token manquant');
      final response = await ApiService.getStepData(
        sessionToken: widget.data.sessionToken!,
        stepNumber: 1,
      );
      if (response['success'] && response['body']['data'] != null) {
        final stepData = RegistrationData.fromApiData(response['body']['data']);
        widget.data
          ..fullName = stepData.fullName
          ..email = stepData.email
          ..phoneNumber = stepData.phoneNumber
          ..nationality = stepData.nationality;
        Navigator.pushNamed(
          context,
          AppRoutes.registerStep1,
          arguments: widget.data,
        );
      } else {
        _showError('Erreur lors de la récupération des données de l\'étape précédente');
      }
    } catch (e) {
      _showError('Erreur lors du retour: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  InputDecoration _customInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.black),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: CesamColors.primary, width: 2),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: 1),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Étape 2 - Informations académiques',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CesamColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Complétez vos informations académiques pour continuer',
                  style: TextStyle(
                    color: CesamColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                cursorColor: CesamColors.primary,
                controller: _ecoleController,
                decoration: _customInputDecoration("Nom de l'école *", Icons.school),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Le nom de l\'école est obligatoire';
                  if (value.trim().length < 2) return 'Le nom de l\'école doit contenir au moins 2 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: CesamColors.primary,
                controller: _filiereController,
                decoration: _customInputDecoration("Filière ou domaine *", Icons.book_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'La filière est obligatoire';
                  if (value.trim().length < 2) return 'La filière doit contenir au moins 2 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _niveauSelectionne,
                items: _niveaux.map((niveau) {
                  return DropdownMenuItem(
                    value: niveau,
                    child: Text(niveau),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _niveauSelectionne = value),
                decoration: _customInputDecoration("Niveau d'études *", Icons.grade_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez sélectionner votre niveau d\'études';
                  return null;
                },
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _villeSelectionnee,
                decoration: _customInputDecoration("Ville *", Icons.location_city),
                items: _villesMaroc.map((ville) {
                  return DropdownMenuItem(
                    value: ville,
                    child: Text(ville),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _villeSelectionnee = value),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez sélectionner une ville';
                  return null;
                },
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CesamColors.primary),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _goToNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CesamColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Suivant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Tous les champs marqués d'un * sont obligatoires",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _goToPreviousStep,
                child: const Text(
                  'Retour à l\'étape précédente',
                  style: TextStyle(
                    color: CesamColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ecoleController.dispose();
    _filiereController.dispose();
    super.dispose();
  }
}