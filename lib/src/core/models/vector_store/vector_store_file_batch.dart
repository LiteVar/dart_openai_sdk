import 'vector_store.dart';

int _vectorStoreBatchInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

/// A batch of files attached to a vector store.
class OpenAIVectorStoreFileBatch {
  final String id;
  final String vectorStoreId;
  final DateTime createdAt;
  final String status;
  final String object;
  final OpenAIVectorStoreFileCounts fileCounts;

  const OpenAIVectorStoreFileBatch({
    required this.id,
    required this.vectorStoreId,
    required this.createdAt,
    required this.status,
    required this.fileCounts,
    this.object = 'vector_store.file_batch',
  });

  factory OpenAIVectorStoreFileBatch.fromMap(Map<String, dynamic> map) =>
      OpenAIVectorStoreFileBatch(
        id: map['id']?.toString() ?? '',
        vectorStoreId: map['vector_store_id']?.toString() ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          _vectorStoreBatchInt(map['created_at']) * 1000,
          isUtc: true,
        ),
        status: map['status']?.toString() ?? '',
        object: map['object']?.toString() ?? 'vector_store.file_batch',
        fileCounts: OpenAIVectorStoreFileCounts.fromMap(
          map['file_counts'] is Map
              ? Map<String, dynamic>.from(map['file_counts'] as Map)
              : const {},
        ),
      );
}
