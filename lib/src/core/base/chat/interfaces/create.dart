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
    bool? enableThinking,
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
    bool? enableThinking,
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
    bool? enableThinking,
  });
}
