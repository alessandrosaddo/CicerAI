import 'package:flutter/material.dart';
import 'package:cicer_ai/models/itinerary/posto_visitabile.dart';
import 'package:cicer_ai/themes/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetail extends StatelessWidget {
  final PostoVisitabile posto;
  final String cityName;
  final String date;
  final Widget imageWidget;
  final Function(LatLng, String)? onOpenInMaps;


  const PlaceDetail({
    super.key,
    required this.posto,
    required this.cityName,
    required this.date,
    required this.imageWidget,
    this.onOpenInMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.hintText(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Contenuto scrollabile
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Immagine
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: imageWidget,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nome del posto
                  Text(
                    posto.nome,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Info città e data
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primary(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$cityName - $date',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.hintText(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),


                  // Descrizione completa
                  Text(
                    'Descrizione',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    posto.descrizione,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.text(context),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Orario
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: AppColors.primary(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${posto.orarioInizio} - ${posto.orarioFine}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_formatDuration(posto.durataInMinuti)})',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.hintText(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (posto.coordinate != null)
                    _buildGoogleMapsButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGoogleMapsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final position = LatLng(posto.coordinate!.lat, posto.coordinate!.lng,);
          onOpenInMaps?.call(position, posto.nome);
        },
        icon: const Icon(Icons.mobile_screen_share_outlined, size: 28),
        label: const Text(
          'Apri in Google Maps',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary(context),
          foregroundColor: AppColors.secondary(context),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: StadiumBorder(),
        ),
      ),
    );
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return 'N/A';

    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (mins == 0) {
      return '${hours}h';
    }

    return '${hours}h ${mins}min';
  }
}