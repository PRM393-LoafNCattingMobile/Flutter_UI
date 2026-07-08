import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('sendAdminMessage preserves Vietnamese text in request and response', () async {
    SharedPreferences.setMockInitialValues({
      'authUser': jsonEncode({
        'userId': 1,
        'name': 'Admin',
        'email': 'admin@example.com',
        'phoneNumber': '0900000000',
        'roleName': 'Admin',
        'token': 'test-token',
      }),
    });

    final client = _RecordingClient();
    final api = ApiService(client: client);

    final messages = await api.sendAdminMessage(
      22,
      'Xin chào tiếng Việt: ă â đ ê ô ơ ư',
    );

    expect(client.lastRequest?.url.path, '/api/staff/conversations/22/messages');
    expect(
      client.lastRequest?.headers['content-type'],
      contains('charset=utf-8'),
    );
    expect(
      jsonDecode(client.lastRequestBody ?? '') as Map<String, dynamic>,
      {'content': 'Xin chào tiếng Việt: ă â đ ê ô ơ ư'},
    );
    expect(messages, hasLength(1));
    expect(messages.single.conversationId, 22);
    expect(messages.single.content, 'Xin chào tiếng Việt: ă â đ ê ô ơ ư');
  });
}

class _RecordingClient extends http.BaseClient {
  http.BaseRequest? lastRequest;
  String? lastRequestBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    if (request is http.Request) {
      lastRequestBody = request.body;
    }

    final body = jsonEncode([
      {
        'messageId': 1,
        'conversationId': 22,
        'senderUserId': 7,
        'sender': 'store',
        'content': 'Xin chào tiếng Việt: ă â đ ê ô ơ ư',
        'isRead': false,
        'sentAt': '2026-07-02T10:00:00Z',
      }
    ]);

    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
