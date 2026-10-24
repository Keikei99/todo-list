import 'package:flutter/material.dart';

import '../models/todo.dart';

const _priorityColors = {
  Priority.high: Color(0xFFD5484D),
  Priority.medium: Color(0xFFE8912D),
  Priority.low: Color(0xFF2F9E62),
};

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDeleted
  });

  final Todo todo;
  final ValueChanged<Todo> onToggle;
  final ValueChanged<Todo> onDeleted;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    final priorityColor = _priorityColors[todo.priority];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: todo.completed,
              onChanged: (_) => onToggle(todo),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo.completed ? outline : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor!.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          todo.priority.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${todo.createdAt.month}月${todo.createdAt.day}日',
                        style: TextStyle(fontSize: 12, color: outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: '删除',
              icon: const Icon(Icons.close),
              onPressed: () => onDeleted(todo),
            ),
          ],
        ),
      ),
    );    
  }
}