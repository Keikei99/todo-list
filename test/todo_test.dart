import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:runoob/models/todo.dart';

void main() {
  const priorityNames = {
    Priority.low: 'low',
    Priority.medium: 'medium',
    Priority.high: 'high',
  };

  for (final entry in priorityNames.entries) {
    test('toggle payload encodes priority as ${entry.value}', () {
      final todo = Todo(
        id: '1',
        title: '测试待办',
        completed: false,
        priority: entry.key,
        createdAt: DateTime.utc(2026, 10, 24),
      );
      final updated = todo.copyWith(completed: true);

      final payload =
          jsonDecode(jsonEncode(updated.toJson())) as Map<String, dynamic>;

      expect(payload['priority'], entry.value);
      expect(payload['completed'], isTrue);
      expect(todo.completed, isFalse);

      final decoded = Todo.fromJson({'id': todo.id, ...payload});
      expect(decoded.priority, entry.key);
      expect(decoded.completed, isTrue);
    });
  }
}
