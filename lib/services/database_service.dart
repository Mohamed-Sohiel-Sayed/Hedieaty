import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/gift.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService {
  Database? _database;
  final _controller = BehaviorSubject<List<Gift>>();

  DatabaseService() {
    _initDB();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    await _initDB();
    return _database!;
  }

  Future<void> _initDB() async {
    String path = join(await getDatabasesPath(), 'hedieaty.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
    // After initializing DB, load initial data
    await _loadPrivateGifts();
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gifts(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        eventId TEXT,
        isPublic INTEGER,
        isPledged INTEGER,
        status TEXT,
        imageUrl TEXT,
        userId TEXT,
        pledgedBy TEXT
      )
    ''');
  }

  Future<void> _loadPrivateGifts() async {
    List<Gift> gifts = await getAllPrivateGifts();
    _controller.add(gifts);
  }

  Future<void> insertGift(Gift gift) async {
    final db = await database;
    await db.insert(
      'gifts',
      gift.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _loadPrivateGifts();
  }

  Future<void> updateGift(Gift gift) async {
    final db = await database;
    await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
    await _loadPrivateGifts();
  }

  Future<void> deleteGift(String giftId, String userId) async {
    final db = await database;
    await db.delete(
      'gifts',
      where: 'id = ? AND userId = ?',
      whereArgs: [giftId, userId],
    );
    await _loadPrivateGifts();
  }

  // Get private gifts by user and event
  Future<List<Gift>> getPrivateGiftsByEvent(String userId, String eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'userId = ? AND eventId = ? AND isPublic = ?',
      whereArgs: [userId, eventId, 0],
    );

    return List.generate(maps.length, (i) {
      return Gift.fromMap(maps[i]);
    });
  }

  // Get all private gifts
  Future<List<Gift>> getAllPrivateGifts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'isPublic = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return Gift.fromMap(maps[i]);
    });
  }

  // Stream of private gifts
  Stream<List<Gift>> getPrivateGiftsStream(String userId, String eventId) async* {
    // Listen to the BehaviorSubject stream
    await for (List<Gift> gifts in _controller.stream) {
      List<Gift> filteredGifts = gifts
          .where((gift) =>
      gift.userId == userId &&
          gift.eventId == eventId &&
          !gift.isPublic)
          .toList();
      yield filteredGifts;
    }
  }

  void dispose() {
    _controller.close();
  }
}