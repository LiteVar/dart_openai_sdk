import 'package:http/http.dart' as http;

import '../../io/openai_file.dart';
import '../../models/file/expires_after.dart';
import '../../models/file/file.dart';
import '../../models/file/file_list.dart';

/// Files API contract bound to one configured [OpenAIClient].
abstract class OpenAIContextualFilesBase {
  String get endpoint;

  Future<OpenAIFileListModel> list({
    String? after,
    int? limit,
    String? order,
    String? purpose,
    http.Client? client,
  });

  Future<OpenAIFileModel> retrieve(String fileId, {http.Client? client});

  Future<String> retrieveContent(String fileId, {http.Client? client});

  Future<OpenAIFileModel> upload({
    required OpenAIFile file,
    required String purpose,
    OpenAIFileExpiresAfter? expiresAfter,
    http.Client? client,
  });

  Future<OpenAIFileModel> uploadBytes({
    required List<int> bytes,
    required String fileName,
    required String purpose,
    OpenAIFileExpiresAfter? expiresAfter,
    http.Client? client,
  });

  Future<bool> delete(String fileId, {http.Client? client});
}
