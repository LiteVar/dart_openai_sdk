import 'package:http/http.dart' as http;

import '../../io/openai_file.dart';
import '../../models/uploads/expires_after.dart';
import '../../models/uploads/upload_part.dart';
import '../../models/uploads/uploads.dart';

/// Contract for creating and managing multipart Uploads.
abstract class OpenAIUploadsBase {
  String get endpoint;

  Future<OpenAIUploadModel> create({
    required int bytes,
    required String filename,
    required String mimeType,
    required String purpose,
    OpenAIUploadExpiresAfter? expiresAfter,
    http.Client? client,
  });

  Future<OpenAIUploadPartModel> addPart({
    required String uploadId,
    required OpenAIFile data,
    http.Client? client,
  });

  Future<OpenAIUploadModel> complete({
    required String uploadId,
    required List<String> partIds,
    String? md5,
    http.Client? client,
  });

  Future<OpenAIUploadModel> cancel({
    required String uploadId,
    http.Client? client,
  });
}
