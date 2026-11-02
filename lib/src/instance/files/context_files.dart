import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/base/files/contextual_files.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/io/openai_file.dart';
import '../../core/models/file/expires_after.dart';
import '../../core/models/file/file.dart';
import '../../core/models/file/file_list.dart';
import '../../core/networking/context_client.dart';

/// Files API methods bound to one [OpenAIClientConfig].
class ContextualOpenAIFiles extends OpenAIContextualFilesBase {
  final OpenAIClientConfig config;

  @override
  String get endpoint => OpenAIStrings.endpoints.files;

  ContextualOpenAIFiles(this.config);

  @override
  Future<OpenAIFileListModel> list({
    String? after,
    int? limit,
    String? order,
    String? purpose,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIFileListModel>(
        from: _urlWithQuery(
          ContextualApiUrlBuilder.build(config, endpoint),
          {
            if (after != null) 'after': after,
            if (limit != null) 'limit': limit.toString(),
            if (order != null) 'order': order,
            if (purpose != null) 'purpose': purpose,
          },
        ),
        onSuccess: OpenAIFileListModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIFileModel> retrieve(String fileId, {http.Client? client}) =>
      ContextualNetworkingClient.getChecked<OpenAIFileModel>(
        from: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(fileId),
        ),
        onSuccess: OpenAIFileModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<String> retrieveContent(String fileId, {http.Client? client}) async {
    final response = await ContextualNetworkingClient.getRawChecked(
      from: ContextualApiUrlBuilder.build(
        config,
        endpoint,
        '${Uri.encodeComponent(fileId)}/content',
      ),
      config: config,
      client: client,
    );
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  @override
  Future<OpenAIFileModel> upload({
    required OpenAIFile file,
    required String purpose,
    OpenAIFileExpiresAfter? expiresAfter,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.multipartPostChecked<OpenAIFileModel>(
        to: ContextualApiUrlBuilder.build(config, endpoint),
        fileField: 'file',
        file: file,
        fields: {
          'purpose': purpose,
          if (expiresAfter != null) ...{
            'expires_after[anchor]': expiresAfter.anchor,
            'expires_after[seconds]': expiresAfter.seconds.toString(),
          },
        },
        onSuccess: OpenAIFileModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIFileModel> uploadBytes({
    required List<int> bytes,
    required String fileName,
    required String purpose,
    OpenAIFileExpiresAfter? expiresAfter,
    http.Client? client,
  }) =>
      upload(
        file: OpenAIFile(bytes: bytes, fileName: fileName),
        purpose: purpose,
        expiresAfter: expiresAfter,
        client: client,
      );

  @override
  Future<bool> delete(String fileId, {http.Client? client}) =>
      ContextualNetworkingClient.deleteChecked<bool>(
        from: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(fileId),
        ),
        onSuccess: (response) => response['deleted'] == true,
        config: config,
        client: client,
      );

  String _urlWithQuery(String url, Map<String, String> query) => query.isEmpty
      ? url
      : Uri.parse(url).replace(queryParameters: query).toString();
}
