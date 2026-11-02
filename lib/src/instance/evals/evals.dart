import 'package:http/http.dart' as http;

import '../../core/base/evals/evals.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/models/evals/evals.dart';
import '../../core/networking/context_client.dart';

/// Evals API methods bound to one [OpenAIClientConfig].
///
/// OpenAI has moved the Evals platform into a read-only transition and has
/// scheduled its API shutdown for November 30, 2026. This module is retained
/// for compatibility with the source SDK and existing evaluation records.
class ContextualOpenAIEvals extends OpenAIEvalsBase {
  final OpenAIClientConfig config;

  @override
  String get endpoint => OpenAIStrings.endpoints.evals;

  ContextualOpenAIEvals(this.config);

  @override
  Future<OpenAIEval> create({
    required Map<String, dynamic> dataSourceConfig,
    String? name,
    List<Map<String, dynamic>>? testingCriteria,
    Map<String, dynamic>? metadata,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIEval>(
        to: ContextualApiUrlBuilder.build(config, endpoint),
        body: {
          'data_source_config': dataSourceConfig,
          if (name != null) 'name': name,
          if (testingCriteria != null) 'testing_criteria': testingCriteria,
          if (metadata != null) 'metadata': metadata,
        },
        onSuccess: OpenAIEval.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIEval> get({
    required String evalId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIEval>(
        from: _evalUrl(evalId),
        onSuccess: OpenAIEval.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIEval> update({
    required String evalId,
    String? name,
    List<Map<String, dynamic>>? testingCriteria,
    Map<String, dynamic>? metadata,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIEval>(
        to: _evalUrl(evalId),
        body: {
          if (name != null) 'name': name,
          if (testingCriteria != null) 'testing_criteria': testingCriteria,
          if (metadata != null) 'metadata': metadata,
        },
        onSuccess: OpenAIEval.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<void> delete({required String evalId, http.Client? client}) async {
    await ContextualNetworkingClient.deleteChecked<bool>(
      from: _evalUrl(evalId),
      onSuccess: (map) => map['deleted'] == true,
      config: config,
      client: client,
    );
  }

  @override
  Future<OpenAIEvalsList> list({
    String? after,
    int? limit,
    String? order,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIEvalsList>(
        from: _urlWithQuery(ContextualApiUrlBuilder.build(config, endpoint), {
          if (after != null) 'after': after,
          if (limit != null) 'limit': limit.toString(),
          if (order != null) 'order': order,
        }),
        onSuccess: OpenAIEvalsList.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIEvalRunsList> getRuns({
    required String evalId,
    String? after,
    int? limit,
    String? order,
    String? status,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIEvalRunsList>(
        from: _urlWithQuery(_runsUrl(evalId), {
          if (after != null) 'after': after,
          if (limit != null) 'limit': limit.toString(),
          if (order != null) 'order': order,
          if (status != null) 'status': status,
        }),
        onSuccess: OpenAIEvalRunsList.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIEvalRun> createRun({
    required String evalId,
    required Map<String, dynamic> dataSource,
    String? name,
    Map<String, dynamic>? metadata,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIEvalRun>(
        to: _runsUrl(evalId),
        body: {
          'data_source': dataSource,
          if (name != null) 'name': name,
          if (metadata != null) 'metadata': metadata,
        },
        onSuccess: OpenAIEvalRun.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIEvalRun> getRun({
    required String evalId,
    required String runId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIEvalRun>(
        from: _runUrl(evalId, runId),
        onSuccess: OpenAIEvalRun.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIEvalRun> cancel({
    required String evalId,
    required String runId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIEvalRun>(
        to: '${_runUrl(evalId, runId)}/cancel',
        onSuccess: OpenAIEvalRun.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<void> deleteRun({
    required String evalId,
    required String runId,
    http.Client? client,
  }) async {
    await ContextualNetworkingClient.deleteChecked<bool>(
      from: _runUrl(evalId, runId),
      onSuccess: (map) => map['deleted'] == true,
      config: config,
      client: client,
    );
  }

  @override
  Future<OpenAIEvalRunOutputItemsList> getEvalRunOutputItems({
    required String evalId,
    required String runId,
    String? after,
    int? limit,
    String? order,
    String? status,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIEvalRunOutputItemsList>(
        from: _urlWithQuery(_outputItemsUrl(evalId, runId), {
          if (after != null) 'after': after,
          if (limit != null) 'limit': limit.toString(),
          if (order != null) 'order': order,
          if (status != null) 'status': status,
        }),
        onSuccess: OpenAIEvalRunOutputItemsList.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIEvalRunOutputItem> getEvalRunOutputItem({
    required String evalId,
    required String runId,
    required String outputItemId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIEvalRunOutputItem>(
        from:
            '${_outputItemsUrl(evalId, runId)}/${Uri.encodeComponent(outputItemId)}',
        onSuccess: OpenAIEvalRunOutputItem.fromMap,
        config: config,
        client: client,
      );

  String _evalUrl(String evalId) => ContextualApiUrlBuilder.build(
        config,
        endpoint,
        Uri.encodeComponent(evalId),
      );

  String _runsUrl(String evalId) => '${_evalUrl(evalId)}/runs';

  String _runUrl(String evalId, String runId) =>
      '${_runsUrl(evalId)}/${Uri.encodeComponent(runId)}';

  String _outputItemsUrl(String evalId, String runId) =>
      '${_runUrl(evalId, runId)}/output_items';

  String _urlWithQuery(String url, Map<String, String> query) => query.isEmpty
      ? url
      : Uri.parse(url).replace(queryParameters: query).toString();
}
