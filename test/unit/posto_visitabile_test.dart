import 'package:flutter_test/flutter_test.dart';
import 'package:cicer_ai/models/itinerary/posto_visitabile.dart';
import 'package:cicer_ai/models/itinerary/coordinate.dart';

void main() {
  group('PostoVisitabile - Test Creazione', () {
    test('Crea attrazione con tutti i dati', () {
      final coordinate = Coordinate(lat: 41.9028, lng: 12.4964);

      final posto = PostoVisitabile(
        nome: 'Colosseo',
        descrizione: 'Antico anfiteatro romano',
        orarioInizio: '09:00',
        orarioFine: '17:00',
        coordinate: coordinate,
        wikipediaTitle: 'Colosseo',
        tipo: TipoPosto.attrazione,
      );

      expect(posto.nome, 'Colosseo');
      expect(posto.descrizione, 'Antico anfiteatro romano');
      expect(posto.orarioInizio, '09:00');
      expect(posto.orarioFine, '17:00');
      expect(posto.coordinate, coordinate);
      expect(posto.wikipediaTitle, 'Colosseo');
      expect(posto.tipo, TipoPosto.attrazione);
      expect(posto.isAttrazione, isTrue);
      expect(posto.isPausa, isFalse);
    });

    test('Crea pausa pranzo senza coordinate', () {
      final posto = PostoVisitabile(
        nome: 'Pausa Pranzo',
        descrizione: 'Pranzo in zona Trastevere',
        orarioInizio: '13:00',
        orarioFine: '14:30',
        tipo: TipoPosto.pausa,
      );

      expect(posto.nome, 'Pausa Pranzo');
      expect(posto.coordinate, isNull);
      expect(posto.wikipediaTitle, isNull);
      expect(posto.tipo, TipoPosto.pausa);
      expect(posto.isPausa, isTrue);
      expect(posto.isAttrazione, isFalse);
    });
  });

  group('PostoVisitabile - Test fromJson', () {
    test('Parsing JSON per attrazione', () {
      final json = {
        'nome': 'Fontana di Trevi',
        'descrizione': 'Famosa fontana barocca',
        'orario_inizio': '08:00',
        'orario_fine': '20:00',
        'coordinate': {'lat': 41.9009, 'lng': 12.4833},
        'wikipedia_title': 'Fontana_di_Trevi',
        'wikipedia_lang': 'it',
        'tipo': 'attrazione',
      };

      final posto = PostoVisitabile.fromJson(json);

      expect(posto.nome, 'Fontana di Trevi');
      expect(posto.descrizione, 'Famosa fontana barocca');
      expect(posto.orarioInizio, '08:00');
      expect(posto.orarioFine, '20:00');
      expect(posto.coordinate, isNotNull);
      expect(posto.wikipediaTitle, 'Fontana_di_Trevi');
      expect(posto.isAttrazione, isTrue);
    });

    test('Parsing JSON per pausa', () {
      final json = {
        'nome': 'Cena in Zona Centro',
        'descrizione': 'Cena tipica romana',
        'orario_inizio': '20:00',
        'orario_fine': '21:30',
        'tipo': 'pausa',
      };

      final posto = PostoVisitabile.fromJson(json);

      expect(posto.nome, 'Cena in Zona Centro');
      expect(posto.coordinate, isNull);
      expect(posto.isPausa, isTrue);
    });

    test('Parsing gestisce tipo come "pause" (lingua inglese)', () {
      final json = {
        'nome': 'Lunch Break',
        'descrizione': 'Typical lunch',
        'orario_inizio': '12:30',
        'orario_fine': '14:00',
        'tipo': 'pause',
      };

      final posto = PostoVisitabile.fromJson(json);

      expect(posto.isPausa, isTrue);
      expect(posto.isAttrazione, isFalse);
    });
  });

  group('PostoVisitabile - Test Calcolo Durata', () {
    test('Calcola durata correttamente (1 ora)', () {
      final posto = PostoVisitabile(
        nome: 'Pantheon',
        descrizione: 'Tempio romano',
        orarioInizio: '10:00',
        orarioFine: '11:00',
      );

      expect(posto.durataInMinuti, 60);
    });

    test('Calcola durata correttamente (2 ore e 30 minuti)', () {
      final posto = PostoVisitabile(
        nome: 'Musei Vaticani',
        descrizione: 'Complesso museale',
        orarioInizio: '09:00',
        orarioFine: '11:30',
      );

      expect(posto.durataInMinuti, 150);
    });

    test('Calcola durata per pausa pranzo (1.5 ore)', () {
      final posto = PostoVisitabile(
        nome: 'Pausa Pranzo',
        descrizione: 'Pranzo',
        orarioInizio: '13:00',
        orarioFine: '14:30',
        tipo: TipoPosto.pausa,
      );

      expect(posto.durataInMinuti, 90);
    });

    test('Restituisce null se formato orario non valido', () {
      final posto = PostoVisitabile(
        nome: 'Test',
        descrizione: 'Test',
        orarioInizio: 'invalid',
        orarioFine: '11:00',
      );

      expect(posto.durataInMinuti, isNull);
    });
  });

  group('PostoVisitabile - Test Proprietà Derivate', () {
    test('hasWikipediaData è true se wikipedia_title è presente', () {
      final posto = PostoVisitabile(
        nome: 'Colosseo',
        descrizione: 'Anfiteatro',
        orarioInizio: '09:00',
        orarioFine: '17:00',
        wikipediaTitle: 'Colosseo',
      );

      expect(posto.hasWikipediaData, isTrue);
    });

    test('hasWikipediaData è false se wikipedia_title è null', () {
      final posto = PostoVisitabile(
        nome: 'Posto Generico',
        descrizione: 'Descrizione',
        orarioInizio: '10:00',
        orarioFine: '12:00',
      );

      expect(posto.hasWikipediaData, isFalse);
    });

    test('hasImage è true se urlImmagine è presente', () {
      final posto = PostoVisitabile(
        nome: 'Colosseo',
        descrizione: 'Anfiteatro',
        orarioInizio: '09:00',
        orarioFine: '17:00',
        urlImmagine: 'https://example.com/colosseo.jpg',
      );

      expect(posto.hasImage, isTrue);
    });

    test('hasImage è false se urlImmagine è vuota', () {
      final posto = PostoVisitabile(
        nome: 'Posto Senza Foto',
        descrizione: 'Descrizione',
        orarioInizio: '10:00',
        orarioFine: '12:00',
        urlImmagine: '',
      );

      expect(posto.hasImage, isFalse);
    });

    test('shouldHaveMarker è true per attrazione con coordinate', () {
      final posto = PostoVisitabile(
        nome: 'Colosseo',
        descrizione: 'Anfiteatro',
        orarioInizio: '09:00',
        orarioFine: '17:00',
        coordinate: Coordinate(lat: 41.9028, lng: 12.4964),
        tipo: TipoPosto.attrazione,
      );

      expect(posto.shouldHaveMarker, isTrue);
    });

    test('shouldHaveMarker è false per pausa', () {
      final posto = PostoVisitabile(
        nome: 'Pranzo',
        descrizione: 'Pausa pranzo',
        orarioInizio: '13:00',
        orarioFine: '14:30',
        tipo: TipoPosto.pausa,
      );

      expect(posto.shouldHaveMarker, isFalse);
    });

    test('shouldHaveMarker è false per attrazione senza coordinate', () {
      final posto = PostoVisitabile(
        nome: 'Attrazione Generica',
        descrizione: 'Senza coordinate',
        orarioInizio: '10:00',
        orarioFine: '12:00',
        tipo: TipoPosto.attrazione,
      );

      expect(posto.shouldHaveMarker, isFalse);
    });
  });

  group('PostoVisitabile - Test toJson', () {
    test('Serializza attrazione correttamente', () {
      final posto = PostoVisitabile(
        nome: 'Colosseo',
        descrizione: 'Anfiteatro romano',
        orarioInizio: '09:00',
        orarioFine: '17:00',
        coordinate: Coordinate(lat: 41.9028, lng: 12.4964),
        wikipediaTitle: 'Colosseo',
        urlImmagine: 'https://example.com/colosseo.jpg',
        tipo: TipoPosto.attrazione,
      );

      final json = posto.toJson();

      expect(json['nome'], 'Colosseo');
      expect(json['descrizione'], 'Anfiteatro romano');
      expect(json['orario_inizio'], '09:00');
      expect(json['orario_fine'], '17:00');
      expect(json['coordinate'], isNotNull);
      expect(json['wikipedia_title'], 'Colosseo');
      expect(json['url_immagine'], 'https://example.com/colosseo.jpg');
      expect(json['tipo'], 'attrazione');
    });

    test('Serializza pausa correttamente', () {
      final posto = PostoVisitabile(
        nome: 'Pausa Pranzo',
        descrizione: 'Pranzo in zona',
        orarioInizio: '13:00',
        orarioFine: '14:30',
        tipo: TipoPosto.pausa,
      );

      final json = posto.toJson();

      expect(json['tipo'], 'pausa');
      expect(json['coordinate'], isNull);
    });
  });
}