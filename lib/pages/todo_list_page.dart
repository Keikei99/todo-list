import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../state/todo_list.dart';
import '../widgets/todo_tile.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // 文本输入控制器
  final _inputController = TextEditingController();
  Priority _newPriority = Priority.medium;

  @override
  void dispose() {
    super.dispose();
  }

    // ---------- 事件处理：统一在这里接状态层，并兜住错误 ----------

  Future<void> _add() async {
    final title = _inputController.text.trim();
    if (title.isEmpty) {
      _showSnackBar('先写点什么吧');
      return;
    }
    try {
      await context.read<TodoList>().add(title, _newPriority);
      _inputController.clear();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('新建失败：$e');
    }
  }

  Future<void> _toggle(Todo todo) async {
    try {
      await context.read<TodoList>().toggle(todo);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('更新失败：$e');
    }
  }

  Future<void> _remove(Todo todo) async {
    try {
      await context.read<TodoList>().remove(todo);
      if (!mounted) return;
      _showSnackBar('已删除「${todo.title}」');
    } catch (e) {
      // 删除失败时重新加载，让被滑走的条目回来
      await context.read<TodoList>().load();
      if (!mounted) return;
      _showSnackBar('删除失败：$e');
    }
  }

  // 弹出通知框
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------- 布局 ----------

  @override
  Widget build(BuildContext context) {
    final list = context.watch<TodoList>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办清单'),
        actions: [
          IconButton(
            tooltip: '重新加载',
            icon: const Icon(Icons.refresh),
            onPressed: list.loading ? null : () => list.load(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              '未完成 ${list.remainingCount} 项 · 共 ${list.todos.length} 条',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          _buildInput(),
          _buildFilters(list),
          Expanded(child: _buildBody(list)),
        ],
      ),
    );
  }

  Widget _buildInput() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                onSubmitted: (_) => _add(),
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: '想做点什么？',
                  border: InputBorder.none,
                ),
              ),
            ),
            DropdownButton<Priority>(
              value: _newPriority,
              underline: const SizedBox.shrink(),
              items: [
                for (final priority in Priority.values)
                  DropdownMenuItem(
                    value: priority,
                    child: Text(priority.label),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _newPriority = value ?? Priority.medium),
            ),
            IconButton.filled(
              tooltip: '添加',
              icon: const Icon(Icons.send),
              onPressed: _add,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildFilters(TodoList list) {
    Widget chip(TodoFilter filter, String label) => ChoiceChip(
          label: Text(label),
          selected: list.filter == filter,
          onSelected: (_) => list.setFilter(filter),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Wrap(
        spacing: 8,
        children: [
          chip(TodoFilter.all, '全部'),
          chip(TodoFilter.active, '未完成'),
          chip(TodoFilter.done, '已完成'),
        ],
      ),
    );
  }

  Widget _buildBody(TodoList list) {
    // 1) 首次加载中
    if (list.loading && list.todos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // 2) 加载失败且没有任何数据
    if (list.error != null && list.todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(list.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: list.load,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }
    // 3) 空列表 / 筛选后为空
    final visible = list.visibleTodos;
    if (visible.isEmpty) {
      return Center(
        child: Text(list.todos.isEmpty ? '还没有待办，输入一条试试' : '这个筛选下没有内容'),
      );
    }
    // 4) 正常列表
    return RefreshIndicator(
      onRefresh: list.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: visible.length,
        separatorBuilder: (_, _) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final todo = visible[index];
          return Dismissible(
            key: ValueKey('todo_${todo.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 28),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            onDismissed: (_) => _remove(todo),
            child: TodoTile(todo: todo, onToggle: _toggle, onDeleted: _remove),
          );
        },
      ),
    );
  }
}