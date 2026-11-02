int _vectorStoreFileInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

/// A file attached to a vector store.
class OpenAIVectorStoreFile {
  final String id;
  final String vectorStoreId;
  final DateTime createdAt;
  final String status;
  final String object;
  final int usageBytes;
  final Map<String, dynamic> attributes;
  final Map<String, dynamic>? lastError;
  final Map<String, dynamic>? chunkingStrategy;

  const OpenAIVectorStoreFile({
    required this.id,
    required this.vectorStoreId,
    required this.createdAt,
    required this.status,
    required this.attributes,
    this.object = 'vector_store.file',
    this.usageBytes = 0,
    this.lastError,
    this.chunkingStrategy,
  });

  factory OpenAIVectorStoreFile.fromMap(Map<String, dynamic> map) {
    final createdAt = map['created_at'];
    return OpenAIVectorStoreFile(
      id: map['id']?.toString() ?? '',
      vectorStoreId: map['vector_store_id']?.toString() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _vectorStoreFileInt(createdAt) * 1000,
        isUtc: true,
      ),
      status: map['status']?.toString() ?? '',
      object: map['object']?.toString() ?? 'vector_store.file',
      usageBytes: _vectorStoreFileInt(map['usage_bytes']),
      attributes: map['attributes'] is Map
          ? Map<String, dynamic>.from(map['attributes'] as Map)
          : const {},
      lastError: map['last_error'] is Map
          ? Map<String, dynamic>.from(map['last_error'] as Map)
          : null,
      chunkingStrategy: map['chunking_strategy'] is Map
          ? Map<String, dynamic>.from(map['chunking_strategy'] as Map)
          : null,
    );
  }
}

/// Result returned when deleting a vector store file.
class OpenAIVectorStoreFileDeleted {
  final String id;
  final bool deleted;
  final String object;

  const OpenAIVectorStoreFileDeleted({
    required this.id,
    required this.deleted,
    this.object = 'vector_store.file.deleted',
  });

  factory OpenAIVectorStoreFileDeleted.fromMap(Map<String, dynamic> map) =>
      OpenAIVectorStoreFileDeleted(
        id: map['id']?.toString() ?? '',
        deleted: map['deleted'] == true,
        object: map['object']?.toString() ?? 'vector_store.file.deleted',
      );
}
