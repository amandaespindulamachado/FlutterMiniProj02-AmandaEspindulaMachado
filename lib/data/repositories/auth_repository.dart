import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';

abstract interface class IAuthRepository {
  Future<Result<UserModel, AppError>> login(
      String username, String password);
}

class AuthRepository implements IAuthRepository {
  final IAuthRemoteDatasource _remoteDatasource;

  AuthRepository({IAuthRemoteDatasource? remoteDatasource})
      : _remoteDatasource =
            remoteDatasource ?? AuthRemoteDatasource();

  @override
  Future<Result<UserModel, AppError>> login(
      String username, String password) async {
    return _remoteDatasource.login(username, password);
  }
}
