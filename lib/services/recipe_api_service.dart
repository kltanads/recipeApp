
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/auth_login_result.dart';
import '../models/auth_user.dart';
import '../models/remote_recipe_dto.dart';

class RecipeApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  // MARK: - Recipe API

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

  // MARK: - Authentication API

  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 60,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
          'Login failed: HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid login response',
        );
      }

      return AuthLoginResult(
        user: AuthUser.fromJson(data),
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
    } catch (e) {
      debugPrint('Login API error: $e');
      rethrow;
    }
  }

  // MARK: - Current User API

  Future<AuthUser> getCurrentUser(
      String accessToken,
      ) async {
    final uri = Uri.parse('$_baseUrl/auth/me');

    try {
      final response = await http
          .get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
          'Get current user failed: HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid user response',
        );
      }

      return AuthUser.fromJson(data);
    } catch (e) {
      debugPrint('Current User API error: $e');
      rethrow;
    }
  }

  // MARK: - Refresh Token API

  Future<({
  String accessToken,
  String refreshToken,
  })> refreshSession(String refreshToken) async {
    final uri = Uri.parse('$_baseUrl/auth/refresh');

    try {
      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
          'expiresInMins': 60,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
          'Refresh token failed: HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid refresh token response',
        );
      }

      return (
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      );
    } catch (e) {
      debugPrint('Refresh Token API error: $e');
      rethrow;
    }
  }
}
