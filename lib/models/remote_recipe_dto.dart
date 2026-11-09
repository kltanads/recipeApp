
class RemoteRecipeDto {
  final int id;
  final String name;
  final String? mealType;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> steps;

  const RemoteRecipeDto({
    required this.id,
    required this.name,
    required this.mealType,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
  });

  factory RemoteRecipeDto.fromJson(Map<String, dynamic> json) {
    final mealTypes = json['mealType'];

    return RemoteRecipeDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      mealType: mealTypes is List && mealTypes.isNotEmpty
          ? mealTypes.first as String
          : null,
      imageUrl: json['image'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      steps: (json['instructions'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
    );
  }
}
