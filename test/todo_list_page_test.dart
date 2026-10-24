import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:runoob/models/todo.dart';
import 'package:runoob/pages/todo_list_page.dart';
import 'package:runoob/services/todo_services.dart';
import 'package:runoob/state/todo_list.dart';

class _FakeTodoServices extends TodoServices {
  _FakeTodoServices(this.result);

  final Future<List<Todo>> result;

  @override
  Future<List<Todo>> fetchTodos() async => List.of(await result);
}

Widget _page(TodoList list) => ChangeNotifierProvider<TodoList>.value(
  value: list,
  child: const MaterialApp(home: TodoListPage()),
);

void main() {
  testWidgets('page builds while loading and after an empty response', (
    tester,
  ) async {
    final response = Completer<List<Todo>>();
    final list = TodoList(services: _FakeTodoServices(response.future));
    addTearDown(list.dispose);
    final loading = list.load();

    await tester.pumpWidget(_page(list));

    expect(tester.takeException(), isNull);
    expect(find.text('未完成 0 项 · 共 0 条'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete([]);
    await loading;
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('未完成 0 项 · 共 0 条'), findsOneWidget);
    expect(find.text('还没有待办，输入一条试试'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('page builds loaded todos and their counts', (tester) async {
    final items = [
      Todo(
        id: 'active',
        title: '待完成任务',
        completed: false,
        priority: Priority.medium,
        createdAt: DateTime.utc(2026, 10, 24),
      ),
      Todo(
        id: 'done',
        title: '已完成任务',
        completed: true,
        priority: Priority.low,
        createdAt: DateTime.utc(2026, 10, 23),
      ),
    ];
    final list = TodoList(services: _FakeTodoServices(Future.value(items)));
    addTearDown(list.dispose);
    await list.load();

    await tester.pumpWidget(_page(list));

    expect(tester.takeException(), isNull);
    expect(find.text('未完成 1 项 · 共 2 条'), findsOneWidget);
    expect(find.text('待完成任务'), findsOneWidget);
    expect(find.text('已完成任务'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
