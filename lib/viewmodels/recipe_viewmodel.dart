
import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository repository;

  RecipeViewModel(this.repository);

  List<Recipe> _recipes = [];

  // All recipes without filtering
  List<Recipe> get recipes => List.unmodifiable(_recipes);

  String? _selectedTypeId;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedTypeId => _selectedTypeId;

  List<Recipe> get filteredRecipes {
    if (_selectedTypeId == null) {
      return _recipes;
    }

    return _recipes
        .where((recipe) => recipe.typeId == _selectedTypeId)
        .toList();
  }

  void filterByType(String? typeId) {
    _selectedTypeId = typeId;
    notifyListeners();
  }

  Future<void> loadRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final recipes = await repository.getRecipes();

      _recipes = recipes;
    } catch (e) {
      _errorMessage = 'Unable to load recipes';
      debugPrint('Load recipes error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    await repository.addRecipe(recipe);
    await loadRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await repository.updateRecipe(recipe);
    await loadRecipes();
  }

  Future<void> deleteRecipe(String id) async {
    await repository.deleteRecipe(id);
    await loadRecipes();
  }
}
