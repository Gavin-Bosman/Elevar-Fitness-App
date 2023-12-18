import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBUtils {
  static Future<Database> init() async {
    String myPath = await getDatabasesPath();

    return openDatabase(path.join(myPath, 'routines_database.db'),
        onCreate: (db, version) async {
      await db.execute('''CREATE TABLE Routines(
          routineName TEXT NOT NULL,
          exerciseName TEXT NOT NULL,
          muscle TEXT NOT NULL,
          heavySetReps INTEGER DEFAULT 0,
          weight FLOAT(6) DEFAULT 0)''');
    }, version: 1);
  }
}