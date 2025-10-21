import 'package:cicer_ai/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:cicer_ai/widgets/tappa/tappa_widget.dart';
import 'package:cicer_ai/models/tappa_data.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToItinerary;
  const HomeScreen({super.key, this.onNavigateToItinerary});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TappaData> tappeData = [TappaData()];

  void _addTappa() => setState(() => tappeData.add(TappaData()));

  void _removeTappa(int index) {
    if (tappeData.length > 1) {
      setState(() => tappeData.removeAt(index));
    }
  }

  void _updateTappa(String id, TappaData updatedData) {
    setState(() {
      final index = tappeData.indexWhere((t) => t.id == id);
      if (index != -1) {
        tappeData[index] = updatedData;
      }
    });
  }

  bool _areAllTappeComplete() {
    for (final tappa in tappeData) {
      if (tappa.citta.trim().isEmpty ||
          tappa.dataInizio == null ||
          tappa.dataFine == null ||
          tappa.oraInizio.trim().isEmpty ||
          tappa.oraFine.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  void _navigateToItinerary() {
    if (widget.onNavigateToItinerary != null) {
      widget.onNavigateToItinerary!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGenerateEnabled = _areAllTappeComplete();

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
                  ),
                );
              },
            ),



            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _addTappa,
                  icon: Icon(Icons.add_location_alt, color: AppColors.primary(context)),
                  label: Text(
                    "Aggiungi Tappa",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary(context),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary(context),
                    side: BorderSide(
                      color: AppColors.primary(context),
                    )
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  onPressed: isGenerateEnabled ? _navigateToItinerary : null,
                  icon: Icon(
                    Icons.route,
                    color: isGenerateEnabled
                      ? AppColors.secondary(context)
                      : AppColors.disabledText(context),
                  ),
                  label: Text(
                    "Genera Itinerario",
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
