import '../data/repositories/todo_repository.dart';
import '../data/datasources/todo_local_datasource.dart';
import '../data/models/todo_model.dart';
import '../core/errors/app_error.dart';
import '../core/result/result.dart';

abstract interface class ITodoService {
  Future<void> init();
  Future<Result<List<TodoModel>, AppError>> loadTodos();
  Future<Result<void, AppError>> completeTodo(int id);
  List<TodoModel> filterTodos({
    required List<TodoModel> todos,
    required String? searchText,
    required TodoFilterStatus status,
  });
}

enum TodoFilterStatus { all, completed, pending }

class TodoService implements ITodoService {
  final ITodoRepository _repository;
  final ITodoLocalDatasource _localDatasource;

  TodoService({
    ITodoRepository? repository,
    ITodoLocalDatasource? localDatasource,
  })  : _repository = repository ?? TodoRepository(),
        _localDatasource = localDatasource ?? TodoLocalDatasource();

  @override
  Future<void> init() => _localDatasource.init();

  /// Busca da API e persiste no banco, retornando via SELECT
  @override
  Future<Result<List<TodoModel>, AppError>> loadTodos() {
    return _repository.fetchAndStoreTodos();
  }

  /// Marca tarefa como completa no SQLite
  @override
  Future<Result<void, AppError>> completeTodo(int id) {
    return _repository.updateTodoCompleted(id, true);
  }

  /// Filtragem local da lista sem nova chamada à API
  @override
  List<TodoModel> filterTodos({
    required List<TodoModel> todos,
    required String? searchText,
    required TodoFilterStatus status,
  }) {
    // Filtro por status usando operadores lógicos
    List<TodoModel> filtered = todos.where((todo) {
      final matchStatus = status == TodoFilterStatus.all ||
          (status == TodoFilterStatus.completed && todo.completed) ||
          (status == TodoFilterStatus.pending && !todo.completed);
      return matchStatus;
    }).toList();

    // Filtro por texto de busca
    if (searchText != null && searchText.trim().isNotEmpty) {
      final query = searchText.trim().toLowerCase();
      filtered = filtered
          .where((todo) => todo.todo.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }
}
