import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service_stage.dart';
import 'offer_detail_page.dart';

class StageEmploiPage extends StatefulWidget {
  const StageEmploiPage({super.key});

  @override
  State<StageEmploiPage> createState() => _StageEmploiPageState();
}

class _StageEmploiPageState extends State<StageEmploiPage> {
  List<Offer> _offers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    
    try {
      final offers = await ApiServiceStage.getOffers();
      setState(() => _offers = offers);
    } catch (e) {
      _showMessage('Erreur lors du chargement des offres', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Offer> get _filteredOffers {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _offers;
    
    return _offers.where((offer) {
      return offer.title.toLowerCase().contains(query) ||
             (offer.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        title: const Text('Stages & Emplois'),
        backgroundColor: CesamColors.background,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOffers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une offre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          // Liste des offres
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: CesamColors.primary))
                : _filteredOffers.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune offre disponible',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOffers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredOffers.length,
                          itemBuilder: (context, index) {
                            final offer = _filteredOffers[index];
                            return _buildOfferCard(offer);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(offer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône du type d'offre
              CircleAvatar(
                radius: 25,
                backgroundColor: offer.type == 'stage' 
                    ? Colors.orange.withOpacity(0.2) 
                    : Colors.blue.withOpacity(0.2),
                child: Icon(
                  offer.type == 'stage' ? Icons.school : Icons.work,
                  color: offer.type == 'stage' ? Colors.orange : Colors.blue,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Informations de l'offre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Type d'offre
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: offer.type == 'stage' 
                            ? Colors.orange.withOpacity(0.1) 
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: offer.type == 'stage' 
                              ? Colors.orange.withOpacity(0.3) 
                              : Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        offer.type == 'stage' ? 'Stage' : 'Emploi',
                        style: TextStyle(
                          color: offer.type == 'stage' ? Colors.orange : Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description (aperçu)
                    if (offer.description != null && offer.description!.isNotEmpty)
                      Text(
                        offer.description!.length > 80
                            ? '${offer.description!.substring(0, 80)}...'
                            : offer.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // Flèche de navigation
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(Offer offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailPage(
          offer: offer,
          onApplicationChanged: _loadOffers, // Recharger la liste après candidature
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}