import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:cicer_ai/models/saved_itinerary.dart';


class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // Configurazione database
  static const String _databaseName = 'cicer_ai.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'saved_itineraries';
  static const String _columnId = 'id';
  static const String _columnName = 'name';
  static const String _columnSavedAt = 'saved_at';
  static const String _columnItineraryJson = 'itinerary_json';

  // Inizializzazione
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    debugPrint(' Inizializzazione database...');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint(' Creazione tabella $_tableName...');
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnName TEXT NOT NULL,
        $_columnSavedAt TEXT NOT NULL,
        $_columnItineraryJson TEXT NOT NULL
      )
    ''');
    debugPrint('Tabella creata con successo');
  }

  // OPERAZIONI CRUD
  Future<int> saveItinerary(SavedItinerary itinerary) async {
    if (itinerary.name.trim().isEmpty) {
      throw Exception('Il nome dell\'itinerario non può essere vuoto');
    }
    if (itinerary.name.trim().length < 3) {
      throw Exception('Il nome deve essere di almeno 3 caratteri');
    }

    try {
      final db = await database;
      final id = await db.insert(
        _tableName,
        itinerary.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Itinerario "${itinerary.name}" salvato con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Errore salvataggio: $e');
      rethrow;
    }
  }


  Future<List<SavedItinerary>> getAllItineraries() async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        orderBy: '$_columnSavedAt DESC',
      );
      debugPrint('Recuperati ${maps.length} itinerari');
      return maps.map((m) => SavedItinerary.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Errore recupero itinerari: $e');
      return [];
    }
  }


  Future<SavedItinerary?> getItineraryById(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: '$_columnId = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        debugPrint('Itinerario $id non trovato');
        return null;
      }

      return SavedItinerary.fromMap(maps.first);
    } catch (e) {
      debugPrint('Errore recupero itinerario $id: $e');
      return null;
    }
  }


  Future<bool> updateItinerary(SavedItinerary itinerary) async {
    if (itinerary.id == null) {
      throw Exception('Impossibile aggiornare: ID mancante');
    }

    try {
      final db = await database;
      final count = await db.update(
        _tableName,
        itinerary.toMap(),
        where: '$_columnId = ?',
        whereArgs: [itinerary.id],
      );
      debugPrint('Itinerario ${itinerary.id} aggiornato');
      return count > 0;
    } catch (e) {
      debugPrint('Errore aggiornamento: $e');
      return false;
    }
  }


  Future<bool> deleteItinerary(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        _tableName,
        where: '$_columnId = ?',
        whereArgs: [id],
      );
      debugPrint('Itinerario $id eliminato');
      return count > 0;
    } catch (e) {
      debugPrint('Errore eliminazione: $e');
      return false;
    }
  }


  Future<bool> deleteAllItineraries() async {
    try {
      final db = await database;
      await db.delete(_tableName);
      debugPrint('Tutti gli itinerari eliminati');
      return true;
    } catch (e) {
      debugPrint('Errore eliminazione totale: $e');
      return false;
    }
  }

  // UTILITY
  Future<bool> existsWithName(String name) async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM $_tableName WHERE LOWER($_columnName) = ?',
          [name.trim().toLowerCase()],
        ),
      );
      return (count ?? 0) > 0;
    } catch (e) {
      debugPrint('Errore verifica nome: $e');
      return false;
    }
  }

  // numero totale di itinerari salvati
  Future<int> getCount() async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
      );
      return count ?? 0;
    } catch (e) {
      debugPrint('Errore conteggio: $e');
      return 0;
    }
  }

  Future<List<SavedItinerary>> searchByName(String query) async {
    if (query.trim().isEmpty) {
      return getAllItineraries();
    }

    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: '$_columnName LIKE ?',
        whereArgs: ['%${query.trim()}%'],
        orderBy: '$_columnSavedAt DESC',
      );
      debugPrint('Trovati ${maps.length} risultati per "$query"');
      return maps.map((m) => SavedItinerary.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Errore ricerca: $e');
      return [];
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    debugPrint('Database chiuso');
  }
}