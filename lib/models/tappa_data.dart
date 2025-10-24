import 'package:uuid/uuid.dart';


class TappaData {
  final String id;
  final String citta;
  final DateTime? dataInizio;
  final DateTime? dataFine;
  final String oraInizio;
  final String oraFine;
  final double? lat;
  final double? lng;

  TappaData({
    String? id,
    this.citta = '',
    this.dataInizio,
    this.dataFine,
    this.oraInizio = '',
    this.oraFine = '',
    this.lat,
    this.lng,
  }) : id = id ?? const Uuid().v4();

  TappaData copyWith({
    String? citta,
    DateTime? dataInizio,
    DateTime? dataFine,
    String? oraInizio,
    String? oraFine,
    double? lat,
    double? lng,
  }) {
    return TappaData(
      id: id,
      citta: citta ?? this.citta,
      dataInizio: dataInizio ?? this.dataInizio,
      dataFine: dataFine ?? this.dataFine,
      oraInizio: oraInizio ?? this.oraInizio,
      oraFine: oraFine ?? this.oraFine,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'citta': citta,
      'dataInizio': dataInizio?.toIso8601String(),
      'dataFine': dataFine?.toIso8601String(),
      'oraInizio': oraInizio,
      'oraFine': oraFine,
      'coordinate': {
        'lat': lat,
        'lng': lng,
      },
    };
  }

}
