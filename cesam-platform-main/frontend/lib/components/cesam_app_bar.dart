import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CesamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // 👈 Gardé si tu veux l’utiliser plus tard, sinon tu peux le retirer

  const CesamAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CesamColors.background,
      elevation: 0,
      title: Row(
        children: const [
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/logo_cesam.png'),
            backgroundColor: CesamColors.background,
          ),
          SizedBox(width: 8),
          Text(
            'CESAM', // 👈 Texte statique au lieu de `title`
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
