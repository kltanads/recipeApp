
import 'package:flutter/foundation.dart';
import 'services/recipe_api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/app_database.dart';
import 'repositories/recipe_repository.dart';
import 'screens/recipe_list_screen.dart';
import 'viewmodels/recipe_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = RecipeRepository(
    AppDatabase.instance,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => RecipeViewModel(
        repository,
      )..loadRecipes(),
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
      ),
      home: const RecipeListScreen(),
    );
  }
}
