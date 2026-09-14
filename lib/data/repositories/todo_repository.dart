import '../datasources/todo_remote_datasource.dart';
import '../datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';

abstract interface class ITodoRepository {
  Future<Result<List<TodoModel>, AppError>> fetchAndStoreTodos();
  Future<Result<List<TodoModel>, AppError>> getLocalTodos();
  Future<Result<void, AppError>> updateTodoCompleted(int id, bool completed);
}

class TodoRepository implements ITodoRepository {
  final ITodoRemoteDatasource _remote;
  final ITodoLocalDatasource _local;

  TodoRepository({
    ITodoRemoteDatasource? remote,
    ITodoLocalDatasource? local,
  })  : _remote = remote ?? TodoRemoteDatasource(),
        _local = local ?? TodoLocalDatasource();

  /// Busca da API → salva no SQLite → retorna lista local (SELECT)
  @override
  Future<Result<List<TodoModel>, AppError>> fetchAndStoreTodos() async {
    final remoteResult = await _remote.fetchTodos();

    if (remoteResult.isFailure) {
      return Failure(remoteResult.failureError);
    }

    final todos = remoteResult.successValue;

    final clearResult = await _local.clearAll();
    if (clearResult.isFailure) {
      return Failure(clearResult.failureError);
    }

    final saveResult = await _local.insertOrReplaceAll(todos);
    if (saveResult.isFailure) {
      return Failure(saveResult.failureError);
    }

    // Consome via SELECT para garantir consistência
    return _local.getAll();
  }

  @override
  Future<Result<List<TodoModel>, AppError>> getLocalTodos() {
    return _local.getAll();
  }

  @override
  Future<Result<void, AppError>> updateTodoCompleted(
      int id, bool completed) async {
    return _local.updateCompleted(id, completed);
  }
}
