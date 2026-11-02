int _vectorStoreInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _vectorStoreDate(dynamic value) {
  if (value == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(
    _vectorStoreInt(value) * 1000,
    isUtc: true,
  );
}

Map<String, dynamic> _vectorStoreMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

/// Expiration policy for a vector store.
class OpenAIVectorStoreExpirationPolicy {
  final String anchor;
  final int days;

  const OpenAIVectorStoreExpirationPolicy({
    this.anchor = 'last_active_at',
    required this.days,
  });

  factory OpenAIVectorStoreExpirationPolicy.fromMap(
    Map<String, dynamic> map,
  ) =>
      OpenAIVectorStoreExpirationPolicy(
        anchor: map['anchor']?.toString() ?? 'last_active_at',
        days: _vectorStoreInt(map['days']),
      );

  Map<String, dynamic> toMap() => {'anchor': anchor, 'days': days};
}

/// File chunking configuration accepted by vector store create/file endpoints.
class OpenAIVectorStoreChunkingStrategy {
  final String type;
  final int? maxChunkSizeTokens;
  final int? chunkOverlapTokens;

  const OpenAIVectorStoreChunkingStrategy.auto()
      : type = 'auto',
        maxChunkSizeTokens = null,
        chunkOverlapTokens = null;

  const OpenAIVectorStoreChunkingStrategy.staticStrategy({
    required int maxChunkSizeTokens,
    required int chunkOverlapTokens,
  })  : type = 'static',
        maxChunkSizeTokens = maxChunkSizeTokens,
        chunkOverlapTokens = chunkOverlapTokens;

  Map<String, dynamic> toMap() => type == 'auto'
      ? {'type': 'auto'}
      : {
          'type': 'static',
          'static': {
            'max_chunk_size_tokens': maxChunkSizeTokens,
            'chunk_overlap_tokens': chunkOverlapTokens,
          },
        };
}

/// Counts of files by processing state for a vector store.
class OpenAIVectorStoreFileCounts {
  final int inProgress;
  final int completed;
  final int failed;
  final int cancelled;
  final int total;

  const OpenAIVectorStoreFileCounts({
    this.inProgress = 0,
    this.completed = 0,
    this.failed = 0,
    this.cancelled = 0,
    this.total = 0,
  });

  factory OpenAIVectorStoreFileCounts.fromMap(Map<String, dynamic> map) =>
      OpenAIVectorStoreFileCounts(
        inProgress: _vectorStoreInt(map['in_progress']),
        completed: _vectorStoreInt(map['completed']),
        failed: _vectorStoreInt(map['failed']),
        cancelled: _vectorStoreInt(map['cancelled']),
        total: _vectorStoreInt(map['total']),
      );

  Map<String, dynamic> toMap() => {
        'in_progress': inProgress,
        'completed': completed,
        'failed': failed,
        'cancelled': cancelled,
        'total': total,
      };
}

/// A server-side vector store used by file search.
class OpenAIVectorStore {
  final String id;
  final DateTime createdAt;
  final String name;
  final String? description;
  final String status;
  final String object;
  final int usageBytes;
  final DateTime? lastActiveAt;
  final DateTime? expiresAt;
  final OpenAIVectorStoreExpirationPolicy? expiresAfter;
  final OpenAIVectorStoreFileCounts fileCounts;
  final Map<String, dynamic> metadata;

  const OpenAIVectorStore({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.status,
    required this.fileCounts,
    required this.metadata,
    this.description,
    this.object = 'vector_store',
    this.usageBytes = 0,
    this.lastActiveAt,
    this.expiresAt,
    this.expiresAfter,
  });

  factory OpenAIVectorStore.fromMap(Map<String, dynamic> map) {
    final expiresAfter = map['expires_after'];
    return OpenAIVectorStore(
      id: map['id']?.toString() ?? '',
      createdAt: _vectorStoreDate(map['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      status: map['status']?.toString() ?? '',
      object: map['object']?.toString() ?? 'vector_store',
      usageBytes: _vectorStoreInt(map['usage_bytes']),
      lastActiveAt: _vectorStoreDate(map['last_active_at']),
      expiresAt: _vectorStoreDate(map['expires_at']),
      expiresAfter: expiresAfter is Map
          ? OpenAIVectorStoreExpirationPolicy.fromMap(
              Map<String, dynamic>.from(expiresAfter),
            )
          : null,
      fileCounts: OpenAIVectorStoreFileCounts.fromMap(
        _vectorStoreMap(map['file_counts']),
      ),
      metadata: _vectorStoreMap(map['metadata']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'object': object,
        'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
        'name': name,
        if (description != null) 'description': description,
        'status': status,
        'usage_bytes': usageBytes,
        if (lastActiveAt != null)
          'last_active_at': lastActiveAt!.millisecondsSinceEpoch ~/ 1000,
        if (expiresAt != null)
          'expires_at': expiresAt!.millisecondsSinceEpoch ~/ 1000,
        if (expiresAfter != null) 'expires_after': expiresAfter!.toMap(),
        'file_counts': fileCounts.toMap(),
        'metadata': metadata,
      };
}

/// Result returned when deleting a vector store.
class OpenAIVectorStoreDeleted {
  final String id;
  final bool deleted;
  final String object;

  const OpenAIVectorStoreDeleted({
    required this.id,
    required this.deleted,
    this.object = 'vector_store.deleted',
  });

  factory OpenAIVectorStoreDeleted.fromMap(Map<String, dynamic> map) =>
      OpenAIVectorStoreDeleted(
        id: map['id']?.toString() ?? '',
        deleted: map['deleted'] == true,
        object: map['object']?.toString() ?? 'vector_store.deleted',
      );
}
