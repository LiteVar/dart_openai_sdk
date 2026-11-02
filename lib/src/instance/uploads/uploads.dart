import 'package:http/http.dart' as http;

import '../../core/base/uploads/uploads.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/io/openai_file.dart';
import '../../core/models/uploads/expires_after.dart';
import '../../core/models/uploads/upload_part.dart';
import '../../core/models/uploads/uploads.dart';
import '../../core/networking/context_client.dart';

/// Multipart Upload API methods bound to one [OpenAIClientConfig].
class ContextualOpenAIUploads extends OpenAIUploadsBase {
  final OpenAIClientConfig config;

  @override
  String get endpoint => OpenAIStrings.endpoints.uploads;

  ContextualOpenAIUploads(this.config);

  @override
  Future<OpenAIUploadModel> create({
    required int bytes,
    required String filename,
    required String mimeType,
    required String purpose,
    OpenAIUploadExpiresAfter? expiresAfter,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIUploadModel>(
        to: ContextualApiUrlBuilder.build(config, endpoint),
        body: {
          'bytes': bytes,
          'filename': filename,
          'mime_type': mimeType,
          'purpose': purpose,
          if (expiresAfter != null)
            'expires_after': {
              'anchor': expiresAfter.anchor,
              'seconds': expiresAfter.seconds,
            },
        },
        onSuccess: OpenAIUploadModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIUploadPartModel> addPart({
    required String uploadId,
    required OpenAIFile data,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.multipartPostChecked<OpenAIUploadPartModel>(
        to: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          '${Uri.encodeComponent(uploadId)}/parts',
        ),
        fileField: 'data',
        file: data,
        fields: const {},
        onSuccess: OpenAIUploadPartModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIUploadModel> complete({
    required String uploadId,
    required List<String> partIds,
    String? md5,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIUploadModel>(
        to: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          '${Uri.encodeComponent(uploadId)}/complete',
        ),
        body: {
          'part_ids': partIds,
          if (md5 != null) 'md5': md5,
        },
        onSuccess: OpenAIUploadModel.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIUploadModel> cancel({
    required String uploadId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIUploadModel>(
        to: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          '${Uri.encodeComponent(uploadId)}/cancel',
        ),
        onSuccess: OpenAIUploadModel.fromMap,
        config: config,
        client: client,
      );
}
