import 'coordinate.dart';
import 'posto_visitabile.dart';


// ======================== CLASSE GIORNATA ========================
class Giornata {
  final String data;
  final List<PostoVisitabile> posti;

  Giornata({
    required this.data,
    required this.posti,
  });

  // Crea Giornata da JSON
  factory Giornata.fromJson(Map<String, dynamic> json) {
    return Giornata(
      data: json['data'] ?? '',
      posti: (json['posti'] as List<dynamic>?)
          ?.map((posto) => PostoVisitabile.fromJson(posto as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  // Converte Giornata in JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'posti': posti.map((p) => p.toJson()).toList(),
    };
  }

  // Calcola il numero totale di posti da visitare
  int get numeroPosti => posti.length;

  // Calcola la durata totale della giornata in minuti
  int? get durataTotaleInMinuti {
    int? totale = 0;
    for (var posto in posti) {
      final durata = posto.durataInMinuti;
      if (durata == null) return null;
      totale = (totale ?? 0) + durata;
    }
    return totale;
  }

  // Formattazione data
  String get dataFormattata {
    try {
      final DateTime dateTime = DateTime.parse(data);
      final giorni = ['Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato', 'Domenica'];
      final mesi = ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
        'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'];

      return '${giorni[dateTime.weekday - 1]} ${dateTime.day} ${mesi[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return data;
    }
  }

  @override
  String toString() => 'Giornata(data: $data, posti: ${posti.length})';
}



// ======================== CLASSE CITTÀ ITINERARIO ========================

class CittaItinerario {
  final String citta;
  final Coordinate? coordinate;
  final List<Giornata> giornate;

  CittaItinerario({
    required this.citta,
    this.coordinate,
    required this.giornate,
  });

  // Crea CittaItinerario da JSON
  factory CittaItinerario.fromJson(Map<String, dynamic> json) {
    return CittaItinerario(
      citta: json['citta'] ?? '',
      coordinate: json['coordinate'] != null
          ? Coordinate.fromJson(json['coordinate'])
          : null,
      giornate: (json['giornate'] as List<dynamic>?)
          ?.map((giornata) => Giornata.fromJson(giornata as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  // Converte CittaItinerario in JSON
  Map<String, dynamic> toJson() {
    return {
      'citta': citta,
      'coordinate': coordinate?.toJson(),
      'giornate': giornate.map((g) => g.toJson()).toList(),
    };
  }

  // Calcola il numero totale di giorni per città
  int get numeroGiorni => giornate.length;

  // Calcola il numero totale di posti da visitare per città
  int get numeroTotalePostiDaVisitare {
    return giornate.fold(0, (sum, giornata) => sum + giornata.numeroPosti);
  }

  // Ottiene la prima data di visita
  String? get primaData {
    return giornate.isNotEmpty ? giornate.first.data : null;
  }

  // Ottiene l'ultima data di visita
  String? get ultimaData {
    return giornate.isNotEmpty ? giornate.last.data : null;
  }

  @override
  String toString() => 'CittaItinerario(citta: $citta, giorni: ${giornate.length})';
}