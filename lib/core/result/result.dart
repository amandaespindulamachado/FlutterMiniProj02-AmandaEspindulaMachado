/// Padrão Result para tratamento de erros sem exceções.
/// [S] = tipo do sucesso, [E] = tipo do erro.
sealed class Result<S, E> {
  const Result();
}

final class Success<S, E> extends Result<S, E> {
  final S value;
  const Success(this.value);
}

final class Failure<S, E> extends Result<S, E> {
  final E error;
  const Failure(this.error);
}

extension ResultExtension<S, E> on Result<S, E> {
  bool get isSuccess => this is Success<S, E>;
  bool get isFailure => this is Failure<S, E>;

  S get successValue => (this as Success<S, E>).value;
  E get failureError => (this as Failure<S, E>).error;

  /// Executa [onSuccess] ou [onFailure] e retorna o resultado
  T when<T>({
    required T Function(S value) onSuccess,
    required T Function(E error) onFailure,
  }) {
    if (this is Success<S, E>) {
      return onSuccess((this as Success<S, E>).value);
    } else {
      return onFailure((this as Failure<S, E>).error);
    }
  }
}
