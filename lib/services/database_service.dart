// // lib/services/database_service.dart
// //import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/user.dart';
// import '../models/event.dart';
// import '../models/gift.dart';
//
// class DatabaseService {
//   static final DatabaseService _instance = DatabaseService._internal();
//   Database? _database;
//
//   factory DatabaseService() {
//     return _instance;
//   }
//
//   DatabaseService._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'hedieaty.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }
//
//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE users (
//         id TEXT PRIMARY KEY,
//         name TEXT,
//         email TEXT,
//         preferences TEXT
//       )
//     ''');
//     await db.execute('''
//       CREATE TABLE events (
//         id TEXT PRIMARY KEY,
//         name TEXT,
//         date TEXT,
//         location TEXT,
//         description TEXT,
//         userId TEXT,
//         FOREIGN KEY (userId) REFERENCES users (id)
//       )
//     ''');
//     await db.execute('''
//       CREATE TABLE gifts (
//         id TEXT PRIMARY KEY,
//         name TEXT,
//         description TEXT,
//         category TEXT,
//         price REAL,
//         status TEXT,
//         eventId TEXT,
//         FOREIGN KEY (eventId) REFERENCES events (id)
//       )
//     ''');
//     await db.execute('''
//       CREATE TABLE friends (
//         userId TEXT,
//         friendId TEXT,
//         PRIMARY KEY (userId, friendId),
//         FOREIGN KEY (userId) REFERENCES users (id),
//         FOREIGN KEY (friendId) REFERENCES users (id)
//       )
//     ''');
//   }
//
//   Future<void> saveFriends(List<UserModel> friends) async {
//     final db = await database;
//     for (var friend in friends) {
//       await db.insert('users', friend.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
//     }
//   }
// }