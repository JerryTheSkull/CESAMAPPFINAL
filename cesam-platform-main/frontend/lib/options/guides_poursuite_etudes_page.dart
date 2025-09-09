import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../components/cesam_app_bar.dart';

class GuidesPoursuiteEtudesPage extends StatelessWidget {
  const GuidesPoursuiteEtudesPage({super.key});

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: const Text("Cette ressource sera bientôt disponible."),
        backgroundColor: CesamColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: CesamColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> guides = [
      "Choisir une spécialisation",
      "Trouver une école ou université",
      "Procédures d’inscription",
      "Bourses et financements",
      "Conseils pour réussir",
    ];

    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: const CesamAppBar(title: 'Guides pour la poursuite d’études'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenue dans la section Guides pour la poursuite d’études.\n\n"
              "Ici, vous trouverez des ressources et conseils pour vous aider à choisir votre parcours après vos études actuelles.",
              style: TextStyle(fontSize: 16, color: CesamColors.textPrimary),
            ),
            const SizedBox(height: 24),
            const Text(
              "Exemples de guides disponibles :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CesamColors.primary),
            ),
            const SizedBox(height: 12),
            ...guides.map((title) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(title),
                onPressed: () => _showComingSoon(context, title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CesamColors.cardBackground,
                  foregroundColor: CesamColors.textPrimary,
                  shadowColor: Colors.transparent,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: CesamColors.primary, width: 1),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
