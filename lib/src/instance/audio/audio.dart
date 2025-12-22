import 'package:dart_openai_sdk/src/core/builder/base_api_url.dart';
import 'package:dart_openai_sdk/src/core/networking/client.dart';

import 'dart:io';

import '../../../dart_openai_sdk.dart';
import '../../core/base/audio/audio.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/logger.dart';

/// {@template openai_audio}
/// This class is responsible for handling all audio requests, such as creating a transcription or translation for a given audio file.
/// {@endtemplate}
interface class OpenAIAudio implements OpenAIAudioBase {
  @override
  String get endpoint => OpenAIStrings.endpoints.audio;

  /// {@macro openai_audio}
  OpenAIAudio() {
    OpenAILogger.logEndpoint(endpoint);
  }

  /// Creates a transcription for a given audio file.
  ///
  /// [file] is the [File] audio which is the audio file to be transcribed.
  ///
  /// [model] is the model which to use for the transcription.
  ///
  /// [prompt] is an optional text to guide the model's style or continue a previous audio segment. The prompt should be in English.
  ///
  /// [responseFormat] is an optional format for the transcription. The default is [OpenAIAudioResponseFormat.json].
  ///
  /// [temperature] is the sampling temperature for the request.
  ///
  /// [language] is the language of the input audio. Supplying the input language in **ISO-639-1** format will improve accuracy and latency.
  ///
  /// [timestamp_granularities] The timestamp granularities to populate for this transcription. response_format must be set verbose_json to use timestamp granularities. Either: word or segment, both doesnt work.
  ///
  /// Example:
  /// ```dart
  /// final transcription = await openai.audio.createTranscription(
  ///  file: File("audio.mp3"),
  /// model: "whisper-1",
  /// prompt: "This is a prompt",
  /// responseFormat: OpenAIAudioResponseFormat.srt,
  /// temperature: 0.5,
  /// );
  /// ```
  @override
  Future<OpenAIAudioModel> createTranscription({
    required File file,
    required String model,
    String? prompt,
    OpenAIAudioResponseFormat? responseFormat,
    double? temperature,
    String? language,
    List<OpenAIAudioTimestampGranularity>? timestamp_granularities,
  }) async {
    return await OpenAINetworkingClient.fileUpload(
      file: file,
      to: BaseApiUrlBuilder.build(endpoint + "/transcriptions"),
      body: {
        "model": model,
        if (prompt != null) "prompt": prompt,
        if (responseFormat != null) "response_format": responseFormat.name,
        if (temperature != null) "temperature": temperature.toString(),
        if (language != null) "language": language,
        if (timestamp_granularities != null)
          "timestamp_granularities[]":
              timestamp_granularities.map((e) => e.name).join(","),
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAIAudioModel.fromMap(response);
      },
      responseMapAdapter: (res) {
        return {"text": res};
      },
    );
  }

  /// Creates a streaming transcription for a given audio file.
  /// 
  /// This method returns a stream of transcription events, allowing you to
  /// receive partial transcription results as they become available.
  /// 
  /// **Note**: Only `gpt-4o-transcribe` and `gpt-4o-mini-transcribe` models support
  /// streaming. The `whisper-1` model does not support streaming.
  ///
  /// [file] is the [File] audio which is the audio file to be transcribed.
  ///
  /// [model] is the model which to use for the transcription. Must be 
  /// `gpt-4o-transcribe` or `gpt-4o-mini-transcribe`.
  ///
  /// [prompt] is an optional text to guide the model's style.
  ///
  /// [language] is the language of the input audio in **ISO-639-1** format.
  ///
  /// Example:
  /// ```dart
  /// final stream = openai.audio.createTranscriptionStream(
  ///   file: File("audio.mp3"),
  ///   model: "gpt-4o-mini-transcribe",
  /// );
  /// 
  /// await for (final event in stream) {
  ///   if (event.type == OpenAITranscriptionStreamEventType.transcriptTextDelta) {
  ///     print('Delta: ${event.delta}');
  ///   } else if (event.type == OpenAITranscriptionStreamEventType.transcriptTextDone) {
  ///     print('Complete: ${event.text}');
  ///   }
  /// }
  /// ```
  @override
  Stream<OpenAITranscriptionStreamEvent> createTranscriptionStream({
    required File file,
    required String model,
    String? prompt,
    String? language,
  }) {
    return OpenAINetworkingClient.fileUploadStream(
      file: file,
      to: BaseApiUrlBuilder.build(endpoint + "/transcriptions"),
      body: {
        "model": model,
        "stream": "true",
        if (prompt != null) "prompt": prompt,
        if (language != null) "language": language,
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAITranscriptionStreamEvent.fromMap(response);
      },
    );
  }

  /// Creates a translation for a given audio file.
  ///
  /// [file] is the [File] audio which is the audio file to be transcribed.
  ///
  /// [model] is the model which to use for the transcription.
  ///
  /// [prompt] is an optional text to guide the model's style or continue a previous audio segment. The prompt should be in English.
  ///
  /// [responseFormat] is an optional format for the transcription. The default is [OpenAIAudioResponseFormat.json].
  ///
  /// [temperature] is the sampling temperature for the request.
  ///
  /// Example:
  /// ```dart
  /// final translation = await openai.audio.createTranslation(
  /// file: File("audio.mp3"),
  /// model: "whisper-1",
  /// prompt: "This is a prompt",
  /// responseFormat: OpenAIAudioResponseFormat.text,
  /// );
  /// ```
  @override
  Future<OpenAIAudioModel> createTranslation({
    required File file,
    required String model,
    String? prompt,
    OpenAIAudioResponseFormat? responseFormat,
    double? temperature,
  }) async {
    return await OpenAINetworkingClient.fileUpload(
      file: file,
      to: BaseApiUrlBuilder.build(endpoint + "/translations"),
      body: {
        "model": model,
        if (prompt != null) "prompt": prompt,
        if (responseFormat != null) "response_format": responseFormat.name,
        if (temperature != null) "temperature": temperature.toString(),
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAIAudioModel.fromMap(response);
      },
      responseMapAdapter: (res) {
        return {"text": res};
      },
    );
  }

  @override
  Future<File> createSpeech({
    required String model,
    required String input,
    required String voice,
    OpenAIAudioSpeechResponseFormat? responseFormat,
    double? speed,
    String outputFileName = "output",
    Directory? outputDirectory,
  }) async {
    String? fileExtension;
    if (responseFormat != null) {
      switch (responseFormat) {
        case OpenAIAudioSpeechResponseFormat.mp3:
          fileExtension = "mp3";
          break;
        case OpenAIAudioSpeechResponseFormat.opus:
          fileExtension = "opus";
          break;
        case OpenAIAudioSpeechResponseFormat.aac:
          fileExtension = "aac";
          break;
        case OpenAIAudioSpeechResponseFormat.flac:
          fileExtension = "flac";
          break;
        case OpenAIAudioSpeechResponseFormat.wav:
          fileExtension = "wav";
          break;
        case OpenAIAudioSpeechResponseFormat.pcm:
          fileExtension = "pcm";
          break;
      }
    }

    return await OpenAINetworkingClient.postAndExpectFileResponse(
      to: BaseApiUrlBuilder.build(endpoint + "/speech"),
      body: {
        "model": model,
        "input": input,
        "voice": voice,
        if (responseFormat != null) "response_format": responseFormat.name,
        if (speed != null) "speed": speed,
      },
      onFileResponse: (File res) {
        return res;
      },
      outputFileName: outputFileName,
      outputDirectory: outputDirectory,
      fileExtension: fileExtension,
    );
  }

  /// Creates a streaming speech from input text.
  /// 
  /// This method returns a stream of audio bytes, allowing you to play audio
  /// before the full file is generated. This is useful for real-time audio
  /// playback scenarios.
  /// 
  /// For the fastest response times, use `pcm` or `wav` as the response format.
  ///
  /// [model] is the model to use (e.g., `tts-1`, `tts-1-hd`, `gpt-4o-mini-tts`).
  ///
  /// [input] is the text to be converted to speech.
  ///
  /// [voice] is the voice to use (e.g., `alloy`, `echo`, `fable`, `onyx`, `nova`, `shimmer`).
  ///
  /// [responseFormat] is the output format. Use `pcm` or `wav` for lowest latency.
  ///
  /// [speed] is the speed of the speech (0.25 to 4.0, default 1.0).
  ///
  /// [instructions] is an optional instruction for the model to control speech style
  /// (only supported by `gpt-4o-mini-tts`).
  ///
  /// Example:
  /// ```dart
  /// final stream = openai.audio.createSpeechStream(
  ///   model: "tts-1",
  ///   input: "Hello, world!",
  ///   voice: "alloy",
  ///   responseFormat: OpenAIAudioSpeechResponseFormat.pcm,
  /// );
  /// 
  /// await for (final chunk in stream) {
  ///   // Play or save audio chunk
  ///   audioPlayer.addChunk(chunk);
  /// }
  /// ```
  @override
  Stream<List<int>> createSpeechStream({
    required String model,
    required String input,
    required String voice,
    OpenAIAudioSpeechResponseFormat? responseFormat,
    double? speed,
    String? instructions,
  }) {
    return OpenAINetworkingClient.postStreamBytes(
      to: BaseApiUrlBuilder.build(endpoint + "/speech"),
      body: {
        "model": model,
        "input": input,
        "voice": voice,
        if (responseFormat != null) "response_format": responseFormat.name,
        if (speed != null) "speed": speed,
        if (instructions != null) "instructions": instructions,
      },
    );
  }
}
