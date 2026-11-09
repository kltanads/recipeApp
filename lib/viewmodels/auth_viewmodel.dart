
import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../services/auth_storage_service.dart';
import '../services/recipe_api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final RecipeApiService apiService;
  final AuthStorageService storageService;

  AuthViewModel({
    required this.apiService,
    required this.storageService,
  });

  AuthUser? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  // MARK: - Getters

  AuthUser? get user => _user;

  bool get isLoading => _isLoading;

  bool get isInitializing => _isInitializing;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null;

  // MARK: - Restore Session

  Future<void> initialize() async {
    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final accessToken = await storageService.getAccessToken();

      if (accessToken == null) {
        return;
      }

      try {
        _user = await apiService.getCurrentUser(accessToken);
      } catch (_) {
        final refreshToken = await storageService.getRefreshToken();

        if (refreshToken == null) {
          await storageService.clearTokens();
          return;
        }

        final tokens = await apiService.refreshSession(refreshToken);

        _user = await apiService.getCurrentUser(tokens.accessToken);

        await storageService.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
      }
    } catch (e) {
      debugPrint('Session restoration failed: $e');

      _user = null;

      try {
        await storageService.clearTokens();
      } catch (storageError) {
        debugPrint('Clear tokens failed: $storageError');
      }
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  // MARK: - Login

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await apiService.login(
        username: username,
        password: password,
      );

      await storageService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      _user = result.user;

      return true;
    } catch (e) {
      debugPrint('Login failed: $e');

      _errorMessage = 'Login failed. Please try again.';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARK: - Logout

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await storageService.clearTokens();

      _user = null;
    } catch (e) {
      debugPrint('Logout failed: $e');

      _errorMessage = 'Logout failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
