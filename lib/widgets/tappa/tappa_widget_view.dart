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
            color: AppColors.widgetBackground(context),
            border: Border.all(color: AppColors.border(context), width: 1.5),
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
                        enabled: controller.cittaController.text.isNotEmpty,
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
                _buildDeleteButton(context),
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
                color: AppColors.primary(context),
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
        border: Border.all(color: AppColors.border(context), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          GooglePlaceAutoCompleteTextField(
            textEditingController: controller.cittaController,
            googleAPIKey: dotenv.env['GOOGLE_API_KEY'] ?? '',
            inputDecoration: InputDecoration(
              hintText: controller.isLoadingLocation ? "" : "Cerca Città/Rileva Posizione",
              hintStyle: TextStyle(color: AppColors.hintText(context)),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.travel_explore,
                size: 30,
                color: AppColors.icon(context),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // X per cancellare
                  if (controller.cittaController.text.isNotEmpty)
                    IconButton(
                      onPressed: () => controller.clearCity(),
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.hintText(context),
                        size: 24,
                      ),
                    ),
                  // Pulsante GPS
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
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
                  leading: Icon(
                    Icons.location_on,
                    color: AppColors.primary(context),
                  ),
                  title: Text(
                    prediction.description ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
                    ),
                  ),
                  subtitle: Text(
                    prediction.structuredFormatting?.secondaryText ?? "",
                    style: TextStyle(color: AppColors.hintText(context)),
                  ),
                ),
              );
            },
            seperatedBuilder: Padding(
              padding: EdgeInsets.zero,
              child: Divider(
                height: 0.5,
                thickness: 0.2,
                color: AppColors.divider(context),
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
                        child: CircularProgressIndicator(strokeWidth: 2.5,color: AppColors.primary(context),),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Rilevamento posizione...",
                        style: TextStyle(color:  AppColors.hintText(context), fontSize: 16),
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
        labelStyle: TextStyle(
          color: enabled
              ? AppColors.text(context)
              : AppColors.disabledText(context),
        ),
        prefixIcon: Icon(
          Icons.calendar_month,
          color: enabled
              ? AppColors.icon(context)
              : AppColors.disabledText(context),
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
        labelStyle: TextStyle(
          color: enabled
              ? AppColors.text(context)
              : AppColors.disabledText(context),
        ),
        prefixIcon: Icon(
          Icons.access_time,
          color: enabled
              ? AppColors.icon(context)
              : AppColors.disabledText(context),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onDelete,
      icon: const Icon(Icons.delete),
      label: const Text("Elimina Tappa"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.delete(context),
        foregroundColor: AppColors.deleteColorText(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
