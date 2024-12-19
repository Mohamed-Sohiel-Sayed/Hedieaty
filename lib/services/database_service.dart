import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/gift.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gifts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gifts (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        imageUrl TEXT,
        status TEXT,
        eventId TEXT,
        isPledged INTEGER,
        pledgedBy TEXT,
        isPublic INTEGER,
        userId TEXT
      )
    ''');
  }

  Future<void> insertGift(Gift gift) async {
    final db = await database;
    await db.insert(
      'gifts',
      gift.toMapForDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Gift>> getPrivateGifts(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'isPublic = ? AND userId = ?',
      whereArgs: [0, userId],
    );
    return List.generate(maps.length, (i) {
      return Gift.fromMap(maps[i]);
    });
  }

  Future<List<Gift>> getPrivateGiftsByEvent(String userId, String eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'isPublic = ? AND userId = ? AND eventId = ?',
      whereArgs: [0, userId, eventId],
    );
    return List.generate(maps.length, (i) {
      return Gift.fromMap(maps[i]);
    });
  }

  Future<void> updateGift(Gift gift) async {
    final db = await database;
    await db.update(
      'gifts',
      gift.toMapForDatabase(),
      where: 'id = ? AND userId = ?',
      whereArgs: [gift.id, gift.userId],
    );
  }

  Future<void> deleteGift(String id, String userId) async {
    final db = await database;
    await db.delete(
      'gifts',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }
}