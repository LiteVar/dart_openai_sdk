import 'dart:convert';

import 'package:dart_openai_sdk/dart_openai_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('Responses API', () {
    test('is available through the legacy singleton facade', () {
      OpenAI.apiKey = 'legacy-key';

      expect(OpenAI.instance.responses.endpoint, '/responses');
    });

    test('uses the owning client config and parses an in-progress response',
        () async {
      late http.BaseRequest capturedRequest;
      final transport = _ScriptedClient((request) async {
        capturedRequest = request;
        return _jsonResponse(request, {
          'id': 'resp_123',
          'object': 'response',
          'created_at': 1,
          'status': 'in_progress',
          'model': 'test-model',
          'output': [
            {
              'type': 'message',
              'content': [
                {'type': 'output_text', 'text': 'hello'},
              ],
            },
          ],
        });
      });
      final client = OpenAIClient(
        apiKey: 'client-a-key',
        baseUrl: 'https://client-a.example/v1',
        organization: 'org-a',
        showLogs: false,
      );

      final response = await client.responses.create(
        model: 'test-model',
        input: 'Say hello',
        previousResponseId: 'resp_previous',
        reasoning: {'effort': 'high'},
        client: transport,
      );

      expect(capturedRequest.url.toString(),
          'https://client-a.example/v1/responses');
      expect(capturedRequest.headers['Authorization'], 'Bearer client-a-key');
      expect(capturedRequest.headers['OpenAI-Organization'], 'org-a');
      final requestBody = jsonDecode((capturedRequest as http.Request).body)
          as Map<String, dynamic>;
      expect(requestBody['input'], 'Say hello');
      expect(requestBody['previous_response_id'], 'resp_previous');
      expect(requestBody['reasoning'], {'effort': 'high'});
      expect(response.status, OpenAiResponseStatus.inProgress);
      expect(response.outputText, 'hello');
      transport.close();
    });

    test('stream emits SSE events once and ends on response.completed',
        () async {
      late http.BaseRequest capturedRequest;
      final transport = _ScriptedClient((request) async {
        capturedRequest = request;
        final bytes = utf8.encode(
          'event: response.created\n'
          'data: {"type":"response.created","sequence_number":0}\n\n'
          'event: response.completed\n'
          'data: {"type":"response.completed","sequence_number":1}\n\n'
          'data: [DONE]\n\n',
        );
        final chunks = <List<int>>[];
        for (var i = 0; i < bytes.length; i += 7) {
          chunks.add(bytes.sublist(i, (i + 7).clamp(0, bytes.length)));
        }
        return http.StreamedResponse(
          Stream<List<int>>.fromIterable(chunks),
          200,
          request: request,
          headers: const {'content-type': 'text/event-stream'},
        );
      });
      final client = OpenAIClient(
        apiKey: 'stream-key',
        baseUrl: 'https://stream.example/v1',
        showLogs: false,
      );

      final events = await client.responses
          .createStream(model: 'test-model', input: 'Hi', client: transport)
          .toList();

      expect(capturedRequest.url.toString(),
          'https://stream.example/v1/responses');
      final requestBody = jsonDecode((capturedRequest as http.Request).body)
          as Map<String, dynamic>;
      expect(requestBody['stream'], isTrue);
      expect(events.map((event) => event['type']), [
        'response.created',
        'response.completed',
      ]);
      transport.close();
    });

    test('surfaces a non-JSON HTTP error as RequestFailedException', () async {
      final transport =
          _ScriptedClient((request) async => http.StreamedResponse(
                Stream.value(utf8.encode('<html>gateway error</html>')),
                502,
                request: request,
              ));
      final client = OpenAIClient(
        apiKey: 'error-key',
        baseUrl: 'https://error.example/v1',
        showLogs: false,
      );

      await expectLater(
        client.responses.create(
          model: 'test-model',
          input: 'Hi',
          client: transport,
        ),
        throwsA(
          isA<RequestFailedException>()
              .having((error) => error.statusCode, 'statusCode', 502)
              .having((error) => error.message, 'message', contains('gateway')),
        ),
      );
      transport.close();
    });

    test('accepts integer input token counts', () async {
      final transport = _ScriptedClient(
          (request) async => _jsonResponse(request, {'input_tokens': 37}));
      final client = OpenAIClient(
        apiKey: 'tokens-key',
        baseUrl: 'https://tokens.example/v1',
        showLogs: false,
      );

      final count = await client.responses.getInputTokenCounts(
        model: 'test-model',
        input: 'Count me',
        client: transport,
      );

      expect(count, 37);
      transport.close();
    });

    test('encodes response IDs and query parameters for retrieval', () async {
      late http.BaseRequest capturedRequest;
      final transport = _ScriptedClient((request) async {
        capturedRequest = request;
        return _jsonResponse(request, {
          'id': 'resp_123',
          'created_at': 1,
          'status': 'completed',
          'output': [],
        });
      });
      final client = OpenAIClient(
        apiKey: 'get-key',
        baseUrl: 'https://get.example/v1',
        showLogs: false,
      );

      await client.responses.get(
        responseId: 'resp/with space',
        include: const ['reasoning.encrypted_content', 'output_text'],
        includeObfuscation: true,
        startingAfter: 7,
        client: transport,
      );

      expect(capturedRequest.url.path, '/v1/responses/resp%2Fwith%20space');
      expect(capturedRequest.url.queryParameters, {
        'include': 'reasoning.encrypted_content,output_text',
        'include_obfuscation': 'true',
        'starting_after': '7',
      });
      transport.close();
    });

    test('lists input items with pagination and preserves raw item maps',
        () async {
      late http.BaseRequest capturedRequest;
      final transport = _ScriptedClient((request) async {
        capturedRequest = request;
        return _jsonResponse(request, {
          'object': 'list',
          'data': [
            {'id': 'item_1', 'type': 'message', 'role': 'user'},
          ],
          'has_more': true,
          'first_id': 'item_1',
          'last_id': 'item_1',
        });
      });
      final client = OpenAIClient(
        apiKey: 'items-key',
        baseUrl: 'https://items.example/v1',
        showLogs: false,
      );

      final items = await client.responses.listInputItems(
        responseId: 'resp 1',
        after: 'item/previous',
        include: const ['message.output_text.logprobs'],
        limit: 20,
        order: 'asc',
        client: transport,
      );

      expect(capturedRequest.url.path, '/v1/responses/resp%201/input_items');
      expect(capturedRequest.url.queryParameters, {
        'after': 'item/previous',
        'include': 'message.output_text.logprobs',
        'limit': '20',
        'order': 'asc',
      });
      expect(items.hasMore, isTrue);
      expect(items.toMap()['data'], [
        {'id': 'item_1', 'type': 'message', 'role': 'user'},
      ]);
      transport.close();
    });

    test('compacts with input context using the compact endpoint', () async {
      late http.BaseRequest capturedRequest;
      final transport = _ScriptedClient((request) async {
        capturedRequest = request;
        return _jsonResponse(request, {
          'id': 'resp_compact',
          'object': 'response.compaction',
          'created_at': 1,
          'output': [
            {'type': 'compaction', 'encrypted_content': 'opaque'},
          ],
        });
      });
      final client = OpenAIClient(
        apiKey: 'compact-key',
        baseUrl: 'https://compact.example/v1',
        showLogs: false,
      );

      final response = await client.responses.compact(
        model: 'test-model',
        input: const [
          {'role': 'user', 'content': 'Earlier context'},
        ],
        previousResponseId: 'resp_previous',
        client: transport,
      );

      expect(capturedRequest.url.path, '/v1/responses/compact');
      final requestBody = jsonDecode((capturedRequest as http.Request).body)
          as Map<String, dynamic>;
      expect(requestBody['input'], isA<List>());
      expect(requestBody['previous_response_id'], 'resp_previous');
      expect(requestBody.containsKey('response_id'), isFalse);
      expect(response.status, OpenAiResponseStatus.completed);
      transport.close();
    });

    test('cancels and deletes a response through their dedicated routes',
        () async {
      final requestPaths = <String>[];
      final transport = _ScriptedClient((request) async {
        requestPaths.add('${request.method} ${request.url.path}');
        if (request.method == 'DELETE') {
          return _jsonResponse(request, {'id': 'resp_1', 'deleted': true});
        }
        return _jsonResponse(request, {
          'id': 'resp_1',
          'created_at': 1,
          'status': 'cancelled',
          'output': [],
        });
      });
      final client = OpenAIClient(
        apiKey: 'manage-key',
        baseUrl: 'https://manage.example/v1',
        showLogs: false,
      );

      final cancelled = await client.responses.cancel(
        responseId: 'resp_1',
        client: transport,
      );
      await client.responses.delete(responseId: 'resp_1', client: transport);

      expect(cancelled.status, OpenAiResponseStatus.cancelled);
      expect(requestPaths, [
        'POST /v1/responses/resp_1/cancel',
        'DELETE /v1/responses/resp_1',
      ]);
      transport.close();
    });
  });
}

http.StreamedResponse _jsonResponse(
  http.BaseRequest request,
  Map<String, dynamic> body,
) =>
    http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(body))),
      200,
      request: request,
    );

class _ScriptedClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest) _handler;

  _ScriptedClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _handler(request);
}
