import '../../../../enum.dart';
import 'sub_models/log_probs/log_probs.dart';
import 'sub_models/message.dart';

/// {@template openai_chat_completion_choice}
/// This class represents a choice of the [OpenAIChatCompletionModel] model of the OpenAI API, which is used and get returned while using the [OpenAIChat] methods.
/// {@endtemplate}
final class OpenAIChatCompletionChoiceModel {
  /// The [index] of the choice.

  //! This is dynamic because the API sometimes returns a [String] and sometimes an [int].
  final index;

  /// The [message] of the choice.
  final OpenAIChatCompletionChoiceMessageModel message;

  /// The [finishReason] of the choice.
  final String? finishReason;

  /// The log probability of the choice.
  final OpenAIChatCompletionChoiceLogProbsModel? logprobs;

  /// Weither the choice have a finish reason.
  bool get haveFinishReason => finishReason != null;

  @override
  int get hashCode {
    return index.hashCode ^ message.hashCode ^ finishReason.hashCode;
  }

  /// {@macro openai_chat_completion_choice}
  const OpenAIChatCompletionChoiceModel({
    required this.index,
    required this.message,
    required this.finishReason,
    required this.logprobs,
  });

  /// This is used  to convert a [Map<String, dynamic>] object to a [OpenAIChatCompletionChoiceModel] object.
  factory OpenAIChatCompletionChoiceModel.fromMap(Map<String, dynamic> json) {
    final rawIndex = json['index'];
    return OpenAIChatCompletionChoiceModel(
      index: rawIndex is int
          ? rawIndex
          : (rawIndex != null ? int.tryParse(rawIndex.toString()) ?? 0 : 0),
      message: json['message'] != null
          ? OpenAIChatCompletionChoiceMessageModel.fromMap(json['message'])
          : const OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.assistant, content: null),
      finishReason: json['finish_reason'],
      logprobs: json['logprobs'] != null
          ? OpenAIChatCompletionChoiceLogProbsModel.fromMap(json['logprobs'])
          : null,
    );
  }

  /// This method used to convert the [OpenAIChatCompletionChoiceModel] to a [Map<String, dynamic>] object.
  Map<String, dynamic> toMap() {
    return {
      "index": index,
      "message": message.toMap(),
      "finish_reason": finishReason,
      "logprobs": logprobs?.toMap(),
    };
  }

  @override
  String toString() {
    return 'OpenAIChatCompletionChoiceModel(index: $index, message: $message, finishReason: $finishReason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OpenAIChatCompletionChoiceModel &&
        other.index == index &&
        other.message == message &&
        other.finishReason == finishReason;
  }
}
