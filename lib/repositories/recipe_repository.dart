
import '../data/database/app_database.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final AppDatabase database;

  RecipeRepository(this.database);

  Future<List<Recipe>> getRecipes() {
    return database.getRecipes();
  }

  Future<void> addRecipe(Recipe recipe) {
    return database.insertRecipe(recipe);
  }

  Future<void> updateRecipe(Recipe recipe) {
    return database.updateRecipe(recipe);
  }

  Future<void> deleteRecipe(String id) {
    return database.deleteRecipe(id);
  }
}