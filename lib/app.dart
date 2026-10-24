// 应用外壳：注入服务与状态、配置主题与首页。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/todo_list_page.dart';
import 'services/todo_services.dart';
import 'state/todo_list.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoList(services: TodoServices())..load(),
      child: MaterialApp(
        title: '待办清单',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF365BDC)),
          useMaterial3: true,
        ),
        home: const TodoListPage(),
      ),
    );
  }
}