import "dart:async";
import "dart:convert";
import "dart:io";

import 'package:dart_openai_sdk/dart_openai_sdk.dart';
import "package:dart_openai_sdk/src/core/builder/context_headers.dart";
import "package:dart_openai_sdk/src/core/config/client_config.dart";
import "package:dart_openai_sdk/src/core/utils/logger.dart";
import "package:http/http.dart" as http;
import "package:meta/meta.dart";

import '../constants/strings.dart';
import '../utils/extensions.dart';

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
                if (line.startsWith(OpenAIStrings.streamResponseStart)) {
                  final String data = line.substring(6);
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

  static http.Client _streamingHttpClient() {
    return createClient();
  }
}