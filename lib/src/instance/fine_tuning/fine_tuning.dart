import 'package:http/http.dart' as http;

import '../../core/base/fine_tuning/fine_tuning.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/models/fine_tuning/fine_tuning_checkpoint.dart';
import '../../core/models/fine_tuning/fine_tuning_event.dart';
import '../../core/models/fine_tuning/fine_tuning_job.dart';
import '../../core/models/fine_tuning/fine_tuning_job_list.dart';
import '../../core/networking/context_client.dart';

/// Fine-tuning API namespace bound to one [OpenAIClientConfig].
class ContextualOpenAIFineTuning extends OpenAIFineTuningBase {
  final OpenAIClientConfig config;
  late final ContextualOpenAIFineTuningJobs _jobs;

  ContextualOpenAIFineTuning(this.config) {
    _jobs = ContextualOpenAIFineTuningJobs(config);
  }

  @override
  ContextualOpenAIFineTuningJobs get jobs => _jobs;
}

/// Current fine-tuning job endpoints and nested resources.
class ContextualOpenAIFineTuningJobs extends OpenAIFineTuningJobsBase {
  final OpenAIClientConfig config;
  late final ContextualOpenAIFineTuningCheckpoints _checkpoints;

  @override
  String get endpoint => OpenAIStrings.endpoints.fineTuningJobs;

  ContextualOpenAIFineTuningJobs(this.config) {
    _checkpoints = ContextualOpenAIFineTuningCheckpoints(config);
  }

  @override
  ContextualOpenAIFineTuningCheckpoints get checkpoints => _checkpoints;

  @override
  Future<OpenAIFineTuningJob> create({
    required String model,
    required String trainingFile,
    String? validationFile,
    String? suffix,
    int? seed,
    Map<String, dynamic>? method,
    Map<String, dynamic>? hyperparameters,
    List<Map<String, dynamic>>? integrations,
    Map<String, dynamic>? metadata,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIFineTuningJob>(
        to: ContextualApiUrlBuilder.build(config, endpoint),
        body: {
          'model': model,
          'training_file': trainingFile,
          if (validationFile != null) 'validation_file': validationFile,
          if (suffix != null) 'suffix': suffix,
          if (seed != null) 'seed': seed,
          if (method != null) 'method': method,
          if (hyperparameters != null) 'hyperparameters': hyperparameters,
          if (integrations != null) 'integrations': integrations,
          if (metadata != null) 'metadata': metadata,
        },
        onSuccess: OpenAIFineTuningJob.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIFineTuningJobList> list({
    String? after,
    int? limit,
    Map<String, String>? metadata,
    bool filterNullMetadata = false,
    http.Client? client,
  }) {
    if (filterNullMetadata && metadata != null && metadata.isNotEmpty) {
      throw ArgumentError(
        'Use metadata filters or filterNullMetadata, not both.',
      );
    }
    final query = <String, String>{
      if (after != null) 'after': after,
      if (limit != null) 'limit': limit.toString(),
      if (filterNullMetadata) 'metadata': 'null',
      if (!filterNullMetadata && metadata != null)
        for (final entry in metadata.entries)
          'metadata[${entry.key}]': entry.value,
    };
    return ContextualNetworkingClient.getChecked<OpenAIFineTuningJobList>(
      from:
          _urlWithQuery(ContextualApiUrlBuilder.build(config, endpoint), query),
      onSuccess: OpenAIFineTuningJobList.fromMap,
      config: config,
      client: client,
    );
  }

  @override
  Future<OpenAIFineTuningJob> retrieve({
    required String fineTuningJobId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIFineTuningJob>(
        from: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(fineTuningJobId),
        ),
        onSuccess: OpenAIFineTuningJob.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIFineTuningJob> cancel({
    required String fineTuningJobId,
    http.Client? client,
  }) =>
      _jobAction(fineTuningJobId, 'cancel', client: client);

  @override
  Future<OpenAIFineTuningJob> pause({
    required String fineTuningJobId,
    http.Client? client,
  }) =>
      _jobAction(fineTuningJobId, 'pause', client: client);

  @override
  Future<OpenAIFineTuningJob> resume({
    required String fineTuningJobId,
    http.Client? client,
  }) =>
      _jobAction(fineTuningJobId, 'resume', client: client);

  @override
  Future<OpenAIFineTuningEventList> listEvents({
    required String fineTuningJobId,
    String? after,
    int? limit,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIFineTuningEventList>(
        from: _urlWithQuery(
          ContextualApiUrlBuilder.build(
            config,
            endpoint,
            '${Uri.encodeComponent(fineTuningJobId)}/events',
          ),
          {
            if (after != null) 'after': after,
            if (limit != null) 'limit': limit.toString(),
          },
        ),
        onSuccess: OpenAIFineTuningEventList.fromMap,
        config: config,
        client: client,
      );

  Future<OpenAIFineTuningJob> _jobAction(
    String fineTuningJobId,
    String action, {
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIFineTuningJob>(
        to: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          '${Uri.encodeComponent(fineTuningJobId)}/$action',
        ),
        onSuccess: OpenAIFineTuningJob.fromMap,
        config: config,
        client: client,
      );
}

/// Checkpoint listing for fine-tuning jobs.
class ContextualOpenAIFineTuningCheckpoints
    extends OpenAIFineTuningCheckpointsBase {
  final OpenAIClientConfig config;

  ContextualOpenAIFineTuningCheckpoints(this.config);

  @override
  Future<OpenAIFineTuningCheckpointList> list({
    required String fineTuningJobId,
    String? after,
    int? limit,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIFineTuningCheckpointList>(
        from: _urlWithQuery(
          ContextualApiUrlBuilder.build(
            config,
            OpenAIStrings.endpoints.fineTuningJobs,
            '${Uri.encodeComponent(fineTuningJobId)}/checkpoints',
          ),
          {
            if (after != null) 'after': after,
            if (limit != null) 'limit': limit.toString(),
          },
        ),
        onSuccess: OpenAIFineTuningCheckpointList.fromMap,
        config: config,
        client: client,
      );
}

String _urlWithQuery(String url, Map<String, String> query) => query.isEmpty
    ? url
    : Uri.parse(url).replace(queryParameters: query).toString();
