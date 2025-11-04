import 'package:flutter/material.dart';
import 'package:cicer_ai/models/itinerary/itinerary_response.dart';
import 'package:cicer_ai/themes/colors.dart';
import 'package:cicer_ai/widgets/place_detail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ItineraryList extends StatelessWidget {
  final ItineraryResponse itinerary;
  final Function(LatLng, String)? onOpenInMaps;

  const ItineraryList({
    super.key,
    required this.itinerary,
    this.onOpenInMaps,
  });


  void _openPlaceDetails(
      BuildContext context,
      posto,
      String cityName,
      String date,
      Widget imageWidget,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PlaceDetail(
        posto: posto,
        cityName: cityName,
        date: date,
        imageWidget: imageWidget,
        onOpenInMaps: onOpenInMaps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: itinerary.itinerario.length,
      itemBuilder: (context, cityIndex) {
        final city = itinerary.itinerario[cityIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lista città (verticale)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_city,
                    color: AppColors.primary(context),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    city.citta,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
                    ),
                  ),
                ],
              ),
            ),

            // Lista giorni (orizzontale)
            ...city.giornate.map((giornata) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data della giornata
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      giornata.dataFormattata,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.hintText(context),
                      ),
                    ),
                  ),

                  // Card
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: giornata.posti.length,
                      itemBuilder: (context, postoIndex) {
                        final posto = giornata.posti[postoIndex];

                        final imageWidget = ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: _buildPlaceImage(posto),
                        );

                        return Container(
                          width: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 4),

                          child: InkWell(
                            onTap: () => _openPlaceDetails(
                              context,
                              posto,
                              city.citta,
                              giornata.dataFormattata,
                              imageWidget,
                            ),
                            borderRadius: BorderRadius.circular(16),

                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: AppColors.secondary(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  imageWidget,


                                  // Contenuto Posto
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Nome
                                          Text(
                                            posto.nome,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.text(context),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 2),

                                          // Orario
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: AppColors.primary(context),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${posto.orarioInizio} - ${posto.orarioFine}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.hintText(context),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 6),

                                          // Descrizione
                                          Text(
                                            posto.descrizione,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.text(context),
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              );
            }),

            // Divisore tra città
            if (cityIndex < itinerary.itinerario.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Divider(
                  color: AppColors.hintText(context),
                  thickness: 0.5,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceImage(dynamic posto) {
    if (posto.isPausa) {
      return Image.asset(
        'images/pausa.jpg',
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return _buildPlaceholderImage();
        },
      );
    } else if (posto.hasImage) {
      return Image.network(
        posto.urlImmagine!,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  // Immagine non disponibile
  Widget _buildPlaceholderImage() {
    return Container(
      height: 140,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}