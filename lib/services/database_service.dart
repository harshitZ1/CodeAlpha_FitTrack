import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/workout.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, 'fitness_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertWorkout(Workout workout) async {
    final db = await database;

    return await db.insert(
      'workouts',
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('workouts');

    return List.generate(
      maps.length,
      (index) => Workout.fromMap(maps[index]),
    );
  }

 Future<int> updateWorkout(Workout workout) async {
  final db = await database;

  return await db.update(
    'workouts',
    workout.toMap(),
    where: 'id = ?',
    whereArgs: [workout.id],
  );
}
Future<int> deleteWorkout(int id) async {
  final db = await database;

  return await db.delete(
    'workouts',
    where: 'id = ?',
    whereArgs: [id],
  );
}
}