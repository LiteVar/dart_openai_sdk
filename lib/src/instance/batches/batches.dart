import 'package:http/http.dart' as http;

import '../../core/base/batches/batches.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/models/batch/batch.dart';
import '../../core/models/batch/batch_list.dart';
import '../../core/networking/context_client.dart';

/// Batch API methods bound to one [OpenAIClientConfig].
class ContextualOpenAIBatches extends OpenAIBatchesBase {
  final OpenAIClientConfig config;

  @override
  String get endpoint => OpenAIStrings.endpoints.batches;

  ContextualOpenAIBatches(this.config);

  @override
  Future<OpenAIBatchModel> create({
    required String inputFileId,
    required String endpoint,
    String completionWindow = '24h',
    Map<String, dynamic>? metadata,
    OpenAIBatchOutputExpirationPolicy? outputExpiresAfter,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIBatchModel>(
        to: ContextualApiUrlBuilder.build(config, this.endpoint),
        body: {
          'input_file_id': inputFileId,
          'endpoint': endpoint,
          'completion_window': completionWindow,
          if (metadata != null) 'metadata': metadata,
          if (outputExpiresAfter != null)
            'output_expires_after': outputExpiresAfter.toMap(),
        },
        onSuccess: OpenAIBatchModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIBatchList> list({
    String? after,
    int? limit,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIBatchList>(
        from: _urlWithQuery(
          ContextualApiUrlBuilder.build(config, endpoint),
          {
            if (after != null) 'after': after,
            if (limit != null) 'limit': limit.toString(),
          },
        ),
        onSuccess: OpenAIBatchList.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIBatchModel> retrieve({
    required String batchId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIBatchModel>(
        from: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(batchId),
        ),
        onSuccess: OpenAIBatchModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIBatchModel> cancel({
    required String batchId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIBatchModel>(
        to: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          '${Uri.encodeComponent(batchId)}/cancel',
        ),
        onSuccess: OpenAIBatchModel.fromMap,
        config: config,
        client: client,
      );
}

String _urlWithQuery(String url, Map<String, String> query) => query.isEmpty
    ? url
    : Uri.parse(url).replace(queryParameters: query).toString();
