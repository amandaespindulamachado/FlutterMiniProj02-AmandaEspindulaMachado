import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../core/errors/app_error.dart';
import '../core/result/result.dart';
import 'prefs_service.dart';

abstract interface class IAuthService {
  Future<Result<UserModel, AppError>> login(
      String username, String password);
  Future<bool> isLoggedIn();
  Future<void> logout();
}

class AuthService implements IAuthService {
  final IAuthRepository _repository;
  final IPrefsService _prefs;

  AuthService({
    IAuthRepository? repository,
    IPrefsService? prefs,
  })  : _repository = repository ?? AuthRepository(),
        _prefs = prefs ?? PrefsService();

  @override
  Future<Result<UserModel, AppError>> login(
      String username, String password) async {
    // Validações lógicas antes de chamar a API
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return const Failure(
          AuthError('Usuário e senha não podem ser vazios.'));
    }

    final result = await _repository.login(username.trim(), password);

    if (result.isSuccess) {
      final user = result.successValue;
      await _prefs.saveUser(
        firstName: user.firstName,
        lastName: user.lastName,
        token: user.token,
      );
    }

    return result;
  }

  @override
  Future<bool> isLoggedIn() => _prefs.isLoggedIn();

  @override
  Future<void> logout() => _prefs.clear();
}
