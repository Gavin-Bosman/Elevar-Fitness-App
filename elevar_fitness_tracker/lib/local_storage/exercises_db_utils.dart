import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBUtils {
  static Future<Database> init() async {
    String myPath = await getDatabasesPath();

    return openDatabase(path.join(myPath, 'exercises_database.db'),
        onCreate: (db, version) async {
      await db.execute('''CREATE TABLE Exercises(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          heavySetReps INTEGER,
          weight FLOAT(6))''');
    }, version: 1);
  }
}

/*
static Future<Database> createRoutineDB(String databaseName) async {
  String myPath = await getDatabasesPath();
  String fileName = '${databaseName.toLowerCase()}_database.db';

  return openDatabase(path.join(myPath, fileName),
      onCreate: (db, version) async {
    await db.execute('''CREATE TABLE $databaseName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        muscle TEXT NOT NULL,
        heavySetReps INTEGER,
        weight FLOAT(6))''');
  }, version: 1);
}
*/