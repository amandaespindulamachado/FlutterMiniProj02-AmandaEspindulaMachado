import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/result/result.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final IAuthService _authService;

  AuthViewModel({IAuthService? authService})
      : _authService = authService ?? AuthService();

  AuthState _state = AuthState.idle;
  String? _errorMessage;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;

  Future<bool> login(String username, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(username, password);

    return result.when(
      onSuccess: (_) {
        _state = AuthState.success;
        notifyListeners();
        return true;
      },
      onFailure: (error) {
        _state = AuthState.error;
        _errorMessage = error.message;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> isLoggedIn() => _authService.isLoggedIn();

  Future<void> logout() => _authService.logout();

  void resetState() {
    _state = AuthState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
