import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/cesam_user.dart';
import '../services/user_management_service.dart';

class AdminUserListPage extends StatefulWidget {
  final List<CesamUser> users;

  const AdminUserListPage({super.key, this.users = const []});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Données
  List<CesamUser> _allUsers = [];
  List<CesamUser> _pendingUsers = [];
  List<CesamUser> _approvedUsers = [];
  List<CesamUser> _filteredUsers = [];
  Map<String, dynamic> _stats = {};
  
  // États
  bool _isLoading = true;
  bool _isSearching = false;
  
  // Filtres et recherche
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  
  // Sélection multiple (simplifié pour ton API)
  Set<int> _selectedUserIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ================ MÉTHODE UTILITAIRE CENTRALISÉE ================
  
  /// Vérification centralisée du rôle admin
  bool _isUserAdmin(CesamUser user) {
    if (user.role == null || user.role!.isEmpty) {
      print('DEBUG _isUserAdmin - Role is null/empty for user: ${user.name}');
      return false;
    }
    
    final normalizedRole = user.role!.toLowerCase().trim();
    final isAdmin = normalizedRole == 'admin' || normalizedRole == 'administrateur';
    
    print('DEBUG _isUserAdmin - User: ${user.name}, raw role: "${user.role}", normalized: "$normalizedRole", isAdmin: $isAdmin');
    
    return isAdmin;
  }

  // ================ CHARGEMENT DES DONNÉES ================
  
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _loadUsers(),
        _loadStats(),
      ]);
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsers() async {
    try {
      final futures = await Future.wait([
        UserManagementService.getAllUsers(),
        UserManagementService.getPendingUsers(), // verified=true & approved=false
        UserManagementService.getApprovedUsers(), // approved=true
      ]);
      
      setState(() {
        _allUsers = futures[0] as List<CesamUser>;
        _pendingUsers = futures[1] as List<CesamUser>;
        _approvedUsers = futures[2] as List<CesamUser>;
        
        _applyFilters();
      });
    } catch (e) {
      throw Exception('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await UserManagementService.getUsersStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      print('Erreur lors du chargement des statistiques: $e');
    }
  }

  void _applyFilters() {
    List<CesamUser> users;
    
    // Selon l'onglet actuel, utiliser la bonne liste
    if (_tabController.index == 0) {
      // Onglet "Approuvés" - seulement les comptes approuvés
      users = List.from(_approvedUsers);
    } else {
      // Onglet "En attente" - seulement les comptes vérifiés mais non approuvés
      users = List.from(_pendingUsers);
    }
    
    // Filtrage par rôle (seulement pour l'onglet approuvés)
    if (_tabController.index == 0) {
      switch (_selectedFilter) {
        case 'admin':
          users = users.where((u) => _isUserAdmin(u)).toList();
          break;
        case 'etudiant':
          users = users.where((u) => !_isUserAdmin(u)).toList();
          break;
      }
    }
    
    // Recherche textuelle
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      users = users.where((u) {
        return u.name.toLowerCase().contains(searchQuery) ||
               u.email.toLowerCase().contains(searchQuery) ||
               (u.school?.toLowerCase().contains(searchQuery) ?? false) ||
               (u.studyField?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }
    
    setState(() {
      _filteredUsers = users;
    });
  }

  // ================ ACTIONS SUR LES UTILISATEURS EN ATTENTE ================

  Future<void> _approveUser(CesamUser user) async {
    try {
      final result = await UserManagementService.approveUser(
        user.id!,
        action: 'approve',
      );

      if (result['success']) {
        _showSuccessSnackBar('Utilisateur approuvé avec succès');
        await _loadUsers();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de l\'approbation');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _disapproveUser(CesamUser user) async {
    try {
      String? reason = await _showDisapprovalDialog();
      if (reason == null || reason.trim().isEmpty) return;

      final result = await UserManagementService.approveUser(
        user.id!,
        action: 'disapprove',
        reason: reason,
      );

      if (result['success']) {
        _showSuccessSnackBar('Utilisateur désapprouvé');
        await _loadUsers();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la désapprobation');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  // ================ ACTIONS SUR LES UTILISATEURS APPROUVÉS ================

  Future<void> _promoteToAdmin(CesamUser user) async {
    try {
      final confirmed = await _showPromotionConfirmation(user.name);
      if (!confirmed) return;

      final result = await UserManagementService.changeUserRole(
        user.id!,
        role: 'admin',
      );

      if (result['success']) {
        _showSuccessSnackBar('${user.name} promu administrateur');
        await _loadUsers();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la promotion');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _demoteToStudent(CesamUser user) async {
    try {
      final confirmed = await _showDemotionConfirmation(user.name);
      if (!confirmed) return;

      final result = await UserManagementService.changeUserRole(
        user.id!,
        role: 'etudiant',
      );

      if (result['success']) {
        _showSuccessSnackBar('${user.name} rétrogradé en étudiant');
        await _loadUsers();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la rétrogradation');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  // ================ NOUVELLES MÉTHODES POUR SUPPRESSION AVEC ANNULATION ================

  Future<void> _deleteUser(CesamUser user) async {
    // Confirmation avant la suppression
    final confirmed = await _showDeleteConfirmation(user.name);
    if (!confirmed) return;

    // Sauvegarder temporairement l'utilisateur
    final userToDelete = user;
    
    // Retirer immédiatement de l'interface
    setState(() {
      _allUsers.removeWhere((u) => u.id == user.id);
      _approvedUsers.removeWhere((u) => u.id == user.id);
      _pendingUsers.removeWhere((u) => u.id == user.id);
      _applyFilters();
    });

    // Variable pour tracker si l'annulation a été demandée
    bool undoRequested = false;
    
    // Afficher le SnackBar avec option d'annulation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} sera supprimé'),
        action: SnackBarAction(
          label: 'ANNULER',
          textColor: Colors.white,
          onPressed: () {
            undoRequested = true;
            // Restaurer immédiatement dans l'interface
            _restoreUserInInterface(userToDelete);
            _showSuccessSnackBar('Suppression annulée');
          },
        ),
        duration: const Duration(seconds: 8),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    ).closed.then((reason) {
      // Quand le SnackBar se ferme, vérifier si on doit vraiment supprimer
      if (!undoRequested) {
        _performActualDeletion(userToDelete);
      }
    });
  }

  // Nouvelle méthode pour restaurer dans l'interface
  void _restoreUserInInterface(CesamUser user) {
    setState(() {
      _allUsers.add(user);
      
      if (user.isApproved == true) {
        _approvedUsers.add(user);
      } else if (user.isVerified == true) {
        _pendingUsers.add(user);
      }
      
      _applyFilters();
    });
  }

  // Nouvelle méthode pour la suppression réelle
  Future<void> _performActualDeletion(CesamUser user) async {
    try {
      final result = await UserManagementService.deleteUser(user.id!);

      if (result['success']) {
        // Suppression réussie - pas besoin de modifier l'interface, déjà fait
        _showSuccessSnackBar('${user.name} supprimé définitivement');
      } else {
        // Erreur - restaurer l'utilisateur dans l'interface
        _restoreUserInInterface(user);
        _showErrorSnackBar(result['message'] ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      // Erreur - restaurer l'utilisateur dans l'interface
      _restoreUserInInterface(user);
      _showErrorSnackBar('Erreur: $e');
    }
  }

  // Nouvelle méthode pour la suppression en lot réelle
  Future<void> _performBulkDeletion(List<CesamUser> usersToDelete) async {
    int successCount = 0;
    int failedCount = 0;
    List<CesamUser> failedUsers = [];

    for (final user in usersToDelete) {
      try {
        final result = await UserManagementService.deleteUser(user.id!);
        if (result['success']) {
          successCount++;
        } else {
          failedCount++;
          failedUsers.add(user);
        }
      } catch (e) {
        failedCount++;
        failedUsers.add(user);
      }
    }

    // Restaurer les utilisateurs qui n'ont pas pu être supprimés
    for (final user in failedUsers) {
      _restoreUserInInterface(user);
    }

    if (successCount > 0) {
      _showSuccessSnackBar('$successCount utilisateur(s) supprimé(s) définitivement');
    }
    if (failedCount > 0) {
      _showErrorSnackBar('$failedCount échec(s) - utilisateurs restaurés');
    }
  }

  // ================ MODE SÉLECTION SIMPLIFIÉ ================

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedUserIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedUserIds.clear();
    });
  }

  void _toggleUserSelection(int userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  // Actions en lot modifiées pour inclure l'annulation de suppression
  Future<void> _performBulkAction(String action) async {
    if (_selectedUserIds.isEmpty) {
      _showErrorSnackBar('Veuillez sélectionner au moins un utilisateur');
      return;
    }

    final confirmed = await _showBulkActionConfirmation(action, _selectedUserIds.length);
    if (!confirmed) return;

    if (action == 'delete') {
      // Sauvegarder les utilisateurs à supprimer
      final usersToDelete = _filteredUsers
          .where((u) => _selectedUserIds.contains(u.id))
          .toList();
      
      // Retirer de l'interface immédiatement
      setState(() {
        for (final userId in _selectedUserIds) {
          _allUsers.removeWhere((u) => u.id == userId);
          _approvedUsers.removeWhere((u) => u.id == userId);
          _pendingUsers.removeWhere((u) => u.id == userId);
        }
        _applyFilters();
      });

      bool undoRequested = false;
      
      // Afficher le SnackBar avec option d'annulation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedUserIds.length} utilisateur(s) seront supprimés'),
          action: SnackBarAction(
            label: 'ANNULER',
            textColor: Colors.white,
            onPressed: () {
              undoRequested = true;
              // Restaurer tous les utilisateurs
              for (final user in usersToDelete) {
                _restoreUserInInterface(user);
              }
              _showSuccessSnackBar('Suppression en lot annulée');
            },
          ),
          duration: const Duration(seconds: 10), // Plus de temps pour plusieurs utilisateurs
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      ).closed.then((reason) {
        // Quand le SnackBar se ferme, effectuer les suppressions réelles
        if (!undoRequested) {
          _performBulkDeletion(usersToDelete);
        }
      });

      _exitSelectionMode();
    } else {
      // Pour les autres actions, garder l'ancienne logique
      int successCount = 0;
      int failedCount = 0;
      List<String> errors = [];

      for (int userId in _selectedUserIds) {
        try {
          final user = _filteredUsers.firstWhere((u) => u.id == userId);
          Map<String, dynamic> result;

          switch (action) {
            case 'approve':
              result = await UserManagementService.approveUser(userId, action: 'approve');
              break;
            case 'disapprove':
              result = await UserManagementService.approveUser(userId, action: 'disapprove');
              break;
            case 'promote_admin':
              result = await UserManagementService.changeUserRole(userId, role: 'admin');
              break;
            case 'demote_student':
              result = await UserManagementService.changeUserRole(userId, role: 'etudiant');
              break;
            default:
              result = {'success': false, 'message': 'Action non reconnue'};
          }

          if (result['success']) {
            successCount++;
          } else {
            failedCount++;
            errors.add('${user.name}: ${result['message']}');
          }
        } catch (e) {
          failedCount++;
          errors.add('Utilisateur $userId: $e');
        }
      }

      if (successCount > 0) {
        _showSuccessSnackBar('$successCount utilisateur(s) traité(s) avec succès');
      }
      if (failedCount > 0) {
        _showErrorSnackBar('$failedCount échec(s)');
      }

      _exitSelectionMode();
      await _loadUsers();
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
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildApprovedUsersTab(),
                      _buildPendingUsersTab(),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : null,
      floatingActionButton: !_isSelectionMode ? _buildFAB() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _isSelectionMode
          ? Text('${_selectedUserIds.length} sélectionné(s)')
          : const Text('Gestion des utilisateurs'),
      backgroundColor: CesamColors.background,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitSelectionMode,
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _enterSelectionMode,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: CesamColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: CesamColors.primary,
        onTap: (index) => _applyFilters(), // Reappliquer les filtres quand on change d'onglet
        tabs: [
          Tab(
            text: 'Approuvés (${_stats['approved'] ?? _approvedUsers.length})',
            icon: const Icon(Icons.verified_user),
          ),
          Tab(
            text: 'En attente (${_stats['pending'] ?? _pendingUsers.length})',
            icon: const Icon(Icons.pending_actions),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    if (_stats.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total', _stats['total']?.toString() ?? '0', Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Vérifiés', _stats['verified']?.toString() ?? '0', Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Approuvés', _stats['approved']?.toString() ?? '0', Colors.purple),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('En attente', _stats['pending']?.toString() ?? '0', Colors.orange),
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
              hintText: 'Rechercher par nom, email, école...',
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
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
              });
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),
          // Filtres (seulement pour l'onglet approuvés)
          if (_tabController.index == 0) _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'Tous', Icons.people),
          _buildFilterChip('admin', 'Admins', Icons.admin_panel_settings),
          _buildFilterChip('student', 'Étudiants', Icons.school),
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

  Widget _buildApprovedUsersTab() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: _filteredUsers.isEmpty
              ? _buildEmptyState('Aucun utilisateur approuvé trouvé', Icons.verified_user)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return _buildApprovedUserCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPendingUsersTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Seuls les comptes vérifiés (email confirmé) peuvent être approuvés.',
                  style: TextStyle(color: Colors.blue[800], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredUsers.isEmpty
              ? _buildEmptyState(
                  'Aucun utilisateur vérifiés en attente d\'approbation', 
                  Icons.pending_actions
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return _buildPendingUserCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingUserCard(CesamUser user) {
    final isSelected = _selectedUserIds.contains(user.id);
    
    return Card(
      color: isSelected ? CesamColors.primary.withOpacity(0.1) : CesamColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
            ? BorderSide(color: CesamColors.primary, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: _isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleUserSelection(user.id!),
                activeColor: CesamColors.primary,
              )
            : _buildUserAvatar(user),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildPendingUserSubtitle(user),
        trailing: _isSelectionMode ? null : const Icon(Icons.expand_more),
        onExpansionChanged: _isSelectionMode
            ? (expanded) {
                if (expanded) _toggleUserSelection(user.id!);
              }
            : null,
        children: [
          _buildPendingUserDetails(user),
        ],
      ),
    );
  }

  Widget _buildApprovedUserCard(CesamUser user) {
    final isSelected = _selectedUserIds.contains(user.id);
    
    return Card(
      color: isSelected ? CesamColors.primary.withOpacity(0.1) : CesamColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
            ? BorderSide(color: CesamColors.primary, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: _isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleUserSelection(user.id!),
                activeColor: CesamColors.primary,
              )
            : _buildUserAvatar(user),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildApprovedUserSubtitle(user),
        trailing: _isSelectionMode ? null : _buildApprovedUserActions(user),
        onExpansionChanged: _isSelectionMode
            ? (expanded) {
                if (expanded) _toggleUserSelection(user.id!);
              }
            : null,
        children: [
          _buildApprovedUserDetails(user),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(CesamUser user) {
    // CORRECTION : Utiliser la méthode centralisée
    print('DEBUG Avatar - User role: "${user.role}", User name: ${user.name}'); // Debug
    
    final isAdmin = _isUserAdmin(user);
    return CircleAvatar(
      backgroundColor: isAdmin
          ? Colors.orange.withOpacity(0.2) 
          : CesamColors.primary.withOpacity(0.2),
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: isAdmin ? Colors.orange : CesamColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPendingUserSubtitle(CesamUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.email,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: const Text(
            'En attente d\'approbation',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedUserSubtitle(CesamUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.email,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildStatusBadge(user),
            const SizedBox(width: 8),
            _buildRoleBadge(user), // Utilise la méthode corrigée
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(CesamUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: const Text(
        'Approuvé',
        style: TextStyle(
          color: Colors.green,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(CesamUser user) {
    // CORRECTION : Utiliser la méthode centralisée
    final isAdmin = _isUserAdmin(user);
    print('DEBUG RoleBadge - User role: "${user.role}", isAdmin: $isAdmin'); // Debug
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAdmin ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Étudiant',
        style: TextStyle(
          color: isAdmin ? Colors.orange : Colors.blue,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPendingUserDetails(CesamUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations personnelles
          _buildDetailSection('Informations personnelles', [
            _buildUserDetail('Téléphone', user.phone ?? 'Non renseigné'),
            _buildUserDetail('Nationalité', user.nationality ?? 'Non renseigné'),
            _buildUserDetail('École', user.school ?? 'Non renseigné'),
            _buildUserDetail('Filière', user.studyField ?? 'Non renseigné'),
            _buildUserDetail('Niveau d\'études', user.academicLevel ?? 'Non renseigné'),
            _buildUserDetail('Ville', user.city ?? 'Non renseigné'),
          ]),
          
          const SizedBox(height: 12),

          // Informations AMCI (si affilié)
          if (user.isAmci == true) ...[
            _buildDetailSection('Informations AMCI', [
              _buildUserDetail('Affilié AMCI', 'Oui ✅'),
              if (user.amciCode?.isNotEmpty == true)
                _buildUserDetail('Code AMCI', user.amciCode!),
              if (user.amciMatricule?.isNotEmpty == true)
                _buildUserDetail('Matricule AMCI', user.amciMatricule!),
            ]),
            const SizedBox(height: 12),
          ],
          
          // Informations système
          _buildDetailSection('Informations système', [
            _buildUserDetail('ID', user.id?.toString() ?? 'N/A'),
            _buildUserDetail('Statut email', user.isVerified == true ? 'Vérifié ✅' : 'Non vérifié ❌'),
            if (user.createdAt != null)
              _buildUserDetail('Inscrit le', _formatDate(user.createdAt!)),
          ]),
          
          const SizedBox(height: 16),
          
          // Actions d'approbation/désapprobation
          _buildPendingActions(user),
        ],
      ),
    );
  }

  Widget _buildApprovedUserDetails(CesamUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations personnelles
          _buildDetailSection('Informations personnelles', [
            _buildUserDetail('Téléphone', user.phone ?? 'Non renseigné'),
            _buildUserDetail('Nationalité', user.nationality ?? 'Non renseigné'),
            _buildUserDetail('École', user.school ?? 'Non renseigné'),
            _buildUserDetail('Filière', user.studyField ?? 'Non renseigné'),
            _buildUserDetail('Niveau d\'études', user.academicLevel ?? 'Non renseigné'),
            _buildUserDetail('Ville', user.city ?? 'Non renseigné'),
          ]),
          
          const SizedBox(height: 12),

          // Informations AMCI (si affilié)
          if (user.isAmci == true) ...[
            _buildDetailSection('Informations AMCI', [
              _buildUserDetail('Affilié AMCI', 'Oui ✅'),
              if (user.amciCode?.isNotEmpty == true)
                _buildUserDetail('Code AMCI', user.amciCode!),
              if (user.amciMatricule?.isNotEmpty == true)
                _buildUserDetail('Matricule AMCI', user.amciMatricule!),
            ]),
            const SizedBox(height: 12),
          ],
          
          // Informations système - CORRECTION : Afficher correctement le rôle
          _buildDetailSection('Informations système', [
            _buildUserDetail('ID', user.id?.toString() ?? 'N/A'),
            _buildUserDetail('Rôle', _isUserAdmin(user) ? 'Administrateur' : 'Étudiant'),
            if (user.createdAt != null)
              _buildUserDetail('Inscrit le', _formatDate(user.createdAt!)),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: CesamColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...details,
      ],
    );
  }

  Widget _buildUserDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions(CesamUser user) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check, color: Colors.white, size: 18),
            label: const Text('Approuver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _approveUser(user),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            label: const Text('Désapprouver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _disapproveUser(user),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedUserActions(CesamUser user) {
    // CORRECTION : Utiliser la méthode centralisée
    final isAdmin = _isUserAdmin(user);
    
    print('DEBUG Actions - User: ${user.name}, role: "${user.role}", isAdmin: $isAdmin'); // Debug
    
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'promote_admin':
            await _promoteToAdmin(user);
            break;
          case 'demote_student':
            await _demoteToStudent(user);
            break;
          case 'delete':
            await _deleteUser(user);
            break;
        }
      },
      itemBuilder: (context) => [
        // Si l'utilisateur N'EST PAS admin, proposer de le promouvoir
        if (!isAdmin)
          const PopupMenuItem(
            value: 'promote_admin',
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text('Promouvoir admin'),
              ],
            ),
          ),
        // Si l'utilisateur EST admin, proposer de le rétrograder
        if (isAdmin)
          const PopupMenuItem(
            value: 'demote_student',
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text('Rétrograder étudiant'),
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

  Widget _buildSelectionBottomBar() {
    if (_tabController.index == 1) {
      // Onglet "En attente" - Actions d'approbation
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Approuver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _performBulkAction('approve'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Désapprouver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _performBulkAction('disapprove'),
              ),
            ),
          ],
        ),
      );
    } else {
      // Onglet "Approuvés" - Actions de gestion
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.admin_panel_settings, size: 18),
                label: const Text('Promouvoir Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _performBulkAction('promote_admin'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person, size: 18),
                label: const Text('Rétrograder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _performBulkAction('demote_student'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Supprimer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _performBulkAction('delete'),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _loadInitialData,
      backgroundColor: CesamColors.primary,
      child: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  // ================ DIALOGUES ================

  Future<String?> _showDisapprovalDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raison de la désapprobation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Entrez la raison de la désapprobation...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool> _showPromotionConfirmation(String userName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promouvoir administrateur'),
        content: Text('Voulez-vous promouvoir "$userName" en tant qu\'administrateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Promouvoir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showDemotionConfirmation(String userName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rétrograder en étudiant'),
        content: Text('Voulez-vous rétrograder "$userName" en étudiant ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rétrograder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showDeleteConfirmation(String userName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer définitivement l\'utilisateur "$userName" ?\n\nCette action est irréversible.',
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

  Future<bool> _showBulkActionConfirmation(String action, int count) async {
    String actionText;
    String warningText;
    
    switch (action) {
      case 'approve':
        actionText = 'approuver';
        warningText = 'Ces utilisateurs seront approuvés et pourront accéder à l\'application.';
        break;
      case 'disapprove':
        actionText = 'désapprouver';
        warningText = 'Ces utilisateurs seront désapprouvés.';
        break;
      case 'delete':
        actionText = 'supprimer';
        warningText = 'Cette action est irréversible.';
        break;
      case 'promote_admin':
        actionText = 'promouvoir en admin';
        warningText = 'Ces utilisateurs deviendront administrateurs.';
        break;
      case 'demote_student':
        actionText = 'rétrograder en étudiant';
        warningText = 'Ces utilisateurs deviendront étudiants.';
        break;
      default:
        actionText = 'traiter';
        warningText = 'Une action sera appliquée à ces utilisateurs.';
    }

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'action en lot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voulez-vous $actionText $count utilisateur${count > 1 ? 's' : ''} ?'),
            const SizedBox(height: 8),
            Text(
              warningText,
              style: TextStyle(
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'delete' ? Colors.red : CesamColors.primary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
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
