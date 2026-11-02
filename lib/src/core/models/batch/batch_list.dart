import 'batch.dart';

/// Paginated response from the Batches list endpoint.
class OpenAIBatchList {
  final List<OpenAIBatchModel> data;
  final String? firstId;
  final String? lastId;
  final bool hasMore;
  final String object;

  const OpenAIBatchList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIBatchList.fromMap(Map<String, dynamic> map) => OpenAIBatchList(
        object: map['object']?.toString() ?? 'list',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIBatchModel.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
        firstId: map['first_id']?.toString(),
        lastId: map['last_id']?.toString(),
        hasMore: map['has_more'] == true,
      );
}
