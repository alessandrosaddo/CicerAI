import 'citta_itinerario.dart';

class ItineraryResponse {
  final List<CittaItinerario> itinerario;

  ItineraryResponse({
    required this.itinerario,
  });

  // Crea ItineraryResponse da JSON
  factory ItineraryResponse.fromJson(Map<String, dynamic> json) {
    return ItineraryResponse(
      itinerario: (json['itinerario'] as List<dynamic>?)
          ?.map((citta) => CittaItinerario.fromJson(citta as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  // Converte ItineraryResponse in JSON
  Map<String, dynamic> toJson() {
    return {
      'itinerario': itinerario.map((c) => c.toJson()).toList(),
    };
  }

  // Calcola il numero totale di città nel viaggio
  int get numeroCitta => itinerario.length;

  // Calcola il numero totale di giorni del viaggio
  int get numeroTotaleGiorni {
    return itinerario.fold(0, (sum, citta) => sum + citta.numeroGiorni);
  }

  // Calcola il numero totale di posti da visitare
  int get numeroTotalePostiDaVisitare {
    return itinerario.fold(0, (sum, citta) => sum + citta.numeroTotalePostiDaVisitare);
  }

  // Verifica se l'itinerario è vuoto
  bool get isEmpty => itinerario.isEmpty;

  // Verifica se l'itinerario è valido (ha almeno una città con posti)
  bool get isValid {
    return itinerario.any((citta) => citta.numeroTotalePostiDaVisitare > 0);
  }

  @override
  String toString() => 'ItineraryResponse(città: ${itinerario.length}, giorni totali: $numeroTotaleGiorni)';
}