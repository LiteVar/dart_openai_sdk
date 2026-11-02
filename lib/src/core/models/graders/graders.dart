/// Builders for the grader JSON objects accepted by the Evals and
/// fine-tuning APIs.
abstract final class OpenAIGraders {
  static Map<String, dynamic> stringCheckGrader({
    required String name,
    required String input,
    required String reference,
    required String operation,
  }) =>
      {
        'type': 'string_check',
        'name': name,
        'input': input,
        'reference': reference,
        'operation': operation,
      };

  static Map<String, dynamic> textSimilarityGrader({
    required String name,
    required String input,
    required String reference,
    required String evaluationMetric,
  }) =>
      {
        'type': 'text_similarity',
        'name': name,
        'input': input,
        'reference': reference,
        'evaluation_metric': evaluationMetric,
      };

  static Map<String, dynamic> scoreModelGrader({
    required String name,
    required String model,
    required List<Map<String, dynamic>> input,
    double? passThreshold,
    List<num>? range,
    Map<String, dynamic>? samplingParams,
  }) =>
      {
        'type': 'score_model',
        'name': name,
        'model': model,
        'input': input,
        if (passThreshold != null) 'pass_threshold': passThreshold,
        if (range != null) 'range': range,
        if (samplingParams != null) 'sampling_params': samplingParams,
      };

  static Map<String, dynamic> labelModelGrader({
    required String name,
    required String model,
    required List<Map<String, dynamic>> input,
    required List<String> labels,
    required List<String> passingLabels,
  }) =>
      {
        'type': 'label_model',
        'name': name,
        'model': model,
        'input': input,
        'labels': labels,
        'passing_labels': passingLabels,
      };

  static Map<String, dynamic> pythonGrader({
    required String name,
    required String source,
    String? imageTag,
  }) =>
      {
        'type': 'python',
        'name': name,
        'source': source,
        if (imageTag != null) 'image_tag': imageTag,
      };

  static Map<String, dynamic> multiGrader({
    required String name,
    required Map<String, dynamic> graders,
    required String calculateOutput,
  }) =>
      {
        'type': 'multi',
        'name': name,
        'graders': graders,
        'calculate_output': calculateOutput,
      };
}
