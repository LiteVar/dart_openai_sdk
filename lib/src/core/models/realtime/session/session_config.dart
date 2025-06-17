import '../common/modality.dart';
import '../common/voice.dart';
import '../audio/audio_config.dart';
import '../tool/tool_definition.dart';

/// The max response output tokens types supported by the Realtime API.
class OpenAIRealtimeMaxTokensModel {
  /// The integer value for max tokens.
  final int? intValue;

  /// The string value for max tokens.
  final String? stringValue;

  /// Creates a new [OpenAIRealtimeMaxTokensModel] with an integer value.
  const OpenAIRealtimeMaxTokensModel.int(this.intValue) : stringValue = null;

  /// Creates a new [OpenAIRealtimeMaxTokensModel] with a string value.
  const OpenAIRealtimeMaxTokensModel.string(this.stringValue) : intValue = null;

  /// Creates a [OpenAIRealtimeMaxTokensModel] from a JSON value.
  factory OpenAIRealtimeMaxTokensModel.fromMap(dynamic value) {
    if (value is int) {
      return OpenAIRealtimeMaxTokensModel.int(value);
    } else if (value is String) {
      return OpenAIRealtimeMaxTokensModel.string(value);
    }
    throw ArgumentError('Invalid max tokens format: $value');
  }

  /// Converts this [OpenAIRealtimeMaxTokensModel] to a JSON value.
  dynamic toMap() {
    return intValue ?? stringValue;
  }

  @override
  String toString() {
    return 'OpenAIRealtimeMaxTokensModel(intValue: $intValue, stringValue: $stringValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeMaxTokensModel &&
        other.intValue == intValue &&
        other.stringValue == stringValue;
  }

  @override
  int get hashCode => Object.hash(intValue, stringValue);
}

/// Session configuration for the Realtime API.
class OpenAIRealtimeSessionConfigModel {
  /// The modalities for the session.
  final List<OpenAIRealtimeModalityModel> modalities;

  /// The instructions for the session.
  final String instructions;

  /// The voice to use.
  final OpenAIRealtimeVoiceModel voice;

  /// The input audio format.
  final OpenAIRealtimeAudioFormatModel inputAudioFormat;

  /// The output audio format.
  final OpenAIRealtimeAudioFormatModel outputAudioFormat;

  /// The input audio transcription configuration.
  final OpenAIRealtimeTranscriptionConfigModel? inputAudioTranscription;

  /// The turn detection configuration.
  final OpenAIRealtimeTurnDetectionModel? turnDetection;

  /// The tools available for the session.
  final List<OpenAIRealtimeToolDefinitionModel> tools;

  /// The tool choice configuration.
  final OpenAIRealtimeToolChoiceModel toolChoice;

  /// The temperature for responses.
  final double temperature;

  /// The maximum response output tokens.
  final OpenAIRealtimeMaxTokensModel maxResponseOutputTokens;

  /// Creates a new [OpenAIRealtimeSessionConfigModel].
  const OpenAIRealtimeSessionConfigModel({
    this.modalities = const [
      OpenAIRealtimeModalityModel.text,
      OpenAIRealtimeModalityModel.audio,
    ],
    this.instructions = '',
    this.voice = OpenAIRealtimeVoiceModel.alloy,
    this.inputAudioFormat = OpenAIRealtimeAudioFormatModel.pcm16,
    this.outputAudioFormat = OpenAIRealtimeAudioFormatModel.pcm16,
    this.inputAudioTranscription,
    this.turnDetection,
    this.tools = const [],
    this.toolChoice = const OpenAIRealtimeToolChoiceModel.auto(),
    this.temperature = 0.8,
    this.maxResponseOutputTokens = const OpenAIRealtimeMaxTokensModel.int(4096),
  });

  /// Creates a [OpenAIRealtimeSessionConfigModel] from a JSON map.
  factory OpenAIRealtimeSessionConfigModel.fromMap(Map<String, dynamic> map) {
    return OpenAIRealtimeSessionConfigModel(
      modalities: (map['modalities'] as List?)
              ?.map((e) => OpenAIRealtimeModalityModel.fromValue(e))
              .toList() ??
          const [
            OpenAIRealtimeModalityModel.text,
            OpenAIRealtimeModalityModel.audio,
          ],
      instructions: map['instructions'] ?? '',
      voice: map['voice'] != null
          ? OpenAIRealtimeVoiceModel.fromValue(map['voice'])
          : OpenAIRealtimeVoiceModel.alloy,
      inputAudioFormat: map['input_audio_format'] != null
          ? OpenAIRealtimeAudioFormatModel.fromValue(map['input_audio_format'])
          : OpenAIRealtimeAudioFormatModel.pcm16,
      outputAudioFormat: map['output_audio_format'] != null
          ? OpenAIRealtimeAudioFormatModel.fromValue(map['output_audio_format'])
          : OpenAIRealtimeAudioFormatModel.pcm16,
      inputAudioTranscription: map['input_audio_transcription'] != null
          ? OpenAIRealtimeTranscriptionConfigModel.fromMap(
              map['input_audio_transcription'])
          : null,
      turnDetection: map['turn_detection'] != null
          ? OpenAIRealtimeTurnDetectionModel.fromMap(map['turn_detection'])
          : null,
      tools: (map['tools'] as List?)
              ?.map((e) => OpenAIRealtimeToolDefinitionModel.fromMap(e))
              .toList() ??
          const [],
      toolChoice: map['tool_choice'] != null
          ? OpenAIRealtimeToolChoiceModel.fromMap(map['tool_choice'])
          : const OpenAIRealtimeToolChoiceModel.auto(),
      temperature: (map['temperature'] ?? 0.8).toDouble(),
      maxResponseOutputTokens: map['max_response_output_tokens'] != null
          ? OpenAIRealtimeMaxTokensModel.fromMap(map['max_response_output_tokens'])
          : const OpenAIRealtimeMaxTokensModel.int(4096),
    );
  }

  /// Converts this [OpenAIRealtimeSessionConfigModel] to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'modalities': modalities.map((e) => e.value).toList(),
      'instructions': instructions,
      'voice': voice.value,
      'input_audio_format': inputAudioFormat.value,
      'output_audio_format': outputAudioFormat.value,
      if (inputAudioTranscription != null)
        'input_audio_transcription': inputAudioTranscription!.toMap(),
      if (turnDetection != null) 'turn_detection': turnDetection!.toMap(),
      'tools': tools.map((e) => e.toMap()).toList(),
      'tool_choice': toolChoice.toMap(),
      'temperature': temperature,
      'max_response_output_tokens': maxResponseOutputTokens.toMap(),
    };
  }

  /// Creates a copy of this [OpenAIRealtimeSessionConfigModel] with the given fields replaced.
  OpenAIRealtimeSessionConfigModel copyWith({
    List<OpenAIRealtimeModalityModel>? modalities,
    String? instructions,
    OpenAIRealtimeVoiceModel? voice,
    OpenAIRealtimeAudioFormatModel? inputAudioFormat,
    OpenAIRealtimeAudioFormatModel? outputAudioFormat,
    OpenAIRealtimeTranscriptionConfigModel? inputAudioTranscription,
    OpenAIRealtimeTurnDetectionModel? turnDetection,
    List<OpenAIRealtimeToolDefinitionModel>? tools,
    OpenAIRealtimeToolChoiceModel? toolChoice,
    double? temperature,
    OpenAIRealtimeMaxTokensModel? maxResponseOutputTokens,
  }) {
    return OpenAIRealtimeSessionConfigModel(
      modalities: modalities ?? this.modalities,
      instructions: instructions ?? this.instructions,
      voice: voice ?? this.voice,
      inputAudioFormat: inputAudioFormat ?? this.inputAudioFormat,
      outputAudioFormat: outputAudioFormat ?? this.outputAudioFormat,
      inputAudioTranscription: inputAudioTranscription ?? this.inputAudioTranscription,
      turnDetection: turnDetection ?? this.turnDetection,
      tools: tools ?? this.tools,
      toolChoice: toolChoice ?? this.toolChoice,
      temperature: temperature ?? this.temperature,
      maxResponseOutputTokens: maxResponseOutputTokens ?? this.maxResponseOutputTokens,
    );
  }

  @override
  String toString() {
    return 'OpenAIRealtimeSessionConfigModel(modalities: $modalities, instructions: $instructions, voice: $voice, inputAudioFormat: $inputAudioFormat, outputAudioFormat: $outputAudioFormat, inputAudioTranscription: $inputAudioTranscription, turnDetection: $turnDetection, tools: $tools, toolChoice: $toolChoice, temperature: $temperature, maxResponseOutputTokens: $maxResponseOutputTokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeSessionConfigModel &&
        other.modalities == modalities &&
        other.instructions == instructions &&
        other.voice == voice &&
        other.inputAudioFormat == inputAudioFormat &&
        other.outputAudioFormat == outputAudioFormat &&
        other.inputAudioTranscription == inputAudioTranscription &&
        other.turnDetection == turnDetection &&
        other.tools == tools &&
        other.toolChoice == toolChoice &&
        other.temperature == temperature &&
        other.maxResponseOutputTokens == maxResponseOutputTokens;
  }

  @override
  int get hashCode => Object.hashAll([
        modalities,
        instructions,
        voice,
        inputAudioFormat,
        outputAudioFormat,
        inputAudioTranscription,
        turnDetection,
        tools,
        toolChoice,
        temperature,
        maxResponseOutputTokens,
      ]);
} 