import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../constants/colors.dart';
import '../components/cesam_app_bar.dart';
import '../components/page_header.dart';
import '../models/cesam_user.dart';
import '../services/api_service_quote.dart';
import '../models/quote.dart';

// ✅ Imports pour les quick access
import '../options/amci_code_page.dart';
import 'profile_acad_page.dart';
import '../options/stage_emploi_page.dart';
import '../options/tv_channel_page.dart';

class HomePage extends StatefulWidget {
  final CesamUser user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int selectedQuickAccessIndex = -1;

  final List<String> bannerImages = [
    'assets/banner1.jpeg',
    'assets/banner2.jpeg',
    'assets/banner3.jpeg',
  ];

  Quote? _latestQuote; // Citation dynamique

  @override
  void initState() {
    super.initState();
    _fetchLatestQuote();
  }

  Future<void> _fetchLatestQuote() async {
    final quote = await ApiServiceQuote.getLatestQuote();
    if (mounted) {
      setState(() {
        _latestQuote = quote;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CesamAppBar(title: ''),
      backgroundColor: CesamColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 90)),

          // 🧊 Header avec avatar interactif
          const SliverToBoxAdapter(
            child: PageHeaderWithAvatar(title: 'Bienvenue sur CESAM'),
          ),

          // 🔍 Barre de recherche stylée
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    hintStyle: TextStyle(color: CesamColors.textSecondary),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: CesamColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: CesamColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🎠 Carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 190.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.88,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: bannerImages.map((imagePath) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: bannerImages.asMap().entries.map((entry) {
                      return Container(
                        width: _currentIndex == entry.key ? 14 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentIndex == entry.key
                              ? CesamColors.primary
                              : CesamColors.primary.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // 📜 Citation
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CesamColors.primary,
                    CesamColors.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _latestQuote == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '✨ Citation du jour :\n"${_latestQuote!.text}"\n— ${_latestQuote!.author}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          // ⚡ Accès rapide
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Accès rapide',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CesamColors.textPrimary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.1,
              children: [
                _buildQuickAccessTile(
                  'Profil',
                  Icons.group,
                  1,
                  targetPage:
                      ProfileAcadPage(initialUser: widget.user), // ✅ raccourci
                ),
                _buildQuickAccessTile(
                  'Code de Bourses',
                  Icons.description,
                  2,
                  targetPage: const AmciCodePage(),
                ),
                _buildQuickAccessTile(
                  'Chaîne TV',
                  Icons.live_tv,
                  3,
                  targetPage: const TvChannelPage(),
                ),
                _buildQuickAccessTile(
                  'Stages & Emplois',
                  Icons.work,
                  4,
                  targetPage: const StageEmploiPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Quick Access Tile avec navigation vers une page
  Widget _buildQuickAccessTile(
    String title,
    IconData icon,
    int index, {
    Widget? targetPage,
  }) {
    final bool isSelected = selectedQuickAccessIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedQuickAccessIndex = index;
        });
        if (targetPage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => targetPage),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CesamColors.cardBackground,
              CesamColors.cardBackground.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: (isSelected
                      ? CesamColors.primary
                      : CesamColors.textSecondary)
                  .withOpacity(0.1),
              child: Icon(
                icon,
                color: isSelected
                    ? CesamColors.primary
                    : CesamColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CesamColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
