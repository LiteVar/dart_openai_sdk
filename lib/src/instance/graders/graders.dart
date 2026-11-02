import 'package:http/http.dart' as http;

import '../../core/base/graders/graders.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/models/graders/grader_result.dart';
import '../../core/networking/context_client.dart';

/// Grader execution and validation calls bound to one client configuration.
///
/// OpenAI is deprecating graders in its evals and fine-tuning workflows. This
/// module remains available for compatibility with the source SDK.
class ContextualOpenAIGraders extends OpenAIGradersBase {
  final OpenAIClientConfig config;

  @override
  String get endpoint => OpenAIStrings.endpoints.graders;

  ContextualOpenAIGraders(this.config);

  @override
  Future<OpenAIGraderRunResult> runGrader({
    required Map<String, dynamic> grader,
    required Object modelSample,
    Map<String, dynamic>? item,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIGraderRunResult>(
        to: ContextualApiUrlBuilder.build(config, endpoint, 'run'),
        body: {
          'grader': grader,
          'model_sample': modelSample,
          if (item != null) 'item': item,
        },
        onSuccess: OpenAIGraderRunResult.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<bool> validateGrader({
    required Map<String, dynamic> grader,
    http.Client? client,
  }) async {
    final response =
        await ContextualNetworkingClient.postChecked<Map<String, dynamic>>(
      to: ContextualApiUrlBuilder.build(config, endpoint, 'validate'),
      body: {'grader': grader},
      onSuccess: (map) => map,
      config: config,
      client: client,
    );
    return response['grader'] is Map;
  }
}
