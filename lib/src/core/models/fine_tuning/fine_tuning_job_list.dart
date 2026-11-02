import 'fine_tuning_job.dart';

/// Paginated fine-tuning job response.
class OpenAIFineTuningJobList {
  final List<OpenAIFineTuningJob> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;
  final String object;

  const OpenAIFineTuningJobList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIFineTuningJobList.fromMap(Map<String, dynamic> map) =>
      OpenAIFineTuningJobList(
        object: map['object']?.toString() ?? 'list',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((value) => OpenAIFineTuningJob.fromMap(
                      Map<String, dynamic>.from(value),
                    ))
                .toList(growable: false)
            : const [],
        hasMore: map['has_more'] == true,
        firstId: map['first_id']?.toString(),
        lastId: map['last_id']?.toString(),
      );
}
