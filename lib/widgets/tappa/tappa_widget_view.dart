import 'package:flutter/material.dart';
import 'tappa_widget_controller.dart';
import '/themes/colors.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TappaWidgetView extends StatelessWidget {
  final TappaWidgetController controller;
  final int tappaIndex;
  final VoidCallback onDelete;
  final bool showControls;
  final bool canDelete;

  const TappaWidgetView({
    Key? key,
    required this.controller,
    required this.tappaIndex,
    required this.onDelete,
    required this.showControls,
    required this.canDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightWidgetBackground,
            border: Border.all(color: AppColors.lightBorderColor, width: 1.5),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              // Ricerca e GPS
              buildRicercaLuogo(context),

              const SizedBox(height: 25),

                // Inizio tappa
                Row(
                  children: [
                    Expanded(
                      child: buildInserimentoDate(
                        context,
                        controller: controller.dalGiornoController,
                        label: "Data Inizio",
                        onTap: () => controller.selectDate(
                          context,
                          controller.dalGiornoController,
                          isStart: true,
                        ),
                        enabled: true,
                      ),
                    ),

                    const SizedBox(width: 8),
                    Expanded(
                      child: buildInserimentoOrario(
                        context,
                        controller: controller.dalleOreController,
                        label: "Ora Inizio",
                        onTap: () => controller.selectTime(
                          context,
                          controller.dalleOreController,
                          isStart: true,
                        ),
                        enabled: controller.dalGiornoController.text.isNotEmpty,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

              // Fine tappa
                Row(
                  children: [
                    Expanded(
                      child: buildInserimentoDate(
                        context,
                        controller: controller.alGiornoController,
                        label: "Data Fine",
                        onTap: () => controller.selectDate(
                          context,
                          controller.alGiornoController,
                          isStart: false,
                        ),
                        enabled:
                            controller.dalGiornoController.text.isNotEmpty &&
                            controller.dalleOreController.text.isNotEmpty,
                      ),
                    ),

                    const SizedBox(width: 8),
                    Expanded(
                      child: buildInserimentoOrario(
                        context,
                        controller: controller.alleOreController,
                        label: "Ora Fine",
                        onTap: () => controller.selectTime(
                          context,
                          controller.alleOreController,
                          isStart: false,
                        ),
                        enabled: controller.alGiornoController.text.isNotEmpty,
                      ),
                    ),
                  ],
                ),

              // Mostra il pulsante elimina solo se canDelete è true
              if (canDelete) ...[
                const SizedBox(height: 12),
                _buildDeleteButton(),
              ],
            ],
          ),
        ),

        // Mostra il banner solo se showControls è true
        if (showControls)
          Positioned(
            top: -15,
            left: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    "Tappa $tappaIndex",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildRicercaLuogo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightBorderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          GooglePlaceAutoCompleteTextField(
            textEditingController: controller.cittaController,
            googleAPIKey: dotenv.env['GOOGLE_API_KEY'] ?? '',
            inputDecoration: InputDecoration(
              hintText: controller.isLoadingLocation ? "" : "Cerca Città/Rileva Posizione",
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.travel_explore, size: 30),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsante X per cancellare
                  if (controller.cittaController.text.isNotEmpty)
                    IconButton(
                      onPressed: () => controller.clearCity(),
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  // Pulsante GPS
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => controller.useCurrentLocation(context),
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
            debounceTime: 400,
            isLatLngRequired: true,
            language: "it",
            isCrossBtnShown: false,

            // Autocompletamento
            itemBuilder: (context, index, prediction) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  leading: const Icon(
                    Icons.location_on,
                    color: AppColors.lightPrimary,
                  ),
                  title: Text(
                    prediction.description ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    prediction.structuredFormatting?.secondaryText ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
            seperatedBuilder: Padding(
              padding: EdgeInsets.zero,
              child: Divider(
                height: 0.5,
                thickness: 0.2,
                color: AppColors.lightBorderColor,
              ),
            ),
            itemClick: (Prediction prediction) {
              FocusScope.of(context).unfocus();
              Future.delayed(const Duration(milliseconds: 100), () {
                controller.updateCity(prediction.description ?? "");
              });
            },
            getPlaceDetailWithLatLng: (Prediction prediction) {
              debugPrint("Lat: ${prediction.lat}, Lng: ${prediction.lng}");
            },
          ),
          // Loading indicator al posto del hint text
          if (controller.isLoadingLocation &&
              controller.cittaController.text.isEmpty)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(left: 60.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5,color: AppColors.lightPrimary,),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Rilevamento posizione...",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildInserimentoDate(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_month),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorderColor),
        ),
      ),
    );
  }

  Widget buildInserimentoOrario(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.access_time),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorderColor),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton.icon(
      onPressed: onDelete,
      icon: const Icon(Icons.delete),
      label: const Text("Elimina Tappa"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightText,
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
