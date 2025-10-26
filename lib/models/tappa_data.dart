import 'package:uuid/uuid.dart';
import 'itinerary/coordinate.dart';


class TappaData {
  final String id;
  final String citta;
  final DateTime? dataInizio;
  final DateTime? dataFine;
  final String oraInizio;
  final String oraFine;
  final Coordinate? coordinate;

  TappaData({
    String? id,
    this.citta = '',
    this.dataInizio,
    this.dataFine,
    this.oraInizio = '',
    this.oraFine = '',
    this.coordinate,
  }) : id = id ?? const Uuid().v4();

  TappaData copyWith({
    String? citta,
    DateTime? dataInizio,
    DateTime? dataFine,
    String? oraInizio,
    String? oraFine,
    Coordinate? coordinate,
  }) {
    return TappaData(
      id: id,
      citta: citta ?? this.citta,
      dataInizio: dataInizio ?? this.dataInizio,
      dataFine: dataFine ?? this.dataFine,
      oraInizio: oraInizio ?? this.oraInizio,
      oraFine: oraFine ?? this.oraFine,
      coordinate: coordinate ?? this.coordinate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'citta': citta,
      'dataInizio': dataInizio?.toIso8601String(),
      'dataFine': dataFine?.toIso8601String(),
      'oraInizio': oraInizio,
      'oraFine': oraFine,
      'coordinate': coordinate?.toJson(),
    };
  }

}
