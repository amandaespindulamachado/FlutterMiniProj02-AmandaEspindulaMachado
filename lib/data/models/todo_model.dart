class TodoModel {
  final int id;
  final String todo;
  bool completed;
  final int userId;

  TodoModel({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as int,
      todo: json['todo'] as String,
      completed: json['completed'] as bool,
      userId: json['userId'] as int,
    );
  }

  /// Cria instância a partir de uma linha do SQLite
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int,
      todo: map['todo'] as String,
      // SQLite armazena bool como 0/1
      completed: (map['completed'] as int) == 1,
      userId: map['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
    };
  }

  /// Converte para mapa compatível com SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed ? 1 : 0,
      'userId': userId,
    };
  }

  /// Retorna uma cópia com campos alterados
  TodoModel copyWith({bool? completed}) {
    return TodoModel(
      id: id,
      todo: todo,
      completed: completed ?? this.completed,
      userId: userId,
    );
  }
}
