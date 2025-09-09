import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final double logoRadius;
  final String logoAssetPath;
  final Color waveColor;

  const AuthScaffold({
    super.key,
    required this.child,
    required this.title,
    this.logoRadius = 80,
    this.logoAssetPath = 'assets/logo_cesam.png',
    this.waveColor = CesamColors.primary,
  });

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
                    // Partie haute avec logo
                    Container(
                      color: Colors.white,
                      height: 200,
                      width: double.infinity,
                      child: Center(
                        child: CircleAvatar(
                          radius: logoRadius,
                          backgroundImage: AssetImage(logoAssetPath),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),

                    // Partie basse avec vague et contenu
                    Expanded(
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: _InvertedTopWaveClipper(),
                            child: Container(
                              color: waveColor,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 32), // ✅ titre descendu
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontFamily: 'Pacifico', // ✅ police manuscrite
                                    fontSize: 26,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
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
                                  child: child,
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

class _InvertedTopWaveClipper extends CustomClipper<Path> {
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
