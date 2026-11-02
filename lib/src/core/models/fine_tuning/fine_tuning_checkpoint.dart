DateTime? _fineTuningCheckpointDate(dynamic value) {
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000,
        isUtc: true);
  }
  return null;
}

int _fineTuningCheckpointInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

/// Model checkpoint generated during a fine-tuning job.
class OpenAIFineTuningCheckpoint {
  final String id;
  final DateTime createdAt;
  final String fineTunedModelCheckpoint;
  final String fineTuningJobId;
  final int stepNumber;
  final Map<String, dynamic> metrics;
  final String object;

  const OpenAIFineTuningCheckpoint({
    required this.id,
    required this.createdAt,
    required this.fineTunedModelCheckpoint,
    required this.fineTuningJobId,
    required this.stepNumber,
    required this.metrics,
    this.object = 'fine_tuning.job.checkpoint',
  });

  factory OpenAIFineTuningCheckpoint.fromMap(Map<String, dynamic> map) =>
      OpenAIFineTuningCheckpoint(
        id: map['id']?.toString() ?? '',
        createdAt: _fineTuningCheckpointDate(map['created_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        fineTunedModelCheckpoint:
            map['fine_tuned_model_checkpoint']?.toString() ?? '',
        fineTuningJobId: map['fine_tuning_job_id']?.toString() ?? '',
        stepNumber: _fineTuningCheckpointInt(map['step_number']),
        metrics: map['metrics'] is Map
            ? Map<String, dynamic>.from(map['metrics'] as Map)
            : const {},
        object: map['object']?.toString() ?? 'fine_tuning.job.checkpoint',
      );
}

/// Paginated checkpoint response.
class OpenAIFineTuningCheckpointList {
  final List<OpenAIFineTuningCheckpoint> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;
  final String object;

  const OpenAIFineTuningCheckpointList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIFineTuningCheckpointList.fromMap(Map<String, dynamic> map) =>
      OpenAIFineTuningCheckpointList(
        object: map['object']?.toString() ?? 'list',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((value) => OpenAIFineTuningCheckpoint.fromMap(
                      Map<String, dynamic>.from(value),
                    ))
                .toList(growable: false)
            : const [],
        hasMore: map['has_more'] == true,
        firstId: map['first_id']?.toString(),
        lastId: map['last_id']?.toString(),
      );
}
