int? _fineTuningInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _fineTuningDate(dynamic value) {
  final timestamp = _fineTuningInt(value);
  return timestamp == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
}

Map<String, dynamic>? _fineTuningOptionalMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

/// A fine-tuning job created through the current `/fine_tuning/jobs` API.
///
/// Method and integration payloads remain maps so this model can represent new
/// training methods and provider fields without losing server data.
class OpenAIFineTuningJob {
  final String id;
  final String model;
  final DateTime createdAt;
  final String status;
  final String trainingFile;
  final String object;
  final String? fineTunedModel;
  final String? organizationId;
  final String? validationFile;
  final DateTime? finishedAt;
  final DateTime? estimatedFinish;
  final int? seed;
  final int? trainedTokens;
  final List<String> resultFiles;
  final dynamic error;
  final Map<String, dynamic>? hyperparameters;
  final Map<String, dynamic>? method;
  final List<Map<String, dynamic>> integrations;
  final Map<String, dynamic>? metadata;

  const OpenAIFineTuningJob({
    required this.id,
    required this.model,
    required this.createdAt,
    required this.status,
    required this.trainingFile,
    required this.resultFiles,
    required this.integrations,
    this.object = 'fine_tuning.job',
    this.fineTunedModel,
    this.organizationId,
    this.validationFile,
    this.finishedAt,
    this.estimatedFinish,
    this.seed,
    this.trainedTokens,
    this.error,
    this.hyperparameters,
    this.method,
    this.metadata,
  });

  factory OpenAIFineTuningJob.fromMap(Map<String, dynamic> map) {
    final createdAt = _fineTuningDate(map['created_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final integrations = map['integrations'];
    final resultFiles = map['result_files'];
    return OpenAIFineTuningJob(
      id: map['id']?.toString() ?? '',
      model: map['model']?.toString() ?? '',
      createdAt: createdAt,
      status: map['status']?.toString() ?? '',
      trainingFile: map['training_file']?.toString() ?? '',
      object: map['object']?.toString() ?? 'fine_tuning.job',
      fineTunedModel: map['fine_tuned_model']?.toString(),
      organizationId: map['organization_id']?.toString(),
      validationFile: map['validation_file']?.toString(),
      finishedAt: _fineTuningDate(map['finished_at']),
      estimatedFinish: _fineTuningDate(map['estimated_finish']),
      seed: _fineTuningInt(map['seed']),
      trainedTokens: _fineTuningInt(map['trained_tokens']),
      resultFiles: resultFiles is List
          ? resultFiles.map((value) => value.toString()).toList(growable: false)
          : const [],
      error: map['error'],
      hyperparameters: _fineTuningOptionalMap(map['hyperparameters']),
      method: _fineTuningOptionalMap(map['method']),
      integrations: integrations is List
          ? integrations
              .whereType<Map>()
              .map((value) => Map<String, dynamic>.from(value))
              .toList(growable: false)
          : const [],
      metadata: _fineTuningOptionalMap(map['metadata']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'object': object,
        'model': model,
        'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
        'status': status,
        'training_file': trainingFile,
        'result_files': resultFiles,
        if (fineTunedModel != null) 'fine_tuned_model': fineTunedModel,
        if (organizationId != null) 'organization_id': organizationId,
        if (validationFile != null) 'validation_file': validationFile,
        if (finishedAt != null)
          'finished_at': finishedAt!.millisecondsSinceEpoch ~/ 1000,
        if (estimatedFinish != null)
          'estimated_finish': estimatedFinish!.millisecondsSinceEpoch ~/ 1000,
        if (seed != null) 'seed': seed,
        if (trainedTokens != null) 'trained_tokens': trainedTokens,
        if (error != null) 'error': error,
        if (hyperparameters != null) 'hyperparameters': hyperparameters,
        if (method != null) 'method': method,
        'integrations': integrations,
        if (metadata != null) 'metadata': metadata,
      };
}
