import 'package:dart_openai_sdk/dart_openai_sdk.dart';
import 'package:example/env/env.dart';

Future<void> main() async {
  OpenAI.apiKey = Env.apiKey;
  OpenAI.showLogs = false;

  Stream<String> wordsOfSentenceToComplete =
      Stream.fromIterable(["Hi ", "Edward", ", ", "I "]);

  String accumulativeSentence = "";

  await for (var word in wordsOfSentenceToComplete) {
    accumulativeSentence += word;

    final completion = await OpenAI.instance.completion.create(
      model: "text-davinci-003",
      prompt: accumulativeSentence,
      maxTokens: 20,
    );

    print(
        "completion for '$accumulativeSentence': ${completion.choices.first.text}");
  }
}
