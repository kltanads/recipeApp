
import 'package:flutter/foundation.dart';
import 'services/recipe_api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/app_database.dart';
import 'repositories/recipe_repository.dart';
import 'screens/recipe_list_screen.dart';
import 'viewmodels/recipe_viewmodel.dart';
import 'services/auth_storage_service.dart';
import 'services/recipe_api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = RecipeRepository(
    AppDatabase.instance,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
          RecipeViewModel(repository)..loadRecipes(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            apiService: RecipeApiService(),
            storageService: AuthStorageService(),
          )..initialize(),
        ),
      ],
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
      home: const AuthGate(),
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authViewModel.isAuthenticated) {
      return const RecipeListScreen();
    }

    return const LoginScreen();
  }
}
