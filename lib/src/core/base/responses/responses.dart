import 'package:http/http.dart' as http;

import '../../models/responses/responses.dart';

abstract class OpenAIResponsesBase {
  String get endpoint;

  Future<OpenAiResponse> create({
    required dynamic input,
    String? model,
    bool? background,
    dynamic conversation,
    List<String>? include,
    dynamic instructions,
    int? maxOutputTokens,
    int? maxToolCalls,
    Map<String, dynamic>? metadata,
    bool? parallelToolCalls,
    String? previousResponseId,
    dynamic prompt,
    String? promptCacheKey,
    dynamic reasoning,
    String? safetyIdentifier,
    String? serviceTier,
    bool? store,
    num? temperature,
    dynamic text,
    dynamic toolChoice,
    List? tools,
    int? topLogprobs,
    num? topP,
    String? truncation,
    http.Client? client,
  });

  Stream<Map<String, dynamic>> createStream({
    required dynamic input,
    String? model,
    dynamic conversation,
    List<String>? include,
    dynamic instructions,
    int? maxOutputTokens,
    int? maxToolCalls,
    Map<String, dynamic>? metadata,
    bool? parallelToolCalls,
    String? previousResponseId,
    dynamic prompt,
    String? promptCacheKey,
    dynamic reasoning,
    String? safetyIdentifier,
    String? serviceTier,
    bool? store,
    num? temperature,
    dynamic text,
    dynamic toolChoice,
    List? tools,
    int? topLogprobs,
    num? topP,
    String? truncation,
    http.Client? client,
  });

  Future<OpenAiResponse> get({
    required String responseId,
    List<String>? include,
    bool? includeObfuscation,
    int? startingAfter,
    http.Client? client,
  });

  Future<void> delete({required String responseId, http.Client? client});

  Future<OpenAiResponse> cancel({
    required String responseId,
    http.Client? client,
  });

  Future<OpenAiResponseInputItemsList> listInputItems({
    required String responseId,
    String? after,
    List<String>? include,
    int? limit,
    String? order,
    http.Client? client,
  });

  Future<int> getInputTokenCounts({
    dynamic conversation,
    dynamic input,
    dynamic instructions,
    String? model,
    bool? parallelToolCalls,
    String? previousResponseId,
    dynamic reasoning,
    dynamic text,
    dynamic toolChoice,
    List? tools,
    String? truncation,
    http.Client? client,
  });

  Future<OpenAiResponse> compact({
    dynamic input,
    String? model,
    dynamic instructions,
    String? previousResponseId,
    dynamic reasoning,
    dynamic text,
    dynamic toolChoice,
    List? tools,
    String? truncation,
    http.Client? client,
  });
}
