import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:runoob/services/todo_services.dart';

void main() {
  test('deleteTodo sends DELETE to the todos resource', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('', 204);
    });
    addTearDown(client.close);

    await http.runWithClient(() async {
      final service = TodoServices(baseUrl: 'http://example.test');
      await service.deleteTodo('1');
    }, () => client);

    expect(capturedRequest.method, 'DELETE');
    expect(capturedRequest.url, Uri.parse('http://example.test/todos/1'));
  });
}
