import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'exercises_db_utils.dart';

/*
  Exercises currently in the database:
  
  List<Map<String, dynamic>> dummyData = [
    {'name':'Dumbell Bicep Curl'},
    {'name':'Barbell Bicep Curl'},
    {'name':'Hammer Curl'},
    {'name':'Lat Pulldown'},
    {'name':'Seated Cable Row'},
    {'name':'Bent-Over Row'},
    {'name':'Lateral Raise'},
    {'name':'Dumbell Shoulder Press'},
    {'name':'Overhead Barbell Press'},
    {'name':'Dumbell Chest Press'},
    {'name':'Bench Press'},
    {'name':'Chest Press'},
    {'name':'Pec Fly'},
    {'name':'Chest Cable Fly'},
    {'name':'Tricep Barbell Extension'},
    {'name':'Tricep Rope Pushdown'},
    {'name':'Tricep Pushdown'}
  ];
*/

// loading and deleting some dummy variables 
Future<void> insertDummyData() async {
  ExerciseDBModel dbModel = ExerciseDBModel();

  // the dummy data gets inserted only if the db is empty
  List<Map<String, dynamic>> allExercises = await dbModel.getAllExercises();

  if (allExercises.isEmpty) {
    List<Map<String, dynamic>> dummyExercises = [
      {'name': 'Dumbbell Bicep Curl', 'heavySetReps': 10, 'weight': 25.0},
      {'name': 'Barbell Bicep Curl', 'heavySetReps': 8, 'weight': 45.0},
      {'name': 'Hammer Curl', 'heavySetReps': 10, 'weight': 30.0},
      {'name': 'Bench Press', 'heavySetReps': 12, 'weight': 200.0},
      {'name': 'Chest Press', 'heavySetReps': 22, 'weight': 200.0},
      {'name': 'Lat Pulldown', 'heavySetReps': 14, 'weight': 35.0},

      {'name': 'Dumbbell Bicep Curl', 'heavySetReps': 10, 'weight': 100.0},
      {'name': 'Barbell Bicep Curl', 'heavySetReps': 8, 'weight': 100.0},
      {'name': 'Hammer Curl', 'heavySetReps': 10, 'weight': 300.0},
      {'name': 'Bench Press', 'heavySetReps': 12, 'weight': 300.0},
      {'name': 'Chest Press', 'heavySetReps': 22, 'weight': 300.0},
      {'name': 'Lat Pulldown', 'heavySetReps': 14, 'weight': 335.0},
      {'name': 'Tricep Pushdown', 'heavySetReps': 14, 'weight': 335.0},
      // add more exercises as needed
    ];

    for (Map<String, dynamic> exercise in dummyExercises) {
      await dbModel.insertExercise(exercise);
    }
  }
}

Future<void> deleteAllExercises() async {
  final db = await DBUtils.init();
  await db.delete('Exercises'); // delete all rows
}

class ExerciseDBModel {
  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await DBUtils.init();
    return await db.insert('Exercises', exercise,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>> getExercise(String name) async {
    final db = await DBUtils.init();
    final List<Map<String, Object?>> result =
        await db.query('Exercises', where: 'name = ?', whereArgs: [name]);
    return result[0];
  }

  Future<List<Map<String, dynamic>>> getAllExercises() async {
    final db = await DBUtils.init();
    return await db.query('Exercises');
  }

  Future<int> updateExercise(String name, int reps, double weight) async {
    final db = await DBUtils.init();
    final Map<String, Object> update = {'heavySetReps': reps, 'weight': weight};

    return await db
        .update('Exercises', update, where: 'name = ?', whereArgs: [name]);
  }

  Future<Map<String, dynamic>> getMaxStatsForExercise(String name) async {
    final db = await DBUtils.init();
    // group the results by the exercise name and return the max values for each group
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT name, MAX(heavySetReps) as maxReps, MAX(weight) as maxWeight FROM Exercises WHERE name = ? GROUP BY name',
      [name],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {
        'name': name,
        'maxWeight': 0,
        'maxReps': 0
      }; // Default values if no data is found
    }
  }

  Future<List<Map<String, dynamic>>> getMaxStatsForAllExercises() async {
    final db = await DBUtils.init();
    // This query groups the results by the exercise name and returns the max values for each group
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT name, MAX(heavySetReps) as maxReps, MAX(weight) as maxWeight FROM Exercises GROUP BY name',
    );

    return result;
  }
}
