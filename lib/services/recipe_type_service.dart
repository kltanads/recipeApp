import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recipe_type.dart';

class RecipeTypeService {
  Future<List<RecipeType>> loadRecipeTypes() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/recipetypes.json',
    );

    final List<dynamic> data = jsonDecode(jsonString);

    return data
        .map((item) => RecipeType.fromJson(
      item as Map<String, dynamic>,
    ))
        .toList();
  }
}