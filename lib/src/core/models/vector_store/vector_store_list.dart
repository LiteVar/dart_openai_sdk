import 'vector_store.dart';

/// Paginated response from the Vector Stores list endpoint.
class OpenAIVectorStoreList {
  final List<OpenAIVectorStore> data;
  final String? firstId;
  final String? lastId;
  final bool hasMore;
  final String object;

  const OpenAIVectorStoreList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIVectorStoreList.fromMap(Map<String, dynamic> map) =>
      OpenAIVectorStoreList(
        object: map['object']?.toString() ?? 'list',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIVectorStore.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
        firstId: map['first_id']?.toString(),
        lastId: map['last_id']?.toString(),
        hasMore: map['has_more'] == true,
      );
}
