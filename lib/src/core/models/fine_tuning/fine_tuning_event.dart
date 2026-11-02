DateTime? _fineTuningEventDate(dynamic value) {
  if (value is! num) return null;
  return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000, isUtc: true);
}

/// Status or metrics event emitted by a fine-tuning job.
class OpenAIFineTuningEvent {
  final String id;
  final DateTime createdAt;
  final String level;
  final String message;
  final String object;
  final String? type;
  final dynamic data;

  const OpenAIFineTuningEvent({
    required this.id,
    required this.createdAt,
    required this.level,
    required this.message,
    this.object = 'fine_tuning.job.event',
    this.type,
    this.data,
  });

  factory OpenAIFineTuningEvent.fromMap(Map<String, dynamic> map) =>
      OpenAIFineTuningEvent(
        id: map['id']?.toString() ?? '',
        createdAt: _fineTuningEventDate(map['created_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        level: map['level']?.toString() ?? '',
        message: map['message']?.toString() ?? '',
        object: map['object']?.toString() ?? 'fine_tuning.job.event',
        type: map['type']?.toString(),
        data: map['data'],
      );
}

/// Paginated fine-tuning events response.
class OpenAIFineTuningEventList {
  final List<OpenAIFineTuningEvent> data;
  final bool hasMore;
  final String object;

  const OpenAIFineTuningEventList({
    required this.data,
    required this.hasMore,
    this.object = 'list',
  });

  factory OpenAIFineTuningEventList.fromMap(Map<String, dynamic> map) =>
      OpenAIFineTuningEventList(
        object: map['object']?.toString() ?? 'list',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((value) => OpenAIFineTuningEvent.fromMap(
                      Map<String, dynamic>.from(value),
                    ))
                .toList(growable: false)
            : const [],
        hasMore: map['has_more'] == true,
      );
}
