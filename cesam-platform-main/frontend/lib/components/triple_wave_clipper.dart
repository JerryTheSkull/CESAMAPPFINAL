// lib/components/triple_wave_clipper.dart
import 'package:flutter/material.dart';

class SimpleProfileWave extends StatelessWidget {
  final double height;
  final Color color;

  const SimpleProfileWave({
    super.key,
    this.height = 160,
    this.color = const Color(0xFF1971C2), // Bleu Cesam par défaut
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipPath(
        clipper: _ProfileWaveClipper(),
        child: Container(
          color: color,
        ),
      ),
    );
  }
}

class _ProfileWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final firstControl = Offset(size.width / 4, size.height);
    final firstEnd = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(firstControl.dx, firstControl.dy, firstEnd.dx, firstEnd.dy);

    final secondControl = Offset(size.width * 3 / 4, size.height - 60);
    final secondEnd = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(secondControl.dx, secondControl.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
