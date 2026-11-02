Map<String, dynamic> _graderMap(dynamic value) => value is Map
    ? Map<String, dynamic>.unmodifiable(Map<String, dynamic>.from(value))
    : const <String, dynamic>{};

/// Result returned after running a grader against a sample.
class OpenAIGraderRunResult {
  final Map<String, dynamic> raw;

  OpenAIGraderRunResult(Map<String, dynamic> raw)
      : raw = Map<String, dynamic>.unmodifiable(raw);

  factory OpenAIGraderRunResult.fromMap(Map<String, dynamic> map) =>
      OpenAIGraderRunResult(map);

  num? get reward => raw['reward'] is num ? raw['reward'] as num : null;
  Map<String, dynamic> get metadata => _graderMap(raw['metadata']);
  Map<String, dynamic> get subRewards => _graderMap(raw['sub_rewards']);
  Map<String, dynamic> get modelGraderTokenUsagePerModel =>
      _graderMap(raw['model_grader_token_usage_per_model']);

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(raw);
}
