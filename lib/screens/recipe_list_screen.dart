
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_type.dart';
import '../services/recipe_type_service.dart';
import '../viewmodels/recipe_viewmodel.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

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
              child: Text(viewModel.errorMessage!),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<List<RecipeType>>(
                  future: _typesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Failed to load recipe types',
                      );
                    }

                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }

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
                        ...snapshot.data!.map(
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
}