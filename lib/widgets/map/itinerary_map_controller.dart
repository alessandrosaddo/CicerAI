import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cicer_ai/models/itinerary/citta_itinerario.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'itinerary_map.dart';


class ItineraryMapController {
  final ItineraryMapModel model;
  GoogleMapController? _mapController;

  ItineraryMapController(this.model);

  // GETTERS
  bool get isDetailMode => model.isDetailMode;
  bool get isInitialized => model.isInitialized;

  CameraTargetBounds get cameraTargetBounds {
    return model.currentBounds != null
        ? CameraTargetBounds(model.currentBounds!)
        : CameraTargetBounds.unbounded;
  }

  CameraPosition get initialCameraPosition => model.initialCameraPosition;

  Set<Marker> get currentMarkers => model.currentMarkers;
  Set<Polyline> get currentPolylines => model.currentPolylines;


  // INIZIALIZZAZIONE
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    _fitAllCities();
  }

  // Inizializza TUTTI i marker in parallelo
  Future<void> initializeAllMarkers() async {
    if (model.isInitialized) {
      debugPrint('⚠️ Marker già inizializzati, skip');
      return;
    }

    debugPrint('🔄 Inizializzazione PARALLELA di TUTTI i marker...');
    final startTime = DateTime.now();

    await model.preloadAllImages();

    await Future.wait([
      _initializeCityMarkers(),
      ...(model.itinerary.itinerario.map(
            (city) => _initializePlaceMarkersForCity(city),
      )),
    ]);

    model.setInitialized(true);
    final duration = DateTime.now().difference(startTime);
    debugPrint(
      '✅ Tutti i marker inizializzati in ${duration.inMilliseconds}ms',
    );
  }

  // CREAZIONE MARKER CITTÀ
  Future<void> _initializeCityMarkers() async {
    debugPrint('📍 Creazione marker città...');
    final startTime = DateTime.now();

    final polylinePoints = <LatLng>[];
    final markerFutures = <Future<Marker?>>[];

    for (int i = 0; i < model.itinerary.itinerario.length; i++) {
      final city = model.itinerary.itinerario[i];
      if (city.coordinate == null) {
        markerFutures.add(Future.value(null));
        continue;
      }

      final position = LatLng(city.coordinate!.lat, city.coordinate!.lng);
      polylinePoints.add(position);

      final letter = String.fromCharCode(65 + i);

      String? imageUrl;
      if (city.giornate.isNotEmpty && city.giornate.first.posti.isNotEmpty) {
        imageUrl = city.giornate.first.posti.first.urlImmagine;
      }

      markerFutures.add(
        _createCityMarker(
          i: i,
          city: city,
          position: position,
          letter: letter,
          imageUrl: imageUrl,
        ),
      );
    }

    final markers = await Future.wait(markerFutures);
    model.setCityMarkers(markers.whereType<Marker>().toSet());

    if (polylinePoints.length > 1) {
      model.setCityPolylines({
        Polyline(
          polylineId: const PolylineId('city_route'),
          points: polylinePoints,
          color: Colors.blue.withOpacity(0.6),
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      });
    }

    model.setCurrentBounds(_calculateBounds(polylinePoints));

    final duration = DateTime.now().difference(startTime);
    debugPrint(
      '✅ ${model.currentMarkers.length} marker città creati in ${duration.inMilliseconds}ms',
    );
  }

  Future<Marker?> _createCityMarker({
    required int i,
    required CittaItinerario city,
    required LatLng position,
    required String letter,
    String? imageUrl,
  }) async {
    final icon = await _createMarkerWithImage(
      imageUrl: imageUrl,
      fallbackLetter: letter,
      fallbackText: city.citta,
      fallbackColor: Colors.blue,
    );

    return Marker(
      markerId: MarkerId('city_$i'),
      position: position,
      icon: icon,
      anchor: const Offset(0.5, 0.5),
      onTap: () => onCityTapped(city),
      infoWindow: InfoWindow(
        title: '$letter. ${city.citta}',
        snippet:
        '${city.numeroGiorni} giorni - ${city.numeroTotalePostiDaVisitare} posti',
      ),
    );
  }

  // CREAZIONE MARKER POSTI
  Future<void> _initializePlaceMarkersForCity(CittaItinerario city) async {
    debugPrint('📍 Creazione marker posti per: ${city.citta}...');
    final startTime = DateTime.now();

    final polylinePoints = <LatLng>[];
    final markerFutures = <Future<Marker?>>[];

    int markerIndex = 0;

    for (final giornata in city.giornate) {
      for (final posto in giornata.posti) {
        if (posto.coordinate == null) {
          markerFutures.add(Future.value(null));
          continue;
        }

        final position = LatLng(posto.coordinate!.lat, posto.coordinate!.lng);
        polylinePoints.add(position);

        final number = (markerIndex + 1).toString();
        final currentIndex = markerIndex;

        markerFutures.add(
          _createPlaceMarker(
            city: city,
            posto: posto,
            position: position,
            number: number,
            markerIndex: currentIndex,
          ),
        );

        markerIndex++;
      }
    }

    final markers = await Future.wait(markerFutures);
    model.setPlaceMarkersForCity(city.citta, markers.whereType<Marker>().toSet());

    if (polylinePoints.length > 1) {
      model.setPlacePolylinesForCity(city.citta, {
        Polyline(
          polylineId: PolylineId('place_route_${city.citta}'),
          points: polylinePoints,
          color: Colors.orange.withOpacity(0.7),
          width: 3,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      });
    }

    final duration = DateTime.now().difference(startTime);
    final count = model.getPlaceMarkersForCity(city.citta)?.length ?? 0;
    debugPrint(
      '✅ $count marker posti creati per ${city.citta} in ${duration.inMilliseconds}ms',
    );
  }

  Future<Marker?> _createPlaceMarker({
    required CittaItinerario city,
    required posto,
    required LatLng position,
    required String number,
    required int markerIndex,
  }) async {
    final icon = await _createMarkerWithImage(
      imageUrl: posto.urlImmagine,
      fallbackLetter: number,
      fallbackText: posto.nome,
      fallbackColor: Colors.orange,
    );

    return Marker(
      markerId: MarkerId('place_${city.citta}_${posto.nome}_$markerIndex'),
      position: position,
      icon: icon,
      anchor: const Offset(0.5, 0.5),
      onTap: () => _openInGoogleMaps(position, posto.nome),
      infoWindow: InfoWindow(
        title: '$number. ${posto.nome}',
        snippet: 'Tap per aprire in Google Maps',
      ),
    );
  }

  // GESTIONE EVENTI
  void onCityTapped(CittaItinerario city) {
    debugPrint('🗺️ Click su città: ${city.citta}');

    model.setSelectedCity(city);
    model.setDetailMode(true);

    final cityMarkers = model.getPlaceMarkersForCity(city.citta);
    if (cityMarkers == null || cityMarkers.isEmpty) {
      debugPrint('⚠️ Nessun marker trovato per ${city.citta}');
      return;
    }

    final coordinates = cityMarkers.map((m) => m.position).toList();
    model.setCurrentBounds(_calculateBounds(coordinates));

    if (_mapController != null && city.coordinate != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(city.coordinate!.lat, city.coordinate!.lng),
            zoom: 13,
          ),
        ),
      );
    }
  }

  void returnToOverview() {
    debugPrint('🗺️ Ritorno alla vista generale');

    model.setDetailMode(false);
    model.setSelectedCity(null);

    final cityCoordinates = model.allCityCoordinates;
    model.setCurrentBounds(_calculateBounds(cityCoordinates));

    _fitAllCities();
  }

  Future<void> _openInGoogleMaps(LatLng position, String label) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // CALCOLI E UTILITÀ
  void _fitAllCities() {
    if (_mapController == null || model.itinerary.itinerario.isEmpty) return;

    final coordinates = model.allCityCoordinates;

    if (coordinates.isEmpty) return;

    if (coordinates.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(coordinates.first, 10),
      );
      return;
    }

    final bounds = _createLatLngBounds(coordinates);
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds? _calculateBounds(List<LatLng> coordinates) {
    if (coordinates.isEmpty) return null;

    if (coordinates.length == 1) {
      final point = coordinates.first;
      const margin = 0.05;
      return LatLngBounds(
        southwest: LatLng(point.latitude - margin, point.longitude - margin),
        northeast: LatLng(point.latitude + margin, point.longitude + margin),
      );
    }

    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    final latMargin = (maxLat - minLat) * 0.1;
    final lngMargin = (maxLng - minLng) * 0.1;

    return LatLngBounds(
      southwest: LatLng(minLat - latMargin, minLng - lngMargin),
      northeast: LatLng(maxLat + latMargin, maxLng + lngMargin),
    );
  }

  LatLngBounds _createLatLngBounds(List<LatLng> coordinates) {
    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // CREAZIONE ICONE MARKER
  Future<BitmapDescriptor> _createMarkerWithImage({
    String? imageUrl,
    required String fallbackLetter,
    required String fallbackText,
    required Color fallbackColor,
  }) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final imageMarker = await _createImageMarker(
          imageUrl,
          fallbackLetter,
          fallbackText,
        );
        if (imageMarker != null) {
          return imageMarker;
        }
      } catch (e) {
        debugPrint('⚠️ Errore caricamento immagine per $fallbackText: $e');
      }
    }

    return _createLetterMarker(fallbackLetter, fallbackText, fallbackColor);
  }

  Future<BitmapDescriptor?> _createImageMarker(
      String imageUrl,
      String letter,
      String placeName,
      ) async {
    try {
      // Usa la cache del model
      Uint8List? imageBytes = model.getCachedImage(imageUrl);

      if (imageBytes == null) {
        debugPrint('📥 Download per $placeName...');
        imageBytes = await model.downloadImage(imageUrl);

        if (imageBytes == null) {
          debugPrint('⚠️ Download fallito per $placeName');
          return null;
        }
      }

      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 200,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      const double size = 100.0;
      const double badgeSize = 30.0;
      const double spacing = 8.0;

      final namePainter = TextPainter(
        text: TextSpan(
          text: placeName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 6),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout();

      final totalWidth = (namePainter.width + 20).clamp(size, double.infinity);
      final totalHeight = size + spacing + namePainter.height + 10;

      final shadowPaint = Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(
        Offset(totalWidth / 2, size / 2).translate(0, 2),
        size / 2,
        shadowPaint,
      );

      canvas.save();
      canvas.clipPath(
        Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(totalWidth / 2, size / 2),
              radius: size / 2,
            ),
          ),
      );

      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(totalWidth / 2 - size / 2, 0, size, size),
        image: image,
        fit: BoxFit.cover,
      );
      canvas.restore();

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(
        Offset(totalWidth / 2, size / 2),
        size / 2,
        borderPaint,
      );

      final badgeCenter = Offset(
        totalWidth / 2 + size / 2 - badgeSize / 2,
        badgeSize / 2,
      );

      canvas.drawCircle(
        badgeCenter.translate(0, 1),
        badgeSize / 2,
        shadowPaint,
      );

      final badgePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(badgeCenter, badgeSize / 2, badgePaint);

      final badgeBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(badgeCenter, badgeSize / 2, badgeBorderPaint);

      final letterPainter = TextPainter(
        text: TextSpan(
          text: letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      letterPainter.layout();
      letterPainter.paint(
        canvas,
        Offset(
          badgeCenter.dx - letterPainter.width / 2,
          badgeCenter.dy - letterPainter.height / 2,
        ),
      );

      namePainter.paint(
        canvas,
        Offset((totalWidth - namePainter.width) / 2, size + spacing),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(
        totalWidth.toInt(),
        totalHeight.toInt(),
      );
      final data = await img.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
    } catch (e) {
      return null;
    }
  }

  Future<BitmapDescriptor> _createLetterMarker(
      String letter,
      String placeName,
      Color color,
      ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final letterPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 56,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    final namePainter = TextPainter(
      text: TextSpan(
        text: placeName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(0, 3), blurRadius: 8),
            Shadow(color: Colors.black87, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    letterPainter.layout();
    namePainter.layout();

    const circleRadius = 50.0;
    const spacing = 12.0;
    const horizontalPadding = 20.0;
    const topPadding = 10.0;
    final totalWidth = (namePainter.width + horizontalPadding * 2).clamp(
      circleRadius * 2,
      double.infinity,
    );
    final totalHeight =
        topPadding + circleRadius * 2 + spacing + namePainter.height + 10;

    final circleCenter = Offset(totalWidth / 2, topPadding + circleRadius);

    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(circleCenter.translate(0, 2), circleRadius, shadowPaint);

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(circleCenter, circleRadius, circlePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(circleCenter, circleRadius, borderPaint);

    letterPainter.paint(
      canvas,
      Offset(
        (totalWidth - letterPainter.width) / 2,
        topPadding + circleRadius - letterPainter.height / 2,
      ),
    );

    namePainter.paint(
      canvas,
      Offset(
        (totalWidth - namePainter.width) / 2,
        topPadding + circleRadius * 2 + spacing,
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(totalWidth.toInt(), totalHeight.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }


  // CLEANUP
  void dispose() {
    _mapController?.dispose();
  }
}