
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/recipe_import_result.dart';
import '../models/remote_recipe_dto.dart';
import '../repositories/recipe_repository.dart';
import 'image_storage_service.dart';
import 'remote_recipe_mapper.dart';

class RecipeImportService {
  final RecipeRepository repository;
  final ImageStorageService imageStorageService;

  RecipeImportService({
    required this.repository,
    required this.imageStorageService,
  });

  Future<RecipeImportResult> importRecipes(
      List<RemoteRecipeDto> remoteRecipes,
      ) async {
    int imported = 0;
    int skipped = 0;
    int failed = 0;

    // Load existing recipes once.
    final existingRecipes = await repository.getRecipes();

    final existingIds =
    existingRecipes.map((recipe) => recipe.id).toSet();

    for (final dto in remoteRecipes) {
      final recipeId = 'remote_${dto.id}';

      // Skip duplicates before downloading images.
      if (existingIds.contains(recipeId)) {
        skipped++;
        continue;
      }

      // Skip unsupported meal types.
      final mappedRecipe = RemoteRecipeMapper.toRecipe(dto);

      if (mappedRecipe == null) {
        skipped++;
        continue;
      }

      String? localImagePath;

      try {
        if (dto.imageUrl != null &&
            dto.imageUrl!.isNotEmpty) {
          try {
            localImagePath =
            await imageStorageService.downloadRecipeImage(
              imageUrl: dto.imageUrl!,
              recipeId: recipeId,
            );
          } catch (e) {
            // Image is optional; continue without it.
            debugPrint('Image download failed: $e');
          }
        }

        final recipe = RemoteRecipeMapper.toRecipe(
          dto,
          localImagePath: localImagePath,
        );

        if (recipe == null) {
          skipped++;
          continue;
        }

        await repository.addRecipe(recipe);

        existingIds.add(recipeId);
        imported++;
      } catch (e) {
        failed++;
        debugPrint('Recipe import failed ($recipeId): $e');

        // Clean up downloaded image if insert failed.
        if (localImagePath != null) {
          try {
            final file = File(localImagePath);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (cleanupError) {
            debugPrint('Image cleanup failed: $cleanupError');
          }
        }
      }
    }

    return RecipeImportResult(
      imported: imported,
      skipped: skipped,
      failed: failed,
    );
  }
}
