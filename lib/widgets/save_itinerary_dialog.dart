import 'package:flutter/material.dart';
import 'package:cicer_ai/themes/colors.dart';
import 'package:cicer_ai/services/database_service.dart';
import 'package:cicer_ai/models/saved_itinerary.dart';
import 'package:cicer_ai/models/itinerary/itinerary_response.dart';

class SaveItineraryDialog extends StatefulWidget {
  final ItineraryResponse itinerary;

  const SaveItineraryDialog({
    super.key,
    required this.itinerary,
  });

  @override
  State<SaveItineraryDialog> createState() => _SaveItineraryDialogState();
}

class _SaveItineraryDialogState extends State<SaveItineraryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final DatabaseService _db = DatabaseService();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }


  Future<void> _saveItinerary() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Inserisci un nome per l\'itinerario');
      return;
    }
    if (name.length < 3) {
      setState(() => _errorMessage = 'Il nome deve essere di almeno 3 caratteri');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final exists = await _db.existsWithName(name);

      if (exists) {
        if (!mounted) return;

        // Chiedi conferma esplicita
        final shouldOverwrite = await _showOverwriteDialog(name);
        if (shouldOverwrite != true) {
          setState(() => _isSaving = false);
          return;
        }

        final existingItineraries = await _db.getAllItineraries();
        final existing = existingItineraries.firstWhere(
              (it) => it.name.toLowerCase() == name.toLowerCase(),
        );
        await _db.deleteItinerary(existing.id!);
      }

      // Crea il SavedItinerary
      final savedItinerary = SavedItinerary.fromItineraryResponse(
        name,
        widget.itinerary,
      );

      // Salva nel database
      final id = await _db.saveItinerary(savedItinerary);

      if (mounted) {
        Navigator.of(context).pop(true); // Successo

        // Mostra conferma
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.acceptColor(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Itinerario "$name" salvato con successo',style: TextStyle(color: AppColors.text(context)),),
                ),
              ],
            ),
            backgroundColor: AppColors.hintText(context),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Errore durante il salvataggio: ${e.toString()}';
        _isSaving = false;
      });
    }
  }

  // Dialog per sovrascrivere un itinerario esistente
  Future<bool?> _showOverwriteDialog(String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warningColor(context)),
            const SizedBox(width: 8),
            const Text('Nome già esistente'),
          ],
        ),
        content: Text(
          'Esiste già un itinerario con il nome "$name".\nVuoi sostituirlo?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppColors.hintText(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Sostituisci',
              style: TextStyle(
                color: AppColors.deleteColorText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.save_alt, color: AppColors.primary(context),size: 30),
          const SizedBox(width: 8),
          const Text('Salva Itinerario'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dai un nome al tuo viaggio per ritrovarlo facilmente!',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          // TextField per il nome
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: 50,
            decoration: InputDecoration(
              labelText: 'Nome Itinerario',
              prefixIcon: Icon(Icons.edit, color: AppColors.icon(context)),
              errorText: _errorMessage,
              counterText: '',
            ),
            onSubmitted: (_) => _saveItinerary(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Annulla',
            style: TextStyle(color: AppColors.hintText(context)),
          ),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveItinerary,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context),
            foregroundColor: AppColors.secondary(context),
          ),
          child: _isSaving
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.secondary(context),
            ),
          )
              : const Text('Salva'),
        ),
      ],
    );
  }
}