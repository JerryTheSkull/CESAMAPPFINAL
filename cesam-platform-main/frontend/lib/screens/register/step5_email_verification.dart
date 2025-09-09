import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/registration_data.dart';
import '../../../constants/colors.dart';
import '../../../components/auth_scaffold.dart';
import '../../app_routes.dart';
import '../../../services/api_service.dart';
import 'dart:async';

class Step5EmailVerification extends StatefulWidget {
  final RegistrationData data;

  const Step5EmailVerification({super.key, required this.data});

  @override
  State<Step5EmailVerification> createState() => _Step5EmailVerificationState();
}

class _Step5EmailVerificationState extends State<Step5EmailVerification> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    print('📧 Step5 - Init with sessionToken: ${widget.data.sessionToken ?? "null"}');
    print('📧 Step5 - Email destinataire: ${widget.data.email}');
    print('📧 Step5 - Code déjà envoyé à l\'étape 4, prêt pour vérification');
    
    // ✅ CORRECTION : Ne plus envoyer automatiquement l'email
    // L'email a déjà été envoyé lors de l'étape 4
    // On démarre juste un compteur pour permettre le renvoi après 30 secondes
    _startInitialCountdown();
  }

  void _startInitialCountdown() {
    // Compteur initial de 30 secondes avant de permettre le renvoi
    setState(() => _countdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startResendCountdown() {
    // Compteur de 60 secondes après un renvoi
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.data.sessionToken == null) {
      _showError('Erreur: Token de session manquant. Veuillez recommencer l\'inscription.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔍 Vérification du code: ${_codeController.text.trim()}');
      final response = await ApiService.registerStep5(
        sessionToken: widget.data.sessionToken!,
        code: _codeController.text.trim(),
      ).timeout(const Duration(seconds: 15));

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        print('✅ Step5 réussi - Email vérifié pour: ${widget.data.email}');
        _showSuccess('Email vérifié avec succès ! Inscription terminée.');
        
        // Attendre un peu pour que l'utilisateur voie le message de succès
        await Future.delayed(const Duration(seconds: 2));
        
        // Rediriger vers la page de connexion
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } else {
        String errorMessage = 'Code de vérification incorrect';
        if (response['body'] != null) {
          final body = response['body'];
          if (body['errors'] != null) {
            final errors = body['errors'] as Map<String, dynamic>;
            errorMessage = errors.values.expand((e) => e as List<dynamic>).join('\n');
          } else if (body['message'] != null) {
            errorMessage = body['message'];
          }
        }
        print('❌ Erreur vérification: $errorMessage');
        _showError(errorMessage);
        
        // Effacer le code incorrect
        _codeController.clear();
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
      _showError('Temps de réponse dépassé. Veuillez vérifier votre connexion.');
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Exception vérification: $e');
      _showError('Erreur de connexion: ${e.toString()}');
    }
  }

  Future<void> _resendCode() async {
    if (widget.data.sessionToken == null) {
      _showError('Erreur: Token de session manquant.');
      return;
    }

    setState(() => _isResending = true);

    try {
      print('🔄 Renvoi du code de vérification pour: ${widget.data.email}');
      final response = await ApiService.resendVerificationCode(
        sessionToken: widget.data.sessionToken!,
      ).timeout(const Duration(seconds: 15));

      setState(() => _isResending = false);

      if (response['success'] == true) {
        print('✅ Code renvoyé avec succès à: ${widget.data.email}');
        _showSuccess('Nouveau code envoyé à votre adresse email.');
        _startResendCountdown();
      } else {
        String errorMessage = 'Erreur lors de l\'envoi du code';
        if (response['body'] != null && response['body']['message'] != null) {
          errorMessage = response['body']['message'];
        }
        print('❌ Erreur renvoi: $errorMessage');
        _showError(errorMessage);
      }
    } catch (e) {
      setState(() => _isResending = false);
      print('❌ Exception renvoi: $e');
      _showError('Erreur de connexion: ${e.toString()}');
    }
  }

  Future<void> _goToPreviousStep() async {
    try {
      if (widget.data.sessionToken == null) {
        throw Exception('Session token manquant');
      }
      
      final response = await ApiService.getStepData(
        sessionToken: widget.data.sessionToken!,
        stepNumber: 4,
      );
      
      if (response['success'] && response['body']['data'] != null) {
        final stepData = RegistrationData.fromApiData(response['body']['data']);
        widget.data
          ..isAmci = stepData.isAmci
          ..amciCode = stepData.amciCode;
        
        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.registerStep4,
            arguments: widget.data,
          );
        }
      } else {
        _showError('Erreur lors de la récupération des données de l\'étape précédente');
      }
    } catch (e) {
      _showError('Erreur lors du retour: $e');
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CesamColors.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      prefixIcon: const Icon(Icons.verified_outlined, color: Colors.black54),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Étape 5 - Vérification Email',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header - Email déjà envoyé
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CesamColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CesamColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CesamColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        size: 40,
                        color: CesamColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vérification de votre email',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CesamColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Un code de vérification à 6 chiffres a été envoyé à :',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.data.email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CesamColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Champ de saisie du code
              TextFormField(
                controller: _codeController,
                decoration: _inputDecoration('Code de vérification (6 chiffres)'),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer le code de vérification';
                  }
                  if (value.length != 6) {
                    return 'Le code doit contenir exactement 6 chiffres';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Vérification automatique quand 6 chiffres sont saisis
                  if (value.length == 6 && !_isLoading) {
                    _verifyCode();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Bouton de vérification
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CesamColors.primary),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CesamColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Vérifier le code',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Section renvoyer le code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Vous n\'avez pas reçu le code ?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_countdown > 0) ...[
                      Text(
                        'Vous pourrez renvoyer le code dans ${_countdown}s',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ] else ...[
                      _isResending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TextButton(
                              onPressed: _resendCode,
                              style: TextButton.styleFrom(
                                foregroundColor: CesamColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Renvoyer le code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bouton Retour
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

              // Instructions supplémentaires
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, 
                            color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Informations importantes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Le code de vérification expire après 10 minutes\n'
                      '• Vérifiez vos spams/courrier indésirable\n'
                      '• La vérification se fait automatiquement à 6 chiffres\n'
                      '• Assurez-vous d\'avoir une connexion internet stable',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                        height: 1.4,
                      ),
                    ),
                  ],
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
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}