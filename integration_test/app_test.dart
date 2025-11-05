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

      //================= STEP 4 Inserimento orario inzio ==============================

      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('⏳ Attendo abilitazione campo orario dopo selezione data...');

      final oraInizioField = find.widgetWithText(TextField, 'Ora Inizio');
      expect(oraInizioField, findsOneWidget);
      debugPrint('✅ Campo "Ora Inizio" trovato e abilitato');

      await tester.tap(oraInizioField);
      await tester.pumpAndSettle();
      debugPrint('✅ Time picker aperto');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Trova il TextField del time picker (di solito è l'ultimo TextField sulla schermata)
      final allTextFields = find.byType(TextField);
      expect(allTextFields, findsWidgets);

      // Prendiamo le ORE
      final pickerHourTextField = allTextFields.at(
        allTextFields.evaluate().length - 2,
      );

      // Focalizza il campo del picker
      await tester.tap(pickerHourTextField);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // SVUOTA il contenuto esistente
      await tester.enterText(pickerHourTextField, '');
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Adesso scrivi l'orario desiderato
      await tester.enterText(pickerHourTextField, '09');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      debugPrint('✏️ Orario "09" inserito nel campo delle ore');

      // Prendiamo i MINUTI
      final pickerMinuteTextField = allTextFields.at(
        allTextFields.evaluate().length - 1,
      );

      // Focalizza il campo del picker
      await tester.tap(pickerMinuteTextField);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // SVUOTA il contenuto esistente
      await tester.enterText(pickerMinuteTextField, '');
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Adesso scrivi l'orario desiderato
      await tester.enterText(pickerMinuteTextField, '00');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      debugPrint('✏️ Orario "00" inserito nel campo dei minuti');

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      debugPrint('✅ Orario confermato con successo');

      //================= STEP 5 Inserimento data fine ==============================

      final dataFineField = find.widgetWithText(TextField, 'Data Fine');
      expect(dataFineField, findsOneWidget);
      debugPrint('✅ Campo "Data Fine" trovato e abilitato');

      await tester.tap(dataFineField);
      await tester.pumpAndSettle();
      debugPrint('✅ Campo data fine, apro il date picker');

      // Seleziona la prima data disponibile (che sarà >= Data Inizio)
      final okButtonFine = find.text('OK');
      await tester.tap(okButtonFine);
      await tester.pumpAndSettle();
      debugPrint('✅ Selezionata la data di fine');




      //================= STEP 6 Inserimento orario fine ==============================

      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('⏳ Attendo che il campo "Ora Fine" diventi disponibile...');

      final oraFineField = find.widgetWithText(TextField, 'Ora Fine');
      expect(oraFineField, findsOneWidget);
      debugPrint('✅ Campo "Ora Fine" trovato e abilitato');

      await tester.tap(oraFineField);
      await tester.pumpAndSettle();
      debugPrint('✅ Time picker aperto per ora fine');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Trova il TextField del time picker (di solito è l'ultimo TextField sulla schermata)
      final fineTextFields = find.byType(TextField);
      expect(fineTextFields, findsWidgets);

      // Prendiamo le ORE
      final pickerHourFineTextField =
      fineTextFields.at(fineTextFields.evaluate().length - 2);

      // Focalizza il campo del picker
      await tester.tap(pickerHourFineTextField);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // SVUOTA il contenuto esistente
      await tester.enterText(pickerHourFineTextField, '');
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Adesso scrivi l'orario desiderato
      await tester.enterText(pickerHourFineTextField, '18');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      debugPrint('✏️ Orario "18" inserito nel campo delle ore (fine)');

      // Prendiamo i MINUTI
      final pickerMinuteFineTextField  = allTextFields.at(
        allTextFields.evaluate().length - 1,
      );

      // Focalizza il campo del picker
      await tester.tap(pickerMinuteFineTextField);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // SVUOTA il contenuto esistente
      await tester.enterText(pickerMinuteFineTextField, '');
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Adesso scrivi l'orario desiderato
      await tester.enterText(pickerMinuteFineTextField, '00');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      debugPrint('✏️ Orario "00" inserito nel campo dei minuti (fine)');

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      debugPrint('✅ Orario confermato con successo');


      //================= STEP 7 Generare l'itinerario ==============================

      await tester.pumpAndSettle(const Duration(seconds: 1));
      final generateButton = find.text('Genera Itinerario');

      await tester.ensureVisible(generateButton);
      await tester.pumpAndSettle();

      await tester.tap(generateButton);
      await tester.pumpAndSettle(const Duration(seconds: 35));

    });
  });
}
