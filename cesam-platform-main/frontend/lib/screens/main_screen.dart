import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/services_page.dart';
import '../pages/profile_acad_page.dart';
import '../constants/colors.dart';
import '../models/cesam_user.dart'; // ✅ Import du modèle utilisateur

class MainScreen extends StatefulWidget {
  final CesamUser user; // ✅ Ajout du user

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomePage(user: widget.user),       // ✅ Tu pourras filtrer l'affichage si besoin
          ServicesPage(user: widget.user),   // ✅ Important pour afficher les options admin
          ProfileAcadPage(initialUser: widget.user),   // ✅ Si tu veux montrer des infos dynamiques
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: CesamColors.background,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: CesamColors.select,
        selectedItemColor: CesamColors.primary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
