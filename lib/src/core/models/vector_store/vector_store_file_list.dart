import 'vector_store_file.dart';

/// Paginated response containing files attached to a vector store.
class OpenAIVectorStoreFileList {
  final List<OpenAIVectorStoreFile> data;
  final String? firstId;
  final String? lastId;
  final bool hasMore;
  final String object;

  const OpenAIVectorStoreFileList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIVectorStoreFileList.fromMap(Map<String, dynamic> map) =>
      OpenAIVectorStoreFileList(
        object: map['object']?.toString() ?? 'list',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIVectorStoreFile.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
        firstId: map['first_id']?.toString(),
        lastId: map['last_id']?.toString(),
        hasMore: map['has_more'] == true,
      );
}
