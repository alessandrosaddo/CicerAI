import 'package:flutter_test/flutter_test.dart';
import 'package:cicer_ai/models/tappa_data.dart';
import 'package:cicer_ai/models/itinerary/coordinate.dart';

void main() {
  group('TappaData - Test Creazione e Validazione', () {
    test('Crea TappaData vuota con valori di default', () {
      final tappa = TappaData();

      expect(tappa.id, isNotEmpty);
      expect(tappa.citta, isEmpty);
      expect(tappa.dataInizio, isNull);
      expect(tappa.dataFine, isNull);
      expect(tappa.oraInizio, isEmpty);
      expect(tappa.oraFine, isEmpty);
      expect(tappa.coordinate, isNull);
    });

    test('Crea TappaData con dati completi', () {
      final dataInizio = DateTime(2025, 11, 10);
      final dataFine = DateTime(2025, 11, 12);
      final coordinate = Coordinate(lat: 41.9028, lng: 12.4964);

      final tappa = TappaData(
        citta: 'Roma',
        dataInizio: dataInizio,
        dataFine: dataFine,
        oraInizio: '09:00',
        oraFine: '18:00',
        coordinate: coordinate,
      );

      expect(tappa.citta, 'Roma');
      expect(tappa.dataInizio, dataInizio);
      expect(tappa.dataFine, dataFine);
      expect(tappa.oraInizio, '09:00');
      expect(tappa.oraFine, '18:00');
      expect(tappa.coordinate, coordinate);
    });

    test('copyWith mantiene i valori non modificati', () {
      final dataInizio = DateTime(2025, 11, 10);
      final tappa = TappaData(
        citta: 'Milano',
        dataInizio: dataInizio,
        oraInizio: '10:00',
      );

      final tappaAggiornata = tappa.copyWith(
        citta: 'Firenze',
      );

      expect(tappaAggiornata.citta, 'Firenze');
      expect(tappaAggiornata.dataInizio, dataInizio);
      expect(tappaAggiornata.oraInizio, '10:00');
      expect(tappaAggiornata.id, tappa.id); // L'ID rimane lo stesso
    });

    test('copyWith aggiorna solo i campi specificati', () {
      final tappa = TappaData(
        citta: 'Napoli',
        oraInizio: '08:00',
      );

      final tappaAggiornata = tappa.copyWith(
        oraFine: '20:00',
      );

      expect(tappaAggiornata.citta, 'Napoli');
      expect(tappaAggiornata.oraInizio, '08:00');
      expect(tappaAggiornata.oraFine, '20:00');
    });

    test('toJson serializza correttamente', () {
      final dataInizio = DateTime(2025, 11, 10);
      final dataFine = DateTime(2025, 11, 12);
      final coordinate = Coordinate(lat: 41.9028, lng: 12.4964);

      final tappa = TappaData(
        citta: 'Roma',
        dataInizio: dataInizio,
        dataFine: dataFine,
        oraInizio: '09:00',
        oraFine: '18:00',
        coordinate: coordinate,
      );

      final json = tappa.toJson();

      expect(json['citta'], 'Roma');
      expect(json['dataInizio'], dataInizio.toIso8601String());
      expect(json['dataFine'], dataFine.toIso8601String());
      expect(json['oraInizio'], '09:00');
      expect(json['oraFine'], '18:00');
      expect(json['coordinate'], isNotNull);
      expect(json['coordinate']['lat'], 41.9028);
      expect(json['coordinate']['lng'], 12.4964);
    });

    test('toJson gestisce correttamente valori null', () {
      final tappa = TappaData(citta: 'Venezia');

      final json = tappa.toJson();

      expect(json['citta'], 'Venezia');
      expect(json['dataInizio'], isNull);
      expect(json['dataFine'], isNull);
      expect(json['coordinate'], isNull);
    });
  });

  group('TappaData - Test ID Univoci', () {
    test('Due TappaData hanno ID diversi', () {
      final tappa1 = TappaData(citta: 'Bologna');
      final tappa2 = TappaData(citta: 'Torino');

      expect(tappa1.id, isNot(equals(tappa2.id)));
    });

    test('copyWith mantiene lo stesso ID', () {
      final tappa = TappaData(citta: 'Palermo');
      final tappaCopy = tappa.copyWith(citta: 'Catania');

      expect(tappaCopy.id, tappa.id);
    });
  });
}