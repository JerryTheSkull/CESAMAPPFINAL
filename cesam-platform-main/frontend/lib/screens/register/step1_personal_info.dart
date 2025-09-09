import 'package:flutter/material.dart';
import '../../../models/registration_data.dart';
import '../../../constants/colors.dart';
import '../../../components/auth_scaffold.dart';
import '../../app_routes.dart';
import '../../../services/api_service.dart';
import 'dart:async';

class Step1PersonalInfo extends StatefulWidget {
  final RegistrationData data;

  const Step1PersonalInfo({super.key, required this.data});

  @override
  State<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends State<Step1PersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  String? _selectedCountry;
  bool _isLoading = false;

  final List<String> _countries = [
    'Afrique du Sud', 'Algérie', 'Angola', 'Bénin', 'Botswana', 'Burkina Faso',
    'Burundi', 'Cameroun', 'Cap-Vert', 'Comores', 'Congo (Brazzaville)',
    'Congo (Kinshasa)', "Côte d'Ivoire", 'Djibouti', 'Égypte', 'Érythrée',
    'Eswatini', 'Éthiopie', 'Gabon', 'Gambie', 'Ghana', 'Guinée', 'Guinée-Bissau',
    'Guinée équatoriale', 'Kenya', 'Lesotho', 'Libéria', 'Libye', 'Madagascar',
    'Malawi', 'Mali', 'Maroc', 'Maurice', 'Mauritanie', 'Mozambique', 'Namibie',
    'Niger', 'Nigéria', 'Ouganda', 'Rwanda', 'São Tomé-et-Principe', 'Sénégal',
    'Seychelles', 'Sierra Leone', 'Somalie', 'Soudan', 'Tanzanie', 'Tchad',
    'Togo', 'Tunisie', 'Zambie', 'Zimbabwe',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.fullName);
    _emailController = TextEditingController(text: widget.data.email);
    _passwordController = TextEditingController(text: widget.data.password);
    _phoneController = TextEditingController(text: widget.data.phoneNumber ?? '');
    _selectedCountry = _countries.contains(widget.data.nationality.trim())
        ? widget.data.nationality.trim()
        : null;

    _loadExistingProcess();
    print('🔄 Step1 - Init with sessionToken: ${widget.data.sessionToken ?? "null"}');
  }

  Future<void> _loadExistingProcess() async {
    final token = await ApiService.getSessionToken();
    if (token != null && widget.data.sessionToken == null) {
      try {
        final response = await ApiService.getStepData(sessionToken: token, stepNumber: 1);
        if (response['success'] && response['body']['data'] != null) {
          final stepData = RegistrationData.fromApiData(response['body']['data']);
          setState(() {
            _nameController.text = stepData.fullName;
            _emailController.text = stepData.email;
            _phoneController.text = stepData.phoneNumber ?? '';
            _selectedCountry = _countries.contains(stepData.nationality.trim())
                ? stepData.nationality.trim()
                : null;
            widget.data
              ..fullName = stepData.fullName
              ..email = stepData.email
              ..phoneNumber = stepData.phoneNumber
              ..nationality = stepData.nationality
              ..sessionToken = token;
          });
          print('✅ Données Step1 chargées depuis le serveur: $stepData');
        }
      } catch (e) {
        print('❌ Erreur chargement Step1: $e');
        _showError('Impossible de charger les données précédentes: $e');
      }
    }
  }

  Future<void> _goToNextStep() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await ApiService.registerStep1(
          nomComplet: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          telephone: _phoneController.text.trim(),
          nationalite: _selectedCountry!,
          sessionToken: widget.data.sessionToken,
        ).timeout(const Duration(seconds: 10));

        setState(() => _isLoading = false);

        if (response['success'] && response['body'] != null) {
          final responseBody = response['body'];
          final sessionToken = responseBody['session_token'];

          if (sessionToken != null) {
            await ApiService.saveSessionToken(sessionToken); // Assure la sauvegarde
            widget.data
              ..fullName = _nameController.text.trim()
              ..email = _emailController.text.trim()
              ..password = _passwordController.text
              ..phoneNumber = _phoneController.text.trim()
              ..nationality = _selectedCountry!
              ..sessionToken = sessionToken;

            print('✅ Step1 réussi - session_token: ${sessionToken.substring(0, 8)}...');
            widget.data.printDebug();

            Navigator.pushNamed(
              context,
              AppRoutes.registerStep2,
              arguments: widget.data,
            );
          } else {
            _showError('Token de session non trouvé dans la réponse');
          }
        } else {
          String errorMessage = response['body']['message'] ?? 'Erreur inconnue';
          if (response['body']['errors'] != null) {
            final errors = response['body']['errors'] as Map<String, dynamic>;
            errorMessage = errors.values.expand((e) => e as List<dynamic>).join('\n');
          }
          _showError(errorMessage);
        }
      } on TimeoutException {
        setState(() => _isLoading = false);
        _showError('Temps de réponse dépassé. Veuillez vérifier votre connexion.');
      } catch (e) {
        setState(() => _isLoading = false);
        _showError('Erreur de connexion: $e');
        print('❌ Exception Step1: $e');
      }
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
      title: 'Étape 1 - Informations personnelles',
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                cursorColor: CesamColors.primary,
                controller: _nameController,
                decoration: _customInputDecoration('Nom complet *', Icons.person_outline),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Le nom complet est obligatoire';
                  if (val.trim().length < 2) return 'Le nom doit contenir au moins 2 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: CesamColors.primary,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _customInputDecoration('Email *', Icons.email_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'L\'email est obligatoire';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) return 'Veuillez entrer un email valide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: CesamColors.primary,
                controller: _passwordController,
                obscureText: true,
                decoration: _customInputDecoration('Mot de passe *', Icons.lock_outline),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Le mot de passe est obligatoire';
                  if (val.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: CesamColors.primary,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _customInputDecoration('Téléphone *', Icons.phone),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Le téléphone est obligatoire';
                  if (val.trim().length < 8) return 'Numéro de téléphone invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _customInputDecoration('Nationalité *', Icons.flag_outlined)
                    .copyWith(hintText: 'Sélectionnez votre pays'),
                value: _selectedCountry,
                items: _countries.map((country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCountry = val),
                validator: (val) => val == null ? 'La nationalité est obligatoire' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CesamColors.primary),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CesamColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _goToNextStep,
                        child: const Text(
                          "Suivant",
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
                "Les champs marqués d'un * sont obligatoires",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}