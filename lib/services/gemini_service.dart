import 'package:flutter/material.dart';
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
      throw Exception('API Key non trovata');
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
      throw Exception('Il formato della risposta è invalido.\nProva con meno giorni o tappe.');
    } catch (e) {
      throw Exception('Errore durante la generazione dell\'itinerario.\nControlla la connessione e riprova.');
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

FORMATO OUTPUT (JSON VALIDO):
Genera ESCLUSIVAMENTE un JSON valido con questa struttura (NESSUN testo prima o dopo il JSON):

{
  "itinerario": [
    {
      "citta": "Nome della città",
      "coordinate": {"lat": 0.0, "lng": 0.0},
      "giornate": [
        {
          "data": "YYYY-MM-DD",
          "posti": [
            {
              "nome": "Nome del posto/attrazione/pranzo/cena",
              "descrizione": "Descrizione dettagliata (2-3 frasi) del posto, cosa vedere, perché è interessante",
              "orario_inizio": "HH:MM",
              "orario_fine": "HH:MM",
              "coordinate": {"lat": 0.0, "lng": 0.0},
              "wikipedia_title": "Titolo_Wikipedia",
              "wikipedia_lang": "it",
              "tipo":  'pausa' : 'attrazione'
            }
          ]
        }
      ]
    }
  ]
}

IMPORTANTE:
- DUE TIPI DI POSTI:
A) ATTRAZIONI TURISTICHE (tipo: "attrazione"):
   - Monumenti, musei, parchi, punti panoramici
   - DEVONO avere coordinate precise (lat/lng)


B) PAUSE PRANZO/CENA (tipo: "pausa"):
   - NON devono avere coordinate (lascia null)
   - NON devono avere wikipedia_title (lascia null)
   - NON devono avere url_immagine
   - PER OGNI giornata, se ha una durata che contiene l'orario per la pausa pranzo/cena devono essere SEMPRE presenti
   - Descrizione BREVE: solo "pranzo/cena in zona [nome zona]. Prova i piatti tipici della cucina locale."
   - La zona deve essere vicina all'ultimo posto visitato o intermedia tra l'ultimo e il prossimo
   - Nome: "Pranzo in Zona [nome zona]" o "Cena in Zona [nome zona]"
   
- Le coordinate devono essere precise (usa valori reali per ogni posto specifico)
- Gli orari devono susseguirsi logicamente senza sovrapposizioni
- Includi almeno 3-5 posti per giornata (in base alla durata)

IMPORTANTE PER LE COORDINATE:
- Le coordinate delle ATTRAZIONI devono essere PRECISE e corrispondere ESATTAMENTE al luogo specifico
- NON usare le coordinate del centro città per tutti i luoghi
- Verifica che lat/lng siano nel range valido (lat: -90 a 90, lng: -180 a 180)
- Per le PAUSE, le coordinate devono essere null


IMPORTANTE PER WIKIPEDIA:
- Per ogni posto, fornisci il campo "wikipedia_title" con il TITOLO ESATTO come appare nell'URL dell'articolo Wikipedia
- Il titolo deve essere quello che appare nell'URL di Wikipedia (es. "Colosseo", "Torre_di_Pisa", "Duomo_di_Milano")
- Usa gli underscore "_" al posto degli spazi (es. "Fontana_di_Trevi" NON "Fontana di Trevi")
- NON usare caratteri URL-encoded (come %27)
- Se non sei sicuro del titolo esatto, usa il nome del posto senza spazi (es. "Colosseo" invece di "Colosseo di Roma")
- Imposta sempre "wikipedia_lang": "it" per articoli in italiano
- Se un posto non ha un articolo Wikipedia chiaro, lascia "wikipedia_title": null


COSA INCLUDERE (SOLO QUESTI DUE TIPI):

A) ATTRAZIONI TURISTICHE (tipo: "attrazione"):
   - Monumenti storici
   - Musei e gallerie d'arte
   - Chiese e cattedrali
   - Palazzi storici
   - Parchi e giardini pubblici
   - Piazze famose
   - Punti panoramici
   - Zone caratteristiche da esplorare a piedi
   - Mercati tipici
   - Teatri storici

B) PAUSE PRANZO/CENA (tipo: "pausa"):
   - Pausa pranzo (fascia oraria 12:30-14:30)
   - Pausa cena (fascia oraria 19:30-21:30)
 

COSA NON INCLUDERE MAI (DIVIETO ASSOLUTO):

✗ "Arrivo a [città]"
✗ "Trasferimento a [città]"
✗ "Partenza da [città]"
✗ "Check-in hotel"
✗ "Check-out hotel"
✗ "Sistemazione in hotel"
✗ "Tempo libero"
✗ "Riposo"
✗ "Spostamento da X a Y"
✗ "Viaggio verso [luogo]"
✗ Qualsiasi attività logistica o di trasferimento
✗ Qualsiasi momento di transito o attesa

INSERISCI ESCLUSIVAMENTE:
✓ Luoghi fisici da visitare (monumenti, musei, piazze, chiese, ecc.)
✓ Pause pranzo/cena


COSA CONSIDERARE:
- Vicinanza geografica dei posti per minimizzare spostamenti
- Tipologia di esperienza bilanciata (cultura, relax, cibo)
- Stagionalità e condizioni meteo tipiche del periodo
- Tempo necessario per godersi ogni esperienza senza fretta

ESEMPIO DI COORDINAZIONE TEMPORALE CORRETTA:
Se una tappa va dal 25/10/2025 alle 11:00 al 28/10/2025 alle 18:00:
- Giorno 1 (25/10): Posti dalle 11:00 alle 23:00
- Giorno 2 (26/10): Posti dalle 09:00 alle 23:00  
- Giorno 3 (27/10): Posti dalle 09:00 alle 23:00
- Giorno 3 (28/10): Posti dalle 09:00 alle 18:00


REGOLE OBBLIGATORIE PER ORARI GIORNALIERI:
- Il valore `oraInizio` fornito dall'utente si applica **solo al primo giorno** (`dataInizio`) e quella giornata DEVE iniziare esattamente a `oraInizio`.
- Il valore `oraFine` fornito dall'utente si applica **solo all'ultimo giorno** (`dataFine`) e quella giornata DEVE terminare esattamente a `oraFine`.
- Se `dataInizio` == `dataFine`, la singola giornata deve iniziare a `oraInizio` e terminare a `oraFine`.
- Tutti i giorni **intermedi** (se esistono) devono rispettare questi vincoli: non iniziare prima delle 09:00 e non terminare dopo le 23:00. Quindi l'orario di ogni giorno intermedio sarà 09:00–23:00.
- Il primo giorno termina alle 23:00, **salvo** che `dataInizio` == `dataFine` (in quel caso termina a `oraFine`).
- L'ultimo giorno inizia alle 09:00, **salvo** che `dataInizio` == `dataFine` (in quel caso inizia a `oraInizio`).
- Applica questi orari prima di assegnare i singoli posti per giornata. Assicurati che tutti i posti inseriti in ciascun giorno abbiano orari compresi tra l'inizio e la fine calcolati per quel giorno.


ESEMPIO PRATICO PRANZO/CENA:
Se l'ultima attrazione prima di pranzo è il Colosseo, e la prima dopo pranzo è Piazza Navona:
{
  "nome": "Pausa Pranzo",
  "descrizione": "Pausa pranzo in zona Monti. Prova i piatti tipici della cucina romana.",
  "orario_inizio": "13:00",
  "orario_fine": "14:30",
  "coordinate": null,
  "wikipedia_title": null,
  "tipo": "pausa"
}


Genera SOLO il JSON, senza alcun testo aggiuntivo prima o dopo.
''';
  }

  // Parsing della risposta di Gemini
  ItineraryResponse _parseResponse(String responseText) {
    try {
      // Pulisci il JSON
      String cleanedJson = _cleanJsonString(responseText);

      // Parsing del JSON
      final Map<String, dynamic> jsonData = jsonDecode(cleanedJson);

      // Crea l'oggetto ItineraryResponse
      final itinerary = ItineraryResponse.fromJson(jsonData);

      return itinerary;

    } catch (e) {
      debugPrint('❌ Errore parsing JSON completo:');
      debugPrint(responseText);
      throw FormatException('Impossibile parsare la risposta di Gemini: $e');
    }
  }

  String _cleanJsonString(String jsonString) {
    String cleaned = jsonString.trim();

    // Rimuovi markdown
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    cleaned = cleaned.trim();
    cleaned = cleaned.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');

    // Rimuovi trailing commas prima di chiudere
    cleaned = cleaned.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

    // Tronca all'ultimo oggetto completo se necessario
    if (!cleaned.endsWith('}') && !cleaned.endsWith(']')) {
      debugPrint('⚠️ JSON troncato, cerco l\'ultimo blocco completo...');

      // Trova l'ultimo "}" che chiude un posto completo
      final lastCompleteObject = cleaned.lastIndexOf('}');
      if (lastCompleteObject != -1) {
        cleaned = cleaned.substring(0, lastCompleteObject + 1);

        // Chiudi gli array e oggetti aperti
        final openBraces = '{'.allMatches(cleaned).length;
        final closeBraces = '}'.allMatches(cleaned).length;
        final openBrackets = '['.allMatches(cleaned).length;
        final closeBrackets = ']'.allMatches(cleaned).length;

        for (int i = 0; i < (openBrackets - closeBrackets); i++) {
          cleaned += ']';
        }
        for (int i = 0; i < (openBraces - closeBraces); i++) {
          cleaned += '}';
        }

        debugPrint('✅ JSON riparato fino all\'ultimo oggetto completo');
      }
    }

    return cleaned;
  }
}