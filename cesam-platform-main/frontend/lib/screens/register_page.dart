import 'package:flutter/material.dart';
import '../constants/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String password = '';

  void _simulateRegister() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Inscription réussie'),
          content: const Text('Vous pouvez maintenant vous connecter.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            )
          ],
        ),
      );
    }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      height: 200,
                      width: double.infinity,
                      child: const Center(
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: AssetImage('assets/logo_cesam.png'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: InvertedTopWaveClipper(),
                            child: Container(
                              color: CesamColors.primary,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),
                                const Text(
                                  'Créer un compte CESAM',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          cursorColor: CesamColors.primary,
                                          decoration: _customInputDecoration('Nom complet', Icons.person_outline),
                                          onChanged: (val) => fullName = val,
                                          validator: (val) =>
                                              val != null && val.isNotEmpty ? null : 'Veuillez entrer votre nom',
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          cursorColor: CesamColors.primary,
                                          decoration: _customInputDecoration('Email', Icons.email_outlined),
                                          keyboardType: TextInputType.emailAddress,
                                          onChanged: (val) => email = val,
                                          validator: (val) =>
                                              val != null && val.contains('@') ? null : 'Email invalide',
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          cursorColor: CesamColors.primary,
                                          decoration: _customInputDecoration('Mot de passe', Icons.lock_outline),
                                          obscureText: true,
                                          onChanged: (val) => password = val,
                                          validator: (val) =>
                                              val != null && val.length >= 6 ? null : 'Mot de passe trop court',
                                        ),
                                        const SizedBox(height: 24),
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
                                            onPressed: _simulateRegister,
                                            child: const Text(
                                              "S'inscrire",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
        },
      ),
    );
  }
}

class InvertedTopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 40);

    final firstControlPoint = Offset(size.width / 4, 0);
    final firstEndPoint = Offset(size.width / 2, 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    final secondControlPoint = Offset(size.width * 3 / 4, 70);
    final secondEndPoint = Offset(size.width, 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
