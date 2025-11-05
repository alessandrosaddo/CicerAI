import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cicer_ai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TappaWidget Integration Test', () {
    testWidgets('Compilazione completa di una tappa con tutti i campi', (
      WidgetTester tester,
    ) async {
      //================= STEP 1 Avvio dell'app ==============================
      app.main();
      await tester.pumpAndSettle();
      debugPrint('✅ App avviata con successo');

      // Verifica presenza testo nella schermata iniziale
      expect(find.text('Personalizza il tuo Viaggio'), findsOneWidget);
      debugPrint('✅ Home Screen caricata');

      //================= STEP 2 Inserimento città ==============================

      // Verifica Ricerca per l'itinerario
      expect(
        find.widgetWithText(
          GooglePlaceAutoCompleteTextField,
          'Cerca Città/Rileva Posizione',
        ),
        findsOneWidget,
      );
      debugPrint('✅ Campo città trovato');

      // Inserisci 'Roma' nella ricerca
      final cityField = find.byType(GooglePlaceAutoCompleteTextField);
      await tester.tap(cityField);
      await tester.pumpAndSettle();

      await tester.enterText(cityField, 'Roma');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      debugPrint('✅ Digitato "Roma" nel campo città...');

      // Trova tutti i suggerimenti dell’autocomplete
      final suggestions = find.byType(ListTile);
      expect(suggestions, findsWidgets);
      debugPrint('✅ Suggerimenti trovati: ${suggestions.evaluate().length}');

      //Seleziona il secondo risultato della lista dall'autocomplete
      await tester.tap(suggestions.at(1));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('✅ Selezionato il secondo risultato dell’autocomplete');

      await tester.pump(const Duration(seconds: 3));
      debugPrint('⏳ Attendo ricostruzione del widget dopo selezione città...');

      //================= STEP 3 Inserimento data inzio ==============================

      final dataInizioField = find.widgetWithText(TextField, 'Data Inizio');
      expect(dataInizioField, findsOneWidget);
      debugPrint('✅ Campo "Data Inizio" trovato e abilitato');

      // Tap sul campo della data
      await tester.tap(dataInizioField);
      await tester.pumpAndSettle();
      debugPrint('✅ Campo data, apro il date picker');

      final okButton = find.text('OK');
      await tester.tap(okButton);
      await tester.pumpAndSettle();
      debugPrint('✅ Selezionata la data odierna');
    });
  });
}
