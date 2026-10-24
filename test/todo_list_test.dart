import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/models/todo.dart';
import 'package:todolist/services/todo_services.dart';
import 'package:todolist/state/todo_list.dart';

class _FakeTodoServices extends TodoServices {
  _FakeTodoServices(this.items);

  final List<Todo> items;

  @override
  Future<List<Todo>> fetchTodos() async => List.of(items);
}

void main() {
  test('todos starts empty and cannot be modified by callers', () {
    final list = TodoList(services: _FakeTodoServices([]));
    addTearDown(list.dispose);

    expect(list.todos, isEmpty);
    expect(() => list.todos.clear(), throwsUnsupportedError);
  });

  test(
    'todos exposes loaded items in creation order as an immutable list',
    () async {
      final older = Todo(
        id: 'older',
        title: '较早的待办',
        completed: true,
        priority: Priority.low,
        createdAt: DateTime.utc(2026, 10, 23),
      );
      final newer = Todo(
        id: 'newer',
        title: '较新的待办',
        completed: false,
        priority: Priority.high,
        createdAt: DateTime.utc(2026, 10, 24),
      );
      final list = TodoList(services: _FakeTodoServices([older, newer]));
      addTearDown(list.dispose);

      await list.load();

      expect(list.loading, isFalse);
      expect(list.error, isNull);
      expect(list.todos, orderedEquals([newer, older]));
      expect(list.remainingCount, 1);
      expect(() => list.todos.add(older), throwsUnsupportedError);
      expect(() => list.todos[0] = older, throwsUnsupportedError);
      expect(list.todos, orderedEquals([newer, older]));
    },
  );
}
