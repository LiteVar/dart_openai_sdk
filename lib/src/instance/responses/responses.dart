import 'package:http/http.dart' as http;

import '../../core/base/responses/responses.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/models/responses/responses.dart';
import '../../core/networking/context_client.dart';

/// Responses API methods bound to one [OpenAIClientConfig].
class ContextualOpenAIResponses implements OpenAIResponsesBase {
  final OpenAIClientConfig config;

  @override
  String get endpoint => OpenAIStrings.endpoints.responses;

  ContextualOpenAIResponses(this.config);

  @override
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
  }) {
    return ContextualNetworkingClient.postChecked<OpenAiResponse>(
      to: ContextualApiUrlBuilder.build(config, endpoint),
      body: _requestBody(
        input: input,
        model: model,
        background: background,
        conversation: conversation,
        include: include,
        instructions: instructions,
        maxOutputTokens: maxOutputTokens,
        maxToolCalls: maxToolCalls,
        metadata: metadata,
        parallelToolCalls: parallelToolCalls,
        previousResponseId: previousResponseId,
        prompt: prompt,
        promptCacheKey: promptCacheKey,
        reasoning: reasoning,
        safetyIdentifier: safetyIdentifier,
        serviceTier: serviceTier,
        store: store,
        temperature: temperature,
        text: text,
        toolChoice: toolChoice,
        tools: tools,
        topLogprobs: topLogprobs,
        topP: topP,
        truncation: truncation,
      ),
      onSuccess: OpenAiResponse.fromMap,
      config: config,
      client: client,
    );
  }

  @override
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
  }) {
    return ContextualNetworkingClient.postEventStream<Map<String, dynamic>>(
      to: ContextualApiUrlBuilder.build(config, endpoint),
      body: {
        ..._requestBody(
          input: input,
          model: model,
          conversation: conversation,
          include: include,
          instructions: instructions,
          maxOutputTokens: maxOutputTokens,
          maxToolCalls: maxToolCalls,
          metadata: metadata,
          parallelToolCalls: parallelToolCalls,
          previousResponseId: previousResponseId,
          prompt: prompt,
          promptCacheKey: promptCacheKey,
          reasoning: reasoning,
          safetyIdentifier: safetyIdentifier,
          serviceTier: serviceTier,
          store: store,
          temperature: temperature,
          text: text,
          toolChoice: toolChoice,
          tools: tools,
          topLogprobs: topLogprobs,
          topP: topP,
          truncation: truncation,
        ),
        'stream': true,
      },
      onSuccess: (event) => event,
      config: config,
      client: client,
      terminalEventTypes: const {
        'response.completed',
        'response.failed',
        'response.incomplete',
      },
    );
  }

  @override
  Future<OpenAiResponse> get({
    required String responseId,
    List<String>? include,
    bool? includeObfuscation,
    int? startingAfter,
    http.Client? client,
  }) {
    final query = <String, String>{
      if (include != null) 'include': include.join(','),
      if (includeObfuscation != null)
        'include_obfuscation': includeObfuscation.toString(),
      if (startingAfter != null) 'starting_after': startingAfter.toString(),
    };

    return ContextualNetworkingClient.getChecked<OpenAiResponse>(
      from: _urlWithQuery(
        ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(responseId),
        ),
        query,
      ),
      onSuccess: OpenAiResponse.fromMap,
      config: config,
      client: client,
    );
  }

  @override
  Future<void> delete({required String responseId, http.Client? client}) async {
    await ContextualNetworkingClient.deleteChecked<bool>(
      from: ContextualApiUrlBuilder.build(
        config,
        endpoint,
        Uri.encodeComponent(responseId),
      ),
      onSuccess: (response) => response['deleted'] == true,
      config: config,
      client: client,
    );
  }

  @override
  Future<OpenAiResponse> cancel({
    required String responseId,
    http.Client? client,
  }) {
    return ContextualNetworkingClient.postChecked<OpenAiResponse>(
      to: ContextualApiUrlBuilder.build(
        config,
        endpoint,
        '${Uri.encodeComponent(responseId)}/cancel',
      ),
      onSuccess: OpenAiResponse.fromMap,
      config: config,
      client: client,
    );
  }

  @override
  Future<OpenAiResponseInputItemsList> listInputItems({
    required String responseId,
    String? after,
    List<String>? include,
    int? limit,
    String? order,
    http.Client? client,
  }) {
    final query = <String, String>{
      if (after != null) 'after': after,
      if (include != null) 'include': include.join(','),
      if (limit != null) 'limit': limit.toString(),
      if (order != null) 'order': order,
    };

    return ContextualNetworkingClient.getChecked<OpenAiResponseInputItemsList>(
      from: _urlWithQuery(
        ContextualApiUrlBuilder.build(
          config,
          endpoint,
          '${Uri.encodeComponent(responseId)}/input_items',
        ),
        query,
      ),
      onSuccess: OpenAiResponseInputItemsList.fromMap,
      config: config,
      client: client,
    );
  }

  @override
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
  }) async {
    final response =
        await ContextualNetworkingClient.postChecked<Map<String, dynamic>>(
      to: ContextualApiUrlBuilder.build(config, '$endpoint/input_tokens'),
      body: {
        if (conversation != null) 'conversation': conversation,
        if (input != null) 'input': input,
        if (instructions != null) 'instructions': instructions,
        if (model != null) 'model': model,
        if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
        if (previousResponseId != null)
          'previous_response_id': previousResponseId,
        if (reasoning != null) 'reasoning': reasoning,
        if (text != null) 'text': text,
        if (toolChoice != null) 'tool_choice': toolChoice,
        if (tools != null) 'tools': tools,
        if (truncation != null) 'truncation': truncation,
      },
      onSuccess: (response) => response,
      config: config,
      client: client,
    );
    final tokens = response['input_tokens'];
    if (tokens is int) return tokens;
    if (tokens is num) return tokens.toInt();
    final parsed = int.tryParse(tokens?.toString() ?? '');
    if (parsed == null) {
      throw FormatException('Invalid input_tokens value: $tokens');
    }
    return parsed;
  }

  @override
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
  }) {
    return ContextualNetworkingClient.postChecked<OpenAiResponse>(
      to: ContextualApiUrlBuilder.build(config, '$endpoint/compact'),
      body: {
        if (model != null) 'model': model,
        if (input != null) 'input': input,
        if (instructions != null) 'instructions': instructions,
        if (previousResponseId != null)
          'previous_response_id': previousResponseId,
        if (reasoning != null) 'reasoning': reasoning,
        if (text != null) 'text': text,
        if (toolChoice != null) 'tool_choice': toolChoice,
        if (tools != null) 'tools': tools,
        if (truncation != null) 'truncation': truncation,
      },
      onSuccess: OpenAiResponse.fromMap,
      config: config,
      client: client,
    );
  }

  Map<String, dynamic> _requestBody({
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
  }) =>
      {
        if (background != null) 'background': background,
        if (conversation != null) 'conversation': conversation,
        if (include != null) 'include': include,
        'input': input,
        if (instructions != null) 'instructions': instructions,
        if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens,
        if (maxToolCalls != null) 'max_tool_calls': maxToolCalls,
        if (metadata != null) 'metadata': metadata,
        if (model != null) 'model': model,
        if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
        if (previousResponseId != null)
          'previous_response_id': previousResponseId,
        if (prompt != null) 'prompt': prompt,
        if (promptCacheKey != null) 'prompt_cache_key': promptCacheKey,
        if (reasoning != null) 'reasoning': reasoning,
        if (safetyIdentifier != null) 'safety_identifier': safetyIdentifier,
        if (serviceTier != null) 'service_tier': serviceTier,
        if (store != null) 'store': store,
        if (temperature != null) 'temperature': temperature,
        if (text != null) 'text': text,
        if (toolChoice != null) 'tool_choice': toolChoice,
        if (tools != null) 'tools': tools,
        if (topLogprobs != null) 'top_logprobs': topLogprobs,
        if (topP != null) 'top_p': topP,
        if (truncation != null) 'truncation': truncation,
      };

  String _urlWithQuery(String url, Map<String, String> query) {
    if (query.isEmpty) return url;
    return Uri.parse(url).replace(queryParameters: query).toString();
  }
}
