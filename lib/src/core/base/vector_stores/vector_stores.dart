import 'package:http/http.dart' as http;

import '../../models/vector_store/vector_store.dart';
import '../../models/vector_store/vector_store_file.dart';
import '../../models/vector_store/vector_store_file_batch.dart';
import '../../models/vector_store/vector_store_file_batch_item.dart';
import '../../models/vector_store/vector_store_file_list.dart';
import '../../models/vector_store/vector_store_list.dart';
import '../../models/vector_store/vector_store_search.dart';

/// Contract for the Vector Stores API, bound to one configured client.
abstract class OpenAIVectorStoresBase {
  String get endpoint;
  OpenAIVectorStoreFilesBase get files;
  OpenAIVectorStoreFileBatchesBase get fileBatches;

  Future<OpenAIVectorStore> create({
    String? name,
    String? description,
    List<String>? fileIds,
    OpenAIVectorStoreExpirationPolicy? expiresAfter,
    Map<String, dynamic>? metadata,
    OpenAIVectorStoreChunkingStrategy? chunkingStrategy,
    http.Client? client,
  });

  Future<OpenAIVectorStore> retrieve({
    required String vectorStoreId,
    http.Client? client,
  });

  Future<OpenAIVectorStoreList> list({
    String? after,
    String? before,
    int? limit,
    String? order,
    http.Client? client,
  });

  Future<OpenAIVectorStore> update({
    required String vectorStoreId,
    String? name,
    OpenAIVectorStoreExpirationPolicy? expiresAfter,
    Map<String, dynamic>? metadata,
    http.Client? client,
  });

  Future<OpenAIVectorStoreDeleted> delete({
    required String vectorStoreId,
    http.Client? client,
  });

  Future<OpenAIVectorStoreSearchResponse> search({
    required String vectorStoreId,
    required Object query,
    OpenAIVectorStoreFilter? filters,
    int? maxNumResults,
    OpenAIVectorStoreRankingOptions? rankingOptions,
    bool? rewriteQuery,
    http.Client? client,
  });
}

/// Contract for files attached to a vector store.
abstract class OpenAIVectorStoreFilesBase {
  Future<OpenAIVectorStoreFile> create({
    required String vectorStoreId,
    required String fileId,
    Map<String, dynamic>? attributes,
    OpenAIVectorStoreChunkingStrategy? chunkingStrategy,
    http.Client? client,
  });

  Future<OpenAIVectorStoreFileList> list({
    required String vectorStoreId,
    String? after,
    String? before,
    String? filter,
    int? limit,
    String? order,
    http.Client? client,
  });

  Future<OpenAIVectorStoreFile> retrieve({
    required String vectorStoreId,
    required String fileId,
    http.Client? client,
  });

  Future<OpenAIVectorStoreFile> update({
    required String vectorStoreId,
    required String fileId,
    required Map<String, dynamic> attributes,
    http.Client? client,
  });

  Future<OpenAIVectorStoreFileDeleted> delete({
    required String vectorStoreId,
    required String fileId,
    http.Client? client,
  });

  Future<OpenAIVectorStoreFileContentPage> retrieveContent({
    required String vectorStoreId,
    required String fileId,
    String? page,
    http.Client? client,
  });
}

/// Contract for vector store file batches.
abstract class OpenAIVectorStoreFileBatchesBase {
  Future<OpenAIVectorStoreFileBatch> create({
    required String vectorStoreId,
    List<String>? fileIds,
    List<OpenAIVectorStoreFileBatchItem>? files,
    Map<String, dynamic>? attributes,
    OpenAIVectorStoreChunkingStrategy? chunkingStrategy,
    http.Client? client,
  });

  Future<OpenAIVectorStoreFileBatch> retrieve({
    required String vectorStoreId,
    required String batchId,
    http.Client? client,
  });

  Future<OpenAIVectorStoreFileBatch> cancel({
    required String vectorStoreId,
    required String batchId,
    http.Client? client,
  });

  Future<OpenAIVectorStoreFileList> listFiles({
    required String vectorStoreId,
    required String batchId,
    String? after,
    String? before,
    String? filter,
    int? limit,
    String? order,
    http.Client? client,
  });
}
