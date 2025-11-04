import 'package:flutter_test/flutter_test.dart';
import 'package:cicer_ai/models/itinerary/coordinate.dart';

void main() {
  group('Coordinate - Test Creazione e Validazione', () {
    test('Crea coordinate valide', () {
      final coordinate = Coordinate(lat: 41.9028, lng: 12.4964);

      expect(coordinate.lat, 41.9028);
      expect(coordinate.lng, 12.4964);
    });

    test('Crea coordinate da JSON', () {
      final json = {'lat': 45.4642, 'lng': 9.1900};
      final coordinate = Coordinate.fromJson(json);

      expect(coordinate.lat, 45.4642);
      expect(coordinate.lng, 9.1900);
    });

    test('toJson serializza correttamente', () {
      final coordinate = Coordinate(lat: 40.8518, lng: 14.2681);
      final json = coordinate.toJson();

      expect(json['lat'], 40.8518);
      expect(json['lng'], 14.2681);
    });

    test('Gestisce valori di default se JSON ha valori null', () {
      final json = {'lat': null, 'lng': null};
      final coordinate = Coordinate.fromJson(json);

      expect(coordinate.lat, 0.0);
      expect(coordinate.lng, 0.0);
    });

    test('toString formatta correttamente', () {
      final coordinate = Coordinate(lat: 41.9028, lng: 12.4964);
      final string = coordinate.toString();

      expect(string, 'Coordinate(lat: 41.9028, lng: 12.4964)');
    });
  });

  group('Coordinate - Test Uguaglianza', () {
    test('Due coordinate con stessi valori sono uguali', () {
      final coord1 = Coordinate(lat: 41.9028, lng: 12.4964);
      final coord2 = Coordinate(lat: 41.9028, lng: 12.4964);

      expect(coord1, equals(coord2));
    });

    test('Due coordinate con valori diversi non sono uguali', () {
      final coord1 = Coordinate(lat: 41.9028, lng: 12.4964);
      final coord2 = Coordinate(lat: 45.4642, lng: 9.1900);

      expect(coord1, isNot(equals(coord2)));
    });

    test('hashCode è uguale per coordinate uguali', () {
      final coord1 = Coordinate(lat: 41.9028, lng: 12.4964);
      final coord2 = Coordinate(lat: 41.9028, lng: 12.4964);

      expect(coord1.hashCode, coord2.hashCode);
    });

    test('hashCode è diverso per coordinate diverse', () {
      final coord1 = Coordinate(lat: 41.9028, lng: 12.4964);
      final coord2 = Coordinate(lat: 45.4642, lng: 9.1900);

      expect(coord1.hashCode, isNot(equals(coord2.hashCode)));
    });
  });
}