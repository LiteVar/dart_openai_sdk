import 'package:dart_openai_sdk/src/core/builder/context_api_url.dart';
import 'package:dart_openai_sdk/src/core/config/client_config.dart';
import 'package:dart_openai_sdk/src/core/networking/context_client.dart';
import 'package:dart_openai_sdk/src/core/utils/extensions.dart';

import '../../core/base/chat/chat.dart';
import '../../core/constants/strings.dart';
import '../../core/models/chat/chat.dart';
import '../../core/models/tool/tool.dart';
import '../../core/utils/logger.dart';

import 'package:http/http.dart' as http;
import 'package:ovo/ovo.dart' as ovo;

/// {@template contextual_openai_chat}
/// A chat feature class based on a configuration instance, supporting concurrent use of multiple instances.
/// Unlike OpenAIChat, this class accepts configuration parameters without relying on global state.
/// {@endtemplate}
class ContextualOpenAIChat implements OpenAIChatBase {
  /// Client configuration instance
  final OpenAIClientConfig config;

  @override
  String get endpoint => OpenAIStrings.endpoints.chat;

  /// {@macro contextual_openai_chat}
  const ContextualOpenAIChat(this.config);

  /// Create a chat completion request
  ///
  /// The parameters are exactly the same as the original create method, but work based on instance configuration rather than global configuration.
  /// 
  /// [model] The model ID to use
  /// [messages] The list of messages
  /// [tools] The list of available tools
  /// [toolChoice] The tool selection strategy
  /// [temperature] Sampling temperature (0-2)
  /// [topP] Core sampling parameter
  /// [n] The number of generated completions
  /// [stop] The stop sequence
  /// [maxTokens] The maximum number of tokens
  /// [presencePenalty] The presence penalty
  /// [frequencyPenalty] The frequency penalty
  /// [logitBias] The token bias
  /// [user] The user identifier
  /// [responseFormat] The response format
  /// [seed] The random seed
  /// [logprobs] Whether to return log probabilities
  /// [topLogprobs] The number of top log probabilities
  /// [client] Custom HTTP client
  /// [enableThinking] Whether to enable thinking process
  @override
  Future<OpenAIChatCompletionModel> create({
    required String model,
    required List<OpenAIChatCompletionChoiceMessageModel> messages,
    List<OpenAIToolModel>? tools,
    toolChoice,
    double? temperature,
    double? topP,
    int? n,
    stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, dynamic>? logitBias,
    String? user,
    Object? responseFormat,
    int? seed,
    bool? logprobs,
    int? topLogprobs,
    http.Client? client,
    bool? enableThinking,
  }) async {
    if (config.showLogs) {
      OpenAILogger.logEndpoint(endpoint);
    }

    return await ContextualNetworkingClient.post(
      to: ContextualApiUrlBuilder.build(config, endpoint),
      config: config,
      body: {
        "model": model,
        "messages": messages.map((message) => message.toMap()).toList(),
        if (tools != null)
          "tools": tools.map((tool) => tool.toMap()).toList(growable: false),
        if (toolChoice != null) "tool_choice": toolChoice,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (n != null) "n": n,
        if (stop != null) "stop": stop,
        if (maxTokens != null) "max_tokens": maxTokens,
        if (presencePenalty != null) "presence_penalty": presencePenalty,
        if (frequencyPenalty != null) "frequency_penalty": frequencyPenalty,
        if (logitBias != null) "logit_bias": logitBias,
        if (user != null) "user": user,
        if (seed != null) "seed": seed,
        if (responseFormat is ovo.Object)
          "response_format": responseFormat.formatJsonData()
        else if (responseFormat is Map<String, dynamic>)
          "response_format": responseFormat,
        if (logprobs != null) "logprobs": logprobs,
        if (topLogprobs != null) "top_logprobs": topLogprobs,
        if (enableThinking != null) "enable_thinking": enableThinking,
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAIChatCompletionModel.fromMap(response);
      },
      client: client,
    );
  }

  /// Create a streaming chat completion request
  ///
  /// The parameters are exactly the same as the original createStream method, but work based on instance configuration rather than global configuration.
  ///
  /// [model] The model ID to use
  /// [messages] The list of messages
  /// [tools] The list of available tools
  /// [toolChoice] The tool selection strategy
  /// [temperature] Sampling temperature (0-2)
  /// [topP] Core sampling parameter
  /// [n] The number of generated completions
  /// [stop] The stop sequence
  /// [maxTokens] The maximum number of tokens
  /// [presencePenalty] The presence penalty
  /// [frequencyPenalty] The frequency penalty
  /// [logitBias] The token bias
  /// [responseFormat] The response format
  /// [seed] The random seed
  /// [user] The user identifier
  /// [client] Custom HTTP client
  /// [streamOptions] Stream options
  /// [enableThinking] Whether to enable thinking process
  @override
  Stream<OpenAIStreamChatCompletionModel> createStream({
    required String model,
    required List<OpenAIChatCompletionChoiceMessageModel> messages,
    List<OpenAIToolModel>? tools,
    toolChoice,
    double? temperature,
    double? topP,
    int? n,
    stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, dynamic>? logitBias,
    Object? responseFormat,
    int? seed,
    String? user,
    http.Client? client,
    Map<String, dynamic>? streamOptions,
    bool? enableThinking,
  }) {
    if (config.showLogs) {
      OpenAILogger.logEndpoint(endpoint);
    }

    return ContextualNetworkingClient.postStream<OpenAIStreamChatCompletionModel>(
      to: ContextualApiUrlBuilder.build(config, endpoint),
      config: config,
      body: {
        "model": model,
        "stream": true,
        "messages": messages.map((message) => message.toMap()).toList(),
        if (tools != null)
          "tools": tools.map((tool) => tool.toMap()).toList(growable: false),
        if (toolChoice != null) "tool_choice": toolChoice,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (n != null) "n": n,
        if (stop != null) "stop": stop,
        if (maxTokens != null) "max_tokens": maxTokens,
        if (presencePenalty != null) "presence_penalty": presencePenalty,
        if (frequencyPenalty != null) "frequency_penalty": frequencyPenalty,
        if (logitBias != null) "logit_bias": logitBias,
        if (user != null) "user": user,
        if (seed != null) "seed": seed,
        if (responseFormat is ovo.Object)
          "response_format": responseFormat.formatJsonData()
        else if (responseFormat is Map<String, dynamic>)
          "response_format": responseFormat,
        if (streamOptions != null && streamOptions.isNotEmpty) "stream_options": streamOptions,
        if (enableThinking != null) "enable_thinking": enableThinking,
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAIStreamChatCompletionModel.fromMap(response);
      },
      client: client,
    );
  }

  /// Create a remote function streaming request
  ///
  /// The parameters are exactly the same as the original createRemoteFunctionStream method, but work based on instance configuration rather than global configuration.
  ///
  /// [model] The model ID to use
  /// [messages] The list of messages
  /// [tools] The list of available tools
  /// [toolChoice] The tool selection strategy
  /// [temperature] Sampling temperature (0-2)
  /// [topP] Core sampling parameter
  /// [n] The number of generated completions
  /// [stop] The stop sequence
  /// [maxTokens] The maximum number of tokens
  /// [presencePenalty] The presence penalty
  /// [frequencyPenalty] The frequency penalty
  /// [logitBias] The token bias
  /// [user] The user identifier
  /// [client] Custom HTTP client
  /// [responseFormat] The response format
  /// [seed] The random seed
  /// [enableThinking] Whether to enable thinking process
  @override
  Stream<OpenAIStreamChatCompletionModel> createRemoteFunctionStream({
    required String model,
    required List<OpenAIChatCompletionChoiceMessageModel> messages,
    List<OpenAIToolModel>? tools,
    toolChoice,
    double? temperature,
    double? topP,
    int? n,
    stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, dynamic>? logitBias,
    String? user,
    http.Client? client,
    Object? responseFormat,
    int? seed,
    bool? enableThinking,
  }) {
    if (config.showLogs) {
      OpenAILogger.logEndpoint(endpoint);
    }

    return ContextualNetworkingClient.postStream<OpenAIStreamChatCompletionModel>(
      to: ContextualApiUrlBuilder.build(config, endpoint),
      config: config,
      body: {
        "model": model,
        "stream": true,
        "messages": messages.map((message) => message.toMap()).toList(),
        if (tools != null)
          "tools": tools.map((tool) => tool.toMap()).toList(growable: false),
        if (toolChoice != null) "tool_choice": toolChoice,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (n != null) "n": n,
        if (stop != null) "stop": stop,
        if (maxTokens != null) "max_tokens": maxTokens,
        if (presencePenalty != null) "presence_penalty": presencePenalty,
        if (frequencyPenalty != null) "frequency_penalty": frequencyPenalty,
        if (logitBias != null) "logit_bias": logitBias,
        if (user != null) "user": user,
        if (seed != null) "seed": seed,
        if (responseFormat is ovo.Object)
          "response_format": responseFormat.formatJsonData()
        else if (responseFormat is Map<String, dynamic>)
          "response_format": responseFormat,
        if (enableThinking != null) "enable_thinking": enableThinking,
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAIStreamChatCompletionModel.fromMap(response);
      },
      client: client,
    );
  }
}