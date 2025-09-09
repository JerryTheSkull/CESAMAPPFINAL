import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../components/cesam_app_bar.dart';
import '../components/page_header.dart';
import '../options/adhesion_paiement_page.dart';
import '../options/amci_code_page.dart';
import 'profile_acad_page.dart';
import 'profile_util_page.dart';
import '../options/stage_emploi_page.dart';
import '../options/pfe_database_page.dart';
import '../models/cesam_user.dart';
import '../services/user_service.dart';
import 'politique_page.dart';

import '../admin/admin_quotes_page.dart';
import '../admin/admin_video_submission_page.dart';
import '../options/guides_poursuite_etudes_page.dart';
import '../admin/admin_excel_upload_page.dart';
import '../admin/admin_user_list_page.dart';
import '../options/tv_channel_page.dart';
import '../admin/admin_pfe_page.dart';

import '../admin/admin_offers_page.dart';

class ServicesPage extends StatefulWidget {
  final CesamUser user;
  const ServicesPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String? selectedServiceTitle;
  CesamUser? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    UserService.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    UserService.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged(CesamUser? user) {
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);

    CesamUser? user = UserService.currentUser;

    if (user == null) {
      user = await UserService.loadCurrentUser();
    }

    // ⚡ Utiliser widget.user comme fallback si UserService ne renvoie rien
    user ??= widget.user;

    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }

    if (user == null && mounted) {
      // Aucun user disponible → redirection login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: CesamColors.background,
        appBar: const CesamAppBar(title: 'Services'),
        body: const Center(
          child: CircularProgressIndicator(color: CesamColors.primary),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: CesamColors.background,
        appBar: const CesamAppBar(title: 'Services'),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Utilisateur non connecté',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: const CesamAppBar(title: 'Services'),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              height: 60,
              child: Container(
                color: CesamColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: PageHeaderWithAvatar(
                  title: 'Services - ${_currentUser!.name}',
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // Section Administration - uniquement pour les admins
              if (_currentUser!.isAdmin) ...[
                _buildSectionTitle('🔧 Administration'),

                _buildServiceTile(
                  'Gérer les utilisateurs',
                  Icons.admin_panel_settings,
                  context,
                  const AdminUserListPage(),
                ),

                _buildServiceTile(
                  'PFE : valider / publier',
                  Icons.library_add_check,
                  context,
                  const AdminPfePage(),
                ),

                _buildServiceTile(
                  'Candidatures',
                  Icons.description,
                  context,
                  const AdminOffersPage(),
                ),

                _buildServiceTile(
                  'Envoyer fichier Excel bourse',
                  Icons.file_upload,
                  context,
                  const AdminExcelUploadPage(),
                ),

                _buildServiceTile(
                  'Gérer les citations',
                  Icons.format_quote,
                  context,
                  const AdminQuotesPage(),
                ),

                _buildServiceTile(
                  'Publier vidéos',
                  Icons.ondemand_video,
                  context,
                  const AdminVideoSubmissionPage(),
                ),

                _buildServiceTile(
                  'Code de Bourses',
                  Icons.description,
                  context,
                  const AmciCodePage(),
                ),

                _buildServiceTile(
                  'Ajouter documents',
                  Icons.insert_drive_file,
                  context,
                  null, // Pas de page définie, donc snackbar
                ),
                const SizedBox(height: 16),
              ],

              // Section Adhésion & Compte
              _buildServiceTile(
                'Mon Profil',
                Icons.person,
                context,
                ProfileUtilPage(initialUser: _currentUser),
              ),

              // Section Espace AMCI - conditionnel (seulement si pas admin car admin l'a déjà)
              if (_currentUser!.isAmci == true && !_currentUser!.isAdmin) ...[
                _buildServiceTile(
                  'Code de Bourses',
                  Icons.description,
                  context,
                  const AmciCodePage(),
                ),
              ] else if (!_currentUser!.isAdmin) ...[
                // Si pas AMCI et pas admin, afficher quand même l'espace AMCI
                _buildServiceTile('Espace AMCI', Icons.school, context),
              ],

              // Section Études & Carrière
              _buildServiceTile('Formations & Écoles', Icons.book, context),
              _buildServiceTile(
                'Base de données PFE / Thèses',
                Icons.library_books,
                context,
                const PfeDatabasePage(),
              ),
              _buildServiceTile(
                'Stages & Emplois',
                Icons.work,
                context,
                const StageEmploiPage(),
              ),
              _buildServiceTile(
                'Guides pour la poursuite d\'études',
                Icons.school_outlined,
                context,
                const GuidesPoursuiteEtudesPage(),
              ),

              // Section Réseautage & Échange
              _buildServiceTile(
                'Valorisation des compétences',
                Icons.star,
                context,
                ProfileAcadPage(initialUser: _currentUser ?? widget.user),
              ),

              // Section Culture & Bien-être
              _buildServiceTile(
                'Chaîne TV étudiante',
                Icons.live_tv,
                context,
                const TvChannelPage(),
              ),
              _buildServiceTile(
                'Politique de Confidentialité',
                Icons.privacy_tip,
                context,
                const PolitiquePage(), // 👈 la page du PDF qu’on a créée
              ),

              const SizedBox(height: 20),

              // Informations utilisateur
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CesamColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CesamColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connecté en tant que :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CesamColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('👤 ${_currentUser!.name}'),
                    Text('📧 ${_currentUser!.email}'),
                    if (_currentUser!.studyField != null)
                      Text('📚 ${_currentUser!.studyField}'),
                    if (_currentUser!.isAdmin)
                      const Text(
                        '👑 Administrateur',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_currentUser!.isAmci == true)
                      const Text(
                        '🎓 Affilié AMCI',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: CesamColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildServiceTile(
    String title,
    IconData icon,
    BuildContext context, [
    Widget? targetPage,
  ]) {
    final bool isSelected = selectedServiceTitle == title;
    final Color iconColor =
        isSelected ? CesamColors.primary : CesamColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: CesamColors.cardBackground,
        child: ListTile(
          leading: Icon(icon, color: iconColor, size: 26),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: CesamColors.textPrimary,
            ),
          ),
          onTap: () {
            setState(() {
              selectedServiceTitle = title;
            });
            if (targetPage != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => targetPage),
              );
            } else {
              // Pour les fonctionnalités pas encore développées
              if (title == 'Ajouter documents') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité en cours de développement'),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _HeaderDelegate({required this.child, this.height = 60});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
