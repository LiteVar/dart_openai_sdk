/// The voice types supported by the Realtime API.
enum OpenAIRealtimeVoiceModel {
  /// Alloy voice.
  alloy('alloy'),

  /// Echo voice.
  echo('echo'),

  /// Fable voice.
  fable('fable'),

  /// Onyx voice.
  onyx('onyx'),

  /// Nova voice.
  nova('nova'),

  /// Shimmer voice.
  shimmer('shimmer');

  const OpenAIRealtimeVoiceModel(this.value);

  /// The string value of the voice.
  final String value;

  /// Returns the [OpenAIRealtimeVoiceModel] from the given [value].
  static OpenAIRealtimeVoiceModel fromValue(String value) {
    return values.firstWhere(
      (voice) => voice.value == value,
      orElse: () => throw ArgumentError('Unknown voice type: $value'),
    );
  }

  @override
  String toString() => value;
} 