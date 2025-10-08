import 'package:uuid/uuid.dart';


class TappaData {
  final String id;
  final String citta;
  final DateTime? dataInizio;
  final DateTime? dataFine;
  final String oraInizio;
  final String oraFine;

  TappaData({
    String? id,
    this.citta = '',
    this.dataInizio,
    this.dataFine,
    this.oraInizio = '',
    this.oraFine = '',
  }) : id = id ?? const Uuid().v4();

  TappaData copyWith({
    String? citta,
    DateTime? dataInizio,
    DateTime? dataFine,
    String? oraInizio,
    String? oraFine,
  }) {
    return TappaData(
      id: id,
      citta: citta ?? this.citta,
      dataInizio: dataInizio ?? this.dataInizio,
      dataFine: dataFine ?? this.dataFine,
      oraInizio: oraInizio ?? this.oraInizio,
      oraFine: oraFine ?? this.oraFine,
    );
  }
}
