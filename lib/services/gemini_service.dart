import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cicer_ai/models/tappa_data.dart';
import 'package:cicer_ai/models/itinerary/itinerary_response.dart';
import 'dart:convert';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY non trovata');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
      ),
    );
  }

  // Genera un itinerario basato sulle tappe fornite
  Future<ItineraryResponse> generateItinerary(List<TappaData> tappe) async {
    try {
      // Validazione input
      _validateTappe(tappe);

      // Costruzione prompt
      final prompt = _buildPrompt(tappe);

      // Chiamata a Gemini
      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini ha restituito una risposta vuota');
      }

      // Parsing JSON
      final itinerary = _parseResponse(response.text!);

      // Validazione output
      if (!itinerary.isValid) {
        throw Exception('L\'itinerario generato non contiene posti da visitare');
      }

      return itinerary;

    } on FormatException catch (e) {
      throw Exception('Errore nel parsing del JSON: ${e.message}');
    } catch (e) {
      throw Exception('Errore durante la generazione dell\'itinerario: $e');
    }
  }



  // Valida che tutte le tappe abbiano i dati necessari
  void _validateTappe(List<TappaData> tappe) {
    if (tappe.isEmpty) {
      throw Exception('Nessuna tappa fornita');
    }

    for (final tappa in tappe) {
      if (tappa.citta.trim().isEmpty) {
        throw Exception('Una tappa non ha il nome della città');
      }

      if (tappa.coordinate == null) {
        throw Exception('La tappa "${tappa.citta}" non ha coordinate');
      }

      if (tappa.dataInizio == null || tappa.dataFine == null) {
        throw Exception('La tappa "${tappa.citta}" non ha date complete');
      }

      if (tappa.oraInizio.isEmpty || tappa.oraFine.isEmpty) {
        throw Exception('La tappa "${tappa.citta}" non ha orari completi');
      }
    }
  }

  // Costruisce il prompt ottimizzato per Gemini
  String _buildPrompt(List<TappaData> tappe) {
    // Converti le tappe in JSON
    final tappeJson = tappe.map((t) => t.toJson()).toList();
    final tappeJsonString = const JsonEncoder.withIndent('  ').convert(tappeJson);

    return '''
Sei un esperto pianificatore di viaggi turistici con anni di esperienza nell'organizzazione di itinerari personalizzati.

Il tuo compito è generare un itinerario turistico DETTAGLIATO e REALISTICO basato sulle seguenti tappe fornite dall'utente:

$tappeJsonString

REGOLE FONDAMENTALI:
1. RISPETTA RIGOROSAMENTE gli orari di inizio e fine di ogni tappa (dataInizio, dataFine, oraInizio, oraFine)
2. Suggerisci SOLO posti che sono effettivamente visitabili negli orari indicati
3. Per ogni città, distribuisci i posti da visitare su TUTTI i giorni disponibili (da dataInizio a dataFine)
4. Gli orari dei posti suggeriti DEVONO essere compresi tra oraInizio e oraFine di ogni giorno
5. Lascia tempo realistico per gli spostamenti tra i posti (almeno 15-30 minuti)
6. Includi pause pranzo/cena negli orari appropriati (es. 13:00-14:30, 20:00-21:30)
7. Considera gli orari di apertura REALI dei luoghi turistici (musei, monumenti, ecc.)

FORMATO OUTPUT (JSON):
Genera ESCLUSIVAMENTE un JSON valido con questa struttura (NESSUN testo prima o dopo il JSON):

{
  "itinerario": [
    {
      "citta": "Nome della città",
      "coordinate": {
        "lat": latitudine_città,
        "lng": longitudine_città
      },
      "giornate": [
        {
          "data": "YYYY-MM-DD",
          "posti": [
            {
              "nome": "Nome del posto/attrazione",
              "descrizione": "Descrizione dettagliata (2-3 frasi) del posto, cosa vedere, perché è interessante",
              "orario_inizio": "HH:MM",
              "orario_fine": "HH:MM",
              "coordinate": {
                "lat": latitudine_posto,
                "lng": longitudine_posto
              },
              "url_immagine": ""
            }
          ]
        }
      ]
    }
  ]
}

COSA INCLUDERE:
- Monumenti e attrazioni turistiche principali
- Musei e gallerie d'arte
- Parchi e giardini
- Esperienze gastronomiche locali (ristoranti tipici, mercati)
- Zone caratteristiche da esplorare a piedi
- Punti panoramici

COSA CONSIDERARE:
- Vicinanza geografica dei posti per minimizzare spostamenti
- Tipologia di esperienza bilanciata (cultura, relax, cibo)
- Stagionalità e condizioni meteo tipiche del periodo
- Tempo necessario per godersi ogni esperienza senza fretta

ESEMPIO DI COORDINAZIONE TEMPORALE CORRETTA:
Se una tappa va dal 25/10/2025 alle 09:00 al 27/10/2025 alle 18:00:
- Giorno 1 (25/10): Posti dalle 09:00 alle 23:00
- Giorno 2 (26/10): Posti dalle 09:00 alle 23:00  
- Giorno 3 (27/10): Posti dalle 09:00 alle 18:00

IMPORTANTE:
- Lascia sempre il campo "url_immagine" come stringa vuota ""
- Le coordinate devono essere precise (usa valori reali per ogni posto specifico)
- Gli orari devono susseguirsi logicamente senza sovrapposizioni
- Includi almeno 3-5 posti per giornata (in base alla durata)

Genera SOLO il JSON, senza alcun testo aggiuntivo prima o dopo.
''';
  }

  // Parsing della risposta di Gemini
  ItineraryResponse _parseResponse(String responseText) {
    try {
      // Rimuovi eventuali caratteri extra prima/dopo il JSON
      String cleanedJson = responseText.trim();

      // Rimuovi eventuali markdown code blocks
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.substring(7);
      } else if (cleanedJson.startsWith('```')) {
        cleanedJson = cleanedJson.substring(3);
      }

      if (cleanedJson.endsWith('```')) {
        cleanedJson = cleanedJson.substring(0, cleanedJson.length - 3);
      }

      cleanedJson = cleanedJson.trim();

      // Parsing del JSON
      final Map<String, dynamic> jsonData = jsonDecode(cleanedJson);

      // Crea l'oggetto ItineraryResponse
      final itinerary = ItineraryResponse.fromJson(jsonData);

      return itinerary;

    } catch (e) {
      throw FormatException('Impossibile parsare la risposta di Gemini: $e');
    }
  }

}