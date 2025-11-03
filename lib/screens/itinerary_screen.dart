import 'package:flutter/material.dart';
import 'package:cicer_ai/models/itinerary/itinerary_response.dart';
import 'package:cicer_ai/widgets/map/itinerary_map_view.dart';
import 'package:cicer_ai/widgets/map/itinerary_map_controller.dart';
import 'package:cicer_ai/widgets/map/itinerary_map.dart';
import 'package:cicer_ai/themes/colors.dart';
import 'package:cicer_ai/services/wikipedia_service.dart';
import 'package:cicer_ai/widgets/itinerary_list.dart';

class ItineraryScreen extends StatefulWidget {
  final ItineraryResponse? itinerario;
  final bool isLoading;
  final String? errorMessage;

  const ItineraryScreen({
    Key? key,
    this.itinerario,
    this.isLoading = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  ItineraryMapModel? _mapModel;
  ItineraryMapController? _mapController;

  final WikipediaService _wikipediaService = WikipediaService();

  bool _isLoadingImages = false;
  bool _isInitializingMarkers = false;

  @override
  void initState() {
    super.initState();
    _initializeItinerary();
  }

  @override
  void didUpdateWidget(ItineraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-inizializza solo se l'itinerario è cambiato
    if (widget.itinerario != oldWidget.itinerario) {
      _initializeItinerary();
    }
  }

  Future<void> _initializeItinerary() async {
    if (widget.itinerario == null || widget.itinerario!.itinerario.isEmpty) {
      return;
    }

    debugPrint('🚀 Inizializzazione itinerario...');

    await _loadWikipediaImages();
    _createMapComponents();
    await _initializeMarkers();

    debugPrint('✅ Itinerario completamente inizializzato');
  }


  Future<void> _loadWikipediaImages() async {
    if (widget.itinerario == null || widget.itinerario!.itinerario.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingImages = true;
    });

    try {
      final postiConWikipedia = <String, String>{};
      final cityNamesMap = <String, String>{};

      // Raccogli tutti i posti con dati Wikipedia
      for (final citta in widget.itinerario!.itinerario) {
        for (final giornata in citta.giornate) {
          for (final posto in giornata.posti) {
            if (posto.hasWikipediaData) {
              postiConWikipedia[posto.nome] = posto.wikipediaTitle!;
              cityNamesMap[posto.wikipediaTitle!] = citta.citta;
            }
          }
        }
      }

      if (postiConWikipedia.isEmpty) {
        setState(() {
          _isLoadingImages = false;
        });
        return;
      }

      debugPrint('📡 Caricamento ${postiConWikipedia.length} immagini da Wikipedia...');

      // Scarica immagini
      final imagesMap = await _wikipediaService.getImagesForPlaces(
        postiConWikipedia,
        cityNames: cityNamesMap,
      );

      // Assegna URL alle immagini
      for (final citta in widget.itinerario!.itinerario) {
        for (final giornata in citta.giornate) {
          for (final posto in giornata.posti) {
            if (posto.hasWikipediaData) {
              posto.urlImmagine = imagesMap[posto.wikipediaTitle];
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoadingImages = false;
        });
      }

      debugPrint('✅ Immagini caricate con successo');
    } catch (e) {
      debugPrint('❌ Errore caricamento immagini: $e');
      if (mounted) {
        setState(() {
          _isLoadingImages = false;
        });
      }
    }
  }

  // Crea Model e Controller
  void _createMapComponents() {
    if (widget.itinerario == null) return;

    // Cleanup precedenti istanze
    _mapController?.dispose();
    _mapModel?.dispose();

    // Crea nuove istanze model e controller
    _mapModel = ItineraryMapModel(widget.itinerario!);
    _mapController = ItineraryMapController(_mapModel!);

    debugPrint('✅ Model e Controller creati');

    if (mounted) {
      setState(() {});
    }
  }

  // Inizializza tutti i marker in parallelo
  Future<void> _initializeMarkers() async {
    if (_mapController == null) return;

    setState(() {
      _isInitializingMarkers = true;
    });

    try {
      await _mapController!.initializeAllMarkers();

      if (mounted) {
        setState(() {
          _isInitializingMarkers = false;
        });
      }

      debugPrint('✅ Marker inizializzati');
    } catch (e) {
      debugPrint('❌ Errore inizializzazione marker: $e');
      if (mounted) {
        setState(() {
          _isInitializingMarkers = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final showBackground = !widget.isLoading &&
        widget.errorMessage == null &&
        (widget.itinerario == null || widget.itinerario!.itinerario.isEmpty);


    if (showBackground) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              isDarkMode
                  ? 'images/travel_dark.png'
                  : 'images/travel_light.png',
              fit: BoxFit.contain,
              alignment: Alignment(0, -0.05),
            ),
          ),
          _buildEmptyState(),
        ],
      );
    }

    if (widget.isLoading) {
      return _buildLoadingState('Generazione itinerario in corso...');
    }

    if (widget.errorMessage != null) {
      return _buildErrorState(widget.errorMessage!);
    }

    if (_isLoadingImages || _isInitializingMarkers || !_isMapReady()) {
      return _buildLoadingState(_getLoadingMessage());
    }

    return _buildItinerary();
  }



  // UI
  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary(context)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: AppColors.text(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.deleteColorText(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Errore nella generazione',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.hintText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Nessun itinerario generato',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vai nella sezione "Cerca" \n e crea il tuo Viaggio!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.hintText(context),
          ),
        ),
        const SizedBox(height: 40)
      ],
    );
  }


  Widget _buildItinerary() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              // Container mappa
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.widgetBackground(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: ItineraryMapView(
                    controller: _mapController!,
                    model: _mapModel!,
                  ),
                ),
              ),

              ItineraryList( itinerary: widget.itinerario!, onOpenInMaps: _mapController!.openInGoogleMaps),
            ],
          ),
        ),

        ],
      ),
    );
  }

  // HELPER

  bool _isMapReady() {
    return _mapController != null &&
        _mapModel != null &&
        _mapController!.isInitialized;
  }

  String _getLoadingMessage() {
    if (_isLoadingImages) {
      return 'Caricamento immagini...';
    }
    if (_isInitializingMarkers) {
      return 'Creazione marker...';
    }
    return 'Preparazione mappa...';
  }
}