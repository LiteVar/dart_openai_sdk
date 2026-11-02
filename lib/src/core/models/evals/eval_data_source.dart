/// JSON data source configuration for creating an evaluation.
///
/// The returned maps are passed to the Evals create method as
/// `dataSourceConfig`. Maps are used so newer schema fields remain available
/// without requiring an SDK release.
abstract final class OpenAIEvalDataSourceConfig {
  /// Evaluates stored request logs, optionally filtered by metadata.
  static Map<String, dynamic> logs({Map<String, dynamic>? metadata}) => {
        'type': 'logs',
        if (metadata != null) 'metadata': metadata,
      };

  /// Evaluates user supplied rows described by [itemSchema].
  static Map<String, dynamic> custom({
    required Map<String, dynamic> itemSchema,
    bool includeSampleSchema = false,
  }) =>
      {
        'type': 'custom',
        'item_schema': itemSchema,
        if (includeSampleSchema) 'include_sample_schema': true,
      };

  /// Evaluates stored completions. OpenAI recommends [logs] for new usage.
  static Map<String, dynamic> storedCompletions({
    Map<String, dynamic>? metadata,
  }) =>
      {
        'type': 'stored_completions',
        if (metadata != null) 'metadata': metadata,
      };
}

/// Data source configuration for starting an evaluation run.
abstract final class OpenAIEvalRunDataSource {
  /// Builds a JSONL source from the raw source object.
  static Map<String, dynamic> jsonl({
    required Map<String, dynamic> source,
  }) =>
      {'type': 'jsonl', 'source': source};

  /// Uses a JSONL file previously uploaded to the Files API.
  static Map<String, dynamic> jsonlFile({required String fileId}) => {
        'type': 'jsonl',
        'source': {'type': 'file_id', 'id': fileId},
      };

  /// Uses JSONL rows supplied inline.
  static Map<String, dynamic> jsonlContent({
    required List<Map<String, dynamic>> content,
  }) =>
      {
        'type': 'jsonl',
        'source': {'type': 'file_content', 'content': content},
      };
}
