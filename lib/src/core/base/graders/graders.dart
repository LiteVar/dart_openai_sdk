import 'package:http/http.dart' as http;

import '../../models/graders/grader_result.dart';

abstract class OpenAIGradersBase {
  String get endpoint;

  Future<OpenAIGraderRunResult> runGrader({
    required Map<String, dynamic> grader,
    required Object modelSample,
    Map<String, dynamic>? item,
    http.Client? client,
  });

  Future<bool> validateGrader({
    required Map<String, dynamic> grader,
    http.Client? client,
  });
}
