import "dart:async";
import "dart:convert";
import "dart:io";

import 'package:dart_openai_sdk/dart_openai_sdk.dart';
import "package:dart_openai_sdk/src/core/builder/context_headers.dart";
import "package:dart_openai_sdk/src/core/utils/logger.dart";
import "package:http/http.dart" as http;
import "package:meta/meta.dart";

import '../constants/strings.dart';

import "../utils/streaming_http_client_default.dart"
    if (dart.library.js) 'package:dart_openai_sdk/src/core/utils/streaming_http_client_web.dart'
    if (dart.library.io) 'package:dart_openai_sdk/src/core/utils/streaming_http_client_io.dart';

/// {@template contextual_networking_client}
/// A network client based on a configuration instance, not relying on global state.
/// All network request methods accept configuration parameters, supporting concurrent use of multiple instances.
/// {@endtemplate}
@protected
@immutable
abstract class ContextualNetworkingClient {
  /// GET request
  static Future<T> get<T>({
    required String from,
    required OpenAIClientConfig config,
    bool returnRawResponse = false,
    T Function(Map<String, dynamic>)? onSuccess,
    http.Client? client,
  }) async {
    if (config.showLogs) {
      OpenAILogger.logStartRequest(from);
    }

    final uri = Uri.parse(from);
    final headers = ContextualHeadersBuilder.build(config);

    final response = client == null
        ? await http
            .get(uri, headers: headers)
            .timeout(config.requestsTimeOut)
        : await client.get(uri, headers: headers);

    if (config.showResponsesLogs) {
      OpenAILogger.logResponseBody(response);
    }

    if (returnRawResponse) {
      return response.body as T;
    }

    if (config.showLogs) {
      OpenAILogger.requestToWithStatusCode(from, response.statusCode);
      OpenAILogger.startingDecoding();
    }

    final utf8decoder = Utf8Decoder();
    final convertedBody = utf8decoder.convert(response.bodyBytes);
    final Map<String, dynamic> decodedBody = _decodeToMap(convertedBody);

    if (config.showLogs) {
      OpenAILogger.decodedSuccessfully();
    }

    if (_doesErrorExists(decodedBody)) {
      final Map<String, dynamic> error =
          decodedBody[OpenAIStrings.errorFieldKey];
      final message = error[OpenAIStrings.messageFieldKey];
      final statusCode = response.statusCode;

      final exception = RequestFailedException(message, statusCode);
      if (config.showLogs) {
        OpenAILogger.errorOcurred(exception);
      }

      throw exception;
    } else {
      if (config.showLogs) {
        OpenAILogger.requestFinishedSuccessfully();
      }

      return onSuccess!(decodedBody);
    }
  }

  /// POST request
  static Future<T> post<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required OpenAIClientConfig config,
    Map<String, dynamic>? body,
    http.Client? client,
  }) async {
    if (config.showLogs) {
      OpenAILogger.logStartRequest(to);
    }

    final uri = Uri.parse(to);
    final headers = ContextualHeadersBuilder.build(config);
    final handledBody = body != null ? jsonEncode(body) : null;

    final response = client == null
        ? await http
            .post(uri, headers: headers, body: handledBody)
            .timeout(config.requestsTimeOut)
        : await client.post(uri, headers: headers, body: handledBody);

    if (config.showResponsesLogs) {
      OpenAILogger.logResponseBody(response);
    }

    if (config.showLogs) {
      OpenAILogger.requestToWithStatusCode(to, response.statusCode);
      OpenAILogger.startingDecoding();
    }

    Utf8Decoder utf8decoder = Utf8Decoder();
    final convertedBody = utf8decoder.convert(response.bodyBytes);
    final Map<String, dynamic> decodedBody = _decodeToMap(convertedBody);

    if (config.showLogs) {
      OpenAILogger.decodedSuccessfully();
    }

    if (_doesErrorExists(decodedBody)) {
      final Map<String, dynamic> error =
          decodedBody[OpenAIStrings.errorFieldKey];
      final message = error[OpenAIStrings.messageFieldKey];
      final statusCode = response.statusCode;

      final exception = RequestFailedException(message, statusCode);
      if (config.showLogs) {
        OpenAILogger.errorOcurred(exception);
      }

      throw exception;
    } else {
      if (config.showLogs) {
        OpenAILogger.requestFinishedSuccessfully();
      }

      return onSuccess(decodedBody);
    }
  }

  /// Checked JSON request used by newly added endpoints that need raw HTTP
  /// status handling without changing the behavior of existing API modules.
  static Future<T> postChecked<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required OpenAIClientConfig config,
    Map<String, dynamic>? body,
    http.Client? client,
  }) async {
    if (config.showLogs) OpenAILogger.logStartRequest(to);
    final uri = Uri.parse(to);
    final headers = ContextualHeadersBuilder.build(config);
    final encodedBody = body == null ? null : jsonEncode(body);
    final response = await (client == null
            ? http.post(uri, headers: headers, body: encodedBody)
            : client.post(uri, headers: headers, body: encodedBody))
        .timeout(config.requestsTimeOut);
    if (config.showResponsesLogs) OpenAILogger.logResponseBody(response);
    final decoded = _decodeCheckedResponse(response, to, config);
    return onSuccess(decoded);
  }

  /// Checked GET request used by newly added endpoints.
  static Future<T> getChecked<T>({
    required String from,
    required T Function(Map<String, dynamic>) onSuccess,
    required OpenAIClientConfig config,
    http.Client? client,
  }) async {
    if (config.showLogs) OpenAILogger.logStartRequest(from);
    final uri = Uri.parse(from);
    final headers = ContextualHeadersBuilder.build(config);
    final response = await (client == null
            ? http.get(uri, headers: headers)
            : client.get(uri, headers: headers))
        .timeout(config.requestsTimeOut);
    if (config.showResponsesLogs) OpenAILogger.logResponseBody(response);
    return onSuccess(_decodeCheckedResponse(response, from, config));
  }

  /// Checked DELETE request used by newly added endpoints.
  static Future<T> deleteChecked<T>({
    required String from,
    required T Function(Map<String, dynamic>) onSuccess,
    required OpenAIClientConfig config,
    http.Client? client,
  }) async {
    if (config.showLogs) OpenAILogger.logStartRequest(from);
    final uri = Uri.parse(from);
    final headers = ContextualHeadersBuilder.build(config);
    final response = await (client == null
            ? http.delete(uri, headers: headers)
            : client.delete(uri, headers: headers))
        .timeout(config.requestsTimeOut);
    if (config.showResponsesLogs) OpenAILogger.logResponseBody(response);
    if (response.statusCode == 204 && response.bodyBytes.isEmpty) {
      return onSuccess(const <String, dynamic>{});
    }
    return onSuccess(_decodeCheckedResponse(response, from, config));
  }

  /// Sends a byte-backed multipart file with checked status and JSON handling.
  static Future<T> multipartPostChecked<T>({
    required String to,
    required String fileField,
    required OpenAIFile file,
    required Map<String, String> fields,
    required T Function(Map<String, dynamic>) onSuccess,
    required OpenAIClientConfig config,
    http.Client? client,
  }) async {
    final ownsClient = client == null;
    final clientForUse = client ?? _streamingHttpClient();
    try {
      if (config.showLogs) OpenAILogger.logStartRequest(to);
      final request = http.MultipartRequest(
        OpenAIStrings.postMethod,
        Uri.parse(to),
      )
        ..headers.addAll(ContextualHeadersBuilder.buildForMultipart(config))
        ..fields.addAll(fields)
        ..files.add(
          http.MultipartFile.fromBytes(
            fileField,
            file.bytes,
            filename: file.fileName,
          ),
        );
      final streamed = await clientForUse
          .send(request)
          .timeout(config.requestsTimeOut);
      final response = await http.Response.fromStream(streamed)
          .timeout(config.requestsTimeOut);
      if (config.showResponsesLogs) OpenAILogger.logResponseBody(response);
      return onSuccess(_decodeCheckedResponse(response, to, config));
    } catch (error, stackTrace) {
      if (config.showLogs) OpenAILogger.errorOcurred(error);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      if (ownsClient) clientForUse.close();
    }
  }

  /// Retrieves non-JSON content while still checking HTTP error statuses.
  static Future<http.Response> getRawChecked({
    required String from,
    required OpenAIClientConfig config,
    http.Client? client,
  }) async {
    if (config.showLogs) OpenAILogger.logStartRequest(from);
    final uri = Uri.parse(from);
    final headers = ContextualHeadersBuilder.build(config);
    final response = await (client == null
            ? http.get(uri, headers: headers)
            : client.get(uri, headers: headers))
        .timeout(config.requestsTimeOut);
    if (config.showResponsesLogs) OpenAILogger.logResponseBody(response);
    if (config.showLogs) {
      OpenAILogger.requestToWithStatusCode(from, response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = utf8.decode(response.bodyBytes, allowMalformed: true);
      throw _requestFailedFromBody(
        body,
        _tryDecodeJsonMap(body),
        response.statusCode,
      );
    }
    return response;
  }

  static Map<String, dynamic> _decodeCheckedResponse(
    http.Response response,
    String url,
    OpenAIClientConfig config,
  ) {
    if (config.showLogs) {
      OpenAILogger.requestToWithStatusCode(url, response.statusCode);
      OpenAILogger.startingDecoding();
    }
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    Map<String, dynamic>? decoded;
    try {
      final value = jsonDecode(body);
      if (value is Map) decoded = Map<String, dynamic>.from(value);
    } on FormatException {
      decoded = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _requestFailedFromBody(body, decoded, response.statusCode);
    }
    if (decoded == null) {
      throw RequestFailedException(
        body.trim().isEmpty ? 'Expected a JSON object response' : body,
        response.statusCode,
      );
    }
    if (config.showLogs) OpenAILogger.decodedSuccessfully();
    return decoded;
  }

  static RequestFailedException _requestFailedFromBody(
    String body,
    Map<String, dynamic>? decoded,
    int statusCode,
  ) {
    if (decoded != null) {
      return _requestFailedFromMap(decoded, statusCode) ??
          RequestFailedException(
            body.trim().isEmpty
                ? 'Request failed with status $statusCode'
                : body,
            statusCode,
          );
    }
    return RequestFailedException(
      body.trim().isEmpty ? 'Request failed with status $statusCode' : body,
      statusCode,
    );
  }

  static RequestFailedException? _requestFailedFromMap(
    Map<String, dynamic> body,
    int statusCode,
  ) {
    final error = body[OpenAIStrings.errorFieldKey];
    if (error != null) {
      final message =
          error is Map ? error['message']?.toString() : error.toString();
      return RequestFailedException(
        message == null || message.isEmpty ? jsonEncode(body) : message,
        statusCode,
      );
    }
    if (_isRemoteBusinessError(body)) {
      final message = body['message']?.toString() ??
          body['data']?.toString() ??
          'Remote service error (code: ${body['code']})';
      return RequestFailedException(message, statusCode);
    }
    return null;
  }

  /// Responses-specific SSE path. The legacy [postStream] remains unchanged
  /// so existing Chat and audio-compatible callers keep their current parser.
  static Stream<T> postEventStream<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required Map<String, dynamic> body,
    required OpenAIClientConfig config,
    http.Client? client,
    Set<String> terminalEventTypes = const {},
  }) async* {
    final ownsClient = client == null;
    final clientForUse = client ?? _streamingHttpClient();
    try {
      if (config.showLogs) OpenAILogger.logStartRequest(to);
      final headers = ContextualHeadersBuilder.build(config)
        ..['Accept'] = 'text/event-stream';
      final request = http.Request(OpenAIStrings.postMethod, Uri.parse(to))
        ..headers.addAll(headers)
        ..body = jsonEncode(body);
      final response =
          await clientForUse.send(request).timeout(config.requestsTimeOut);
      if (config.showLogs) {
        OpenAILogger.requestToWithStatusCode(to, response.statusCode);
        OpenAILogger.startReadStreamResponse();
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorBody = await response.stream
            .timeout(config.requestsTimeOut)
            .transform(utf8.decoder)
            .join();
        throw _requestFailedFromBody(
            errorBody, _tryDecodeJsonMap(errorBody), response.statusCode);
      }
      await for (final event in _parseSseEvents(
        response.stream.timeout(config.requestsTimeOut),
        response.statusCode,
      )) {
        yield onSuccess(event);
        if (terminalEventTypes.contains(event['type'])) return;
      }
    } catch (error, stackTrace) {
      if (config.showLogs) OpenAILogger.errorOcurred(error);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      if (ownsClient) clientForUse.close();
    }
  }

  static Map<String, dynamic>? _tryDecodeJsonMap(String body) {
    try {
      final value = jsonDecode(body);
      return value is Map ? Map<String, dynamic>.from(value) : null;
    } on FormatException {
      return null;
    }
  }

  static Stream<Map<String, dynamic>> _parseSseEvents(
    Stream<List<int>> byteStream,
    int statusCode,
  ) async* {
    final eventData = <String>[];
    final rawBody = StringBuffer();
    var emittedEvent = false;

    Map<String, dynamic> decodeEvent(String data) {
      if (data.trim() == OpenAIStrings.streamResponseEnd) {
        return const {'type': '__done__'};
      }
      final decoded = jsonDecode(data);
      if (decoded is! Map) {
        throw FormatException('Expected an SSE JSON object, got: $data');
      }
      final event = Map<String, dynamic>.from(decoded);
      if (event['type'] == 'error') {
        final message = event['message']?.toString() ?? jsonEncode(event);
        throw RequestFailedException(message, statusCode);
      }
      return event;
    }

    final lines = byteStream.transform(utf8.decoder).transform(LineSplitter());
    await for (final line in lines) {
      if (line.isEmpty) {
        if (eventData.isEmpty) continue;
        final event = decodeEvent(eventData.join('\n'));
        eventData.clear();
        if (event['type'] == '__done__') {
          OpenAILogger.streamResponseDone();
          return;
        }
        emittedEvent = true;
        yield event;
        continue;
      }
      if (line.startsWith(':')) continue;
      if (line.startsWith('data:')) {
        var value = line.substring(5);
        if (value.startsWith(' ')) value = value.substring(1);
        eventData.add(value);
      } else if (!line.startsWith('event:') &&
          !line.startsWith('id:') &&
          !line.startsWith('retry:')) {
        rawBody.writeln(line);
      }
    }

    if (eventData.isNotEmpty) {
      final event = decodeEvent(eventData.join('\n'));
      if (event['type'] == '__done__') {
        OpenAILogger.streamResponseDone();
        return;
      }
      emittedEvent = true;
      yield event;
    }
    final raw = rawBody.toString().trim();
    if (!emittedEvent && raw.isNotEmpty) {
      throw _requestFailedFromBody(raw, _tryDecodeJsonMap(raw), statusCode);
    }
  }

  /// POST streaming request
  static Stream<T> postStream<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required Map<String, dynamic> body,
    required OpenAIClientConfig config,
    http.Client? client,
  }) async* {
    try {
      final clientForUse = client ?? _streamingHttpClient();
      final uri = Uri.parse(to);
      final headers = ContextualHeadersBuilder.build(config);
      final httpMethod = OpenAIStrings.postMethod;
      final request = http.Request(httpMethod, uri);
      request.headers.addAll(headers);
      request.body = jsonEncode(body);

      if (config.showLogs) {
        OpenAILogger.logStartRequest(to);
      }

      try {
        final respond = await clientForUse.send(request);

        try {
          if (config.showLogs) {
            OpenAILogger.startReadStreamResponse();
          }

          final stream = respond.stream
              .transform(utf8.decoder)
              .transform(LineSplitter());

          try {
            String respondData = "";
            await for (final value
                in stream.where((event) => event.isNotEmpty)) {
              final data = value;
              respondData += data;

              final dataLines = data
                  .split("\n")
                  .where((element) => element.isNotEmpty)
                  .toList();

              for (String line in dataLines) {
                if (line.startsWith(OpenAIStrings.streamResponsePrefix)) {
                  final String data = line
                      .substring(OpenAIStrings.streamResponsePrefix.length)
                      .trimLeft();
                  if (data.contains(OpenAIStrings.streamResponseEnd)) {
                    if (config.showLogs) {
                      OpenAILogger.streamResponseDone();
                    }
                    break;
                  }
                  final decoded = jsonDecode(data) as Map<String, dynamic>;
                  yield onSuccess(decoded);
                  continue;
                }

                Map<String, dynamic> decodedData = {};
                try {
                  decodedData = _decodeToMap(respondData);
                } catch (error) {
                  // ignore, data has not been received
                }

                if (_doesErrorExists(decodedData)) {
                  final error = decodedData[OpenAIStrings.errorFieldKey]
                      as Map<String, dynamic>;
                  var message = error[OpenAIStrings.messageFieldKey] as String;
                  message = message.isEmpty ? jsonEncode(error) : message;
                  final statusCode = respond.statusCode;
                  final exception = RequestFailedException(message, statusCode);

                  yield* Stream<T>.error(exception);
                } else if (_isRemoteBusinessError(decodedData)) {
                  final message = decodedData['message']?.toString() ??
                      decodedData['data']?.toString() ??
                      'Remote service error (code: ${decodedData['code']})';
                  yield* Stream<T>.error(
                    RequestFailedException(message, respond.statusCode),
                  );
                }
              }
            }
          } catch (error, stackTrace) {
            yield* Stream<T>.error(error, stackTrace);
          }
        } catch (error, stackTrace) {
          yield* Stream<T>.error(error, stackTrace);
        }
      } catch (e) {
        yield* Stream<T>.error(e);
      }
    } catch (e) {
      yield* Stream<T>.error(e);
    }
  }

  /// File upload request
  static Future<T> fileUpload<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required Map<String, String> body,
    required File file,
    required OpenAIClientConfig config,
    Map<String, dynamic> Function(String rawResponse)? responseMapAdapter,
  }) async {
    if (config.showLogs) {
      OpenAILogger.logStartRequest(to);
    }

    final uri = Uri.parse(to);
    final headers = ContextualHeadersBuilder.buildForMultipart(config);

    final httpMethod = OpenAIStrings.postMethod;
    final request = http.MultipartRequest(httpMethod, uri);

    request.headers.addAll(headers);

    final multiPartFile = await http.MultipartFile.fromPath("file", file.path);

    request.files.add(multiPartFile);
    request.fields.addAll(body);

    final http.StreamedResponse response =
        await request.send().timeout(config.requestsTimeOut);

    final String responseBody = await response.stream.bytesToString();

    if (config.showResponsesLogs) {
      OpenAILogger.logResponseBody(responseBody);
    }

    if (config.showLogs) {
      OpenAILogger.requestToWithStatusCode(to, response.statusCode);
      OpenAILogger.startingDecoding();
    }

    var resultBody;

    resultBody = switch ((responseBody.canBeParsedToJson, responseMapAdapter)) {
      (true, _) => _decodeToMap(responseBody),
      (_, null) => responseBody,
      (_, final func) => func!(responseBody),
    };

    if (config.showLogs) {
      OpenAILogger.decodedSuccessfully();
    }

    if (_doesErrorExists(resultBody)) {
      final Map<String, dynamic> error =
          resultBody[OpenAIStrings.errorFieldKey];
      final message = error[OpenAIStrings.messageFieldKey];
      final statusCode = response.statusCode;

      final exception = RequestFailedException(message, statusCode);
      if (config.showLogs) {
        OpenAILogger.errorOcurred(exception);
      }

      throw exception;
    } else {
      if (config.showLogs) {
        OpenAILogger.requestFinishedSuccessfully();
      }

      return onSuccess(resultBody);
    }
  }

  /// DELETE request
  static Future<T> delete<T>({
    required String from,
    required T Function(Map<String, dynamic> response) onSuccess,
    required OpenAIClientConfig config,
    http.Client? client,
  }) async {
    if (config.showLogs) {
      OpenAILogger.logStartRequest(from);
    }

    final headers = ContextualHeadersBuilder.build(config);
    final uri = Uri.parse(from);

    final response = client == null
        ? await http
            .delete(uri, headers: headers)
            .timeout(config.requestsTimeOut)
        : await client.delete(uri, headers: headers);

    if (config.showResponsesLogs) {
      OpenAILogger.logResponseBody(response);
    }

    if (config.showLogs) {
      OpenAILogger.requestToWithStatusCode(from, response.statusCode);
      OpenAILogger.startingDecoding();
    }

    final Map<String, dynamic> decodedBody = _decodeToMap(response.body);

    if (config.showLogs) {
      OpenAILogger.decodedSuccessfully();
    }

    if (_doesErrorExists(decodedBody)) {
      final Map<String, dynamic> error =
          decodedBody[OpenAIStrings.errorFieldKey];
      final String message = error[OpenAIStrings.messageFieldKey];
      final statusCode = response.statusCode;

      final exception = RequestFailedException(message, statusCode);
      if (config.showLogs) {
        OpenAILogger.errorOcurred(exception);
      }

      throw exception;
    } else {
      if (config.showLogs) {
        OpenAILogger.requestFinishedSuccessfully();
      }

      return onSuccess(decodedBody);
    }
  }

  /// Image edit form request
  static Future imageEditForm<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required File image,
    required File? mask,
    required Map<String, String> body,
    required OpenAIClientConfig config,
  }) async {
    if (config.showLogs) {
      OpenAILogger.logStartRequest(to);
    }

    final uri = Uri.parse(to);
    final headers = ContextualHeadersBuilder.buildForMultipart(config);
    final httpMethod = OpenAIStrings.postMethod;
    final request = http.MultipartRequest(httpMethod, uri);

    request.headers.addAll(headers);

    final file = await http.MultipartFile.fromPath("image", image.path);
    final maskFile = mask != null
        ? await http.MultipartFile.fromPath("mask", mask.path)
        : null;

    request.files.add(file);
    if (maskFile != null) request.files.add(maskFile);
    request.fields.addAll(body);

    final response = await request.send().timeout(config.requestsTimeOut);

    if (config.showLogs) {
      OpenAILogger.requestToWithStatusCode(to, response.statusCode);
      OpenAILogger.startingDecoding();
    }

    final String encodedBody = await response.stream.bytesToString();

    if (config.showResponsesLogs) {
      OpenAILogger.logResponseBody(encodedBody);
    }

    final Map<String, dynamic> decodedBody = _decodeToMap(encodedBody);

    if (config.showLogs) {
      OpenAILogger.decodedSuccessfully();
    }

    if (_doesErrorExists(decodedBody)) {
      final Map<String, dynamic> error =
          decodedBody[OpenAIStrings.errorFieldKey];
      final message = error[OpenAIStrings.messageFieldKey];
      final statusCode = response.statusCode;

      final exception = RequestFailedException(message, statusCode);
      if (config.showLogs) {
        OpenAILogger.errorOcurred(exception);
      }

      throw exception;
    } else {
      if (config.showLogs) {
        OpenAILogger.requestFinishedSuccessfully();
      }

      return onSuccess(decodedBody);
    }
  }

  /// Image variation form request
  static Future<T> imageVariationForm<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required Map<String, String> body,
    required File image,
    required OpenAIClientConfig config,
  }) async {
    if (config.showLogs) {
      OpenAILogger.logStartRequest(to);
    }

    final httpMethod = OpenAIStrings.postMethod;
    final request = http.MultipartRequest(httpMethod, Uri.parse(to));

    request.headers.addAll(ContextualHeadersBuilder.buildForMultipart(config));

    final imageFile = await http.MultipartFile.fromPath("image", image.path);

    request.fields.addAll(body);
    request.files.add(imageFile);

    final http.StreamedResponse response =
        await request.send().timeout(config.requestsTimeOut);

    if (config.showLogs) {
      OpenAILogger.requestToWithStatusCode(to, response.statusCode);
      OpenAILogger.startingDecoding();
    }

    final String encodedBody = await response.stream.bytesToString();

    if (config.showResponsesLogs) {
      OpenAILogger.logResponseBody(encodedBody);
    }

    final Map<String, dynamic> decodedBody = _decodeToMap(encodedBody);

    if (config.showLogs) {
      OpenAILogger.decodedSuccessfully();
    }

    if (_doesErrorExists(decodedBody)) {
      final Map<String, dynamic> error =
          decodedBody[OpenAIStrings.errorFieldKey];
      final message = error[OpenAIStrings.messageFieldKey];
      final statusCode = response.statusCode;

      final exception = RequestFailedException(message, statusCode);
      if (config.showLogs) {
        OpenAILogger.errorOcurred(exception);
      }

      throw exception;
    } else {
      if (config.showLogs) {
        OpenAILogger.requestFinishedSuccessfully();
      }

      return onSuccess(decodedBody);
    }
  }

  /// POST request and expect file response
  static Future<File> postAndExpectFileResponse({
    required String to,
    required File Function(File fileRes) onFileResponse,
    required String outputFileName,
    required Directory? outputDirectory,
    required OpenAIClientConfig config,
    Map<String, dynamic>? body,
    http.Client? client,
    String? fileExtension,
  }) async {
    if (config.showLogs) {
      OpenAILogger.logStartRequest(to);
    }

    final uri = Uri.parse(to);
    final headers = ContextualHeadersBuilder.build(config);
    final handledBody = body != null ? jsonEncode(body) : null;

    final response = client == null
        ? await http
            .post(uri, headers: headers, body: handledBody)
            .timeout(config.requestsTimeOut)
        : await client.post(uri, headers: headers, body: handledBody);

    if (config.showLogs) {
      OpenAILogger.requestToWithStatusCode(to, response.statusCode);
      OpenAILogger.startingTryCheckingForError();
    }

    final isJsonDecodedMap = _tryDecodedToMap(response.body);

    if (isJsonDecodedMap) {
      final decodedBody = _decodeToMap(response.body);

      if (_doesErrorExists(decodedBody)) {
        if (config.showLogs) {
          OpenAILogger.errorFoundInRequest();
        }

        final error = decodedBody[OpenAIStrings.errorFieldKey];
        final message = error[OpenAIStrings.messageFieldKey];
        final statusCode = response.statusCode;

        final exception = RequestFailedException(message, statusCode);
        if (config.showLogs) {
          OpenAILogger.errorOcurred(exception);
        }

        throw exception;
      } else {
        if (config.showLogs) {
          OpenAILogger.unexpectedResponseGotten();
        }

        throw OpenAIUnexpectedException(
          "Expected file response, but got non-error json response",
          response.body,
        );
      }
    } else {
      if (config.showLogs) {
        OpenAILogger.noErrorFound();
        OpenAILogger.requestFinishedSuccessfully();
      }

      String finalFileExtension;
      if (fileExtension != null && fileExtension.isNotEmpty) {
        finalFileExtension = fileExtension;
      } else {
        final fileTypeHeader = "content-type";
        finalFileExtension =
            response.headers[fileTypeHeader]?.split("/").last ?? "mp3";
      }

      final fileName = outputFileName + "." + finalFileExtension;

      File file = File(
        "${outputDirectory != null ? outputDirectory.path : ''}" +
            "/" +
            fileName,
      );

      if (config.showLogs) {
        OpenAILogger.creatingFile(fileName);
      }

      await file.create();

      if (config.showLogs) {
        OpenAILogger.fileCreatedSuccessfully(fileName);
        OpenAILogger.writingFileContent(fileName);
      }

      file = await file.writeAsBytes(
        response.bodyBytes,
        mode: FileMode.write,
      );

      if (config.showLogs) {
        OpenAILogger.fileContentWrittenSuccessfully(fileName);
      }

      return onFileResponse(file);
    }
  }

  // Helper methods
  static Map<String, dynamic> _decodeToMap(String responseBody) {
    try {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Failed to decode JSON: $e');
    }
  }

  static bool _tryDecodedToMap(String responseBody) {
    try {
      jsonDecode(responseBody) as Map<String, dynamic>;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool _doesErrorExists(Map<String, dynamic> decodedResponseBody) {
    return decodedResponseBody[OpenAIStrings.errorFieldKey] != null;
  }

  /// Detects non-OpenAI business errors such as `{"code": 30015, "message": "..."}`.
  static bool _isRemoteBusinessError(Map<String, dynamic> body) {
    final code = body['code'];
    return code is int && code != 0 && body.containsKey('message');
  }

  static http.Client _streamingHttpClient() {
    return createClient();
  }
}
