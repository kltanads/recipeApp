
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/remote_recipe_dto.dart';

class RecipeApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<List<RemoteRecipeDto>> fetchRecipes() async {
    final uri = Uri.parse('$_baseUrl/recipes?limit=10');

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch recipes: HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic> ||
          data['recipes'] is! List) {
        throw const FormatException(
          'Invalid recipes response',
        );
      }

      final recipes = data['recipes'] as List<dynamic>;

      return recipes.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid recipe item');
        }

        return RemoteRecipeDto.fromJson(item);
      }).toList();
    } catch (e) {
      debugPrint('Recipe API error: $e');
      rethrow;
    }
  }
}