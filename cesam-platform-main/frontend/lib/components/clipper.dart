import 'package:flutter/material.dart';

/// 🌊 Vague bleue classique — utilisée dans le profil
class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);

    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    final secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// 📈 Vague dynamique — utilisée dans les headers d’Accueil / Services / Compte
class ProgressiveWaveClipper extends CustomClipper<Path> {
  final int pageIndex; // 0: Accueil, 1: Services, 2: Compte...

  ProgressiveWaveClipper({required this.pageIndex});

  @override
  Path getClip(Size size) {
    final path = Path();

    final double baseDrop = 40.0 + (pageIndex * 20); // variation progressive

    path.lineTo(0, size.height - baseDrop - 60);

    final firstControlPoint = Offset(size.width / 4, size.height - baseDrop);
    final firstEndPoint = Offset(size.width / 2, size.height - baseDrop - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 3 / 4, size.height - baseDrop - 80);
    final secondEndPoint = Offset(size.width, size.height - baseDrop - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ProgressiveWaveClipper oldClipper) {
    return oldClipper.pageIndex != pageIndex;
  }
}

/// ✅ Petite vague d’accent verte — utilisée sous un bloc pour la photo
class BottomAccentWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);

    final firstControlPoint = Offset(size.width / 4, 30);
    final firstEndPoint = Offset(size.width / 2, 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 3 / 4, 10);
    final secondEndPoint = Offset(size.width, 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// 🔁 Vague miroir utilisée pour le haut et le bas de la page Login
class SymmetricWaveClipper extends CustomClipper<Path> {
  final double drop;

  SymmetricWaveClipper(this.drop);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - drop);

    final firstControl = Offset(size.width * 0.25, size.height - drop - 40);
    final firstEnd = Offset(size.width * 0.5, size.height - drop + 80);
    path.quadraticBezierTo(firstControl.dx, firstControl.dy, firstEnd.dx, firstEnd.dy);

    final secondControl = Offset(size.width * 0.75, size.height - drop + 120);
    final secondEnd = Offset(size.width, size.height - drop + 60);
    path.quadraticBezierTo(secondControl.dx, secondControl.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(SymmetricWaveClipper oldClipper) => oldClipper.drop != drop;
}
