import 'package:http/http.dart' as http;

import '../../io/openai_file.dart';
import '../../models/container/container_file.dart';
import '../../models/container/container_file_list.dart';
import '../../models/container/container.dart';
import '../../models/container/container_list.dart';

abstract class OpenAIContainersBase {
  String get endpoint;

  Future<OpenAIContainerModel> create({
    required String name,
    Map<String, dynamic>? expiresAfter,
    List<String>? fileIds,
    String? memoryLimit,
    Map<String, dynamic>? networkPolicy,
    List<Map<String, dynamic>>? skills,
    http.Client? client,
  });

  Future<OpenAIContainerList> list({
    String? after,
    int? limit,
    String? name,
    String? order,
    http.Client? client,
  });

  Future<OpenAIContainerModel> get({
    required String containerId,
    http.Client? client,
  });

  Future<void> delete({
    required String containerId,
    http.Client? client,
  });
}

abstract class OpenAIContainerFilesBase {
  Future<OpenAIContainerFileModel> create({
    required String containerId,
    OpenAIFile? file,
    String? fileId,
    http.Client? client,
  });

  Future<OpenAIContainerFileList> list({
    required String containerId,
    String? after,
    int? limit,
    String? order,
    http.Client? client,
  });

  Future<OpenAIContainerFileModel> get({
    required String containerId,
    required String fileId,
    http.Client? client,
  });

  Future<List<int>> getContent({
    required String containerId,
    required String fileId,
    http.Client? client,
  });

  Future<void> delete({
    required String containerId,
    required String fileId,
    http.Client? client,
  });
}
