
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_type.dart';
import '../services/recipe_type_service.dart';
import '../viewmodels/recipe_viewmodel.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';
import 'import_recipe_screen.dart';
import '../viewmodels/auth_viewmodel.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() =>
      _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late final Future<List<RecipeType>> _typesFuture;

  @override
  void initState() {
    super.initState();
    _typesFuture = RecipeTypeService().loadRecipeTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        actions: [
          IconButton(
            tooltip: 'Import Recipes',
            icon: const Icon(Icons.cloud_download_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImportRecipeScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _userLogout,
          ),
        ],
      ),
      body: Consumer<RecipeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: viewModel.loadRecipes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<List<RecipeType>>(
                  future: _typesFuture,
                  builder: (context, snapshot) {
                    // Loading state
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LinearProgressIndicator();
                    }

                    // Error state
                    if (snapshot.hasError) {
                      return const Text(
                        'Failed to load recipe types',
                      );
                    }

                    // Success state
                    final types = snapshot.data ?? [];

                    return DropdownButtonFormField<String>(
                      initialValue: viewModel.selectedTypeId,
                      decoration: const InputDecoration(
                        labelText: 'Recipe Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Recipes'),
                        ),
                        ...types.map(
                              (type) => DropdownMenuItem<String>(
                            value: type.id,
                            child: Text(type.name),
                          ),
                        ),
                      ],
                      onChanged: viewModel.filterByType,
                    );
                  },
                ),
              ),
              Expanded(
                child: viewModel.filteredRecipes.isEmpty
                    ? const Center(
                  child: Text('No recipes found'),
                )
                    : ListView.builder(
                  itemCount: viewModel.filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe =
                    viewModel.filteredRecipes[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.restaurant_menu,
                        ),
                        title: Text(recipe.name),
                        subtitle: Text(
                          '${recipe.ingredients.length} ingredients',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailScreen(
                                recipe: recipe,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RecipeFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _userLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context
          .read<AuthViewModel>()
          .logout();

      if (!mounted) return;

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to logout'),
        ),
      );
    }
  }
}