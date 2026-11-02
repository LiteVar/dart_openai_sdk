import 'package:http/http.dart' as http;

import '../../models/evals/evals.dart';

abstract class OpenAIEvalsBase {
  String get endpoint;

  Future<OpenAIEval> create({
    required Map<String, dynamic> dataSourceConfig,
    String? name,
    List<Map<String, dynamic>>? testingCriteria,
    Map<String, dynamic>? metadata,
    http.Client? client,
  });

  Future<OpenAIEval> get({required String evalId, http.Client? client});

  Future<OpenAIEval> update({
    required String evalId,
    String? name,
    List<Map<String, dynamic>>? testingCriteria,
    Map<String, dynamic>? metadata,
    http.Client? client,
  });

  Future<void> delete({required String evalId, http.Client? client});

  Future<OpenAIEvalsList> list({
    String? after,
    int? limit,
    String? order,
    http.Client? client,
  });

  Future<OpenAIEvalRunsList> getRuns({
    required String evalId,
    String? after,
    int? limit,
    String? order,
    String? status,
    http.Client? client,
  });

  Future<OpenAIEvalRun> createRun({
    required String evalId,
    required Map<String, dynamic> dataSource,
    String? name,
    Map<String, dynamic>? metadata,
    http.Client? client,
  });

  Future<OpenAIEvalRun> getRun({
    required String evalId,
    required String runId,
    http.Client? client,
  });

  Future<OpenAIEvalRun> cancel({
    required String evalId,
    required String runId,
    http.Client? client,
  });

  Future<void> deleteRun({
    required String evalId,
    required String runId,
    http.Client? client,
  });

  Future<OpenAIEvalRunOutputItemsList> getEvalRunOutputItems({
    required String evalId,
    required String runId,
    String? after,
    int? limit,
    String? order,
    String? status,
    http.Client? client,
  });

  Future<OpenAIEvalRunOutputItem> getEvalRunOutputItem({
    required String evalId,
    required String runId,
    required String outputItemId,
    http.Client? client,
  });
}
