import 'package:dart_openai_sdk/dart_openai_sdk.dart';

import 'env/env.dart';

void main() async {
  OpenAI.apiKey = Env.apiKey;

  String reasoningContent = '';
  String answerContent = '';

  try {
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "who are you?, please tell me in detail",
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final chatStream = OpenAI.instance.chat.createStream(
      model: "", // qwen3、deepseek r1 
      messages: [userMessage],
      enableThinking: true, 
    );

    await for (final chunk in chatStream) {
      if (chunk.choices.isEmpty) {
        if (chunk.usage != null) {
          print('\nUsage:');
          print('Total tokens: ${chunk.usage!.totalTokens}');
          print('Prompt tokens: ${chunk.usage!.promptTokens}');
          print('Completion tokens: ${chunk.usage!.completionTokens}');
        }
        continue;
      }

      final delta = chunk.choices.first.delta;

      if (delta.haveReasoningContent && delta.reasoningContent != null) {
        print('delta.reasoningContent: ${delta.reasoningContent}');
        reasoningContent += delta.reasoningContent!;
      }

      if (delta.haveContent && delta.content != null) {
        final contentText = delta.content!
            .where((item) => item != null)
            .map((item) => item!.text ?? '')
            .join();
        
        if (contentText.isNotEmpty) {
          // print('delta.contentText: $contentText');
          answerContent += contentText;
        }
      }
    }

    print('\n\n${'=' * 50}');
    print('reasoningContent:');
    print(reasoningContent);
    print('\n${'=' * 50}');
    print('answerContent:');
    print(answerContent);
    
  } catch (error) {
    print('error: $error');
  }
}