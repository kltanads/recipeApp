
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../viewmodels/recipe_viewmodel.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState
    extends State<RecipeDetailScreen> {
  late Recipe _recipe;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  Future<void> _editRecipe() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeFormScreen(
          recipe: _recipe,
        ),
      ),
    );

    if (!mounted || updated != true) return;

    final viewModel = context.read<RecipeViewModel>();

    // Find the updated recipe from the complete list.
    final updatedRecipe = viewModel.recipes
        .where((recipe) => recipe.id == _recipe.id)
        .firstOrNull;

    if (updatedRecipe != null) {
      setState(() {
        _recipe = updatedRecipe;
      });
    }
  }

  Future<void> _deleteRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text(
          'Are you sure you want to delete this recipe?',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context
          .read<RecipeViewModel>()
          .deleteRecipe(_recipe.id);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete recipe'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editRecipe,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteRecipe,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recipe Image
          if (_recipe.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_recipe.imagePath!),
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(
                  Icons.broken_image,
                  size: 80,
                ),
              ),
            )
          else
            const SizedBox(
              height: 160,
              child: Icon(
                Icons.restaurant_menu,
                size: 80,
              ),
            ),

          const SizedBox(height: 20),

          // Recipe Name
          Text(
            _recipe.name,
            style: Theme.of(context)
                .textTheme.headlineMedium,
          ),

          const SizedBox(height: 24),

          // Ingredients
          Text(
            'Ingredients',
            style: Theme.of(context)
                .textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          ..._recipe.ingredients.map(
                (ingredient) => ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
              ),
              title: Text(ingredient),
            ),
          ),

          const SizedBox(height: 20),

          // Cooking Steps
          Text(
            'Cooking Steps',
            style: Theme.of(context)
                .textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          ..._recipe.steps.asMap().entries.map(
                (entry) => ListTile(
              leading: CircleAvatar(
                child: Text('${entry.key + 1}'),
              ),
              title: Text(entry.value),
            ),
          ),
        ],
      ),
    );
  }
}
