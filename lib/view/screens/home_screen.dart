import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/todo_view_model.dart';
import '../viewModel/auth_view_model.dart';
import '../../data/models/todo_model.dart';
import '../../services/todo_service.dart';
import '../../core/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento após o primeiro frame para ter contexto disponível
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoViewModel>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthViewModel>().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Olá,',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                Text(
                  vm.userName.isNotEmpty ? vm.userName : 'Usuário',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _onLogout,
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de busca e filtros
              _FilterBar(searchController: _searchController, vm: vm),
              // Contadores
              if (vm.state == TodoState.success) _CounterRow(vm: vm),
              // Conteúdo principal
              Expanded(child: _buildBody(vm)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(TodoViewModel vm) {
    switch (vm.state) {
      case TodoState.loading:
      case TodoState.idle:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF1A237E)),
              SizedBox(height: 16),
              Text('Carregando tarefas...'),
            ],
          ),
        );

      case TodoState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  vm.errorMessage ?? 'Erro ao carregar tarefas.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: vm.loadTodos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case TodoState.success:
        if (vm.todos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhuma tarefa encontrada.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF1A237E),
          onRefresh: vm.loadTodos,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: vm.todos.length,
            itemBuilder: (context, index) {
              final todo = vm.todos[index];
              return _TodoCard(todo: todo, vm: vm);
            },
          ),
        );
    }
  }
}

// ─── Widget: barra de filtros ─────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final TodoViewModel vm;

  const _FilterBar({required this.searchController, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A237E),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Campo de busca por texto
          TextField(
            controller: searchController,
            onChanged: vm.setSearchQuery,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar tarefa...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon:
                  const Icon(Icons.search, color: Colors.white70),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        searchController.clear();
                        vm.setSearchQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Filtros por status
          Row(
            children: [
              _FilterChip(
                label: 'Todos',
                selected: vm.filterStatus == TodoFilterStatus.all,
                onTap: () => vm.setFilterStatus(TodoFilterStatus.all),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pendentes',
                selected: vm.filterStatus == TodoFilterStatus.pending,
                onTap: () => vm.setFilterStatus(TodoFilterStatus.pending),
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Concluídas',
                selected: vm.filterStatus == TodoFilterStatus.completed,
                onTap: () =>
                    vm.setFilterStatus(TodoFilterStatus.completed),
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : Colors.white30,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1A237E) : Colors.white,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Widget: contadores ───────────────────────────────────────────────────────

class _CounterRow extends StatelessWidget {
  final TodoViewModel vm;
  const _CounterRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CounterItem(
            value: vm.totalCount,
            label: 'Total',
            color: const Color(0xFF1A237E),
          ),
          _CounterItem(
            value: vm.pendingCount,
            label: 'Pendentes',
            color: Colors.orange,
          ),
          _CounterItem(
            value: vm.completedCount,
            label: 'Concluídas',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _CounterItem extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _CounterItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// ─── Widget: card de tarefa ───────────────────────────────────────────────────

class _TodoCard extends StatelessWidget {
  final TodoModel todo;
  final TodoViewModel vm;

  const _TodoCard({required this.todo, required this.vm});

  @override
  Widget build(BuildContext context) {
    // RF06: tarefas completadas ficam mais apagadas (opacidade reduzida)
    return Opacity(
      opacity: todo.completed ? 0.55 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: todo.completed ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: todo.completed
                ? Colors.grey.shade300
                : const Color(0xFF1A237E).withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RF07: checkbox apenas para tarefas não completas
              if (!todo.completed)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _onComplete(context),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1A237E),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.check_box_rounded,
                  color: Colors.green,
                  size: 22,
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.todo,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todo.completed
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Usuário #${todo.userId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Operador ternário para status visual
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: todo.completed
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            todo.completed ? 'Concluída' : 'Pendente',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: todo.completed
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onComplete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Concluir tarefa'),
        content: Text('Marcar como concluída?\n\n"${todo.todo}"'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      vm.completeTodo(todo.id);
    }
  }
}
