
import 'dart:convert';

class Recipe {
  final String id;
  final String name;
  final String typeId;
  final String? imagePath;
  final List<String> ingredients;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.name,
    required this.typeId,
    this.imagePath,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromMap(Map<String, Object?> map) {
    return Recipe(
      id: map['id'] as String,
      name: map['name'] as String,
      typeId: map['type_id'] as String,
      imagePath: map['image_path'] as String?,
      ingredients: List<String>.from(
        jsonDecode(map['ingredients'] as String) as List,
      ),
      steps: List<String>.from(
        jsonDecode(map['steps'] as String) as List,
      ),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type_id': typeId,
      'image_path': imagePath,
      'ingredients': jsonEncode(ingredients),
      'steps': jsonEncode(steps),
    };
  }

  Recipe copyWith({
    String? name,
    String? typeId,
    String? imagePath,
    List<String>? ingredients,
    List<String>? steps,
  }) {
    return Recipe(
      id: id,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      imagePath: imagePath ?? this.imagePath,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }
}
