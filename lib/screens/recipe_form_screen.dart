
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/recipe.dart';
import '../models/recipe_type.dart';
import '../services/image_storage_service.dart';
import '../services/recipe_type_service.dart';
import '../viewmodels/recipe_viewmodel.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeFormScreen({
    super.key,
    this.recipe,
  });

  @override
  State<RecipeFormScreen> createState() =>
      _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _stepController = TextEditingController();

  final _imageService = ImageStorageService();

  late final Future<List<RecipeType>> _typesFuture;

  String? _selectedTypeId;
  String? _imagePath;

  List<String> _ingredients = [];
  List<String> _steps = [];

  bool _isSaving = false;

  bool get isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();

    _typesFuture = RecipeTypeService().loadRecipeTypes();

    final recipe = widget.recipe;

    if (recipe != null) {
      _nameController.text = recipe.name;
      _selectedTypeId = recipe.typeId;
      _imagePath = recipe.imagePath;
      _ingredients = List.from(recipe.ingredients);
      _steps = List.from(recipe.steps);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final value = _ingredientController.text.trim();

    if (value.isEmpty) return;

    setState(() {
      _ingredients.add(value);
      _ingredientController.clear();
    });
  }

  void _addStep() {
    final value = _stepController.text.trim();

    if (value.isEmpty) return;

    setState(() {
      _steps.add(value);
      _stepController.clear();
    });
  }

  Future<void> _pickImage() async {
    try {
      final path = await _imageService.pickAndSaveImage();

      if (!mounted || path == null) return;

      setState(() {
        _imagePath = path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select image'),
        ),
      );
    }
  }

  Future<void> _saveRecipe() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    if (_ingredients.isEmpty || _steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least one ingredient and step',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final recipe = Recipe(
      id: widget.recipe?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      typeId: _selectedTypeId!,
      imagePath: _imagePath,
      ingredients: List.from(_ingredients),
      steps: List.from(_steps),
    );

    try {
      final viewModel = context.read<RecipeViewModel>();

      if (isEditing) {
        await viewModel.updateRecipe(recipe);
      } else {
        await viewModel.addRecipe(recipe);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save recipe'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recipe' : 'Add Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter recipe name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            FutureBuilder<List<RecipeType>>(
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
                  initialValue: _selectedTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Type',
                    border: OutlineInputBorder(),
                  ),
                  items: snapshot.data!.map((type) {
                    return DropdownMenuItem<String>(
                      value: type.id,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select recipe type';
                    }
                    return null;
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            if (_imagePath != null)
              Image.file(
                File(_imagePath!),
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image),
              ),

            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Choose Image'),
            ),

            const SizedBox(height: 20),

            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            ..._ingredients.asMap().entries.map(
                  (entry) => ListTile(
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      _ingredients.removeAt(entry.key);
                    });
                  },
                ),
              ),
            ),

            TextField(
              controller: _ingredientController,
              decoration: InputDecoration(
                hintText: 'Add ingredient',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addIngredient,
                ),
              ),
              onSubmitted: (_) => _addIngredient(),
            ),

            const SizedBox(height: 20),

            Text(
              'Cooking Steps',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            ..._steps.asMap().entries.map(
                  (entry) => ListTile(
                title: Text(
                  '${entry.key + 1}. ${entry.value}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      _steps.removeAt(entry.key);
                    });
                  },
                ),
              ),
            ),

            TextField(
              controller: _stepController,
              decoration: InputDecoration(
                hintText: 'Add cooking step',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addStep,
                ),
              ),
              onSubmitted: (_) => _addStep(),
            ),

            const SizedBox(height: 28),

            FilledButton(
              onPressed: _isSaving ? null : _saveRecipe,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _isSaving ? 'Saving...' : 'Save Recipe',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}