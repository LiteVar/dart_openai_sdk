/// The audio formats supported by the Realtime API.
enum OpenAIRealtimeAudioFormatModel {
  /// PCM16 format at 24kHz.
  pcm16('pcm16'),

  /// G711_ULAW format at 8kHz.
  g711Ulaw('g711_ulaw'),

  /// G711_ALAW format at 8kHz.
  g711Alaw('g711_alaw');

  const OpenAIRealtimeAudioFormatModel(this.value);

  /// The string value of the audio format.
  final String value;

  /// Returns the [OpenAIRealtimeAudioFormatModel] from the given [value].
  static OpenAIRealtimeAudioFormatModel fromValue(String value) {
    return values.firstWhere(
      (format) => format.value == value,
      orElse: () => throw ArgumentError('Unknown audio format: $value'),
    );
  }

  @override
  String toString() => value;
}

/// Configuration for input audio transcription.
class OpenAIRealtimeTranscriptionConfigModel {
  /// Whether to enable input audio transcription.
  final bool? enabled;

  /// The model to use for transcription.
  final String? model;

  /// Creates a new [OpenAIRealtimeTranscriptionConfigModel].
  const OpenAIRealtimeTranscriptionConfigModel({
    this.enabled,
    this.model,
  });

  /// Creates a [OpenAIRealtimeTranscriptionConfigModel] from a JSON map.
  factory OpenAIRealtimeTranscriptionConfigModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return OpenAIRealtimeTranscriptionConfigModel(
      enabled: map['enabled'] as bool?,
      model: map['model'] as String?,
    );
  }

  /// Converts this [OpenAIRealtimeTranscriptionConfigModel] to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      if (enabled != null) 'enabled': enabled,
      if (model != null) 'model': model,
    };
  }

  @override
  String toString() {
    return 'OpenAIRealtimeTranscriptionConfigModel(enabled: $enabled, model: $model)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeTranscriptionConfigModel &&
        other.enabled == enabled &&
        other.model == model;
  }

  @override
  int get hashCode => Object.hash(enabled, model);
}

/// The turn detection types supported by the Realtime API.
enum OpenAIRealtimeTurnDetectionTypeModel {
  /// Server-side voice activity detection.
  serverVad('server_vad'),

  /// No turn detection.
  none('none');

  const OpenAIRealtimeTurnDetectionTypeModel(this.value);

  /// The string value of the turn detection type.
  final String value;

  /// Returns the [OpenAIRealtimeTurnDetectionTypeModel] from the given [value].
  static OpenAIRealtimeTurnDetectionTypeModel fromValue(String value) {
    return values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('未知的转向检测类型: $value'),
    );
  }

  @override
  String toString() => value;
}

/// Configuration for turn detection.
class OpenAIRealtimeTurnDetectionModel {
  /// The type of turn detection.
  final OpenAIRealtimeTurnDetectionTypeModel type;

  /// The threshold for voice activity detection (0.0 to 1.0).
  final double? threshold;

  /// The silence duration in milliseconds before considering turn end.
  final int? silenceDurationMs;

  /// The prefix padding in milliseconds.
  final int? prefixPaddingMs;

  /// Creates a new [OpenAIRealtimeTurnDetectionModel].
  const OpenAIRealtimeTurnDetectionModel({
    required this.type,
    this.threshold,
    this.silenceDurationMs,
    this.prefixPaddingMs,
  });

  /// Creates a [OpenAIRealtimeTurnDetectionModel] from a JSON map.
  factory OpenAIRealtimeTurnDetectionModel.fromMap(Map<String, dynamic> map) {
    return OpenAIRealtimeTurnDetectionModel(
      type: OpenAIRealtimeTurnDetectionTypeModel.fromValue(map['type']),
      threshold: map['threshold']?.toDouble(),
      silenceDurationMs: map['silence_duration_ms']?.toInt(),
      prefixPaddingMs: map['prefix_padding_ms']?.toInt(),
    );
  }

  /// Converts this [OpenAIRealtimeTurnDetectionModel] to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      if (threshold != null) 'threshold': threshold,
      if (silenceDurationMs != null) 'silence_duration_ms': silenceDurationMs,
      if (prefixPaddingMs != null) 'prefix_padding_ms': prefixPaddingMs,
    };
  }

  @override
  String toString() {
    return 'OpenAIRealtimeTurnDetectionModel(type: $type, threshold: $threshold, silenceDurationMs: $silenceDurationMs, prefixPaddingMs: $prefixPaddingMs)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeTurnDetectionModel &&
        other.type == type &&
        other.threshold == threshold &&
        other.silenceDurationMs == silenceDurationMs &&
        other.prefixPaddingMs == prefixPaddingMs;
  }

  @override
  int get hashCode => Object.hash(type, threshold, silenceDurationMs, prefixPaddingMs);
} 