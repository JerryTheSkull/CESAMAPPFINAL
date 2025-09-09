import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service_pfe.dart';
import 'package:open_file/open_file.dart';

class AdminPfePage extends StatefulWidget {
  const AdminPfePage({super.key});

  @override
  State<AdminPfePage> createState() => _AdminPfePageState();
}

class _AdminPfePageState extends State<AdminPfePage> with TickerProviderStateMixin {
  List<dynamic> _reports = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String _currentFilter = 'pending'; // 'all', 'pending', 'accepted', 'rejected'
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    switch (_tabController.index) {
      case 0: _currentFilter = 'pending'; break;
      case 1: _currentFilter = 'accepted'; break;
      case 2: _currentFilter = 'rejected'; break;
      case 3: _currentFilter = 'all'; break;
    }
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    
    try {
      final result = (_currentFilter == 'pending')
          ? await ApiServicePfe.fetchPendingReports()
          : await ApiServicePfe.fetchReports(status: _currentFilter);

      if (result != null && result['success'] == true) {
        setState(() {
          _reports = result['data'] ?? [];
          _stats = (_currentFilter == 'pending') ? result['meta'] ?? {} : result['stats'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _reports = [];
          _isLoading = false;
        });
        print("Erreur fetchReports: $result");
      }
    } catch (e) {
      setState(() {
        _reports = [];
        _isLoading = false;
      });
      print("Erreur lors du chargement: $e");
    }
  }

  Future<void> _openPdf(dynamic report) async {
    if (report["id"] == null) {
      _showSnackBar("ID du rapport non disponible", Colors.red);
      return;
    }

    try {
      _showSnackBar("Chargement du PDF...", Colors.blue);

      final pdfBytes = await ApiServicePfe.downloadAdminPdf(report["id"]);

      if (pdfBytes == null) {
        _showSnackBar("Erreur lors du chargement du PDF", Colors.red);
        return;
      }

      final dir = await getTemporaryDirectory();
      final fileName = "${report["author_name"] ?? "document"} - ${report["title"] ?? "pdf"}.pdf"
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      await OpenFile.open(file.path);
      _showSnackBar("PDF ouvert", Colors.green);
    } catch (e) {
      print("Erreur ouverture PDF: $e");
      _showSnackBar("Erreur lors de l'ouverture: ${e.toString()}", Colors.red);
    }
  }

  void _showActionDialog(int reportId, String currentStatus) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Action sur le rapport"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: "Commentaire (optionnel)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (currentStatus != 'accepted')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _acceptReport(reportId, commentController.text.trim());
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Accepter"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  if (currentStatus != 'rejected')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _rejectReport(reportId, commentController.text.trim());
                      },
                      icon: const Icon(Icons.close),
                      label: const Text("Rejeter"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  if (currentStatus == 'accepted')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _cancelAcceptance(reportId, commentController.text.trim());
                      },
                      icon: const Icon(Icons.undo),
                      label: const Text("Annuler acceptation"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  if (currentStatus == 'rejected')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _cancelRejection(reportId, commentController.text.trim());
                      },
                      icon: const Icon(Icons.undo),
                      label: const Text("Annuler rejet"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptReport(int reportId, String comment) async {
    final result = await ApiServicePfe.acceptReport(
      reportId, 
      adminComment: comment.isNotEmpty ? comment : null,
    );
    
    if (result != null) {
      _loadReports();
      _showSnackBar("Rapport accepté avec succès", Colors.green);
    } else {
      _showSnackBar("Erreur lors de l'acceptation", Colors.red);
    }
  }

  Future<void> _rejectReport(int reportId, String comment) async {
    if (comment.isEmpty) {
      _showSnackBar("Un commentaire est requis pour le rejet", Colors.orange);
      return;
    }
    
    final result = await ApiServicePfe.rejectReport(reportId, comment);
    
    if (result != null) {
      _loadReports();
      _showSnackBar("Rapport rejeté", Colors.orange);
    } else {
      _showSnackBar("Erreur lors du rejet", Colors.red);
    }
  }

  Future<void> _cancelAcceptance(int reportId, String comment) async {
    final result = await ApiServicePfe.cancelAcceptance(
      reportId, 
      adminComment: comment.isNotEmpty ? comment : null,
    );
    
    if (result != null) {
      _loadReports();
      _showSnackBar("Acceptation annulée", Colors.orange);
    } else {
      _showSnackBar("Erreur lors de l'annulation", Colors.red);
    }
  }

  Future<void> _cancelRejection(int reportId, String comment) async {
    final result = await ApiServicePfe.cancelRejection(
      reportId, 
      adminComment: comment.isNotEmpty ? comment : null,
    );
    
    if (result != null) {
      _loadReports();
      _showSnackBar("Rejet annulé", Colors.orange);
    } else {
      _showSnackBar("Erreur lors de l'annulation", Colors.red);
    }
  }

  Future<void> _showReportHistory(int reportId) async {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Historique"),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    final history = await ApiServicePfe.getReportHistory(reportId);
    Navigator.pop(context);
    
    if (history != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Historique du rapport"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Statut actuel", history['current_status'] ?? 'N/A'),
                  _buildInfoRow("Traité par", history['processed_by'] ?? 'N/A'),
                  _buildInfoRow("Date de traitement", history['processed_at'] ?? 'N/A'),
                  if (history['admin_comment'] != null)
                    _buildInfoRow("Commentaire", history['admin_comment']),
                  const SizedBox(height: 16),
                  const Text(
                    "Informations du rapport:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (history['report'] != null) ...[
                    _buildInfoRow("Titre", history['report']['title'] ?? 'N/A'),
                    _buildInfoRow("Auteur", history['report']['author_name'] ?? 'N/A'),
                    _buildInfoRow("Type", history['report']['type'] ?? 'N/A'),
                    _buildInfoRow("Année", history['report']['defense_year']?.toString() ?? 'N/A'),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        ),
      );
    } else {
      _showSnackBar("Erreur lors du chargement de l'historique", Colors.red);
    }
  }

  Widget _getStatusIcon(String? status) {
    switch (status) {
      case 'accepted': return const Icon(Icons.check_circle, color: Colors.green);
      case 'rejected': return const Icon(Icons.cancel, color: Colors.red);
      case 'pending': return const Icon(Icons.schedule, color: Colors.orange);
      default: return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des PFE/PFA"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: "En attente",
              icon: Badge(
                isLabelVisible: _stats?['pending'] != null && _stats!['pending'] > 0,
                label: Text(_stats?['pending']?.toString() ?? ''),
                child: const Icon(Icons.schedule),
              ),
            ),
            Tab(
              text: "Acceptés", 
              icon: Badge(
                isLabelVisible: _stats?['accepted'] != null && _stats!['accepted'] > 0,
                label: Text(_stats?['accepted']?.toString() ?? ''),
                child: const Icon(Icons.check_circle),
              ),
            ),
            Tab(
              text: "Rejetés",
              icon: Badge(
                isLabelVisible: _stats?['rejected'] != null && _stats!['rejected'] > 0,
                label: Text(_stats?['rejected']?.toString() ?? ''),
                child: const Icon(Icons.cancel),
              ),
            ),
            Tab(
              text: "Tous",
              icon: Badge(
                isLabelVisible: _stats?['total'] != null && _stats!['total'] > 0,
                label: Text(_stats?['total']?.toString() ?? ''),
                child: const Icon(Icons.list),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReports,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "Aucun rapport ${_getFilterText()}",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tirez vers le bas pour actualiser",
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _reports.length,
                    itemBuilder: (context, i) {
                      var report = _reports[i];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(report["status"]),
                            child: Text(
                              report["type"]?.substring(0, 3).toUpperCase() ?? "?",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          title: Text(
                            report["title"] ?? "Titre non disponible",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Auteur: ${report["author_name"] ?? "N/A"}"),
                              Row(
                                children: [
                                  _getStatusIcon(report["status"]),
                                  const SizedBox(width: 4),
                                  Text(
                                    report["status"]?.toUpperCase() ?? "INCONNU",
                                    style: TextStyle(
                                      color: _getStatusColor(report["status"]),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow("Type", report["type"] ?? "N/A"),
                                  _buildInfoRow("Auteur", report["author_name"] ?? "N/A"),
                                  _buildInfoRow("Année", report["defense_year"]?.toString() ?? "N/A"),
                                  _buildInfoRow("Domaine", report["domain"] ?? "N/A"),
                                  _buildInfoRow("Statut", report["status"] ?? "N/A"),
                                  _buildInfoRow("Soumis le", report["submitted_at"] ?? "N/A"),
                                  if (report["user"] != null && report["user"]["name"] != null)
                                    _buildInfoRow("Soumis par", report["user"]["name"]),
                                  if (report["admin_comment"] != null && report["admin_comment"].toString().isNotEmpty)
                                    _buildInfoRow("Commentaire admin", report["admin_comment"]),
                                  const SizedBox(height: 16),
                                  
                                  // Bouton Voir uniquement
                                  ElevatedButton.icon(
                                    onPressed: () => _openPdf(report),
                                    icon: const Icon(Icons.remove_red_eye),
                                    label: const Text("Voir"),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Actions administratives
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _showActionDialog(
                                            report["id"], 
                                            report["status"]
                                          ),
                                          icon: const Icon(Icons.admin_panel_settings),
                                          label: const Text("Actions"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _showReportHistory(report["id"]),
                                          icon: const Icon(Icons.history),
                                          label: const Text("Historique"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _getFilterText() {
    switch (_currentFilter) {
      case 'pending': return 'en attente';
      case 'accepted': return 'accepté';
      case 'rejected': return 'rejeté';
      default: return '';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
