/// Hierarquia de erros da aplicação
sealed class AppError {
  final String message;
  const AppError(this.message);

  @override
  String toString() => message;
}

/// Erros relacionados a autenticação
final class AuthError extends AppError {
  const AuthError(super.message);
}

/// Erros de credenciais inválidas
final class InvalidCredentialsError extends AuthError {
  const InvalidCredentialsError()
      : super('Usuário ou senha inválidos. Verifique e tente novamente.');
}

/// Erros de rede / HTTP
final class NetworkError extends AppError {
  final int? statusCode;
  const NetworkError(super.message, {this.statusCode});
}

/// Erros de banco de dados local
final class DatabaseError extends AppError {
  const DatabaseError(super.message);
}

/// Erro genérico / inesperado
final class UnknownError extends AppError {
  const UnknownError([super.message = 'Ocorreu um erro inesperado.']);
}
