// Fichier : step4_amci.dart
import 'package:flutter/material.dart';
import '../../../models/registration_data.dart';
import '../../../constants/colors.dart';
import '../../app_routes.dart';
import '../../../services/api_service.dart';
import 'dart:async';

class Step4AMCI extends StatefulWidget {
  final RegistrationData data;

  const Step4AMCI({super.key, required this.data});

  @override
  State<Step4AMCI> createState() => _Step4AMCIState();
}

class _Step4AMCIState extends State<Step4AMCI> {
  bool _isAffilie = false;
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isAffilie = widget.data.isAmci ?? false;
    _codeController.text = widget.data.amciCode ?? '';
    print('🏛️ Step4 - Données reçues:');
    widget.data.printDebug();
  }

  Future<void> _goToNextStep() async {
    if (widget.data.sessionToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Token de session manquant. Veuillez recommencer l\'inscription.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.registerStep4(
        sessionToken: widget.data.sessionToken!,
        codeAmci: _isAffilie && _codeController.text.trim().isNotEmpty
            ? _codeController.text.trim()
            : null,
        affilieAmci: _isAffilie,
      ).timeout(const Duration(seconds: 10));

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        widget.data
          ..isAmci = _isAffilie
          ..amciCode = _isAffilie && _codeController.text.trim().isNotEmpty
              ? _codeController.text.trim()
              : null;

        print('✅ Step4 réussi');
        widget.data.printDebug();

        Navigator.pushNamed(
          context,
          AppRoutes.registerStep5,
          arguments: widget.data,
        );
      } else {
        String errorMessage = 'Erreur inconnue';
        if (response['body'] != null) {
          final body = response['body'];
          if (body['errors'] != null) {
            final errors = body['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            errors.forEach((field, messages) {
              if (messages is List) {
                errorMessages.addAll(messages.cast<String>());
              } else if (messages is String) {
                errorMessages.add(messages);
              }
            });
            errorMessage = errorMessages.join('\n');
          } else if (body['message'] != null) {
            errorMessage = body['message'];
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        print('❌ Erreur API Step4: ${response['status']} - $errorMessage');
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Temps de réponse dépassé. Veuillez vérifier votre connexion.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('❌ Exception Step4: $e');
    }
  }

  Future<void> _goToPreviousStep() async {
  try {
    if (widget.data.sessionToken == null) {
      throw Exception('Session token manquant');
    }

    final response = await ApiService.getStepData(
      sessionToken: widget.data.sessionToken!,
      stepNumber: 3, // Étape précédente = 3
    );

    if (response['success'] && response['body']['data'] != null) {
      final stepData = RegistrationData.fromApiData(response['body']['data']);
      
      // Mettre à jour les champs nécessaires de Step4AMCI
      widget.data
        ..skills = stepData.skills
        ..skillsList = stepData.skillsList
        ..projects = stepData.projects
        ..cvFilePath = stepData.cvFilePath;

      Navigator.pushNamed(
        context,
        AppRoutes.registerStep3,
        arguments: widget.data,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la récupération des données de l\'étape précédente'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors du retour: $e'),
        backgroundColor: Colors.red,
      ),
    );
    print('❌ Erreur retour Step3: $e');
  }
}


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black26)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: CesamColors.primary, width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black26)),
      prefixIcon: const Icon(Icons.badge_outlined, color: Colors.black54),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              children: [
                // Logo
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: const AssetImage('assets/logo_cesam.png'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                // Wave + contenu
                ClipPath(
                  clipper: _InvertedTopWaveClipper(),
                  child: Container(
                    width: double.infinity,
                    color: CesamColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          'Étape 4 - Affiliation AMCI',
                          style: TextStyle(fontSize: 26, fontFamily: 'Pacifico', color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildInfoAmci(),
                              const SizedBox(height: 24),
                              _buildStatutAmciCard(),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CesamColors.primary)),
                                      )
                                    : ElevatedButton(
                                        onPressed: _goToNextStep,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: CesamColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text(
                                          'Suivant',
                                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _goToPreviousStep,
                                child: const Text('Retour à l\'étape précédente'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoAmci() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CesamColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CesamColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.info_outline, color: CesamColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'L\'Agence Marocaine de Coopération Internationale (AMCI) gère les programmes de bourses d\'études pour les étudiants étrangers au Maroc.',
                  style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatutAmciCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statut AMCI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CesamColors.primary)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: _isAffilie ? CesamColors.primary.withOpacity(0.1) : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isAffilie ? CesamColors.primary.withOpacity(0.3) : Colors.grey[300]!),
              ),
              child: SwitchListTile(
                title: const Text('Êtes-vous affilié(e) à l\'AMCI ?'),
                subtitle: Text(
                  _isAffilie ? 'Vous bénéficiez d\'une bourse AMCI' : 'Vous n\'êtes pas boursier AMCI',
                  style: TextStyle(color: _isAffilie ? CesamColors.primary : Colors.grey[600]),
                ),
                value: _isAffilie,
                onChanged: (value) {
                  setState(() {
                    _isAffilie = value;
                    if (!value) _codeController.clear();
                  });
                },
                activeColor: CesamColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            if (_isAffilie) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: _inputDecoration('Matricule AMCI (optionnel)'),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 8),
              Text(
                'Si vous ne connaissez pas votre matricule AMCI, vous pouvez laisser ce champ vide.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}

class _InvertedTopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 40);
    path.quadraticBezierTo(size.width / 4, 0, size.width / 2, 30);
    path.quadraticBezierTo(size.width * 3 / 4, 70, size.width, 40);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
