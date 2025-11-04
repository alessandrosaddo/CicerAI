import 'package:cicer_ai/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:cicer_ai/widgets/tappa/tappa_widget.dart';
import 'package:cicer_ai/models/tappa_data.dart';
import 'package:cicer_ai/services/gemini_service.dart';
import 'package:cicer_ai/models/itinerary/itinerary_response.dart';

class HomeScreen extends StatefulWidget {
  final Function(ItineraryResponse?, bool, String?)? onItineraryGenerated;

  const HomeScreen({
    super.key,
    this.onItineraryGenerated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TappaData> tappeData = [TappaData()];
  final GeminiService _geminiService = GeminiService();
  bool _isGenerating = false;



  void _addTappa() {
    if (!_isLastTappaComplete()) {
      return;
    }
    setState(() => tappeData.add(TappaData()));
  }

  void _removeTappa(int index) {
    if (tappeData.length > 1) {
      setState(() => tappeData.removeAt(index));
    }
  }

  void _updateTappa(String id, TappaData updatedData) {
    setState(() {
      final index = tappeData.indexWhere((t) => t.id == id);
      if (index != -1) {
        final oldData = tappeData[index];
        tappeData[index] = updatedData;


        if (_hasRelevantChanges(oldData, updatedData)) {
          _resetSubsequentTappeFrom(index);
        }
      }
    });
  }




  // Reset
  bool _hasRelevantChanges(TappaData oldData, TappaData newData) {
    return oldData.dataInizio != newData.dataInizio ||
        oldData.dataFine != newData.dataFine ||
        oldData.oraInizio != newData.oraInizio ||
        oldData.oraFine != newData.oraFine ||
        oldData.citta != newData.citta ||
        oldData.coordinate != newData.coordinate;
  }

  void _resetSubsequentTappeFrom(int fromIndex) {
    for (int i = fromIndex + 1; i < tappeData.length; i++) {
      tappeData[i] = TappaData();
    }

    if (fromIndex + 1 < tappeData.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber,color: AppColors.warningColor(context)),
              SizedBox(width: 8),
              Text('Reinserisci i dati per le tappe successive.'),
            ],
          ),
          backgroundColor: AppColors.text(context),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }



  // Helper
  bool _isTappaComplete(TappaData tappa) {
    return tappa.citta.trim().isNotEmpty &&
        tappa.dataInizio != null &&
        tappa.dataFine != null &&
        tappa.oraInizio.trim().isNotEmpty &&
        tappa.oraFine.trim().isNotEmpty &&
        tappa.coordinate != null;
  }


  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }





  // Validation
  bool _isLastTappaComplete() {
    if (tappeData.isEmpty) return false;
    return _isTappaComplete(tappeData.last);
  }


  bool _areAllTappeComplete() {
    if (tappeData.isEmpty) return false;
    return tappeData.every(_isTappaComplete);
  }


  DateTime? _getMinDateForTappa(int index) {
    if (index == 0) return null;

    final previousTappa = tappeData[index - 1];
    return previousTappa.dataFine;
  }

  String? _getMinTimeForTappa(int index, DateTime? selectedDate) {
    if (index == 0 || selectedDate == null) return null;

    final previousTappa = tappeData[index - 1];
    if (previousTappa.dataFine == null) return null;

    final isSameDay = _isSameDate(selectedDate, previousTappa.dataFine!);
    return isSameDay ? previousTappa.oraFine : null;
  }






  Future<void> _generateItinerary() async {
    if (!_areAllTappeComplete()) return;

    setState(() => _isGenerating = true);
    widget.onItineraryGenerated?.call(null, true, null);

    try {
      final itinerario = await _geminiService.generateItinerary(tappeData);
      widget.onItineraryGenerated?.call(itinerario, false, null);
    } catch (e) {
      widget.onItineraryGenerated?.call(null, false, e.toString());

    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final bool canAddTappa = _isLastTappaComplete() && !_isGenerating;
    final bool isGenerateEnabled = _areAllTappeComplete() && !_isGenerating;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: Column(
          children: [
            Text(
              "Personalizza il tuo Viaggio",
              style: TextStyle(
                fontSize: 20,
                color: AppColors.text(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tappeData.length,
              itemBuilder: (context, index) {
                final tappa = tappeData[index];
                return Padding(
                  key: ValueKey(tappa.id),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TappaWidget(
                    tappaData: tappa,
                    tappaIndex: index + 1,
                    onDelete: () => _removeTappa(index),
                    onUpdate: _updateTappa,
                    showControls: tappeData.length > 1,
                    canDelete: tappeData.length > 1,

                    minDate: _getMinDateForTappa(index),
                    getMinTime: (selectedDate) => _getMinTimeForTappa(index, selectedDate),
                  ),
                );
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: canAddTappa
                      ? 'Aggiungi una nuova tappa'
                      : 'Completa la tappa precedente',
                  child: ElevatedButton.icon(
                    onPressed: canAddTappa ? _addTappa : null,
                    icon: Icon(
                      Icons.add_location_alt,
                      color: canAddTappa
                          ? AppColors.primary(context)
                          : AppColors.disabledText(context),
                    ),
                    label: Text(
                      "Aggiungi Tappa",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: canAddTappa
                            ? AppColors.primary(context)
                            : AppColors.disabledText(context),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary(context),
                      side: BorderSide(
                        color: canAddTappa
                            ? AppColors.primary(context)
                            : AppColors.disabledText(context),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  onPressed: isGenerateEnabled ? _generateItinerary : null,
                  icon: _isGenerating
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.secondary(context),
                    ),
                  )
                      : Icon(
                    Icons.route,
                    color: isGenerateEnabled
                        ? AppColors.secondary(context)
                        : AppColors.disabledText(context),
                  ),
                  label: Text(
                    _isGenerating ? "Generazione..." : "Genera Itinerario",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: isGenerateEnabled
                          ? AppColors.secondary(context)
                          : AppColors.disabledText(context),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}