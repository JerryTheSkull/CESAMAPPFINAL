import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service_pfe.dart';
import 'submit_pfe_form_page.dart';

class PfeDatabasePage extends StatefulWidget {
  const PfeDatabasePage({super.key});

  @override
  State<PfeDatabasePage> createState() => _PfeDatabasePageState();
}

class _PfeDatabasePageState extends State<PfeDatabasePage> {
  List<dynamic> _reports = [];
  bool _isLoading = false;
  String? _selectedDomain;
  int? _selectedYear;
  String _searchQuery = '';

  final List<String> _domains = [
    'Informatique & Numérique',
    'Génie & Technologies',
    'Sciences & Mathématiques',
    'Économie & Gestion',
    'Droit & Sciences politiques',
    'Médecine & Santé',
    'Arts & Lettres',
    'Enseignement & Pédagogie',
    'Agronomie & Environnement',
    'Tourisme & Hôtellerie',
    'Autres'
  ];

  // ✅ Générer les années disponibles (2000 à année actuelle)
  List<int> get _availableYears {
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 1999, (index) => currentYear - index);
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() async {
    setState(() => _isLoading = true);
    try {
      var reports = await ApiServicePfe.fetchAcceptedReports(
        domain: _selectedDomain,
        year: _selectedYear,
      );
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Erreur lors du chargement: $e");
    }
  }

  // ✅ CORRIGÉ: Utiliser les bonnes URLs pour les PDF
  Future<void> _viewPdf(int reportId) async {
    try {
      final viewUrl = ApiServicePfe.getViewUrl(reportId);
      if (!await launchUrl(
        Uri.parse(viewUrl),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception("Impossible d'ouvrir le PDF");
      }
    } catch (e) {
      _showErrorSnackBar("Erreur lors de l'ouverture du PDF: $e");
    }
  }

  // ✅ NOUVEAU: Télécharger un PDF
  Future<void> _downloadPdf(int reportId) async {
    try {
      final downloadUrl = ApiServicePfe.getDownloadUrl(reportId);
      if (!await launchUrl(
        Uri.parse(downloadUrl),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception("Impossible de télécharger le PDF");
      }
    } catch (e) {
      _showErrorSnackBar("Erreur lors du téléchargement: $e");
    }
  }

  // ✅ NOUVEAU: Afficher les détails d'un rapport
  Future<void> _showReportDetails(Map<String, dynamic> report) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          report["title"] ?? "Titre non disponible",
          style: const TextStyle(fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow("Type", report["type"]),
              _buildDetailRow("Auteur", report["author_name"]),
              _buildDetailRow("Année", report["defense_year"]?.toString()),
              _buildDetailRow("Domaine", report["domain"]),
              if (report["user"] != null && report["user"]["name"] != null)
                _buildDetailRow("Soumis par", report["user"]["name"]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _viewPdf(report["id"]);
            },
            icon: const Icon(Icons.visibility),
            label: const Text("Voir PDF"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? "N/A"),
          ),
        ],
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

  // ✅ AMÉLIORÉ: Modal de filtres plus complet
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 8),
                  const Text(
                    "Filtres de recherche",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Domaine",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                value: _selectedDomain,
                items: [
                  const DropdownMenuItem(value: null, child: Text("Tous les domaines")),
                  ..._domains.map((d) => DropdownMenuItem(
                    value: d, 
                    child: Text(d, style: const TextStyle(fontSize: 14)),
                  )),
                ],
                onChanged: (val) => setModalState(() => _selectedDomain = val),
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Année de soutenance",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                value: _selectedYear,
                items: [
                  const DropdownMenuItem(value: null, child: Text("Toutes les années")),
                  ..._availableYears.map((year) => DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  )),
                ],
                onChanged: (val) => setModalState(() => _selectedYear = val),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setModalState(() {
                          _selectedDomain = null;
                          _selectedYear = null;
                        });
                        setState(() {
                          _selectedDomain = null;
                          _selectedYear = null;
                        });
                        Navigator.pop(context);
                        _loadReports();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text("Réinitialiser"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadReports();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Appliquer"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NOUVEAU: Filtrage local par recherche textuelle
  List<dynamic> get _filteredReports {
    if (_searchQuery.isEmpty) return _reports;
    return _reports.where((report) {
      final title = (report["title"] ?? "").toLowerCase();
      final author = (report["author_name"] ?? "").toLowerCase();
      final domain = (report["domain"] ?? "").toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return title.contains(query) || 
             author.contains(query) || 
             domain.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Base de données PFE/PFA"),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
            tooltip: "Filtres",
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ NOUVEAU: Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher par titre, auteur ou domaine...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // ✅ NOUVEAU: Indicateur de filtres actifs
          if (_selectedDomain != null || _selectedYear != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  const Text("Filtres actifs:", style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  if (_selectedDomain != null)
                    Chip(
                      label: Text(_selectedDomain!, style: const TextStyle(fontSize: 10)),
                      onDeleted: () {
                        setState(() => _selectedDomain = null);
                        _loadReports();
                      },
                    ),
                  if (_selectedYear != null) ...[
                    const SizedBox(width: 4),
                    Chip(
                      label: Text(_selectedYear.toString(), style: const TextStyle(fontSize: 10)),
                      onDeleted: () {
                        setState(() => _selectedYear = null);
                        _loadReports();
                      },
                    ),
                  ],
                ],
              ),
            ),
          
          // Liste des rapports
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadReports(),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredReports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty 
                                    ? "Aucun rapport trouvé pour '$_searchQuery'"
                                    : "Aucun rapport trouvé",
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Tirez vers le bas pour actualiser",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredReports.length,
                          itemBuilder: (context, i) {
                            var report = _filteredReports[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: report["type"] == "PFE" 
                                      ? Colors.blue.shade100 
                                      : Colors.green.shade100,
                                  child: Text(
                                    report["type"] ?? "?",
                                    style: TextStyle(
                                      color: report["type"] == "PFE" 
                                          ? Colors.blue.shade700 
                                          : Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  report["title"] ?? "Titre non disponible",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text("👤 ${report["author_name"] ?? "N/A"}"),
                                    Text("📅 ${report["defense_year"] ?? "N/A"}"),
                                    Text(
                                      "🎓 ${report["domain"] ?? "N/A"}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.info),
                                          SizedBox(width: 8),
                                          Text("Détails"),
                                        ],
                                      ),
                                      onTap: () => Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () => _showReportDetails(report),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.visibility),
                                          SizedBox(width: 8),
                                          Text("Voir PDF"),
                                        ],
                                      ),
                                      onTap: () => Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () => _viewPdf(report["id"]),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(Icons.download),
                                          SizedBox(width: 8),
                                          Text("Télécharger"),
                                        ],
                                      ),
                                      onTap: () => Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () => _downloadPdf(report["id"]),
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                onTap: () => _showReportDetails(report),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitPfeFormPage()),
          ).then((_) => _loadReports()); // ✅ Recharger après soumission
        },
        icon: const Icon(Icons.add),
        label: const Text("Soumettre"),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
    );
  }
}