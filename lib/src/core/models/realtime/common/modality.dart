/// The modalities supported by the Realtime API.
enum OpenAIRealtimeModalityModel {
  /// Text modality.
  text('text'),

  /// Audio modality.
  audio('audio');

  const OpenAIRealtimeModalityModel(this.value);

  /// The string value of the modality.
  final String value;

  /// Returns the [OpenAIRealtimeModalityModel] from the given [value].
  static OpenAIRealtimeModalityModel fromValue(String value) {
    return values.firstWhere(
      (modality) => modality.value == value,
      orElse: () => throw ArgumentError('Unknown modality type: $value'),
    );
  }

  @override
  String toString() => value;
} 