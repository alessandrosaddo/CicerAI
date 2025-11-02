import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cicer_ai/models/itinerary/itinerary_response.dart';
import 'package:cicer_ai/models/itinerary/citta_itinerario.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;


class ItineraryMapModel extends ChangeNotifier {
  final ItineraryResponse itinerary;

  // Stato
  bool _isDetailMode = false;
  CittaItinerario? _selectedCity;
  LatLngBounds? _currentBounds;
  bool _isInitialized = false;

  // Cache markers e polylines
  Set<Marker> _cityMarkers = {};
  final Map<String, Set<Marker>> _placeMarkersCache = {};
  Set<Polyline> _cityPolylines = {};
  final Map<String, Set<Polyline>> _placePolylinesCache = {};

  // Cache immagini
  final Map<String, Uint8List?> _imageCache = {};

  ItineraryMapModel(this.itinerary) {
    debugPrint(
      '🗺️ ItineraryMapModel creato con ${itinerary.numeroCitta} città',
    );
  }

  // GETTERS
  bool get isDetailMode => _isDetailMode;
  CittaItinerario? get selectedCity => _selectedCity;
  bool get isInitialized => _isInitialized;

  Set<Marker> get currentMarkers {
    if (_isDetailMode && _selectedCity != null) {
      return _placeMarkersCache[_selectedCity!.citta] ?? {};
    }
    return _cityMarkers;
  }

  Set<Polyline> get currentPolylines {
    if (_isDetailMode && _selectedCity != null) {
      return _placePolylinesCache[_selectedCity!.citta] ?? {};
    }
    return _cityPolylines;
  }

  LatLngBounds? get currentBounds => _currentBounds;

  CameraPosition get initialCameraPosition {
    if (itinerary.itinerario.isEmpty) {
      return const CameraPosition(target: LatLng(41.9028, 12.4964), zoom: 6);
    }

    final firstCity = itinerary.itinerario.first;
    if (firstCity.coordinate != null) {
      return CameraPosition(
        target: LatLng(firstCity.coordinate!.lat, firstCity.coordinate!.lng),
        zoom: 6,
      );
    }

    return const CameraPosition(target: LatLng(41.9028, 12.4964), zoom: 6);
  }

  List<LatLng> get allCityCoordinates {
    return itinerary.itinerario
        .where((city) => city.coordinate != null)
        .map((city) => LatLng(city.coordinate!.lat, city.coordinate!.lng))
        .toList();
  }

  // SETTERS (per il Controller)
  void setDetailMode(bool isDetail) {
    _isDetailMode = isDetail;
    notifyListeners();
  }

  void setSelectedCity(CittaItinerario? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setCurrentBounds(LatLngBounds? bounds) {
    _currentBounds = bounds;
    notifyListeners();
  }

  void setInitialized(bool initialized) {
    _isInitialized = initialized;
    notifyListeners();
  }

  // GESTIONE MARKERS
  void setCityMarkers(Set<Marker> markers) {
    _cityMarkers = markers;
  }

  void setCityPolylines(Set<Polyline> polylines) {
    _cityPolylines = polylines;
  }

  void setPlaceMarkersForCity(String cityName, Set<Marker> markers) {
    _placeMarkersCache[cityName] = markers;
  }

  void setPlacePolylinesForCity(String cityName, Set<Polyline> polylines) {
    _placePolylinesCache[cityName] = polylines;
  }

  Set<Marker>? getPlaceMarkersForCity(String cityName) {
    return _placeMarkersCache[cityName];
  }

  Set<Polyline>? getPlacePolylinesForCity(String cityName) {
    return _placePolylinesCache[cityName];
  }

  // GESTIONE CACHE IMMAGINI
  List<String> getAllImageUrls() {
    final allImageUrls = <String>{};

    for (final city in itinerary.itinerario) {
      // Immagine città (prima della prima giornata)
      if (city.giornate.isNotEmpty && city.giornate.first.posti.isNotEmpty) {
        final url = city.giornate.first.posti.first.urlImmagine;
        if (url != null && url.isNotEmpty) {
          allImageUrls.add(url);
        }
      }

      // Immagini posti
      for (final giornata in city.giornate) {
        for (final posto in giornata.posti) {
          if (posto.urlImmagine != null && posto.urlImmagine!.isNotEmpty) {
            allImageUrls.add(posto.urlImmagine!);
          }
        }
      }
    }

    return allImageUrls.toList();
  }

  // Verifica se un'immagine è in cache
  bool isImageCached(String url) {
    return _imageCache.containsKey(url);
  }

  // Ottiene un'immagine dalla cache
  Uint8List? getCachedImage(String url) {
    return _imageCache[url];
  }

  // Salva un'immagine in cache
  void cacheImage(String url, Uint8List? imageBytes) {
    _imageCache[url] = imageBytes;
  }

  // Scarica un'immagine (con timeout)
  Future<Uint8List?> downloadImage(String url) async {
    if (_imageCache.containsKey(url)) {
      return _imageCache[url];
    }

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        _imageCache[url] = bytes;
        return bytes;
      }
    } catch (e) {
      debugPrint('⚠️ Errore download immagine $url: $e');
    }

    _imageCache[url] = null;
    return null;
  }

  // Scarica immagini in batch con limite di concorrenza
  Future<Map<String, Uint8List?>> downloadImagesInBatch(
      List<String> urls, {
        int maxConcurrent = 5,
      }) async {
    final results = <String, Uint8List?>{};

    for (int i = 0; i < urls.length; i += maxConcurrent) {
      final batch = urls.skip(i).take(maxConcurrent).toList();

      final futures = batch.map((url) => downloadImage(url));
      final batchResults = await Future.wait(futures);

      for (int j = 0; j < batch.length; j++) {
        results[batch[j]] = batchResults[j];
      }
    }

    return results;
  }

  // Pre-carica tutte le immagini dell'itinerario
  Future<void> preloadAllImages() async {
    final urls = getAllImageUrls();

    if (urls.isEmpty) {
      debugPrint('ℹ️ Nessuna immagine da precaricare');
      return;
    }

    debugPrint(
      '📥 Pre-caricamento di ${urls.length} immagini (max 5 parallele)...',
    );
    final startTime = DateTime.now();

    await downloadImagesInBatch(urls, maxConcurrent: 5);

    final duration = DateTime.now().difference(startTime);
    final loaded = _imageCache.values.where((img) => img != null).length;
    debugPrint(
      '✅ Pre-caricate $loaded/${urls.length} immagini in ${duration.inMilliseconds}ms',
    );
  }

  // CLEANUP
  @override
  void dispose() {
    _imageCache.clear();
    super.dispose();
  }
}