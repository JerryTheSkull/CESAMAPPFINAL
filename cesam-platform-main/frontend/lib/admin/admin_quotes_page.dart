import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/quote.dart';
import '../services/api_service_quote.dart';
import 'admin_quote_form_page.dart';

class AdminQuotesPage extends StatefulWidget {
  const AdminQuotesPage({super.key});

  @override
  State<AdminQuotesPage> createState() => _AdminQuotesPageState();
}

class _AdminQuotesPageState extends State<AdminQuotesPage> {
  List<Quote> _quotes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
  }

  Future<void> _fetchQuotes() async {
    setState(() => _loading = true);
    try {
      final data = await ApiServiceQuote.getQuotes();
      if (data != null) {
        final List published = data['published'] ?? [];
        final List unpublished = data['unpublished'] ?? [];
        _quotes = [
          ...unpublished.map((e) => Quote.fromJson(e)),
          ...published.map((e) => Quote.fromJson(e)),
        ];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openQuoteForm({Quote? quote}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminQuoteFormPage(existingQuote: quote),
      ),
    );

    if (result != null && result is Quote) {
      await _fetchQuotes();
    }
  }

  Future<void> _publishQuote(Quote quote) async {
    try {
      await ApiServiceQuote.publishQuote(quote.id!);
      await _fetchQuotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  Future<void> _deleteQuote(Quote quote) async {
    try {
      await ApiServiceQuote.deleteQuote(quote.id!);
      await _fetchQuotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  Widget _buildQuoteCard(Quote quote) {
    return Card(
      color: CesamColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text('"${quote.text}"', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('- ${quote.author} • par ${quote.submittedBy}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!quote.isPublished)
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: "Publier",
                onPressed: () => _publishQuote(quote),
              ),
            IconButton(
              icon: const Icon(Icons.edit, color: CesamColors.primary),
              onPressed: () => _openQuoteForm(quote: quote),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deleteQuote(quote),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        title: const Text('Gestion des citations', style: TextStyle(color: Colors.black)),
        backgroundColor: CesamColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _quotes.map((q) => _buildQuoteCard(q)).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CesamColors.primary,
        onPressed: () => _openQuoteForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
