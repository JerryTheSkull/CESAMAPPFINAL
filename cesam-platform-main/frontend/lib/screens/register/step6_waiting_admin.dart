import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../models/registration_data.dart';

class Step6WaitingAdmin extends StatelessWidget {
  final RegistrationData? data;

  const Step6WaitingAdmin({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    print('✅ Step6WaitingAdmin affiché pour : ${data?.fullName}');

    return Scaffold(
      backgroundColor: CesamColors.primary,
      body: SafeArea(
        child: Center( // ✅ Correction ici
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_read_rounded, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  "Votre inscription a bien été prise en compte.\n\n"
                  "Vous recevrez une notification une fois que l'administrateur l'aura validée.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Revenir à la connexion"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: CesamColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
