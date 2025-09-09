import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service_reset_password.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  int step = 1; // 1 = email, 2 = code, 3 = nouveau mot de passe
  bool isLoading = false;
  String? message;
  String? _resetToken; // token renvoyé par le backend

  // Étape 1 : envoyer le code
  void _sendCode() async {
    // Validation basique de l'email
    if (_emailController.text.trim().isEmpty || 
        !_emailController.text.trim().contains('@')) {
      setState(() {
        message = 'Veuillez entrer un email valide.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = null;
    });

    final result = await ApiServiceResetPassword.sendResetCode(
      _emailController.text.trim(),
    );

    setState(() {
      isLoading = false;
      message = result['message'] ?? (result['success'] ? 'Code envoyé' : 'Erreur');
      if (result['success'] == true) {
        step = 2;
        // NE PAS récupérer le token ici - sécurité
        // Le token sera récupéré après vérification du code
      }
    });
  }

  // Étape 2 : vérifier le code
  void _verifyCode() async {
    // Validation basique du code
    if (_codeController.text.trim().isEmpty) {
      setState(() {
        message = 'Veuillez entrer le code reçu.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = null;
    });

    final result = await ApiServiceResetPassword.verifyResetCode(
      _emailController.text.trim(),
      _codeController.text.trim(),
    );

    setState(() {
      isLoading = false;
      message = result['message'] ?? (result['success'] ? 'Code validé' : 'Erreur');
      if (result['success'] == true) {
        step = 3;
        // MAINTENANT récupérer le token après vérification réussie
        _resetToken = result['data']['token'];
        print('Token récupéré après vérification: $_resetToken'); // Debug
      }
    });
  }

  // Étape 3 : réinitialiser le mot de passe
  void _resetPassword() async {
    // Validation du mot de passe
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        message = 'Veuillez entrer un nouveau mot de passe.';
      });
      return;
    }

    if (_passwordController.text.length < 8) {
      setState(() {
        message = 'Le mot de passe doit contenir au moins 8 caractères.';
      });
      return;
    }

    if (_resetToken == null) {
      setState(() {
        message = 'Token manquant, veuillez recommencer le processus.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = null;
    });

    final result = await ApiServiceResetPassword.resetPassword(
      _emailController.text.trim(),
      _codeController.text.trim(),
      _passwordController.text.trim(),
      _resetToken!,
    );

    setState(() {
      isLoading = false;
      message = result['message'] ?? (result['success'] ? 'Mot de passe réinitialisé avec succès' : 'Erreur');
      if (result['success'] == true) {
        // Retour à l'étape 1 et nettoyage
        step = 1;
        _emailController.clear();
        _codeController.clear();
        _passwordController.clear();
        _resetToken = null;
        
        // Optionnel : retourner à l'écran de connexion après quelques secondes
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        backgroundColor: CesamColors.primary,
        title: const Text(
          'Réinitialisation du mot de passe',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: CesamColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: CesamColors.border),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Indicateur d'étape
                  _buildStepIndicator(),
                  const SizedBox(height: 20),
                  
                  // Contenu selon l'étape
                  if (step == 1) _buildEmailStep(),
                  if (step == 2) _buildCodeStep(),
                  if (step == 3) _buildPasswordStep(),
                  
                  const SizedBox(height: 20),
                  
                  // Bouton d'action ou loader
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    _buildActionButton(),
                  
                  // Message de retour
                  if (message != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSuccessMessage(message!) 
                            ? CesamColors.accent.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isSuccessMessage(message!) 
                              ? CesamColors.accent
                              : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        message!,
                        style: TextStyle(
                          color: _isSuccessMessage(message!) 
                              ? CesamColors.accent
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1, 'Email'),
        _buildStepLine(step > 1),
        _buildStepCircle(2, 'Code'),
        _buildStepLine(step > 2),
        _buildStepCircle(3, 'Mot de passe'),
      ],
    );
  }

  Widget _buildStepCircle(int stepNumber, String label) {
    bool isActive = step == stepNumber;
    bool isCompleted = step > stepNumber;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
                ? CesamColors.accent
                : isActive 
                    ? CesamColors.primary
                    : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive || isCompleted 
                ? CesamColors.textPrimary
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? CesamColors.accent : Colors.grey.shade300,
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Entrez votre email :",
          style: TextStyle(fontSize: 16, color: CesamColors.textPrimary),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Email",
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Entrez le code reçu par email :",
          style: TextStyle(fontSize: 16, color: CesamColors.textPrimary),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Code de vérification",
            prefixIcon: Icon(Icons.security),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Entrez votre nouveau mot de passe :",
          style: TextStyle(fontSize: 16, color: CesamColors.textPrimary),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nouveau mot de passe",
            prefixIcon: Icon(Icons.lock_outline),
            helperText: "Minimum 8 caractères",
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    String text = '';
    VoidCallback? onPressed;

    switch (step) {
      case 1:
        text = 'Envoyer le code';
        onPressed = _sendCode;
        break;
      case 2:
        text = 'Vérifier le code';
        onPressed = _verifyCode;
        break;
      case 3:
        text = 'Réinitialiser le mot de passe';
        onPressed = _resetPassword;
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CesamColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _isSuccessMessage(String message) {
    return message.toLowerCase().contains("succès") ||
           message.toLowerCase().contains("envoyé") ||
           message.toLowerCase().contains("validé") ||
           message.toLowerCase().contains("réinitialisé");
  }
}