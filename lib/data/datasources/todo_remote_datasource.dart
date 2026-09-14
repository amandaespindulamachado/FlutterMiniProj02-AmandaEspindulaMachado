import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo_model.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';

abstract interface class ITodoRemoteDatasource {
  Future<Result<List<TodoModel>, AppError>> fetchTodos();
}

class TodoRemoteDatasource implements ITodoRemoteDatasource {
  static const String _baseUrl = 'https://dummymyjson.com';
  final http.Client _client;

  TodoRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<Result<List<TodoModel>, AppError>> fetchTodos() async {
    try {
      final uri = Uri.parse('$_baseUrl/todos?limit=100');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final todosJson = json['todos'] as List<dynamic>;

        // Iteração com map para transformar json em lista de entidades
        final todos = todosJson
            .map((item) => TodoModel.fromJson(item as Map<String, dynamic>))
            .toList();

        return Success(todos);
      } else {
        return Failure(
          NetworkError(
            'Erro ao buscar tarefas: ${response.statusCode}',
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Failure(NetworkError('Falha na conexão: ${e.toString()}'));
    }
  }
}
