import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service_stage.dart';

class AdminOffersPage extends StatefulWidget {
  const AdminOffersPage({super.key});

  @override
  State<AdminOffersPage> createState() => _AdminOffersPageState();
}

class _AdminOffersPageState extends State<AdminOffersPage> {
  // Données
  List<Offer> _allOffers = [];
  List<Offer> _filteredOffers = [];
  
  // États
  bool _isLoading = true;
  
  // Filtres
  String _selectedFilter = 'all';
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

  // ================ CHARGEMENT DES DONNÉES ================
  
  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    
    try {
      final offers = await ApiServiceStage.getAdminOffers();
      setState(() {
        _allOffers = offers;
        _applyFilters();
      });
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Offer> offers = List.from(_allOffers);
    
    // Filtrage par type/statut
    switch (_selectedFilter) {
      case 'stage':
        offers = offers.where((o) => o.type == 'stage').toList();
        break;
      case 'emploi':
        offers = offers.where((o) => o.type == 'emploi').toList();
        break;
      case 'active':
        offers = offers.where((o) => o.isActive).toList();
        break;
      case 'inactive':
        offers = offers.where((o) => !o.isActive).toList();
        break;
    }
    
    // Recherche textuelle
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      offers = offers.where((o) {
        return o.title.toLowerCase().contains(searchQuery) ||
               (o.description?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }
    
    setState(() {
      _filteredOffers = offers;
    });
  }

  // ================ ACTIONS ================

  Future<void> _createOffer() async {
    final result = await Navigator.push<Offer>(
      context,
      MaterialPageRoute(builder: (context) => const CreateOfferPage()),
    );
    
    if (result != null) {
      _showSuccessSnackBar('Offre créée avec succès');
      await _loadOffers();
    }
  }

  Future<void> _toggleOfferStatus(Offer offer) async {
    try {
      final result = await ApiServiceStage.toggleOfferStatus(offer.id!);
      
      if (result['success']) {
        _showSuccessSnackBar(result['message']);
        await _loadOffers();
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _deleteOffer(Offer offer) async {
    final confirmed = await _showDeleteConfirmation(offer.title);
    if (!confirmed) return;

    try {
      final result = await ApiServiceStage.deleteOffer(offer.id!);
      
      if (result['success']) {
        _showSuccessSnackBar(result['message']);
        await _loadOffers();
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _viewApplications(Offer offer) async {
    try {
      final result = await ApiServiceStage.getOfferApplications(offer.id!);
      
      if (result['success']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfferApplicationsPage(
              offerTitle: result['offer_title'],
              applicants: result['applicants'],
              offerId: offer.id!,
            ),
          ),
        );
      } else {
        _showErrorSnackBar('Erreur lors du chargement des candidatures');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  // ================ INTERFACE UTILISATEUR ================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: CesamColors.primary),
            )
          : Column(
              children: [
                _buildStatsBar(),
                _buildSearchAndFilters(),
                Expanded(
                  child: _filteredOffers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredOffers.length,
                          itemBuilder: (context, index) {
                            final offer = _filteredOffers[index];
                            return _buildOfferCard(offer);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createOffer,
        backgroundColor: CesamColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Gestion des Offres'),
      backgroundColor: CesamColors.background,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadOffers,
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    final totalOffers = _allOffers.length;
    final activeOffers = _allOffers.where((o) => o.isActive).length;
    final stageOffers = _allOffers.where((o) => o.type == 'stage').length;
    final emploiOffers = _allOffers.where((o) => o.type == 'emploi').length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total', totalOffers.toString(), Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Actives', activeOffers.toString(), Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Stages', stageOffers.toString(), Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Emplois', emploiOffers.toString(), Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher par titre ou description...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 12),
          // Filtres
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'Toutes', Icons.list),
          _buildFilterChip('stage', 'Stages', Icons.school),
          _buildFilterChip('emploi', 'Emplois', Icons.work),
          _buildFilterChip('active', 'Actives', Icons.visibility),
          _buildFilterChip('inactive', 'Inactives', Icons.visibility_off),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
          _applyFilters();
        },
        selectedColor: CesamColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? CesamColors.primary : Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune offre trouvée',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Créer une offre'),
            onPressed: _createOffer,
            style: ElevatedButton.styleFrom(
              backgroundColor: CesamColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Card(
      color: CesamColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: _buildOfferIcon(offer),
        title: Text(
          offer.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildOfferSubtitle(offer),
        trailing: _buildOfferActions(offer),
        children: [
          _buildOfferDetails(offer),
        ],
      ),
    );
  }

  Widget _buildOfferIcon(Offer offer) {
    return CircleAvatar(
      backgroundColor: offer.type == 'stage' 
          ? Colors.orange.withOpacity(0.2) 
          : Colors.blue.withOpacity(0.2),
      child: Icon(
        offer.type == 'stage' ? Icons.school : Icons.work,
        color: offer.type == 'stage' ? Colors.orange : Colors.blue,
      ),
    );
  }

  Widget _buildOfferSubtitle(Offer offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          offer.description != null && offer.description!.length > 50
              ? '${offer.description!.substring(0, 50)}...'
              : offer.description ?? 'Pas de description',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildTypeBadge(offer),
            const SizedBox(width: 8),
            _buildStatusBadge(offer),
            const SizedBox(width: 8),
            if (offer.applicationsCount != null)
              _buildApplicationsBadge(offer),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeBadge(Offer offer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: offer.type == 'stage' ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: offer.type == 'stage' ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Text(
        offer.type == 'stage' ? 'Stage' : 'Emploi',
        style: TextStyle(
          color: offer.type == 'stage' ? Colors.orange : Colors.blue,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Offer offer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: offer.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: offer.isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Text(
        offer.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: offer.isActive ? Colors.green : Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildApplicationsBadge(Offer offer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Text(
        '${offer.applicationsCount} candidat${offer.applicationsCount! > 1 ? 's' : ''}',
        style: const TextStyle(
          color: Colors.purple,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOfferActions(Offer offer) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'toggle_status':
            await _toggleOfferStatus(offer);
            break;
          case 'applications':
            await _viewApplications(offer);
            break;
          case 'delete':
            await _deleteOffer(offer);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle_status',
          child: Row(
            children: [
              Icon(
                offer.isActive ? Icons.visibility_off : Icons.visibility,
                color: offer.isActive ? Colors.orange : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(offer.isActive ? 'Désactiver' : 'Activer'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'applications',
          child: Row(
            children: [
              const Icon(Icons.people, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text('Candidatures (${offer.applicationsCount ?? 0})'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Supprimer'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferDetails(Offer offer) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer.description != null) ...[
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CesamColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(offer.description!),
            const SizedBox(height: 12),
          ],
          
          Row(
            children: [
              if (offer.images != null && offer.images!.isNotEmpty)
                _buildDetailChip('${offer.images!.length} image(s)', Icons.image),
              if (offer.pdfs != null && offer.pdfs!.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildDetailChip('${offer.pdfs!.length} PDF(s)', Icons.picture_as_pdf),
              ],
              if (offer.links != null && offer.links!.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildDetailChip('${offer.links!.length} lien(s)', Icons.link),
              ],
            ],
          ),
          
          if (offer.createdAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Créée le ${_formatDate(offer.createdAt!)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ================ DIALOGUES ================

  Future<bool> _showDeleteConfirmation(String offerTitle) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'offre "$offerTitle" ?\n\nToutes les candidatures associées seront également supprimées.\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  // ================ UTILITAIRES ================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// ================ PAGE DE CRÉATION D'OFFRE ================

class CreateOfferPage extends StatefulWidget {
  const CreateOfferPage({super.key});

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'stage';
  bool _isActive = true;
  bool _isLoading = false;
  
  final List<String> _images = [];
  final List<String> _pdfs = [];
  final List<String> _links = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final offer = Offer(
        title: _titleController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        images: _images.isNotEmpty ? _images : null,
        pdfs: _pdfs.isNotEmpty ? _pdfs : null,
        links: _links.isNotEmpty ? _links : null,
        isActive: _isActive,
      );

      final result = await ApiServiceStage.createOffer(offer);

      if (result['success']) {
        Navigator.pop(context, result['offer']);
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        title: const Text('Créer une offre'),
        backgroundColor: CesamColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Titre
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de l\'offre *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre est obligatoire';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type d\'offre *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'stage', child: Text('Stage')),
                DropdownMenuItem(value: 'emploi', child: Text('Emploi')),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            
            const SizedBox(height: 16),
            
            // Statut actif
            SwitchListTile(
              title: const Text('Offre active'),
              subtitle: const Text('L\'offre sera visible par les utilisateurs'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: CesamColors.primary,
            ),
            
            const SizedBox(height: 32),
            
            // Bouton de création
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CesamColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Créer l\'offre'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ================ PAGE DES CANDIDATURES ================

class OfferApplicationsPage extends StatelessWidget {
  final String offerTitle;
  final List<Applicant> applicants;
  final int offerId;

  const OfferApplicationsPage({
    super.key,
    required this.offerTitle,
    required this.applicants,
    required this.offerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        title: Text('Candidatures - $offerTitle'),
        backgroundColor: CesamColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: applicants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune candidature pour cette offre',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applicants.length,
              itemBuilder: (context, index) {
                final applicant = applicants[index];
                return Card(
                  color: CesamColors.cardBackground,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: CesamColors.primary.withOpacity(0.2),
                      child: Text(
                        applicant.nomComplet.isNotEmpty 
                            ? applicant.nomComplet[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: CesamColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      applicant.nomComplet,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (applicant.competences.isNotEmpty)
                          Text(
                            'Compétences: ${applicant.competences.join(', ')}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        Text(
                          'Candidature le ${_formatDate(applicant.appliedAt)}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${applicant.projects.length} projet${applicant.projects.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}