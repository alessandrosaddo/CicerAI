import 'package:cicer_ai/screens/history_screen.dart';
import 'package:cicer_ai/widgets/itinerary_list.dart';
import 'package:cicer_ai/widgets/place_detail.dart';
import 'package:cicer_ai/widgets/save_itinerary_dialog.dart';
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
      await tester.pumpAndSettle(const Duration(seconds: 1));
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
      await tester.pumpAndSettle();
      debugPrint('⏳ Attendo il caricamento completo dell\'itinerario...');



      //================= STEP 8 Apri una card ============================

      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(ItineraryList), findsOneWidget);
      debugPrint('✅ ItineraryList trovata');

      await tester.pumpAndSettle(const Duration(seconds: 1));
      final cardFinder = find.byType(Card).first;
      expect(cardFinder, findsOneWidget);
      debugPrint('✅ Card trovata nell\'itinerario');


      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(cardFinder);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('✅ Card tappata, apertura PlaceDetail...');

      expect(find.byType(PlaceDetail), findsOneWidget);
      debugPrint('✅ PlaceDetail aperto con successo');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      final placeDetailFinder = find.byType(PlaceDetail);

      // Drag verso il basso di 500 pixel
      await tester.drag(placeDetailFinder, const Offset(0, 500));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      debugPrint('✅ PlaceDetail chiuso (drag verso il basso)');


      // Verifica che il PlaceDetail sia chiuso
      expect(find.byType(PlaceDetail), findsNothing);
      debugPrint('✅ PlaceDetail non più presente');


      //================= STEP 9 Salva un itinerario ============================

      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      debugPrint('✅ Scroll verso il basso eseguito');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Trova il FloatingActionButton per salvare
      final saveFab = find.byWidgetPredicate(
            (widget) =>
        widget is FloatingActionButton &&
            widget.child is Icon &&
            (widget.child as Icon).icon == Icons.save_alt,
      );
      expect(saveFab, findsOneWidget);
      debugPrint('✅ FloatingActionButton "Salva" trovato');


      // Tap sul FAB
      await tester.tap(saveFab);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      debugPrint('✅ FAB "Salva" premuto');


      expect(find.byType(SaveItineraryDialog), findsOneWidget);
      expect(find.text('Salva Itinerario'), findsOneWidget);
      debugPrint('✅ Dialog "Salva Itinerario" aperto');

      // Verifica presenza campo di testo
      final nameField = find.byWidgetPredicate(
            (widget) =>
        widget is TextField &&
            widget.decoration?.labelText == 'Nome Itinerario',
      );
      expect(nameField, findsOneWidget);
      debugPrint('✅ Campo "Nome Itinerario" trovato');

      // Inserisci il nome "Viaggio Roma"
      await tester.enterText(nameField, 'Viaggio Roma');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      debugPrint('✏️ Nome "Viaggio Roma" inserito');


      // Trova e premi il pulsante "Salva"
      final saveButton = find.widgetWithText(ElevatedButton, 'Salva');
      expect(saveButton, findsOneWidget);
      debugPrint('✅ Pulsante "Salva" trovato');

      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      debugPrint('✅ Pulsante "Salva" premuto');

      //================= STEP 10 Naviga alla schermata Archivio ==============================

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Trova il BottomNavigationBar
      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);
      debugPrint('✅ BottomNavigationBar trovata');


      // Trova l'icona "Archivio"
      final archivioBnb = find.descendant(
        of: bottomNavBar,
        matching: find.byIcon(Icons.history),
      );
      expect(archivioBnb, findsOneWidget);
      debugPrint('✅ Icona "Archivio" trovata nella bottom navigation bar');

      // Tap sull'icona Archivio
      await tester.tap(archivioBnb);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('✅ Navigato alla schermata Archivio');


      // Verifica che la schermata Archivio sia caricata
      expect(find.byType(HistoryScreen), findsOneWidget);
      debugPrint('✅ HistoryScreen caricata con successo');


      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verifica presenza dell'itinerario salvato
      expect(find.text('Viaggio Roma'), findsOneWidget);
      debugPrint('✅ Itinerario "Viaggio Roma" trovato nella lista');

      //================= STEP 11 Apri l'itinerario salvato ==============================

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Trova la card dell'itinerario "Viaggio Roma"
      final itineraryCard = find.ancestor(
        of: find.text('Viaggio Roma'),
        matching: find.byType(Card),
      );
      expect(itineraryCard, findsOneWidget);
      debugPrint('✅ Card itinerario "Viaggio Roma" trovata');


      // Tap sulla card per aprire l'itinerario
      await tester.tap(itineraryCard);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Card tappata, apertura itinerario...');


      expect(find.byType(ItineraryList), findsOneWidget);
      debugPrint('✅ Itinerario salvato aperto con successo');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Ritorna alla schermata Archivio
      await tester.tap(archivioBnb);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('✅ Ritorno alla schermata Archivio');

      expect(find.byType(HistoryScreen), findsOneWidget);
      debugPrint('✅ HistoryScreen nuovamente aperta');

      //================= STEP 12 Elimina tutti gli itinerari ==============================

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Trova il pulsante "Elimina tutti"
      final deleteAllButton = find.byWidgetPredicate(
            (widget) =>
        widget is IconButton &&
            widget.icon is Icon &&
            (widget.icon as Icon).icon == Icons.delete_sweep,
      );
      expect(deleteAllButton, findsOneWidget);
      debugPrint('✅ Pulsante "Elimina tutti" trovato');


      // Tap sul pulsante elimina tutti
      await tester.tap(deleteAllButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('✅ Pulsante "Elimina tutti" premuto');


      // Verifica apertura dialog di conferma
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Attenzione'), findsOneWidget);
      expect(find.textContaining('Vuoi eliminare tutti gli itinerari'), findsOneWidget);
      debugPrint('✅ Dialog di conferma eliminazione aperto');


      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verifica presenza pulsante "Elimina Tutto"
      final confirmDeleteButton = find.text('Elimina Tutto');
      expect(confirmDeleteButton, findsOneWidget);
      debugPrint('✅ Pulsante "Elimina Tutto" trovato');


      // Tap su "Elimina Tutto"
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Confermata eliminazione di tutti gli itinerari');


      // Verifica chiusura dialog
      expect(find.byType(AlertDialog), findsNothing);
      debugPrint('✅ Dialog chiuso');


      // Attendi che lo SnackBar scompaia
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verifica che la schermata mostri lo stato vuoto
      expect(find.text('Nessun viaggio salvato'), findsOneWidget);
      debugPrint('✅ Archivio vuoto');


      debugPrint('🎉 Test completato con successo! Tutti gli step eseguiti.');

    });
  });
}
