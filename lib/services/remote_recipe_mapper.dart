
import '../models/recipe.dart';
import '../models/remote_recipe_dto.dart';

class RemoteRecipeMapper {
  static const Map<String, String> _typeIds = {
    'Breakfast': '1',
    'Lunch': '2',
    'Dinner': '3',
    'Dessert': '4',
    'Snack': '5',
    'Beverage': '6',
  };

  static Recipe? toRecipe(
      RemoteRecipeDto dto, {
        String? localImagePath,
      }) {
    final typeId = _typeIds[dto.mealType];

    // Skip recipes with unsupported meal types.
    if (typeId == null) {
      return null;
    }

    return Recipe(
      id: 'remote_${dto.id}',
      name: dto.name,
      typeId: typeId,
      imagePath: localImagePath,
      ingredients: dto.ingredients,
      steps: dto.steps,
    );
  }
}
