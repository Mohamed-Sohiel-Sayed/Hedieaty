// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/event.dart';
// import '../models/gift.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//
//   static Database? _db;
//
//   DatabaseHelper._internal();
//
//   Future<Database> get db async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }
//
//   Future<Database> _initDB() async {
//     String path = join(await getDatabasesPath(), 'hedieaty.db');
//     return await openDatabase(
//       path,
//       version: 2, // Increment version to add new tables
//       onCreate: (db, version) async {
//         // Users Table
//         await db.execute('''
//           CREATE TABLE IF NOT EXISTS users (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT,
//             email TEXT,
//             preferences TEXT
//           )
//         ''');
//
//         // Friends Table
//         await db.execute('''
//           CREATE TABLE IF NOT EXISTS friends (
//             user_id INTEGER,
//             friend_id INTEGER,
//             PRIMARY KEY (user_id, friend_id)
//           )
//         ''');
//
//         // Events Table
//         await db.execute('''
//           CREATE TABLE IF NOT EXISTS events (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT,
//             date TEXT,
//             location TEXT,
//             description TEXT,
//             userId TEXT
//           )
//         ''');
//
//         // Gifts Table
//         await db.execute('''
//           CREATE TABLE IF NOT EXISTS gifts (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT,
//             description TEXT,
//             category TEXT,
//             price REAL,
//             status TEXT,
//             event_id INTEGER,
//             FOREIGN KEY (event_id) REFERENCES events (id)
//           )
//         ''');
//         print("Tables created successfully.");
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 2) {
//           // Add new tables during an upgrade
//           await db.execute('''
//             CREATE TABLE IF NOT EXISTS events (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               name TEXT,
//               date TEXT,
//               location TEXT,
//               description TEXT,
//               userId TEXT
//             )
//           ''');
//
//           await db.execute('''
//             CREATE TABLE IF NOT EXISTS gifts (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               name TEXT,
//               description TEXT,
//               category TEXT,
//               price REAL,
//               status TEXT,
//               event_id INTEGER,
//               FOREIGN KEY (event_id) REFERENCES events (id)
//             )
//           ''');
//         }
//       },
//     );
//   }
//
//   // CRUD for Events
//   Future<int> insertEvent(Event event) async {
//     final dbClient = await db;
//     try {
//       int result = await dbClient.insert('events', event.toMap());
//       print("Event inserted: \$result");
//       return result;
//     } catch (e) {
//       print("Error inserting event: \$e");
//       return -1;
//     }
//   }
//
//   Future<List<Event>> getEvents(String userId) async {
//     final dbClient = await db;
//     try {
//       final result = await dbClient.query('events', where: 'userId = ?', whereArgs: [userId]);
//       print("Events retrieved: \${result.length}");
//       return result.map((e) => Event.fromMap(e)).toList();
//     } catch (e) {
//       print("Error retrieving events: \$e");
//       return [];
//     }
//   }
//
//   Future<int> updateEvent(Event event) async {
//     final dbClient = await db;
//     try {
//       int result = await dbClient.update('events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
//       print("Event updated: \$result");
//       return result;
//     } catch (e) {
//       print("Error updating event: \$e");
//       return -1;
//     }
//   }
//
//   Future<int> deleteEvent(int id) async {
//     final dbClient = await db;
//     try {
//       int result = await dbClient.delete('events', where: 'id = ?', whereArgs: [id]);
//       print("Event deleted: \$result");
//       return result;
//     } catch (e) {
//       print("Error deleting event: \$e");
//       return -1;
//     }
//   }
//
//   // CRUD for Gifts
//   Future<int> insertGift(Gift gift) async {
//     final dbClient = await db;
//     try {
//       int result = await dbClient.insert('gifts', gift.toMap());
//       print("Gift inserted: \$result");
//       return result;
//     } catch (e) {
//       print("Error inserting gift: \$e");
//       return -1;
//     }
//   }
//
//   Future<List<Gift>> getGifts(int eventId) async {
//     final dbClient = await db;
//     try {
//       final result = await dbClient.query('gifts', where: 'event_id = ?', whereArgs: [eventId]);
//       print("Gifts retrieved: \${result.length}");
//       return result.map((g) => Gift.fromMap(g)).toList();
//     } catch (e) {
//       print("Error retrieving gifts: \$e");
//       return [];
//     }
//   }
//
//   Future<int> updateGift(Gift gift) async {
//     final dbClient = await db;
//     try {
//       int result = await dbClient.update('gifts', gift.toMap(), where: 'id = ?', whereArgs: [gift.id]);
//       print("Gift updated: \$result");
//       return result;
//     } catch (e) {
//       print("Error updating gift: \$e");
//       return -1;
//     }
//   }
//
//   Future<int> deleteGift(int id) async {
//     final dbClient = await db;
//     try {
//       int result = await dbClient.delete('gifts', where: 'id = ?', whereArgs: [id]);
//       print("Gift deleted: \$result");
//       return result;
//     } catch (e) {
//       print("Error deleting gift: \$e");
//       return -1;
//     }
//   }
// }
