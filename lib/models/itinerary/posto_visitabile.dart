import 'coordinate.dart';

class PostoVisitabile {
  final String nome;
  final String descrizione;
  final String orarioInizio;
  final String orarioFine;
  final Coordinate? coordinate;
  final String? wikipediaTitle;
  final String? wikipediaLang;
  String? urlImmagine;

  PostoVisitabile({
    required this.nome,
    required this.descrizione,
    required this.orarioInizio,
    required this.orarioFine,
    this.coordinate,
    this.wikipediaTitle,
    this.wikipediaLang = 'it',
    this.urlImmagine = '',
  });

  // Crea PostoVisitabile da JSON
  factory PostoVisitabile.fromJson(Map<String, dynamic> json) {
    return PostoVisitabile(
      nome: json['nome'] ?? '',
      descrizione: json['descrizione'] ?? '',
      orarioInizio: json['orario_inizio'] ?? '',
      orarioFine: json['orario_fine'] ?? '',
      coordinate: json['coordinate'] != null
          ? Coordinate.fromJson(json['coordinate'])
          : null,
      wikipediaTitle: json['wikipedia_title'],
      wikipediaLang: json['wikipedia_lang'] ?? 'it',
      urlImmagine: json['url_immagine'] ?? '',
    );
  }

  // Converte PostoVisitabile in JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descrizione': descrizione,
      'orario_inizio': orarioInizio,
      'orario_fine': orarioFine,
      'coordinate': coordinate?.toJson(),
      'wikipedia_title': wikipediaTitle,
      'wikipedia_lang': wikipediaLang,
      'url_immagine': urlImmagine,
    };
  }

  // Calcola la durata della visita
  int? get durataInMinuti {
    try {
      final inizioParts = orarioInizio.split(':');
      final fineParts = orarioFine.split(':');

      final inizioMinuti = int.parse(inizioParts[0]) * 60 + int.parse(inizioParts[1]);
      final fineMinuti = int.parse(fineParts[0]) * 60 + int.parse(fineParts[1]);

      return fineMinuti - inizioMinuti;
    } catch (e) {
      return null;
    }
  }
  // Verifica se il posto ha dati Wikipedia
  bool get hasWikipediaData => wikipediaTitle != null && wikipediaTitle!.isNotEmpty;

  // Verifica se l'immagine è stata caricata
  bool get hasImage => urlImmagine != null && urlImmagine!.isNotEmpty;


  @override
  String toString() => 'PostoVisitabile(nome: $nome, orario: $orarioInizio-$orarioFine)';
}