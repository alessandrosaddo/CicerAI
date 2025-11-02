import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WikipediaService {
  Future<String?> getMainImage(
      String title, {
        String lang = 'it',
        String? cityName,
      }) async {
    try {
      final decodedTitle = Uri.decodeComponent(title);
      final encodedTitle = Uri.encodeComponent(decodedTitle);

      final url = Uri.parse(
        'https://$lang.wikipedia.org/w/api.php?'
            'action=query&'
            'titles=$encodedTitle&'
            'prop=pageimages&'
            'format=json&'
            'pithumbsize=1600&'
            'origin=*',
      );

      debugPrint('📡 Wikipedia API: Richiesta immagine per "$title" ($lang)');

      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'] as Map<String, dynamic>;

        final page = pages.values.first;

        // Verifica se l'articolo esiste
        if (page['missing'] != null) {
          debugPrint('⚠️ Articolo "$decodedTitle" non trovato');

          // Prova con il nome della città
          if (cityName != null && cityName.isNotEmpty) {
            return await _searchWithCity(decodedTitle, cityName, lang);
          }
          return null;
        }

        // Verifica se c'è un'immagine
        if (page['thumbnail'] != null && page['thumbnail']['source'] != null) {
          final imageUrl = page['thumbnail']['source'] as String;
          debugPrint('✅ Immagine trovata per "$title"');
          return imageUrl;
        } else {
          debugPrint('⚠️ Articolo trovato ma senza immagine per: "$title"');

          // Prova comunque con il nome della città
          if (cityName != null && cityName.isNotEmpty) {
            return await _searchWithCity(decodedTitle, cityName, lang);
          }
          return null;
        }
      } else {
        debugPrint('❌ Errore HTTP ${response.statusCode} per "$title"');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Errore nel recupero immagine per "$title": $e');
      return null;
    }
  }

  // Cerca su Wikipedia aggiungendo il nome della città
  Future<String?> _searchWithCity(
      String placeName,
      String cityName,
      String lang,
      ) async {
    try {
      // Pulisce il nome del posto
      final cleanPlaceName = placeName.replaceAll('_', ' ');

      // Pulisci il nome della città (solo prima parte prima della virgola)
      final cleanCityName = cityName.split(',').first.trim();

      // Query
      final searchQuery = '$cleanPlaceName $cleanCityName';

      debugPrint('🔍 Ricerca Wikipedia: "$searchQuery"');

      final searchUrl = Uri.parse(
          'https://$lang.wikipedia.org/w/api.php?'
              'action=query&'
              'list=search&'
              'srsearch=${Uri.encodeComponent(searchQuery)}&'
              'srlimit=1&'
              'format=json&'
              'origin=*'
      );

      final response = await http.get(searchUrl).timeout(
        const Duration(seconds: 3),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['query']['search'] as List?;

        if (results != null && results.isNotEmpty) {
          final foundTitle = results[0]['title'] as String;
          debugPrint('✅ Trovato articolo: "$foundTitle"');

          return await _getImageByTitle(foundTitle, lang);
        }
      }

      debugPrint('❌ Nessun risultato per "$searchQuery"');
      return null;

    } catch (e) {
      debugPrint('❌ Errore ricerca: $e');
      return null;
    }
  }

  // Recupera immagine dato un titolo esatto (senza fallback)
  Future<String?> _getImageByTitle(String title, String lang) async {
    try {
      final encodedTitle = Uri.encodeComponent(title);

      final url = Uri.parse(
          'https://$lang.wikipedia.org/w/api.php?'
              'action=query&'
              'titles=$encodedTitle&'
              'prop=pageimages&'
              'format=json&'
              'pithumbsize=1600&'
              'origin=*'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 3),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'] as Map<String, dynamic>;
        final page = pages.values.first;

        if (page['missing'] == null &&
            page['thumbnail'] != null &&
            page['thumbnail']['source'] != null) {
          return page['thumbnail']['source'] as String;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String?>> getImagesForPlaces(
      Map<String, String> placesMap,
          {
        String lang = 'it',
        Map<String, String>? cityNames,
      }
      ) async {
    final results = <String, String?>{};

    // Esegui richieste con un limite di concorrenza
    const batchSize = 5;
    final entries = placesMap.entries.toList();

    for (var i = 0; i < entries.length; i += batchSize) {
      final batch = entries.skip(i).take(batchSize);

      final futures = batch.map((entry) async {
        final wikipediaTitle = entry.value;
        final cityName = cityNames?[wikipediaTitle];

        final imageUrl = await getMainImage(
          wikipediaTitle,
          lang: lang,
          cityName: cityName,
        );

        return MapEntry(wikipediaTitle, imageUrl);
      });

      final responses = await Future.wait(futures);

      for (final response in responses) {
        results[response.key] = response.value;
      }
    }

    final trovate = results.values.where((url) => url != null).length;
    debugPrint('📊 Immagini caricate: $trovate/${results.length}');

    return results;
  }
}