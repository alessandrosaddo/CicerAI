import 'package:cicer_ai/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:cicer_ai/widgets/tappa/tappa_widget.dart';
import 'package:cicer_ai/models/tappa_data.dart';

// ItinerarioPage
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: Column(
          children: [
            const Text(
              "Personalizza il tuo Viaggio",
              style: TextStyle(fontSize: 20),
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
                    canDelete:
                        tappeData.length >
                        1, // Mostra elimina solo se ci sono più tappe
                  ),
                );
              },
            ),

            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: AppColors.lightPrimary,
                  onPressed: _addTappa,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Aggiungi Tappa",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
