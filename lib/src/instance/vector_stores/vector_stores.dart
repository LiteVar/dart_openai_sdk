import 'package:http/http.dart' as http;

import '../../core/base/vector_stores/vector_stores.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/models/vector_store/vector_store.dart';
import '../../core/models/vector_store/vector_store_file.dart';
import '../../core/models/vector_store/vector_store_file_batch.dart';
import '../../core/models/vector_store/vector_store_file_batch_item.dart';
import '../../core/models/vector_store/vector_store_file_list.dart';
import '../../core/models/vector_store/vector_store_list.dart';
import '../../core/models/vector_store/vector_store_search.dart';
import '../../core/networking/context_client.dart';

/// Vector Stores API methods bound to one [OpenAIClientConfig].
class ContextualOpenAIVectorStores extends OpenAIVectorStoresBase {
  final OpenAIClientConfig config;
  late final ContextualOpenAIVectorStoreFiles _files;
  late final ContextualOpenAIVectorStoreFileBatches _fileBatches;

  @override
  String get endpoint => OpenAIStrings.endpoints.vectorStores;

  ContextualOpenAIVectorStores(this.config) {
    _files = ContextualOpenAIVectorStoreFiles(config);
    _fileBatches = ContextualOpenAIVectorStoreFileBatches(config);
  }

  @override
  ContextualOpenAIVectorStoreFiles get files => _files;

  @override
  ContextualOpenAIVectorStoreFileBatches get fileBatches => _fileBatches;

  @override
  Future<OpenAIVectorStore> create({
    String? name,
    String? description,
    List<String>? fileIds,
    OpenAIVectorStoreExpirationPolicy? expiresAfter,
    Map<String, dynamic>? metadata,
    OpenAIVectorStoreChunkingStrategy? chunkingStrategy,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIVectorStore>(
        to: ContextualApiUrlBuilder.build(config, endpoint),
        body: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (fileIds != null) 'file_ids': fileIds,
          if (expiresAfter != null) 'expires_after': expiresAfter.toMap(),
          if (metadata != null) 'metadata': metadata,
          if (chunkingStrategy != null)
            'chunking_strategy': chunkingStrategy.toMap(),
        },
        onSuccess: OpenAIVectorStore.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStore> retrieve({
    required String vectorStoreId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIVectorStore>(
        from: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(vectorStoreId),
        ),
        onSuccess: OpenAIVectorStore.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreList> list({
    String? after,
    String? before,
    int? limit,
    String? order,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIVectorStoreList>(
        from: _urlWithQuery(ContextualApiUrlBuilder.build(config, endpoint), {
          if (after != null) 'after': after,
          if (before != null) 'before': before,
          if (limit != null) 'limit': limit.toString(),
          if (order != null) 'order': order,
        }),
        onSuccess: OpenAIVectorStoreList.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStore> update({
    required String vectorStoreId,
    String? name,
    OpenAIVectorStoreExpirationPolicy? expiresAfter,
    Map<String, dynamic>? metadata,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIVectorStore>(
        to: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(vectorStoreId),
        ),
        body: {
          if (name != null) 'name': name,
          if (expiresAfter != null) 'expires_after': expiresAfter.toMap(),
          if (metadata != null) 'metadata': metadata,
        },
        onSuccess: OpenAIVectorStore.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreDeleted> delete({
    required String vectorStoreId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.deleteChecked<OpenAIVectorStoreDeleted>(
        from: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(vectorStoreId),
        ),
        onSuccess: OpenAIVectorStoreDeleted.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreSearchResponse> search({
    required String vectorStoreId,
    required Object query,
    OpenAIVectorStoreFilter? filters,
    int? maxNumResults,
    OpenAIVectorStoreRankingOptions? rankingOptions,
    bool? rewriteQuery,
    http.Client? client,
  }) {
    if (query is! String &&
        !(query is List && query.every((item) => item is String))) {
      throw ArgumentError.value(
        query,
        'query',
        'Must be a string or a list of strings.',
      );
    }
    return ContextualNetworkingClient.postChecked<
        OpenAIVectorStoreSearchResponse>(
      to: ContextualApiUrlBuilder.build(
        config,
        endpoint,
        '${Uri.encodeComponent(vectorStoreId)}/search',
      ),
      body: {
        'query': query,
        if (filters != null) 'filters': filters.toMap(),
        if (maxNumResults != null) 'max_num_results': maxNumResults,
        if (rankingOptions != null) 'ranking_options': rankingOptions.toMap(),
        if (rewriteQuery != null) 'rewrite_query': rewriteQuery,
      },
      onSuccess: OpenAIVectorStoreSearchResponse.fromMap,
      config: _vectorStoreRequestConfig(config),
      client: client,
    );
  }
}

/// Operations on files attached to a vector store.
class ContextualOpenAIVectorStoreFiles extends OpenAIVectorStoreFilesBase {
  final OpenAIClientConfig config;

  ContextualOpenAIVectorStoreFiles(this.config);

  @override
  Future<OpenAIVectorStoreFile> create({
    required String vectorStoreId,
    required String fileId,
    Map<String, dynamic>? attributes,
    OpenAIVectorStoreChunkingStrategy? chunkingStrategy,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIVectorStoreFile>(
        to: _vectorStoreChildUrl(config, vectorStoreId, 'files'),
        body: {
          'file_id': fileId,
          if (attributes != null) 'attributes': attributes,
          if (chunkingStrategy != null)
            'chunking_strategy': chunkingStrategy.toMap(),
        },
        onSuccess: OpenAIVectorStoreFile.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreFileList> list({
    required String vectorStoreId,
    String? after,
    String? before,
    String? filter,
    int? limit,
    String? order,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIVectorStoreFileList>(
        from: _urlWithQuery(
          _vectorStoreChildUrl(config, vectorStoreId, 'files'),
          {
            if (after != null) 'after': after,
            if (before != null) 'before': before,
            if (filter != null) 'filter': filter,
            if (limit != null) 'limit': limit.toString(),
            if (order != null) 'order': order,
          },
        ),
        onSuccess: OpenAIVectorStoreFileList.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreFile> retrieve({
    required String vectorStoreId,
    required String fileId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIVectorStoreFile>(
        from: _vectorStoreChildUrl(
          config,
          vectorStoreId,
          'files/${Uri.encodeComponent(fileId)}',
        ),
        onSuccess: OpenAIVectorStoreFile.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreFile> update({
    required String vectorStoreId,
    required String fileId,
    required Map<String, dynamic> attributes,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIVectorStoreFile>(
        to: _vectorStoreChildUrl(
          config,
          vectorStoreId,
          'files/${Uri.encodeComponent(fileId)}',
        ),
        body: {'attributes': attributes},
        onSuccess: OpenAIVectorStoreFile.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreFileDeleted> delete({
    required String vectorStoreId,
    required String fileId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.deleteChecked<OpenAIVectorStoreFileDeleted>(
        from: _vectorStoreChildUrl(
          config,
          vectorStoreId,
          'files/${Uri.encodeComponent(fileId)}',
        ),
        onSuccess: OpenAIVectorStoreFileDeleted.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreFileContentPage> retrieveContent({
    required String vectorStoreId,
    required String fileId,
    String? page,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIVectorStoreFileContentPage>(
        from: _urlWithQuery(
          _vectorStoreChildUrl(
            config,
            vectorStoreId,
            'files/${Uri.encodeComponent(fileId)}/content',
          ),
          {if (page != null) 'page': page},
        ),
        onSuccess: OpenAIVectorStoreFileContentPage.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );
}

/// Operations on vector store file batches.
class ContextualOpenAIVectorStoreFileBatches
    extends OpenAIVectorStoreFileBatchesBase {
  final OpenAIClientConfig config;

  ContextualOpenAIVectorStoreFileBatches(this.config);

  @override
  Future<OpenAIVectorStoreFileBatch> create({
    required String vectorStoreId,
    List<String>? fileIds,
    List<OpenAIVectorStoreFileBatchItem>? files,
    Map<String, dynamic>? attributes,
    OpenAIVectorStoreChunkingStrategy? chunkingStrategy,
    http.Client? client,
  }) {
    if (fileIds != null && files != null) {
      throw ArgumentError('Specify fileIds or files, but not both.');
    }
    return ContextualNetworkingClient.postChecked<OpenAIVectorStoreFileBatch>(
      to: _vectorStoreChildUrl(config, vectorStoreId, 'file_batches'),
      body: {
        if (fileIds != null) 'file_ids': fileIds,
        if (files != null) 'files': files.map((item) => item.toMap()).toList(),
        if (attributes != null) 'attributes': attributes,
        if (chunkingStrategy != null)
          'chunking_strategy': chunkingStrategy.toMap(),
      },
      onSuccess: OpenAIVectorStoreFileBatch.fromMap,
      config: _vectorStoreRequestConfig(config),
      client: client,
    );
  }

  @override
  Future<OpenAIVectorStoreFileBatch> retrieve({
    required String vectorStoreId,
    required String batchId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIVectorStoreFileBatch>(
        from: _vectorStoreChildUrl(
          config,
          vectorStoreId,
          'file_batches/${Uri.encodeComponent(batchId)}',
        ),
        onSuccess: OpenAIVectorStoreFileBatch.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreFileBatch> cancel({
    required String vectorStoreId,
    required String batchId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIVectorStoreFileBatch>(
        to: _vectorStoreChildUrl(
          config,
          vectorStoreId,
          'file_batches/${Uri.encodeComponent(batchId)}/cancel',
        ),
        onSuccess: OpenAIVectorStoreFileBatch.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );

  @override
  Future<OpenAIVectorStoreFileList> listFiles({
    required String vectorStoreId,
    required String batchId,
    String? after,
    String? before,
    String? filter,
    int? limit,
    String? order,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIVectorStoreFileList>(
        from: _urlWithQuery(
          _vectorStoreChildUrl(
            config,
            vectorStoreId,
            'file_batches/${Uri.encodeComponent(batchId)}/files',
          ),
          {
            if (after != null) 'after': after,
            if (before != null) 'before': before,
            if (filter != null) 'filter': filter,
            if (limit != null) 'limit': limit.toString(),
            if (order != null) 'order': order,
          },
        ),
        onSuccess: OpenAIVectorStoreFileList.fromMap,
        config: _vectorStoreRequestConfig(config),
        client: client,
      );
}

OpenAIClientConfig _vectorStoreRequestConfig(OpenAIClientConfig config) =>
    config.copyWith(
      additionalHeaders: {
        ...config.additionalHeaders,
        'OpenAI-Beta': 'assistants=v2',
      },
    );

String _vectorStoreChildUrl(
  OpenAIClientConfig config,
  String vectorStoreId,
  String path,
) =>
    ContextualApiUrlBuilder.build(
      config,
      OpenAIStrings.endpoints.vectorStores,
      '${Uri.encodeComponent(vectorStoreId)}/$path',
    );

String _urlWithQuery(String url, Map<String, String> query) => query.isEmpty
    ? url
    : Uri.parse(url).replace(queryParameters: query).toString();
