import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';

abstract interface class IAuthRemoteDatasource {
  Future<Result<UserModel, AppError>> login(
      String username, String password);
}

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  static const String _baseUrl = 'https://dummymyjson.com';
  final http.Client _client;

  AuthRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<Result<UserModel, AppError>> login(
      String username, String password) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/login');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 60,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final user = UserModel.fromJson(json);
        return Success(user);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return const Failure(InvalidCredentialsError());
      } else {
        return Failure(
          NetworkError(
            'Erro no servidor: ${response.statusCode}',
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Failure(NetworkError('Falha na conexão: ${e.toString()}'));
    }
  }
}
