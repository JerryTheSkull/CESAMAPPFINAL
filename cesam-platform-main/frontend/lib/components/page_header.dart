// lib/components/page_header_with_avatar.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service_profile.dart';
import '../pages/profile_util_page.dart'; // Assure-toi que le chemin est correct

class PageHeaderWithAvatar extends StatefulWidget {
  final String title;

  const PageHeaderWithAvatar({super.key, required this.title});

  @override
  State<PageHeaderWithAvatar> createState() => _PageHeaderWithAvatarState();
}

class _PageHeaderWithAvatarState extends State<PageHeaderWithAvatar> {
  String? _profilePhotoUrl;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final result = await ApiServiceProfile.getProfile();
      final body = result['body'];
      setState(() {
        _profilePhotoUrl = body['photo_url']; // selon ton API
        _fullName = body['nom_complet'] ?? 'Utilisateur';
      });
    } catch (e) {
      print('❌ Impossible de charger le profil: $e');
    }
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: CesamColors.primary,
                    backgroundImage: _profilePhotoUrl != null
                        ? NetworkImage(_profilePhotoUrl!)
                        : null,
                    child: _profilePhotoUrl == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName ?? '',
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileUtilPage(initialUser: null), 
                              // ou passe l'objet utilisateur si tu en as un
                            ),
                          );
                        },
                        child: const Text(
                          'Voir le profil',
                          style: TextStyle(
                            color: CesamColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.black12),
              const SizedBox(height: 8),
              _UserMenuItem(
                icon: Icons.access_time,
                label: 'Récents',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CesamColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => _showUserMenu(context),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: CesamColors.primary,
              backgroundImage:
                  _profilePhotoUrl != null ? NetworkImage(_profilePhotoUrl!) : null,
              child: _profilePhotoUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UserMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(color: Colors.black87)),
      onTap: onTap,
    );
  }
}
