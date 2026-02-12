import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';

class SQLHelper {
  static Future<sql.Database> db() async {
    final dbPath = await sql.getDatabasesPath();
    final path = join(dbPath, 'fasihah_diary.db');

    return sql.openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await createTables(db);
        await createUserTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE diaries ADD COLUMN title TEXT;");
        }
        if (oldVersion < 3) {
          await db.execute("CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT)");
        }
      },
    );
  }

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE diaries(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        feeling TEXT,
        thoughts TEXT,
        activity TEXT,
        place TEXT,
        weather TEXT,
        withWhom TEXT,
        createdAt TEXT NOT NULL,
        photoPath TEXT
      )
    """);
  }

  static Future<void> createUserTable(sql.Database database) async {
    await database.execute("""
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        username TEXT UNIQUE,
        password TEXT
      )
    """);
  }

  static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await SQLHelper.db();

    // Check if user exists
    var result = await db.query(
      'users',
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      await db.insert('users', {'username': username, 'password': password});
      return {'username': username, 'password': password};
    }
  }

  static Future<int> createDiary({
    String? title,
    required String feeling,
    required String thoughts,
    required String activity,
    required String place,
    required String weather,
    required String withWhom,
    required String createdAt,
    String? photoPath
  }) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'feeling': feeling,
      'thoughts': thoughts,
      'activity': activity,
      'place': place,
      'weather': weather,
      'withWhom': withWhom,
      'photoPath': photoPath ?? '',
      'createdAt': createdAt,
    };
    return await db.insert('diaries', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<int> updateDiary({
    required int id,
    String? title,
    required String feeling,
    required String thoughts,
    required String activity,
    required String place,
    required String weather,
    required String withWhom,
    required String createdAt,
    String? photoPath
  }) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'feeling': feeling,
      'thoughts': thoughts,
      'activity': activity,
      'place': place,
      'weather': weather,
      'withWhom': withWhom,
      'createdAt': createdAt,
      'photoPath': photoPath ?? '',
    };
    return await db.update('diaries', data, where: "id = ?", whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getDiaries() async {
    final db = await SQLHelper.db();
    final data = await db.query('diaries', orderBy: "createdAt DESC");

    return data.map((entry) {
      return {
        'id': entry['id'],
        'title': entry['title'] ?? 'Untitled',
        'feeling': entry['feeling'] ?? '',
        'thoughts': entry['thoughts'] ?? '',
        'activity': entry['activity'] ?? '',
        'place': entry['place'] ?? '',
        'weather': entry['weather'] ?? '',
        'withWhom': entry['withWhom'] ?? '',
        'createdAt': entry['createdAt'],
        'photoPath': entry['photoPath'] ?? '',
      };
    }).toList();
  }

  static Future<void> deleteDiary(int id) async {
    final db = await SQLHelper.db();
    await db.delete('diaries', where: "id = ?", whereArgs: [id]);
  }
}