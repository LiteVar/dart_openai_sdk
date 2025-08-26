import 'package:http/http.dart' as http;

import '../../../models/chat/chat.dart';
import '../../../models/tool/tool.dart';

abstract class CreateInterface {
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
    http.Client? client,
    Object? responseFormat,
    int? seed,
    String? reasoningEffort, // OpenAI reasoning parameters. `minimal`, `low`, `medium`, and `high`: low favored speed and fewer tokens, while high favored more thorough reasoning.
    bool? enableThinking, // For qwen and deepseek models
  });

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
    String? user,
    http.Client? client,
    int? seed,
    String? reasoningEffort, // OpenAI reasoning parameters
    bool? enableThinking, // For qwen and deepseek models
  });

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
    String? reasoningEffort, // OpenAI reasoning parameters
    bool? enableThinking, // For qwen and deepseek models
  });
}
