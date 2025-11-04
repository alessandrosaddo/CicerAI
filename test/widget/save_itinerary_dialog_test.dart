import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cicer_ai/widgets/save_itinerary_dialog.dart';
import 'package:cicer_ai/models/itinerary/itinerary_response.dart';
import 'package:cicer_ai/models/itinerary/citta_itinerario.dart';
import 'package:cicer_ai/models/itinerary/coordinate.dart';

void main() {
  // Helper per creare un itinerario di test
  ItineraryResponse createTestItinerary() {
    return ItineraryResponse(
      itinerario: [
        CittaItinerario(
          citta: 'Roma',
          coordinate: Coordinate(lat: 41.9028, lng: 12.4964),
          giornate: [],
        ),
      ],
    );
  }

  // Helper per creare il widget di test
  Widget createTestWidget(ItineraryResponse itinerary) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => SaveItineraryDialog(itinerary: itinerary),
        ),
      ),
    );
  }

  group('SaveItineraryDialog - Test UI', () {
    testWidgets('Dialog mostra titolo e icona corretti', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(createTestWidget(itinerary));

      // Verifica presenza titolo
      expect(find.text('Salva Itinerario'), findsOneWidget);

      // Verifica presenza icona save
      expect(find.byIcon(Icons.save_alt), findsOneWidget);

      // Verifica presenza testo descrittivo
      expect(
        find.text('Dai un nome al tuo viaggio per ritrovarlo facilmente!'),
        findsOneWidget,
      );
    });

    testWidgets('Dialog mostra TextField per il nome', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(createTestWidget(itinerary));

      // Verifica presenza TextField
      expect(find.byType(TextField), findsOneWidget);

      // Verifica label del TextField
      expect(find.text('Nome Itinerario'), findsOneWidget);

      // Verifica icona edit nel TextField
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('Dialog mostra pulsanti Annulla e Salva', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(createTestWidget(itinerary));

      // Verifica presenza pulsanti
      expect(find.text('Annulla'), findsOneWidget);
      expect(find.text('Salva'), findsOneWidget);
    });
  });

  group('SaveItineraryDialog - Test Interazioni', () {
    testWidgets('TextField accetta input di testo', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(createTestWidget(itinerary));

      // Trova il TextField
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Inserisci testo
      await tester.enterText(textField, 'Il Mio Viaggio a Roma');
      await tester.pump();

      // Verifica che il testo sia stato inserito
      expect(find.text('Il Mio Viaggio a Roma'), findsOneWidget);
    });

    testWidgets('Pulsante Annulla chiude il dialog', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SaveItineraryDialog(
                        itinerary: itinerary,
                      ),
                    );
                  },
                  child: const Text('Apri Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Apri il dialog
      await tester.tap(find.text('Apri Dialog'));
      await tester.pumpAndSettle();

      // Verifica che il dialog sia visibile
      expect(find.text('Salva Itinerario'), findsOneWidget);

      // Tap su Annulla
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      // Verifica che il dialog sia chiuso
      expect(find.text('Salva Itinerario'), findsNothing);
    });

    testWidgets('Mostra errore se il nome è vuoto', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SaveItineraryDialog(
                        itinerary: itinerary,
                      ),
                    );
                  },
                  child: const Text('Apri Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Apri il dialog
      await tester.tap(find.text('Apri Dialog'));
      await tester.pumpAndSettle();

      // Tap su Salva senza inserire testo
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      // Verifica messaggio di errore
      expect(
        find.text('Inserisci un nome per l\'itinerario'),
        findsOneWidget,
      );
    });

    testWidgets('Mostra errore se il nome è troppo corto', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SaveItineraryDialog(
                        itinerary: itinerary,
                      ),
                    );
                  },
                  child: const Text('Apri Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Apri il dialog
      await tester.tap(find.text('Apri Dialog'));
      await tester.pumpAndSettle();

      // Inserisci nome troppo corto
      await tester.enterText(find.byType(TextField), 'AB');
      await tester.pump();

      // Tap su Salva
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      // Verifica messaggio di errore
      expect(
        find.text('Il nome deve essere di almeno 3 caratteri'),
        findsOneWidget,
      );
    });

    testWidgets('TextField ha limite di 50 caratteri', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(createTestWidget(itinerary));

      // Trova il TextField
      final textField = find.byType(TextField);

      // Verifica che il TextField abbia maxLength = 50
      final TextField widget = tester.widget(textField);
      expect(widget.maxLength, 50);

      // Inserisci testo molto lungo (60 caratteri)
      final longText = 'A' * 60;
      await tester.enterText(textField, longText);
      await tester.pump();

      // Il TextField dovrebbe troncare automaticamente a 50 caratteri
      // (Flutter lo gestisce internamente)
    });
  });

  group('SaveItineraryDialog - Test Accessibilità', () {
    testWidgets('TextField ha autofocus attivo', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(createTestWidget(itinerary));

      // Verifica che il TextField abbia autofocus
      final TextField widget = tester.widget(find.byType(TextField));
      expect(widget.autofocus, isTrue);
    });

    testWidgets('TextField può essere inviato con Enter', (tester) async {
      final itinerary = createTestItinerary();

      await tester.pumpWidget(createTestWidget(itinerary));

      // Trova il TextField
      final textField = find.byType(TextField);

      // Verifica che onSubmitted sia definito
      final TextField widget = tester.widget(textField);
      expect(widget.onSubmitted, isNotNull);
    });
  });
}