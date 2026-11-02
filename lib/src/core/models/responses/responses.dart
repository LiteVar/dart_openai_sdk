int? _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

Map<String, dynamic>? _mapValue(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

String? _stringValue(dynamic value) => value?.toString();

/// A response returned by the OpenAI Responses API.
class OpenAiResponse {
  final String id;
  final String object;
  final DateTime createdAt;
  final OpenAiResponseStatus status;
  final dynamic input;
  final dynamic output;
  final dynamic instructions;
  final String model;
  final OpenAiResponseError? error;
  final OpenAiResponseIncompleteDetails? incompleteDetails;
  final int? maxOutputTokens;
  final int? maxToolCalls;
  final Map<String, dynamic>? metadata;
  final bool parallelToolCalls;
  final String? previousResponseId;
  final dynamic prompt;
  final String? promptCacheKey;
  final OpenAiResponseReasoning? reasoning;
  final String? safetyIdentifier;
  final String? serviceTier;
  final bool background;
  final OpenAiResponseConversation? conversation;
  final num? temperature;
  final OpenAiResponseText? text;
  final dynamic toolChoice;
  final List<dynamic> tools;
  final int? topLogprobs;
  final num? topP;
  final OpenAiResponseTruncation truncation;
  final bool store;
  final OpenAiResponseUsage? usage;

  const OpenAiResponse({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.status,
    required this.input,
    required this.output,
    required this.instructions,
    required this.model,
    this.error,
    this.incompleteDetails,
    this.maxOutputTokens,
    this.maxToolCalls,
    this.metadata,
    required this.parallelToolCalls,
    this.previousResponseId,
    this.prompt,
    this.promptCacheKey,
    this.reasoning,
    this.safetyIdentifier,
    this.serviceTier,
    required this.background,
    this.conversation,
    this.temperature,
    this.text,
    this.toolChoice,
    required this.tools,
    this.topLogprobs,
    this.topP,
    required this.truncation,
    required this.store,
    this.usage,
  });

  factory OpenAiResponse.fromMap(Map<String, dynamic> json) {
    final statusValue = json['status']?.toString().toLowerCase();
    final status = switch (statusValue) {
      null => OpenAiResponseStatus.completed,
      'in_progress' || 'inprogress' => OpenAiResponseStatus.inProgress,
      'cancelled' => OpenAiResponseStatus.cancelled,
      'queued' => OpenAiResponseStatus.queued,
      'completed' => OpenAiResponseStatus.completed,
      'incomplete' => OpenAiResponseStatus.incomplete,
      _ => OpenAiResponseStatus.failed,
    };
    final truncationValue = json['truncation']?.toString().toLowerCase();

    return OpenAiResponse(
      id: _stringValue(json['id']) ?? '',
      object: _stringValue(json['object']) ?? 'response',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (_intValue(json['created_at']) ?? 0) * 1000,
        isUtc: true,
      ),
      status: status,
      input: json['input'],
      output: json['output'] ?? const <dynamic>[],
      instructions: json['instructions'],
      model: _stringValue(json['model']) ?? '',
      error: _mapValue(json['error']) == null
          ? null
          : OpenAiResponseError.fromMap(_mapValue(json['error'])!),
      incompleteDetails: _mapValue(json['incomplete_details']) == null
          ? null
          : OpenAiResponseIncompleteDetails.fromMap(
              _mapValue(json['incomplete_details'])!,
            ),
      maxOutputTokens: _intValue(json['max_output_tokens']),
      maxToolCalls: _intValue(json['max_tool_calls']),
      metadata: _mapValue(json['metadata']),
      parallelToolCalls: json['parallel_tool_calls'] == true,
      previousResponseId: _stringValue(json['previous_response_id']),
      prompt: json['prompt'],
      promptCacheKey: _stringValue(json['prompt_cache_key']),
      reasoning: _mapValue(json['reasoning']) == null
          ? null
          : OpenAiResponseReasoning.fromMap(_mapValue(json['reasoning'])!),
      safetyIdentifier: _stringValue(json['safety_identifier']),
      serviceTier: _stringValue(json['service_tier']),
      background: json['background'] == true,
      conversation: _mapValue(json['conversation']) == null
          ? null
          : OpenAiResponseConversation.fromMap(
              _mapValue(json['conversation'])!,
            ),
      temperature:
          json['temperature'] is num ? json['temperature'] as num : null,
      text: _mapValue(json['text']) == null
          ? null
          : OpenAiResponseText.fromMap(_mapValue(json['text'])!),
      toolChoice: json['tool_choice'],
      tools:
          json['tools'] is List ? List<dynamic>.from(json['tools']) : const [],
      topLogprobs: _intValue(json['top_logprobs']),
      topP: json['top_p'] is num ? json['top_p'] as num : null,
      truncation: truncationValue == 'auto'
          ? OpenAiResponseTruncation.auto
          : OpenAiResponseTruncation.disabled,
      store: json['store'] != false,
      usage: _mapValue(json['usage']) == null
          ? null
          : OpenAiResponseUsage.fromMap(_mapValue(json['usage'])!),
    );
  }

  /// Concatenated text from output message items, when present.
  String get outputText {
    if (output is! List) return '';
    return (output as List)
        .whereType<Map>()
        .where((item) => item['type'] == 'message' && item['content'] is List)
        .expand((item) => item['content'] as List)
        .whereType<Map>()
        .where((item) => item['type'] == 'output_text')
        .map((item) => item['text']?.toString() ?? '')
        .join();
  }
}

enum OpenAiResponseStatus {
  failed,
  inProgress,
  cancelled,
  queued,
  completed,
  incomplete,
}

enum OpenAiResponseTruncation { auto, disabled }

class OpenAiResponseUsage {
  final int? inputTokens;
  final OpenAiResponseUsageInputTokenDetails? inputTokensDetails;
  final int? outputTokens;
  final OpenAiResponseUsageOutputTokensDetails? outputTokensDetails;
  final int? totalTokens;

  const OpenAiResponseUsage({
    this.inputTokens,
    this.inputTokensDetails,
    this.outputTokens,
    this.outputTokensDetails,
    this.totalTokens,
  });

  factory OpenAiResponseUsage.fromMap(Map<String, dynamic> json) =>
      OpenAiResponseUsage(
        inputTokens: _intValue(json['input_tokens']),
        inputTokensDetails: _mapValue(json['input_tokens_details']) == null
            ? null
            : OpenAiResponseUsageInputTokenDetails.fromMap(
                _mapValue(json['input_tokens_details'])!,
              ),
        outputTokens: _intValue(json['output_tokens']),
        outputTokensDetails: _mapValue(json['output_tokens_details']) == null
            ? null
            : OpenAiResponseUsageOutputTokensDetails.fromMap(
                _mapValue(json['output_tokens_details'])!,
              ),
        totalTokens: _intValue(json['total_tokens']),
      );
}

class OpenAiResponseUsageInputTokenDetails {
  final int? cachedTokens;
  final int? cacheWriteTokens;

  const OpenAiResponseUsageInputTokenDetails({
    this.cachedTokens,
    this.cacheWriteTokens,
  });

  factory OpenAiResponseUsageInputTokenDetails.fromMap(
    Map<String, dynamic> json,
  ) =>
      OpenAiResponseUsageInputTokenDetails(
        cachedTokens: _intValue(json['cached_tokens']),
        cacheWriteTokens: _intValue(json['cache_write_tokens']),
      );
}

class OpenAiResponseUsageOutputTokensDetails {
  final int? reasoningTokens;

  const OpenAiResponseUsageOutputTokensDetails({this.reasoningTokens});

  factory OpenAiResponseUsageOutputTokensDetails.fromMap(
    Map<String, dynamic> json,
  ) =>
      OpenAiResponseUsageOutputTokensDetails(
        reasoningTokens: _intValue(json['reasoning_tokens']),
      );
}

class OpenAiResponseText {
  final Map<String, dynamic> format;
  final String? verbosity;

  const OpenAiResponseText({required this.format, this.verbosity});

  factory OpenAiResponseText.fromMap(Map<String, dynamic> json) =>
      OpenAiResponseText(
        format: _mapValue(json['format']) ?? const {},
        verbosity: _stringValue(json['verbosity']),
      );
}

class OpenAiResponseReasoning {
  final String? effort;
  final String? summary;

  const OpenAiResponseReasoning({this.effort, this.summary});

  factory OpenAiResponseReasoning.fromMap(Map<String, dynamic> json) =>
      OpenAiResponseReasoning(
        effort: _stringValue(json['effort']),
        summary: _stringValue(json['summary']),
      );
}

class OpenAiResponseIncompleteDetails {
  final String? reason;

  const OpenAiResponseIncompleteDetails({this.reason});

  factory OpenAiResponseIncompleteDetails.fromMap(Map<String, dynamic> json) =>
      OpenAiResponseIncompleteDetails(reason: _stringValue(json['reason']));
}

class OpenAiResponseConversation {
  final String conversationId;

  const OpenAiResponseConversation({required this.conversationId});

  factory OpenAiResponseConversation.fromMap(Map<String, dynamic> json) =>
      OpenAiResponseConversation(
        conversationId: _stringValue(json['id']) ?? '',
      );
}

class OpenAiResponseError {
  final String? message;
  final String? code;

  const OpenAiResponseError({this.message, this.code});

  factory OpenAiResponseError.fromMap(Map<String, dynamic> json) =>
      OpenAiResponseError(
        message: _stringValue(json['message']),
        code: _stringValue(json['code']),
      );
}

class OpenAiResponseInputItemsList {
  final String object;
  final List<Map<String, dynamic>> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;

  const OpenAiResponseInputItemsList({
    required this.object,
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
  });

  factory OpenAiResponseInputItemsList.fromMap(Map<String, dynamic> json) =>
      OpenAiResponseInputItemsList(
        object: _stringValue(json['object']) ?? 'list',
        data: json['data'] is List
            ? (json['data'] as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList(growable: false)
            : const [],
        hasMore: json['has_more'] == true,
        firstId: _stringValue(json['first_id']),
        lastId: _stringValue(json['last_id']),
      );

  Map<String, dynamic> toMap() => {
        'object': object,
        'data': data,
        'has_more': hasMore,
        if (firstId != null) 'first_id': firstId,
        if (lastId != null) 'last_id': lastId,
      };
}
