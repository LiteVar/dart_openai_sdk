import 'dart:convert';
import 'dart:io';

import 'package:dart_openai_sdk/dart_openai_sdk.dart';
import 'package:dart_openai_sdk/export_package.dart' as ovo;

import 'env/env.dart';

Map<String, dynamic> initJsonSchema() {
  String configFilePath =
      '${Directory.current.path}${Platform.pathSeparator}lib${Platform.pathSeparator}json${Platform.pathSeparator}json_schema.json';
  String configJsonString = File(configFilePath).readAsStringSync();
  final Map<String, dynamic> jsonSchema = jsonDecode(configJsonString);
  return jsonSchema;
}

class Step extends ovo.Object {
  Step(super.properties);

  @override
  Map<String, ovo.OvO> get properties => {
    "explanation": ovo.String(),
    "output": ovo.String(),
  };
}

class MathResponse extends ovo.Object {
  MathResponse(super.properties);

  @override
  Map<String, ovo.OvO> get properties => {
    "steps": ovo.Array(Step({})),
    "final_answer": ovo.String(),
  };
}

/// how to use
/// https://platform.openai.com/docs/guides/structured-outputs?lang=curl&context=ex1#how-to-use
void main() async {
  // Set the OpenAI API key from the .env file.
  OpenAI.apiKey = Env.apiKey;
  OpenAI.baseUrl = "https://oneapi.cxtx-ai.com";

  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "You are a helpful math tutor. Guide the user through the solution step by step.",
      ),
    ],
    role: OpenAIChatMessageRole.system,
  );

  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "how can I solve 8x + 7 = -23",
      ),

      //! image url contents are allowed only for models with image support
      // OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
      //   "https://placehold.co/600x400",
      // ),
    ],
    role: OpenAIChatMessageRole.user,
    name: "anas",
  );

  final requestMessages = [
    systemMessage,
    userMessage,
  ];

  //Map<String, dynamic> jsonSchema = initJsonSchema();

  OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
    model: "gpt-4o-mini",
    responseFormat: MathResponse({}),//Nesting is limited to 5 layers
    seed: 6,
    messages: requestMessages,
    temperature: 0.2,
    maxTokens: 500,

    // uncomment and set your own properties if you want to use tool choices feature..

    // toolChoice: "auto",
    // tools: [],
  );

  print(chatCompletion.choices.first.message); //
  print(chatCompletion.systemFingerprint); //
  print(chatCompletion.usage.promptTokens); //
  print(chatCompletion.id); //
}