import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_helper;
import '../models/todo_model.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';

abstract interface class ITodoLocalDatasource {
  Future<void> init();
  Future<Result<void, AppError>> insertOrReplaceAll(List<TodoModel> todos);
  Future<Result<List<TodoModel>, AppError>> getAll();
  Future<Result<void, AppError>> updateCompleted(int id, bool completed);
  Future<Result<void, AppError>> clearAll();
}

class TodoLocalDatasource implements ITodoLocalDatasource {
  static const String _dbName = 'todos.db';
  static const String _tableName = 'todos';
  Database? _db;

  @override
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path_helper.join(dbPath, _dbName);

    _db = await openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id      INTEGER PRIMARY KEY,
            todo    TEXT    NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            userId  INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Database get _database {
    if (_db == null) throw StateError('Database não inicializado.');
    return _db!;
  }

  @override
  Future<Result<void, AppError>> insertOrReplaceAll(
      List<TodoModel> todos) async {
    try {
      final batch = _database.batch();
      for (final todo in todos) {
        batch.insert(
          _tableName,
          todo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Erro ao salvar tarefas: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<TodoModel>, AppError>> getAll() async {
    try {
      final rows = await _database.query(
        _tableName,
        orderBy: 'id ASC',
      );
      final todos = rows.map(TodoModel.fromMap).toList();
      return Success(todos);
    } catch (e) {
      return Failure(
          DatabaseError('Erro ao carregar tarefas: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, AppError>> updateCompleted(
      int id, bool completed) async {
    try {
      await _database.update(
        _tableName,
        {'completed': completed ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure(
          DatabaseError('Erro ao atualizar tarefa: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, AppError>> clearAll() async {
    try {
      await _database.delete(_tableName);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseError('Erro ao limpar tarefas: ${e.toString()}'));
    }
  }
}
