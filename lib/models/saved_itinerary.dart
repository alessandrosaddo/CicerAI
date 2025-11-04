import 'package:cicer_ai/models/itinerary/itinerary_response.dart';
import 'dart:convert';


class SavedItinerary {
  final int? id;
  final String name;
  final DateTime savedAt;
  final String itineraryJson;

  SavedItinerary({
    this.id,
    required this.name,
    required this.savedAt,
    required this.itineraryJson,
  });

  // CONVERSIONE DATABASE
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'saved_at': savedAt.toIso8601String(),
      'itinerary_json': itineraryJson,
    };
  }

  factory SavedItinerary.fromMap(Map<String, dynamic> map) {
    return SavedItinerary(
      id: map['id'] as int?,
      name: map['name'] as String,
      savedAt: DateTime.parse(map['saved_at'] as String),
      itineraryJson: map['itinerary_json'] as String,
    );
  }

  // CONVERSIONE ITINERARIO
  factory SavedItinerary.fromItineraryResponse(
      String name,
      ItineraryResponse itinerary,
      ) {
    return SavedItinerary(
      name: name.trim(),
      savedAt: DateTime.now(),
      itineraryJson: jsonEncode(itinerary.toJson()),
    );
  }

  // Converte il JSON salvato in un ItineraryResponse utilizzabile
  ItineraryResponse toItineraryResponse() {
    final Map<String, dynamic> json = jsonDecode(itineraryJson);
    return ItineraryResponse.fromJson(json);
  }

  // UTILITY

  // data user-friendly
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(savedAt);

    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${savedAt.day}/${savedAt.month}/${savedAt.year}';
    }
  }

  SavedItinerary copyWith({
    int? id,
    String? name,
    DateTime? savedAt,
    String? itineraryJson,
  }) {
    return SavedItinerary(
      id: id ?? this.id,
      name: name ?? this.name,
      savedAt: savedAt ?? this.savedAt,
      itineraryJson: itineraryJson ?? this.itineraryJson,
    );
  }

  @override
  String toString() => 'SavedItinerary(id: $id, name: "$name", savedAt: $savedAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedItinerary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}