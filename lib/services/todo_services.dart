import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

// 异常类
class TodoApiException implements Exception {
  TodoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

// Service 类
class TodoServices {
  TodoServices({this.baseUrl = 'http://127.0.0.1:3000'});

  final String baseUrl;
  final http.Client _client = http.Client();

  // 接收到 response 后需要 decode
  dynamic _decode(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

  // 确认接收到的响应时 ok 的
  void _ensureOk(http.Response response, String action) {
    if (response.statusCode >= 400) {
      throw TodoApiException('$action失败（HTTP ${response.statusCode}）');
    }
  }

  // 拉取所有 Todo-list
  // curl -i -X GET http://127.0.0.1:3000/todos
  Future<List<Todo>> fetchTodos() async {
    final response = await _client.get(Uri.parse('$baseUrl/todos'));
    _ensureOk(response, '加载待办');
    final data = _decode(response) as List<dynamic>;
    return data
      .map((item) => Todo.fromJson(item as Map<String, dynamic>))
      .toList();
  }

  // 创建一个待办
  // curl -i -X POST http://127.0.0.1:3000/todos -d {...}
  Future<Todo> createTodo(Todo todo) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/todos'),
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(todo.toJson())
    );
    _ensureOk(response, '新建待办');
    return Todo.fromJson(_decode(response) as Map<String, dynamic>);
  }

  // 更新待办
  // curl -i -X PATCH http://127.0.0.1:3000/todos/<id> -d {...}
  Future<Todo> updateTodo(Todo todo) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/todos/${todo.id}'),
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(todo.toJson())
    );
    _ensureOk(response, '更新待办');
    return Todo.fromJson(_decode(response) as Map<String, dynamic>);
  }

  // 删除待办
  // curl -i -X DELETE http://127.0.0.1:3000/todos/<id>
  Future<void> deleteTodo(String id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/todos/$id'));
    _ensureOk(response, '删除待办');
  }
}

