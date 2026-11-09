
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/remote_recipe_dto.dart';
import '../services/image_storage_service.dart';
import '../services/recipe_api_service.dart';
import '../services/recipe_import_service.dart';
import '../viewmodels/recipe_viewmodel.dart';

class ImportRecipeScreen extends StatefulWidget {
  const ImportRecipeScreen({super.key});

  @override
  State<ImportRecipeScreen> createState() =>
      _ImportRecipeScreenState();
}

class _ImportRecipeScreenState
    extends State<ImportRecipeScreen> {
  final RecipeApiService _apiService = RecipeApiService();

  late Future<List<RemoteRecipeDto>> _recipesFuture;

  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _apiService.fetchRecipes();
  }

  void _retry() {
    setState(() {
      _recipesFuture = _apiService.fetchRecipes();
    });
  }

  Future<void> _importRecipes(
      List<RemoteRecipeDto> remoteRecipes,
      ) async {
    if (_isImporting) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final viewModel = context.read<RecipeViewModel>();

      final importService = RecipeImportService(
        repository: viewModel.repository,
        imageStorageService: ImageStorageService(),
      );

      final result = await importService.importRecipes(
        remoteRecipes,
      );

      await viewModel.loadRecipes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported: ${result.imported}, '
                'Skipped: ${result.skipped}, '
                'Failed: ${result.failed}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Recipes'),
      ),
      body: FutureBuilder<List<RemoteRecipeDto>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState !=
              ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load remote recipes'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final recipes = snapshot.data ?? [];

          if (recipes.isEmpty) {
            return const Center(
              child: Text('No remote recipes available'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];

                    return ListTile(
                      leading: recipe.imageUrl != null
                          ? Image.network(
                        recipe.imageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(
                          Icons.restaurant,
                        ),
                      )
                          : const Icon(Icons.restaurant),
                      title: Text(recipe.name),
                      subtitle: Text(
                        recipe.mealType ?? 'Unknown Type',
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _isImporting
                      ? null
                      : () => _importRecipes(recipes),
                  child: _isImporting
                      ? const CircularProgressIndicator()
                      : const Text('Import All Recipes'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
