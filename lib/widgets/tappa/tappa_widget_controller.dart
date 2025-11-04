import 'package:flutter/material.dart';
import 'package:cicer_ai/models/tappa_data.dart';
import 'package:cicer_ai/services/location_service.dart';
import 'package:cicer_ai/models/itinerary/coordinate.dart';

class TappaWidgetController {
  final TappaData tappaData;
  final void Function(VoidCallback fn) setState;
  final Function(TappaData) onUpdate;

  final TextEditingController _cittaController = TextEditingController();
  final TextEditingController _dalGiornoController = TextEditingController();
  final TextEditingController _alGiornoController = TextEditingController();
  final TextEditingController _dalleOreController = TextEditingController();
  final TextEditingController _alleOreController = TextEditingController();

  DateTime? _dataInizio;
  DateTime? _dataFine;
  bool _isLoadingLocation = false;

  Coordinate? _coordinate;

  TappaWidgetController(this.tappaData, this.setState, this.onUpdate) {
    _cittaController.text = tappaData.citta;
    if (tappaData.dataInizio != null) {
      _dalGiornoController.text = _formatDate(tappaData.dataInizio!);
      _dataInizio = tappaData.dataInizio;
    }
    if (tappaData.dataFine != null) {
      _alGiornoController.text = _formatDate(tappaData.dataFine!);
      _dataFine = tappaData.dataFine;
    }
    _dalleOreController.text = tappaData.oraInizio;
    _alleOreController.text = tappaData.oraFine;

    // Inizializza coordinate se presenti
    _coordinate = tappaData.coordinate;

    // Aggiorna la UI quando il testo cambia
    _cittaController.addListener(_onCityChanged);
  }

  void _notifyUpdate() {
    onUpdate(toModel());
  }

  void _onCityChanged() {
    setState(() {});
    _notifyUpdate();
  }

  // Getter pubblici per il controller
  TextEditingController get cittaController => _cittaController;
  TextEditingController get dalGiornoController => _dalGiornoController;
  TextEditingController get alGiornoController => _alGiornoController;
  TextEditingController get dalleOreController => _dalleOreController;
  TextEditingController get alleOreController => _alleOreController;

  bool get isLoadingLocation => _isLoadingLocation;

  void updateCity(String city) {
    _cittaController.text = city;
    _cittaController.selection = TextSelection.fromPosition(
      TextPosition(offset: city.length),
    );
    setState(() {});
    _notifyUpdate();
  }

  void updateCoordinates(double? lat, double? lng) {
    if (lat != null && lng != null) {
      _coordinate = Coordinate(lat: lat, lng: lng);
    } else {
      _coordinate = null;
    }
    _notifyUpdate();
  }

  void clearCity() {
    _cittaController.clear();
    _coordinate = null;
    setState(() {});
    _notifyUpdate();
  }

  Future<void> useCurrentLocation(BuildContext context) async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await LocationService.getCurrentCity(context: context);

      if (locationData != null) {
        updateCity(locationData.city);

        updateCoordinates(locationData.lat, locationData.lng);

        debugPrint('✅ Posizione rilevata: ${locationData.city} (${locationData.lat}, ${locationData.lng})');
      } else {
        debugPrint('⚠️ Nessuna posizione rilevata');
      }
    } catch (e) {
      debugPrint('❌ Errore rilevamento posizione: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  String _formatDate(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

  Future<void> selectDate(
    BuildContext context,
    TextEditingController controller, {
    bool isStart = true, // Indica se è la data di inizio o di fine
  }) async {
    final DateTime today = DateTime.now();
    final DateTime initialDate = isStart ? today : _dataInizio!;
    final firstDate = initialDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _dataInizio = picked;

          // resetta TUTTO quello che dipende dall'inizio
          _dalleOreController.clear();
          _alGiornoController.clear();
          _alleOreController.clear();
        } else {
          _dataFine = picked;
          _alleOreController.clear();
        }

        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
      _notifyUpdate();
    }
  }

  Future<void> selectTime(
    BuildContext context,
    TextEditingController controller, {
    bool isStart = true,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (picked == null) return;

    final int pickedMinutes = picked.hour * 60 + picked.minute;

    // Se dataInizio e dataFine sono stati compilati controlla l'orario
    if (!isStart && _dataInizio != null && _dataFine != null) {
      final bool sameDay =
          _dataInizio!.year == _dataFine!.year &&
          _dataInizio!.month == _dataFine!.month &&
          _dataInizio!.day == _dataFine!.day;

      if (sameDay) {
        final inizioParts = _dalleOreController.text.split(":");
        final startMinutes =
            int.parse(inizioParts[0]) * 60 + int.parse(inizioParts[1]);

        if (pickedMinutes - startMinutes < 60) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Orario non valido"),
              content: const Text(
                "Inserisci almeno un'ora di differenza dall'orario inziale",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
          return;
        }
      }
    }

    setState(() {
      controller.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

      if (isStart) {
        // se cambia Ora Inizio → resetta Data Fine e Ora Fine
        _alGiornoController.clear();
        _alleOreController.clear();
        _dataFine = null;
      }
    });
    _notifyUpdate();
  }

  TappaData toModel() {
    return tappaData.copyWith(
      citta: _cittaController.text,
      dataInizio: _dataInizio,
      dataFine: _dataFine,
      oraInizio: _dalleOreController.text,
      oraFine: _alleOreController.text,
      coordinate: _coordinate,
    );
  }

  void dispose() {
    _cittaController.removeListener(_onCityChanged);
    _cittaController.dispose();
    _dalGiornoController.dispose();
    _alGiornoController.dispose();
    _dalleOreController.dispose();
    _alleOreController.dispose();
  }
}
