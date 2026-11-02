import 'package:http/http.dart' as http;

import '../../models/batch/batch.dart';
import '../../models/batch/batch_list.dart';

/// Contract for the asynchronous Batches API.
abstract class OpenAIBatchesBase {
  String get endpoint;

  Future<OpenAIBatchModel> create({
    required String inputFileId,
    required String endpoint,
    String completionWindow = '24h',
    Map<String, dynamic>? metadata,
    OpenAIBatchOutputExpirationPolicy? outputExpiresAfter,
    http.Client? client,
  });

  Future<OpenAIBatchList> list({
    String? after,
    int? limit,
    http.Client? client,
  });

  Future<OpenAIBatchModel> retrieve({
    required String batchId,
    http.Client? client,
  });

  Future<OpenAIBatchModel> cancel({
    required String batchId,
    http.Client? client,
  });
}
