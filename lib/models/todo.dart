enum Priority { low, medium, high } // 低、中、高三种优先级

// 辅助 json 解析
Priority priorityFromName(String? name) => switch (name) {
  'high' => Priority.high,
  'medium' => Priority.medium,
  'low' => Priority.low,
  _ => Priority.low,
};

// 针对已有类型进行拓展，可以给一个类型增加成员
extension PriorityLabel on Priority {
  String get label => switch (this) {
    Priority.high => '高',
    Priority.medium => '中',
    Priority.low => '低',
  };
}

// Todo 的数据模型
class Todo {
  // 构造函数
  Todo({
    required this.id,
    required this.title,
    required this.completed,
    required this.priority,
    required this.createdAt
  });

  // 基本类型定义
  final String id;
  final String title;
  final bool completed;
  final Priority priority;
  final DateTime createdAt;

  // 工厂函数，解析 json 到数据模型
  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'].toString(),
    title: json['title'].toString(),
    completed: json['completed'] as bool,
    priority: priorityFromName(json['priority'] as String?),
    createdAt: DateTime.tryParse(json['createdAt'] as String)?.toLocal() ?? DateTime.now()
  );

  // 将数据模型拼装为 json
  Map<String, dynamic> toJson() => {
    'title': title,
    'completed': completed,
    'priority': priority.name,
    'createdAt': createdAt.toUtc().toIso8601String()
  };

  // 当仅改一条数据的时候会使用
  // 不改旧对象，复制一个新对象并替换需要更换的字段
  Todo copyWith({String? title, bool? completed, Priority? priority}) => Todo(
    id: id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
    priority: priority ?? this.priority,
    createdAt: createdAt
  );
}
