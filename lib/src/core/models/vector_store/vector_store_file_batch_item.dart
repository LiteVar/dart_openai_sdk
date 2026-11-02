import 'vector_store.dart';

/// Per-file overrides supported when creating a vector store file batch.
class OpenAIVectorStoreFileBatchItem {
  final String fileId;
  final Map<String, dynamic>? attributes;
  final OpenAIVectorStoreChunkingStrategy? chunkingStrategy;

  const OpenAIVectorStoreFileBatchItem({
    required this.fileId,
    this.attributes,
    this.chunkingStrategy,
  });

  Map<String, dynamic> toMap() => {
        'file_id': fileId,
        if (attributes != null) 'attributes': attributes,
        if (chunkingStrategy != null)
          'chunking_strategy': chunkingStrategy!.toMap(),
      };
}
