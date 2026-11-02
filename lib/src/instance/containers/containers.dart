import 'package:http/http.dart' as http;

import '../../core/base/containers/containers.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/io/openai_file.dart';
import '../../core/models/container/container.dart';
import '../../core/models/container/container_file.dart';
import '../../core/models/container/container_file_list.dart';
import '../../core/models/container/container_list.dart';
import '../../core/networking/context_client.dart';

/// Containers and their files, bound to one [OpenAIClientConfig].
class ContextualOpenAIContainers extends OpenAIContainersBase {
  final OpenAIClientConfig config;
  late final ContextualOpenAIContainerFiles containerFiles =
      ContextualOpenAIContainerFiles(config);

  /// Access the container collection using the source SDK's resource grouping.
  ContextualOpenAIContainers get containers => this;

  @override
  String get endpoint => OpenAIStrings.endpoints.containers;

  ContextualOpenAIContainers(this.config);

  @override
  Future<OpenAIContainerModel> create({
    required String name,
    Map<String, dynamic>? expiresAfter,
    List<String>? fileIds,
    String? memoryLimit,
    Map<String, dynamic>? networkPolicy,
    List<Map<String, dynamic>>? skills,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIContainerModel>(
        to: ContextualApiUrlBuilder.build(config, endpoint),
        body: {
          'name': name,
          if (expiresAfter != null) 'expires_after': expiresAfter,
          if (fileIds != null) 'file_ids': fileIds,
          if (memoryLimit != null) 'memory_limit': memoryLimit,
          if (networkPolicy != null) 'network_policy': networkPolicy,
          if (skills != null) 'skills': skills,
        },
        onSuccess: OpenAIContainerModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIContainerList> list({
    String? after,
    int? limit,
    String? name,
    String? order,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIContainerList>(
        from: _urlWithQuery(ContextualApiUrlBuilder.build(config, endpoint), {
          if (after != null) 'after': after,
          if (limit != null) 'limit': limit.toString(),
          if (name != null) 'name': name,
          if (order != null) 'order': order,
        }),
        onSuccess: OpenAIContainerList.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIContainerModel> get({
    required String containerId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIContainerModel>(
        from: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(containerId),
        ),
        onSuccess: OpenAIContainerModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<void> delete({
    required String containerId,
    http.Client? client,
  }) async {
    await ContextualNetworkingClient.deleteChecked<bool>(
      from: ContextualApiUrlBuilder.build(
        config,
        endpoint,
        Uri.encodeComponent(containerId),
      ),
      onSuccess: (_) => true,
      config: config,
      client: client,
    );
  }

  String _urlWithQuery(String url, Map<String, String> query) => query.isEmpty
      ? url
      : Uri.parse(url).replace(queryParameters: query).toString();
}

/// File operations for a container, bound to one client configuration.
class ContextualOpenAIContainerFiles extends OpenAIContainerFilesBase {
  final OpenAIClientConfig config;

  ContextualOpenAIContainerFiles(this.config);

  String _endpoint(String containerId) => ContextualApiUrlBuilder.build(
        config,
        OpenAIStrings.endpoints.containers,
        '${Uri.encodeComponent(containerId)}/files',
      );

  @override
  Future<OpenAIContainerFileModel> create({
    required String containerId,
    OpenAIFile? file,
    String? fileId,
    http.Client? client,
  }) {
    if ((file == null) == (fileId == null)) {
      throw ArgumentError('Provide exactly one of file or fileId.');
    }
    final url = _endpoint(containerId);
    if (file != null) {
      return ContextualNetworkingClient.multipartPostChecked<
          OpenAIContainerFileModel>(
        to: url,
        fileField: 'file',
        file: file,
        fields: const {},
        onSuccess: OpenAIContainerFileModel.fromMap,
        config: config,
        client: client,
      );
    }
    return ContextualNetworkingClient.postChecked<OpenAIContainerFileModel>(
      to: url,
      body: {'file_id': fileId},
      onSuccess: OpenAIContainerFileModel.fromMap,
      config: config,
      client: client,
    );
  }

  @override
  Future<OpenAIContainerFileList> list({
    required String containerId,
    String? after,
    int? limit,
    String? order,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIContainerFileList>(
        from: _urlWithQuery(_endpoint(containerId), {
          if (after != null) 'after': after,
          if (limit != null) 'limit': limit.toString(),
          if (order != null) 'order': order,
        }),
        onSuccess: OpenAIContainerFileList.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIContainerFileModel> get({
    required String containerId,
    required String fileId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIContainerFileModel>(
        from: ContextualApiUrlBuilder.build(
          config,
          OpenAIStrings.endpoints.containers,
          '${Uri.encodeComponent(containerId)}/files/${Uri.encodeComponent(fileId)}',
        ),
        onSuccess: OpenAIContainerFileModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<List<int>> getContent({
    required String containerId,
    required String fileId,
    http.Client? client,
  }) async =>
      (await ContextualNetworkingClient.getRawChecked(
        from: ContextualApiUrlBuilder.build(
          config,
          OpenAIStrings.endpoints.containers,
          '${Uri.encodeComponent(containerId)}/files/${Uri.encodeComponent(fileId)}/content',
        ),
        config: config,
        client: client,
      ))
          .bodyBytes;

  @override
  Future<void> delete({
    required String containerId,
    required String fileId,
    http.Client? client,
  }) async {
    await ContextualNetworkingClient.deleteChecked<bool>(
      from: ContextualApiUrlBuilder.build(
        config,
        OpenAIStrings.endpoints.containers,
        '${Uri.encodeComponent(containerId)}/files/${Uri.encodeComponent(fileId)}',
      ),
      onSuccess: (_) => true,
      config: config,
      client: client,
    );
  }

  String _urlWithQuery(String url, Map<String, String> query) => query.isEmpty
      ? url
      : Uri.parse(url).replace(queryParameters: query).toString();
}
