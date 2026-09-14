import 'package:flutter/material.dart';
import '../../services/todo_service.dart';
import '../../services/prefs_service.dart';
import '../../data/models/todo_model.dart';
import '../../core/result/result.dart';

enum TodoState { idle, loading, success, error }

class TodoViewModel extends ChangeNotifier {
  final ITodoService _todoService;
  final IPrefsService _prefs;

  TodoViewModel({
    ITodoService? todoService,
    IPrefsService? prefs,
  })  : _todoService = todoService ?? TodoService(),
        _prefs = prefs ?? PrefsService();

  // --- Estado ---
  TodoState _state = TodoState.idle;
  String? _errorMessage;
  List<TodoModel> _allTodos = [];
  List<TodoModel> _filteredTodos = [];
  String _userName = '';
  String _searchQuery = '';
  TodoFilterStatus _filterStatus = TodoFilterStatus.all;

  // --- Getters ---
  TodoState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TodoState.loading;
  List<TodoModel> get todos => _filteredTodos;
  String get userName => _userName;
  String get searchQuery => _searchQuery;
  TodoFilterStatus get filterStatus => _filterStatus;

  Future<void> init() async {
    await _todoService.init();
    await _loadUserName();
    await loadTodos();
  }

  Future<void> _loadUserName() async {
    final first = await _prefs.getFirstName();
    final last = await _prefs.getLastName();
    _userName = '${first ?? ''} ${last ?? ''}'.trim();
    notifyListeners();
  }

  Future<void> loadTodos() async {
    _state = TodoState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _todoService.loadTodos();

    // Padrão Result com switch expression (Dart 3 pattern matching)
    switch (result) {
      case Success(:final value):
        _allTodos = value;
        _state = TodoState.success;
        _applyFilters();
      case Failure(:final error):
        _state = TodoState.error;
        _errorMessage = error.message;
    }

    notifyListeners();
  }

  Future<void> completeTodo(int id) async {
    final result = await _todoService.completeTodo(id);

    switch (result) {
      case Success():
        // Atualiza em memória sem nova chamada à API
        final index = _allTodos.indexWhere((t) => t.id == id);
        if (index != -1) {
          _allTodos[index] = _allTodos[index].copyWith(completed: true);
          _applyFilters();
          notifyListeners();
        }
      case Failure():
        break;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilterStatus(TodoFilterStatus status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredTodos = _todoService.filterTodos(
      todos: _allTodos,
      searchText: _searchQuery,
      status: _filterStatus,
    );
  }

  int get totalCount => _allTodos.length;
  int get completedCount => _allTodos.where((t) => t.completed).length;
  int get pendingCount => _allTodos.where((t) => !t.completed).length;
}
