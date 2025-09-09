import 'package:flutter/material.dart';
import '../components/auth_scaffold.dart';
import '../constants/colors.dart';
import '../app_routes.dart';
import '../models/cesam_user.dart';
import '../services/api_service.dart';
import 'dashboard_student.dart'; // ✅ Import ajouté
import '../pages/reset_password_screen.dart'; // ✅ Import pour le reset de mot de passe

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false; // ✅ Variable pour gérer le loading

  // ✅ MÉTHODE DE LOGIN MISE À JOUR
  Future<void> _handleRealLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('🔐 Tentative de connexion avec API...');
        
        final result = await ApiService.login(
          email: email,
          password: password,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          print('📊 Résultat login: $result');

          if (result['success'] == true && result['body']['success'] == true) {
            // Connexion réussie
            final userData = result['body'];
            
            // Sauvegarder le token
            await ApiService.saveToken(userData['access_token']);
            
            // Sauvegarder les données utilisateur
            await ApiService.saveUserData(userData);
            
            // Afficher message de succès
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(userData['message'] ?? 'Connexion réussie'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            
            // ✅ NAVIGATION MISE À JOUR - Naviguer avec les données API et le rôle Spatie
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentDashboard(
                    apiUserData: userData['user'],
                    userRole: userData['role'], // ✅ Rôle depuis Spatie
                  ),
                ),
              );
            }
            
          } else {
            // Erreur de connexion
            final errorMessage = result['body']['message'] ?? 'Erreur de connexion';
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
            
            // Gestion des erreurs spécifiques
            if (result['status'] == 403) {
              // Email non vérifié
              _showEmailVerificationDialog();
            }
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          print('❌ Erreur lors de la connexion: $e');
          
          String errorMessage = 'Erreur de connexion';
          if (e.toString().contains('timeout')) {
            errorMessage = 'Délai d\'attente dépassé';
          } else if (e.toString().contains('SocketException')) {
            errorMessage = 'Impossible de se connecter au serveur';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email non vérifié'),
        content: const Text(
          'Votre email n\'est pas encore vérifié. '
          'Veuillez vérifier votre boîte mail et suivre les instructions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.black),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: CesamColors.primary, width: 2),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black26, width: 1),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Bienvenue dans l'App de la CESAM",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              cursorColor: CesamColors.primary,
              decoration: _inputDecoration('Email', Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              onChanged: (val) => email = val,
              validator: (val) => val != null && val.contains('@') ? null : 'Email invalide',
            ),
            const SizedBox(height: 20),
            TextFormField(
              cursorColor: CesamColors.primary,
              decoration: _inputDecoration('Mot de passe', Icons.lock_outline),
              obscureText: true,
              onChanged: (val) => password = val,
              validator: (val) => val != null && val.length >= 6 ? null : 'Mot de passe trop court',
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CesamColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                // ✅ BOUTON MISE À JOUR avec gestion du loading
                onPressed: _isLoading ? null : _handleRealLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

// ✅ BOUTON MOT DE PASSE OUBLIÉ
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ResetPasswordScreen(),
      ),
    );
  },
  child: const Text(
    "Mot de passe oublié ?",
    style: TextStyle(
      color: CesamColors.primary,
      fontWeight: FontWeight.bold,
    ),
  ),
),

// Lien vers l'inscription
TextButton(
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.registerStep1);
  },
  child: const Text(
    "Vous n'avez pas encore de compte ? S'inscrire",
    style: TextStyle(color: CesamColors.primary),
  ),
),

          ],
        ),
      ),
    );
  }
}