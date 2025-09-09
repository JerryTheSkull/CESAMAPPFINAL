import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/quote.dart';
import '../services/api_service_quote.dart';

class AdminQuoteFormPage extends StatefulWidget {
  final Quote? existingQuote;

  const AdminQuoteFormPage({super.key, this.existingQuote});

  @override
  State<AdminQuoteFormPage> createState() => _AdminQuoteFormPageState();
}

class _AdminQuoteFormPageState extends State<AdminQuoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _authorController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.existingQuote?.text ?? '');
    _authorController = TextEditingController(text: widget.existingQuote?.author ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      Quote? quote;
      if (widget.existingQuote != null) {
        quote = await ApiServiceQuote.updateQuoteWithValidation(
          widget.existingQuote!.id!, // Assure-toi que ton modèle Quote contient un champ `id`
          text: _textController.text.trim(),
          author: _authorController.text.trim(),
        );
      } else {
        quote = await ApiServiceQuote.createQuoteWithValidation(
          _textController.text.trim(),
          _authorController.text.trim(),
        );
      }

      if (quote != null && mounted) {
        Navigator.pop(context, quote);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingQuote != null;

    return Scaffold(
      backgroundColor: CesamColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier une citation' : 'Ajouter une citation',
            style: const TextStyle(color: Colors.black)),
        backgroundColor: CesamColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _textController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Texte de la citation',
                  filled: true,
                  fillColor: CesamColors.cardBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Auteur',
                  filled: true,
                  fillColor: CesamColors.cardBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CesamColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? 'Modifier' : 'Ajouter', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
