
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

        await _insertSampleRecipes(db);
      },
    );
  }

  Future<void> _insertSampleRecipes(Database db) async {
    final samples = [
      Recipe(
        id: '1',
        name: 'Pancakes',
        typeId: '1',
        ingredients: ['Flour', 'Milk', 'Eggs', 'Sugar'],
        steps: [
          'Mix the ingredients.',
          'Heat a frying pan.',
          'Pour the batter.',
          'Cook until golden brown.',
        ],
      ),
      Recipe(
        id: '2',
        name: 'Fried Rice',
        typeId: '2',
        ingredients: ['Rice', 'Egg', 'Garlic', 'Soy sauce'],
        steps: [
          'Heat oil in a wok.',
          'Add garlic and egg.',
          'Add rice and soy sauce.',
          'Stir-fry until cooked.',
        ],
      ),
      Recipe(
        id: '3',
        name: 'Chocolate Cake',
        typeId: '4',
        ingredients: [
          'Flour',
          'Cocoa powder',
          'Eggs',
          'Butter',
        ],
        steps: [
          'Preheat the oven.',
          'Mix all ingredients.',
          'Pour into a baking pan.',
          'Bake until cooked.',
        ],
      ),
    ];

    for (final recipe in samples) {
      await db.insert('recipes', recipe.toMap());
    }
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