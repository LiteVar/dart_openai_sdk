import 'package:dart_openai_sdk/dart_openai_sdk.dart';
import 'package:example/env/env.dart';

void main() {
  OpenAI.showLogs = true;
  OpenAI.showResponsesLogs = true;
  OpenAI.apiKey = Env.apiKey;

  final models = OpenAI.instance.model.list();

  print(models);
}
