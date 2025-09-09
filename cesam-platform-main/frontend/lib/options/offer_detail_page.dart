import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../services/api_service_stage.dart';

class OfferDetailPage extends StatefulWidget {
  final Offer offer;
  final VoidCallback? onApplicationChanged;

  const OfferDetailPage({
    super.key,
    required this.offer,
    this.onApplicationChanged,
  });

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage> {
  late Offer _offer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _offer = widget.offer;
    _loadOfferDetails();
  }

  Future<void> _loadOfferDetails() async {
    setState(() => _isLoading = true);
    
    try {
      final offer = await ApiServiceStage.getOffer(_offer.id!);
      setState(() => _offer = offer);
    } catch (e) {
      _showMessage('Erreur lors du chargement', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _applyToOffer() async {
    try {
      final result = await ApiServiceStage.applyToOffer(_offer.id!);
      
      if (result['success']) {
        _showMessage('Candidature envoyée avec succès !');
        await _loadOfferDetails();
        widget.onApplicationChanged?.call();
      } else {
        _showMessage(result['message'], isError: true);
      }
    } catch (e) {
      _showMessage('Erreur lors de l\'envoi', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        title: Text(_offer.title),
        backgroundColor: CesamColors.background,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  if (_offer.description != null) ...[
                    _buildSection('Description', _offer.description!),
                    const SizedBox(height: 20),
                  ],
                  if (_offer.images != null && _offer.images!.isNotEmpty) ...[
                    _buildImagesSection(),
                    const SizedBox(height: 20),
                  ],
                  if (_offer.pdfs != null && _offer.pdfs!.isNotEmpty) ...[
                    _buildPdfsSection(),
                    const SizedBox(height: 20),
                  ],
                  if (_offer.links != null && _offer.links!.isNotEmpty) ...[
                    _buildLinksSection(),
                    const SizedBox(height: 20),
                  ],
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
      floatingActionButton: _offer.userHasApplied == true
          ? FloatingActionButton.extended(
              onPressed: null,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.check),
              label: const Text('Déjà postulé'),
            )
          : FloatingActionButton.extended(
              onPressed: _applyToOffer,
              backgroundColor: CesamColors.primary,
              icon: const Icon(Icons.send),
              label: const Text('Postuler'),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _offer.type == 'stage' ? Colors.orange : Colors.blue,
            child: Icon(
              _offer.type == 'stage' ? Icons.school : Icons.work,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _offer.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _offer.type == 'stage' ? Colors.orange : Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _offer.type == 'stage' ? 'Stage' : 'Emploi',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_offer.userHasApplied == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Vous avez déjà postulé',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CesamColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CesamColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _offer.images!.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _offer.images![index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documents PDF',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CesamColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...(_offer.pdfs!.map((pdf) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(pdf.split('/').last),
              trailing: const Icon(Icons.download),
              onTap: () => _openUrl(pdf),
              tileColor: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ))).toList(),
        ],
      ),
    );
  }

  Widget _buildLinksSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liens utiles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CesamColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...(_offer.links!.map((link) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.link, color: Colors.blue),
              title: Text(
                link,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openUrl(link),
              tileColor: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ))).toList(),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showMessage('Impossible d\'ouvrir le lien', isError: true);
      }
    } catch (e) {
      _showMessage('Erreur lors de l\'ouverture', isError: true);
    }
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