import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/todo_services.dart';

enum TodoFilter { all, active, done }

class TodoList extends ChangeNotifier {
  TodoList({required this._services});

  final TodoServices _services;
  final List<Todo> _todos = [];
  
  TodoFilter _filter = TodoFilter.all;
  bool _loading = false;
  String? _error;

  List<Todo> get todos => List.unmodifiable(_todos);
  TodoFilter get filter => _filter;
  bool get loading => _loading;
  String? get error => _error;

  // 获取还未完成的待办数量
  int get remainingCount => _todos.where((todo) => !todo.completed).length;

  // 根据 todo 的 completed 状态来筛选此时能看到的 todo
  List<Todo> get visibleTodos => switch (_filter) {
    TodoFilter.all => _todos,
    TodoFilter.active => _todos.where((todo) => !todo.completed).toList(),
    TodoFilter.done => _todos.where((todo) => todo.completed).toList(),
  };

  // 加载待办
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await _services.fetchTodos();
      // 根据创建时间 createdAt 来进行排序
      fetched.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _todos
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // 添加待办
  Future<void> add(String title, Priority priority) async {
    final todo = await _services.createTodo(
      Todo(
        id: '',
        title: title,
        completed: false,
        priority: priority,
        createdAt: DateTime.now()
      )
    );
    _todos.insert(0, todo);
    notifyListeners();
  }

  // 完成待办
  Future<void> toggle(Todo todo) async {
    final updated = await _services.updateTodo(
      todo.copyWith(completed: !todo.completed)
    );
    final index = _todos.indexWhere((item) => item.id == updated.id);
    if (index >= 0) _todos[index] = updated;
    notifyListeners();
  }

  // 删除待办
  Future<void> remove(Todo todo) async {
    await _services.deleteTodo(todo.id);
    _todos.removeWhere((item) => item.id == todo.id);
    notifyListeners();
  }

  // 设置 filter
  void setFilter(TodoFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }
}
