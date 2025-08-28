# Dart OpenAI SDK

A Flutter/Dart SDK for OpenAI API by [LitaVar](https://github.com/LiteVar).

- **NOT** OpenAI official
- **NEW:** Chat Completion json_schema Support.
- **TODO:** RealTime API Support.
- **fork** from [dart_openai](https://github.com/anasfik/openai) and continue maintained by [LiteVar](https://github.com/LiteVar).

## Note
- Help this grow and get discovered by people who might need it by starring it ⭐.
- An open-source Client package that allows developers to easily integrate the power of OpenAI's state-of-the-art AI models into their Dart/Flutter applications.
- This library provides simple and intuitive methods for making requests to OpenAI's various APIs, including the GPT-3 language model, DALL-E image generation, and more.
- The package is designed to be lightweight and easy to use, so you can focus on building your application, rather than worrying about the complexities and errors caused by dealing with HTTP requests.

## Key Features

- Easy to use methods that reflect exactly the OpenAI documentation, with additional functionalities that make it better to use with Dart Programming Language.
- Authorize just once, use it anywhere and at any time in your application.
- Developer-friendly.
- `Stream` functionality for completions API & fine-tune events API.
- Ready examples/snippets for almost everything implemented in the package at `/example` folder.

## Code Progress

- [x] [Authentication](#authentication)
- [x] [Models](#models)
- [x] [Completions](#completions)
  - [x] With `Stream` responses.
- [x] [Chat (ChatCompletions)](#chat-chatcompletions)
  - [x] With `Stream` responses.
  - [x] [Tools](#tools--new-implementation-of-functions-calling)
- [x] [RealTime](#realtime)
- [x] [Edits](#edits)
- [x] [Images](#images)
- [x] [Embeddings](#embeddings)
- [x] [Audio](#audio)
- [x] [Files](#files)
- [x] [Fine-tunes](#fine-tunes)
  - [x] With events `Stream` responses.
- [x] [Moderation](#moderations)

# Usage

## Installation


## Authentication

### API key

- The OpenAI API uses API keys for authentication. you can get your account API key by visiting [API keys](https://platform.openai.com/account/api-keys) of your account.
- We highly recommend loading your secret key at runtime from a `.env` file, you can use the [envied](https://pub.dev/packages/envied) package or any other package that does the same job.

```env
// .env
OPEN_AI_API_KEY=<REPLACE WITH YOUR API KEY>
```

```dart
// lib/env/env.dart
import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env")
abstract class Env {
  @EnviedField(varName: 'OPEN_AI_API_KEY') // the .env variable.
  static const apiKey = _Env.apiKey;
}
```

```dart
// lib/main.dart
void main() {
  OpenAI.apiKey = Env.apiKey; // Initializes the package with that API key, all methods now are ready for use.
  // ..
}
```

- If no `apiKey` is set, and you tried to access `OpenAI.instance`, a `MissingApiKeyException` will be thrown even before making the actual request.
- If the `apiKey` is set, but it is invalid when making requests, a `RequestFailedException` will be thrown in your app, check the [error handling](#error-handling) section for more info.

### Setting an organization

- If you belong to a specific organization, you can pass its id to `OpenAI.organization` like this:

```dart
OpenAI.organization = "ORGANIZATION ID";
```

- If you don't belong actually to any organization, you can just ignore this section, or set it to `null`.

[Learn More From Here.](https://platform.openai.com/docs/api-reference/authentication)

### Settings a default request timeout

- The package make use if the [http](https://pub.dev/packages/http) to make requests, this one have a default timeout of 120 seconds, this means that any requests that takes more than 120 seconds will be cancelled, and a exception will be thrown, to chenge that you will need to set your own default timeout:

```dart
OpenAI.requestsTimeOut = Duration(seconds: 60); // 60 seconds.
```

And now, the time-consuming methods will wait for 60 seconds to get a response before throwing an exception.

### Setting your own base url

You can change the base url used in the package to your own, this can be helpful if you want to proxy the requests to the OpenAI API, or if you want to use your own server as a proxy to the OpenAI API.

```dart
OpenAI.baseUrl = "https://api.openai.com/v1"; // the default one.
```

### Enable debugging and logs
You can make the package logs the operations flows and steps by setting the `showLogs`:
  
```dart
OpenAI.showLogs = true;
```

This will only log the requests steps such when the request started and finished, when the decoding started...

But if you want to log raw responses that are returned from the API (JSON, RAW...), you can set the `showResponsesLogs`:

```dart
OpenAI.showResponsesLogs = true;
```

This will log the raw responses that are returned from the API, such when the request is successful, or when it failed. (This don't include the stream responses).

## Models

### List Models

Lists the currently available models, and provides information about each one such as the owner and availability.

```dart
List<OpenAIModelModel> models = await OpenAI.instance.model.list();
OpenAIModelModel firstModel = models.first;
 
print(firstModel.id); // ...
print(firstModel.permission); // ...
```

### Retrieve model

Retrieves a single model by its id and gets additional pieces of information about it.

```dart
OpenAIModelModel model = await OpenAI.instance.model.retrieve("text-davinci-003");

print(model.ownedBy); // ...
```

If the model id you provided does not exist or isn't available for your account, a `RequestFailedException` will be thrown, check [Error Handling](#error-handling) section.

[Learn More From Here.](https://platform.openai.com/docs/api-reference/models)


### Delete fine tuned models

OpenAI offers [fine-tuning](https://platform.openai.com/docs/guides/fine-tuning) feature, which you can make use of it with this package [here](#fine-tunes).

However, if it happens that you want to delete a fine-tuned model, you can use the `delete()` method:

```dart
bool isDeleted = await OpenAI.instance.model.delete("fine-tune-id");

print(isDeleted); // ...
```

## Completions

### Create completion

Creates a predicted completion based on the provided `model`, `prompt` & other properties asynchronously.

```dart
OpenAICompletionModel completion = await OpenAI.instance.completion.create(
  model: "text-davinci-003",
  prompt: "Dart is a program",
  maxTokens: 20,
  temperature: 0.5,
  n: 1,
  stop: ["\n"],
  echo: true,
  seed: 42,
  bestOf: 2,
);

print(completion.choices.first.text); // ...
print(completion.systemFingerprint); // ...
print(completion.id); // ...
```

if the request failed (as an example, if you did pass an invalid `model`...), a `RequestFailedException` will be thrown, check [Error Handling](#error-handling) section.

### Create Completion Stream

In addition to calling the `OpenAI.instance.completion.create()` which is a `Future` (asynchronous) and will not return an actual value until the full completion is generated, you can get a `Stream` of them as they happen to be generated:

```dart
Stream<OpenAIStreamCompletionModel> completionStream = OpenAI.instance.completion.createStream(
  model: "text-davinci-003",
  prompt: "Github is ",
  maxTokens: 100,
  temperature: 0.5,
  topP: 1,
  seed: 42,
  stop: '###',
  n: 2,
);

completionStream.listen((event) {
  final firstCompletionChoice = event.choices.first;

  print(firstCompletionChoice.index); // ...
  print(firstCompletionChoice.text); // ...
});
```

**Useful: Check also the `createStreamText()` method**

[Learn More From Here.](https://platform.openai.com/docs/api-reference/completions)

## Chat (ChatCompletions)

### Create chat completion

Creates a predicted completion for a chat message(s), from the provided properties:

```dart
// the system message that will be sent to the request.
final systemMessage = OpenAIChatCompletionChoiceMessageModel(
  content: [
    OpenAIChatCompletionChoiceMessageContentItemModel.text(
      "return any message you are given as JSON.",
    ),
  ],
  role: OpenAIChatMessageRole.assistant,
);

  // the user message that will be sent to the request.
 final userMessage = OpenAIChatCompletionChoiceMessageModel(
   content: [
     OpenAIChatCompletionChoiceMessageContentItemModel.text(
       "Hello, I am a chatbot created by OpenAI. How are you today?",
     ),

     //! image url contents are allowed only for models with image support such gpt-4.
     OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
       "https://placehold.co/600x400",
     ),
   ],
   role: OpenAIChatMessageRole.user,
 );

// all messages to be sent.
final requestMessages = [
  systemMessage,
  userMessage,
];

// the actual request.
OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
  model: "gpt-3.5-turbo-1106",
  responseFormat: {"type": "json_object"},
  seed: 6,
  messages: requestMessages,
  temperature: 0.2,
  maxTokens: 500,
);

print(chatCompletion.choices.first.message); // ...
print(chatCompletion.systemFingerprint); // ...
print(chatCompletion.usage.promptTokens); // ...
print(chatCompletion.id); // ...
```

### Create a chat completion stream

In addition to calling `OpenAI.instance.chat.create()` which is a `Future` (asynchronous) and will resolve only after the whole chat is generated, you can get a `Stream` of them as they happen to be generated:

```dart
// The user message to be sent to the request.
final userMessage = OpenAIChatCompletionChoiceMessageModel(
  content: [
    OpenAIChatCompletionChoiceMessageContentItemModel.text(
      "Hello my friend!",
    ),
  ],
  role: OpenAIChatMessageRole.user,
);

// The request to be sent.
final chatStream = OpenAI.instance.chat.createStream(
  model: "gpt-3.5-turbo",
  messages: [
    userMessage,
  ],
  seed: 423,
  n: 2,
);

// Listen to the stream.
chatStream.listen(
  (streamChatCompletion) {
    final content = streamChatCompletion.choices.first.delta.content;
    print(content);
  },
  onDone: () {
    print("Done");
  },
);
```

### OpenAI Reasoning Models

The package provides full support for OpenAI's reasoning models, which offer advanced reasoning capabilities with transparent thought processes.  

⚠️ Note: Since the chat completion API does not support `reasoning_content`, this feature may not work as expected. See [reference](https://github.com/openai/openai-python/pull/2192#issuecomment-2722436716).

#### Basic Usage

```dart
final userMessage = OpenAIChatCompletionChoiceMessageModel(
  content: [
    OpenAIChatCompletionChoiceMessageContentItemModel.text(
      "Explain quantum entanglement and its applications in quantum computing.",
    ),
  ],
  role: OpenAIChatMessageRole.user,
);

// Non-streaming reasoning
final response = await OpenAI.instance.chat.create(
  model: "o1",  // or "o1-mini"
  messages: [userMessage],
  
  reasoningEffort: "high",        // OpenAI reasoning parameters: minimal, low, medium, high
  
  temperature: 0.7,
  maxTokens: 1500,
);

final message = response.choices.first.message;

// Access reasoning process (compatible with both formats)
if (message.haveReasoningContent) {
  final reasoning = message.reasoningTokens ?? message.reasoningContent;
  print('🧠 Reasoning: $reasoning');
}

// Access final answer
if (message.haveContent) {
  final answer = message.content!
      .where((item) => item.text != null)
      .map((item) => item.text!)
      .join();
  print('💡 Answer: $answer');
}
```

#### Streaming Reasoning

```dart
final chatStream = OpenAI.instance.chat.createStream(
  model: "o1-mini",
  messages: [userMessage],
  
  reasoningEffort: "medium",      // OpenAI reasoning parameters
);

String reasoning = '';
String answer = '';

await for (final chunk in chatStream) {
  if (chunk.choices.isEmpty) continue;
  
  final delta = chunk.choices.first.delta;
  
  // Real-time reasoning process
  if (delta.haveReasoningContent) {
    final reasoningPart = delta.reasoningTokens ?? delta.reasoningContent;
    if (reasoningPart != null && reasoningPart.isNotEmpty) {
      print('🧠 [Thinking] $reasoningPart');
      reasoning += reasoningPart;
    }
  }
  
  // Real-time answer
  if (delta.haveContent && delta.content != null) {
    final answerPart = delta.content!
        .where((item) => item != null)
        .map((item) => item!.text ?? '')
        .join();
    
    if (answerPart.isNotEmpty) {
      print('💡 [Answer] $answerPart');
      answer += answerPart;
    }
  }
}
```

#### Horizontal Compatibility

The package maintains horizontal compatibility with existing reasoning models.

```dart
// Works with Qwen3, DeepSeek R1, and other models
final chatStream = OpenAI.instance.chat.createStream(
  model: "qwen3",  // or "deepseek-r1"
  messages: [userMessage],
  enableThinking: true,  // For qwen and deepseek models
);

// Both reasoningContent and reasoningTokens are supported
await for (final chunk in chatStream) {
  final delta = chunk.choices.first.delta;
  if (delta.haveReasoningContent) {
    // Automatically handles both formats
    final reasoning = delta.reasoningTokens ?? delta.reasoningContent;
    print('Reasoning: $reasoning');
  }
}
```

### Tools ( new implementation of functions calling)

The chat API offer the `tools` feature which allows for calling functions from the chat API, this feature is implemented in the package, and can be used like the following, please note that this is just a showcase, and you should handle the edge cases in your app such when there is no tool call, or when the tool call is not the one you sent, etc...:

```dart
OpenAI.apiKey = Env.apiKey;

// The function to be called by the tool.
void sumNumbers(int number1, int number2) {
  print("Your sum answer is ${number1 + number2}");
}

// The tool object that wilm be sent to the API.
final sumNumbersTool = OpenAIToolModel(
    type: "function",
  function: OpenAIFunctionModel.withParameters(
    name: "sumOfTwoNumbers",
    parameters: [
      OpenAIFunctionProperty.integer(
        name: "number1",
        description: "The first number to add",
      ),
      OpenAIFunctionProperty.integer(
        name: "number2",
        description: "The second number to add",
      ),
    ],
  ),
);

// The user text message that will be sent to the API.
final userMessage = OpenAIChatCompletionChoiceMessageModel(
  content: [
    OpenAIChatCompletionChoiceMessageContentItemModel.text(
      "What is the sum of 9996 and 3?",
    ),
  ],
  role: OpenAIChatMessageRole.user,
);

// The actual call.
final chat = await OpenAI.instance.chat.create(
  model: "gpt-3.5-turbo",
  messages: [userMessage],
  tools: [sumNumbersTool],
);

// ! This handling is only for showcase and not completed as edge cases will not be handled that you should handle in your app.

final message = chat.choices.first.message;

// Whether the message has a tool call.
if (message.haveToolCalls) {
  final call = message.toolCalls!.first;

  // Whether the tool call is the one we sent.
  if (call.function.name == "sumOfTwoNumbers") {
    // decode the arguments from the tool call.
    final decodedArgs = jsonDecode(call.function.arguments);

    final number1 = decodedArgs["number1"];
    final number2 = decodedArgs["number2"];

    // Call the function with the arguments.
    sumNumbers(number1, number2);
  }
}
```

Learn more from [here](https://platform.openai.com/docs/api-reference/chat/create).

## RealTime

### Create session

Create an ephemeral API token for use in client-side applications with the Realtime API.

```dart
void main() async {

  OpenAI.apiKey = Env.apiKey;

  OpenAIRealtime realtime = OpenAI.instance.realtime;

  try {
    // Connect to realtime API
    print('🔌 Connecting to OpenAI Realtime API...');
    await realtime.connect(
      model: RealtimeConfig.model,
      debug: true,
    );

    print('✅ Connection established successfully!');

    // Configure session with audio input transcription support
    final sessionConfig = OpenAIRealtimeSessionConfigModel(
      modalities: [OpenAIRealtimeModalityModel.text, OpenAIRealtimeModalityModel.audio],
      instructions: RealtimeConfig.instructions,
      inputAudioTranscription: const OpenAIRealtimeTranscriptionConfigModel(
          model: 'whisper-1'
      ),
      turnDetection: OpenAIRealtimeTurnDetectionModel(
        type: OpenAIRealtimeTurnDetectionTypeModel.serverVad,
        threshold: RealtimeConfig.threshold,
        silenceDurationMs: RealtimeConfig.silenceDurationMs,
      ),
      toolChoice: const OpenAIRealtimeToolChoiceModel.auto(),
    );
    await realtime.updateSession(sessionConfig: sessionConfig);
    print('✅ Session configuration updated successfully');

    // Setup event listeners
    _setupEventListeners(realtime);

    // Add tools
    _addTools(realtime);

    // Wait for connection stabilization
    await Future.delayed(RealtimeConfig.connectionStabilizationDelay);

    // Demonstrate Base64 audio functionality
    await _demonstrateBase64Audio(realtime);

    // Wait for processing completion
    await Future.delayed(RealtimeConfig.processingDelay);

    // Disconnect
    await realtime.disconnect();
    print('✅ Connection closed successfully');

  } catch (e) {
    print('❌ Error: $e');
    try {
      await realtime.disconnect();
    } catch (disconnectError) {
      print('❌ Failed to disconnect: $disconnectError');
    }
  }
}
```

[Learn More From Here.](https://platform.openai.com/docs/api-reference/realtime)

## Edits

### Create edit

Creates an edited version of the given prompt based on the used model.

```dart
OpenAIEditModel edit = await OpenAI.instance.edit.create(
  model: "text-davinci-edit-001";
  instruction: "remote all '!'from input text",
  input: "Hello!!, I! need to be ! somethi!ng"
  n: 1,
  temperature: 0.8,
);

// Prints the choices.
for (int index = 0; index < edit.choices.length; index++) {
  print(edit.choices[index].text);
}
```

[Learn More From Here.](https://platform.openai.com/docs/api-reference/edits)

## Images

### Create image

Generates a new image based on a prompt given.

```dart
 OpenAIImageModel image = await OpenAI.instance.image.create(
  prompt: 'an astronaut on the sea',
  n: 1,
  size: OpenAIImageSize.size1024,
  responseFormat: OpenAIImageResponseFormat.url,
);

// Printing the output to the console.
for (int index = 0; index < image.data.length; index++) {
  final currentItem = image.data[index];
  print(currentItem.url);
}
```

### Create image edit

Creates an edited or extended image given an original image and a prompt.

```dart
OpenAIImageModel imageEdits = await OpenAI.instance.image.edit(
  prompt: 'mask the image with color red',
  image: File(/* IMAGE PATH HERE */),
  mask: File(/* MASK PATH HERE */),
  n: 1,
  size: OpenAIImageSize.size1024,
  responseFormat: OpenAIImageResponseFormat.b64Json,
);

for (int index = 0; index < imageEdits.data.length; index++) {
  final currentItem = imageEdits.data[index];
  print(currentItem.b64Json);
}
```

### Create image variation

Creates a variation of a given image.

```dart
// Creates the Image Variation
final imageVariations = await OpenAI.instance.image.variation(
  model: "dall-e-2",
  image: File("dart.png"),
  n: 4,
  size: OpenAIImageSize.size512,
  responseFormat: OpenAIImageResponseFormat.url,
);

 // Prints the output to the console.
for (var index = 0; index < imageVariations.data.length; index++) {
  final currentItem = imageVariations.data[index];
  print(currentItem.url);
}
```

[Learn More From Here.](https://platform.openai.com/docs/api-reference/images)


## Embeddings

Get a vector representation of a given input that can be easily consumed by machine learning models and algorithms.

### Create embeddings

```dart
final embedding = await OpenAI.instance.embedding.create(
  model: "text-embedding-ada-002",
  input: "This is a sample text",
);

for (int index = 0; index < embedding.data.length; index++) {
  final currentItem = embedding.data[index];
  print(currentItem);
}
```

[Learn More From Here.](https://platform.openai.com/docs/api-reference/embeddings)

## Audio

### Create Speech

For creating a speech from a text, you can use the `createSpeech()` method directly by providing the required params:

```dart
// The speech request.
File speechFile = await OpenAI.instance.audio.createSpeech(
  model: "tts-1",
  input: "Say my name is Anas",
  voice: "nova",
  responseFormat: OpenAIAudioSpeechResponseFormat.mp3,
  outputDirectory: await Directory("speechOutput").create(),
  outputFileName: "anas",
);

// The file result.
print(speechFile.path);
```

**Note: the `outputDirectory` and `outputFileName` are helpers for this method, you can use them to save the audio file to a specific directory with a specific name, with the file extension being extracted from the `responseFormat`. if you don't want to use them, just ignore it, and the audio file will be saved to the default directory of your app, with the `output` file name.**

The example snippet above will place a generated `anas.mp3` in the `speechOutput` directory in your project.

### Create transcription

For transcribing an audio `File`, you can use the `createTranscription()` method directly by providing the `file` property:

```dart
OpenAIAudioModel transcription = OpenAI.instance.audio.createTranscription(
  file: File(/* THE FILE PATH*/),
  model: "whisper-1",
  responseFormat: OpenAIAudioResponseFormat.json,
);

// print the transcription.
print(transcription.text);
```

### Create translation

to get access to the translation API, and translate an audio file to english, you can use the `createTranslation()` method, by providing the `file`` property:

```dart
OpenAIAudioModel translation = await OpenAI.instance.audio.createTranslation(
  file: File(/* THE FILE PATH*/),
  model: "whisper-1",
  responseFormat: OpenAIAudioResponseFormat.text,
);

// print the translation.
print(translation.text);
```

Learn more from [here](https://platform.openai.com/docs/api-reference/audio/createTranslation).


## Files

Files are used to upload documents that can be used with features like [Fine-tuning](#fine-tunes).

### List files

Get a list of all the uploaded files o-to your OpenAI account.

```dart
List<OpenAIFileModel> files = await OpenAI.instance.file.list();

print(files.first.fileName); // ...
print(files.first.id); // ...
```

### Upload file

Upload a file that contains document(s) to be used across various endpoints/features. Currently, the size of all the files uploaded by one organization can be up to 1 GB. Please contact us if you need to increase the storage limit.

```dart
OpenAIFileModel uploadedFile = await OpenAI.instance.file.upload(
 file: File("/* FILE PATH HERE */"),
 purpose: "fine-tuning",
);

print(uploadedFile.id); // ...
```

### Delete file

Deletes an existent file by its id.

```dart
bool isFileDeleted = await OpenAI.instance.file.delete("/* FILE ID */");

print(isFileDeleted);
```

### Retrieve file

Fetches for a single file by its id and returns information about it.

```dart
OpenAIFileModel file = await OpenAI.instance.file.retrieve("FILE ID");
print(file.id);
```

### Retrieve file content

Fetches for a single file content by its id.

```dart
dynamic fileContent  = await OpenAI.instance.file.retrieveContent("FILE ID");

print(fileContent);
```

[Learn More From Here.](https://platform.openai.com/docs/api-reference/files)


## Fine-Tunes

### Create fine-tune

Creates a job that fine-tunes a specified model from a given dataset, and returns a fine-tuned object about the enqueued job.

```dart
OpenAIFineTuneModel fineTune = await OpenAI.instance.fineTune.create(
  trainingFile: "FILE ID",
);

print(fineTune.status); // ...
```

### List fine-tunes

List your organization's fine-tuning jobs.

```dart
List<OpenAIFineTuneModel> fineTunes = await OpenAI.instance.fineTune.list();

print(fineTunes.first); // ...
```

### Retrieve fine-tune

Retrieves a fine-tuned by its id.

```dart
OpenAIFineTuneModel fineTune = await OpenAI.instance.fineTune.retrieve("FINE TUNE ID");

print(fineTune.id); // ...
```

### Cancel fine-tune

Cancels a fine-tune job by its id, and returns it.

```dart
OpenAIFineTuneModel cancelledFineTune = await OpenAI.instance.fineTune.cancel("FINE TUNE ID");

print(cancelledFineTune.status); // ...
```

### List fine-tune events

Lists a single fine-tune progress events by its id.

```dart
List<OpenAIFineTuneEventModel> events = await OpenAI.instance.fineTune.listEvents("FINE TUNE ID");

print(events.first.message); // ...
```

### Listen to fine-tune events `Stream`

Streams all events of a fine-tune job by its id, as they happen.

This is a long-running operation that will not return until the fine-tune job is terminated.

The stream will emit an event every time a new event is available.

```dart
Stream<OpenAIFineTuneEventStreamModel> eventsStream = OpenAI.instance.fineTune.listEventsStream("FINE TUNE ID");

eventsStream.listen((event) {
 print(event.message);
});
```

### Delete fine-tune

Deletes a fine-tune job by its id.

```dart
 bool deleted = await OpenAI.instance.fineTune.delete("FINE TUNE ID");

print(deleted); // ...
```

[Learn More From Here.](https://platform.openai.com/docs/api-reference/fine-tunes)


## Moderations

### Create moderation

Classifies if text violates OpenAI's Content Policy

```dart
OpenAIModerationModel moderation = await OpenAI.instance.moderation.create(
  input: "I want to kill him",
);

print(moderation.results); // ...
print(moderation.results.first.categories.hate); // ...
```

[Learn More From Here.](https://platform.openai.com/docs/api-reference/moderations)

## Error Handling

Any time an error happens from the OpenAI API ends (As Example: when you try to create an image variation from a non-image file.. , a `RequestFailedException` will be thrown automatically inside your Flutter / Dart app, you can use a `try-catch` to catch that error, and make an action based on it:

```dart
try {
  // This will throw an error.
  final errorVariation = await OpenAI.instance.image.variation(
    image: File(/*PATH OF NON-IMAGE FILE*/),
  );
} on RequestFailedException catch(e) {
  print(e.message);
  print(e.statusCode);
}
```