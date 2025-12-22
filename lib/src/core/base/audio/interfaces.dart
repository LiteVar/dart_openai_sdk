import 'dart:io';

import '../../../../dart_openai_sdk.dart';

abstract class CreateInterface {
  Future<File> createSpeech({
    required String model,
    required String input,
    required String voice,
    OpenAIAudioSpeechResponseFormat? responseFormat,
    double? speed,
    String outputFileName = "output",
    Directory? outputDirectory,
  });

  /// 流式文本转语音
  /// 
  /// 返回音频数据流，可以边生成边播放
  /// 
  /// [model] 模型名称，如 tts-1, tts-1-hd, gpt-4o-mini-tts
  /// [input] 要转换的文本
  /// [voice] 语音类型
  /// [responseFormat] 响应格式，推荐 pcm 或 wav 以获得最低延迟
  /// [speed] 语速，范围 0.25-4.0
  /// [instructions] 语音指令（仅 gpt-4o-mini-tts 支持）
  Stream<List<int>> createSpeechStream({
    required String model,
    required String input,
    required String voice,
    OpenAIAudioSpeechResponseFormat? responseFormat,
    double? speed,
    String? instructions,
  });

  Future<OpenAIAudioModel> createTranscription({
    required File file,
    required String model,
    String? prompt,
    OpenAIAudioResponseFormat? responseFormat,
    double? temperature,
    String? language,
    List<OpenAIAudioTimestampGranularity>? timestamp_granularities,
  });

  /// 流式语音转文本
  /// 
  /// 返回转写事件流，可以实时获取转写结果
  /// 
  /// [file] 音频文件
  /// [model] 模型名称，必须是 gpt-4o-transcribe 或 gpt-4o-mini-transcribe（whisper-1 不支持流式）
  /// [prompt] 提示词
  /// [language] 语言代码（ISO-639-1格式）
  Stream<OpenAITranscriptionStreamEvent> createTranscriptionStream({
    required File file,
    required String model,
    String? prompt,
    String? language,
  });

  Future<OpenAIAudioModel> createTranslation({
    required File file,
    required String model,
    String? prompt,
    OpenAIAudioResponseFormat? responseFormat,
    double? temperature,
  });
}
