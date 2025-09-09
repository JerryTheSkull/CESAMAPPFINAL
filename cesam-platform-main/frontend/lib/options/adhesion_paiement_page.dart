import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AdhesionPaiementPage extends StatefulWidget {
  const AdhesionPaiementPage({super.key});

  @override
  _AdhesionPaiementPageState createState() => _AdhesionPaiementPageState();
}

class _AdhesionPaiementPageState extends State<AdhesionPaiementPage> {
  String _selectedCommunity = 'Sénégal';
  String _paymentMethod = 'Carte bancaire';

  final List<String> _communities = [
    'Algérie', 'Angola', 'Bénin', 'Botswana', 'Burkina Faso',
    'Burundi', 'Cameroun', 'Cap-Vert', 'Centrafrique', 'Comores',
    'Congo-Brazzaville', 'Congo-Kinshasa', 'Côte d\'Ivoire', 'Djibouti',
    'Égypte', 'Érythrée', 'Éthiopie', 'Eswatini', 'Gabon', 'Gambie',
    'Ghana', 'Guinée', 'Guinée-Bissau', 'Guinée équatoriale', 'Kenya',
    'Lesotho', 'Libéria', 'Libye', 'Madagascar', 'Malawi', 'Mali',
    'Maroc', 'Maurice', 'Mauritanie', 'Mozambique', 'Namibie', 'Niger',
    'Nigéria', 'Rwanda', 'Sao Tomé-et-Principe', 'Sénégal', 'Seychelles',
    'Sierra Leone', 'Somalie', 'Soudan', 'Soudan du Sud', 'Tanzanie',
    'Tchad', 'Togo', 'Tunisie', 'Ouganda', 'Zambie', 'Zimbabwe'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adhésion & Paiement',style: TextStyle(color: CesamColors.textPrimary)),
        backgroundColor: CesamColors.background,
        
      ),
      backgroundColor: CesamColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Statut d’adhésion'),
            _buildStatusCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Sélection d\'une communauté'),
            _buildAssociationDropdown(),
            const SizedBox(height: 20),
            _buildSectionTitle('Montant à payer'),
            _buildAmountCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Moyen de paiement'),
            _buildPaymentMethodSelector(),
            const SizedBox(height: 24),
            Center(child: _buildPayButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: CesamColors.textPrimary,
        ),
      );

  Widget _buildStatusCard() => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: CesamColors.cardBackground,
        child: ListTile(
          leading: const Icon(Icons.verified_user, color: CesamColors.primary),
          title: const Text(
            'Adhésion active',
            style: TextStyle(color: CesamColors.textPrimary),
          ),
          subtitle: Text('Membre de la Communauté $_selectedCommunity'),
          trailing: TextButton(
            onPressed: () {
              // action future
            },
            style: TextButton.styleFrom(foregroundColor: CesamColors.primary),
            child: const Text('Modifier'),
          ),
        ),
      );

  Widget _buildAssociationDropdown() => DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: CesamColors.cardBackground,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: _selectedCommunity,
        items: _communities
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _selectedCommunity = value);
        },
      );

  Widget _buildAmountCard() => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: CesamColors.cardBackground,
        child: const ListTile(
          leading: Icon(Icons.attach_money, color: CesamColors.primary),
          title: Text('Montant : 100 MAD'),
          subtitle: Text('Adhésion annuelle'),
        ),
      );

  Widget _buildPaymentMethodSelector() => Column(
        children: ['Carte bancaire', 'Mobile Money', 'Virement'].map((method) {
          IconData icon = method == 'Carte bancaire'
              ? Icons.credit_card
              : method == 'Mobile Money'
                  ? Icons.phone_android
                  : Icons.account_balance;
          return RadioListTile<String>(
            value: method,
            groupValue: _paymentMethod,
            activeColor: CesamColors.primary,
            onChanged: (value) {
              if (value != null) setState(() => _paymentMethod = value);
            },
            title: Text(method),
            secondary: Icon(icon, color: CesamColors.primary),
          );
        }).toList(),
      );

  Widget _buildPayButton() => ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: CesamColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: Colors.white,
          iconColor: Colors.white,
        ),
        onPressed: () {
          // TODO: envoyer _selectedCommunity & _paymentMethod au backend
        },
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text('Payer maintenant', style: TextStyle(fontSize: 16)),
      );
}
