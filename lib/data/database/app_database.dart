
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/recipe.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, 'recipes.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type_id TEXT NOT NULL,
            image_path TEXT,
            ingredients TEXT NOT NULL,
            steps TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final rows = await db.query(
      'recipes',
      orderBy: 'name ASC',
    );

    return rows.map(Recipe.fromMap).toList();
  }

  Future<void> insertRecipe(Recipe recipe) async {
    final db = await database;
    await db.insert('recipes', recipe.toMap());
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final db = await database;
    await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<void> deleteRecipe(String id) async {
    final db = await database;
    await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}