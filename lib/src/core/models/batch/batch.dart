int _batchInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _batchDate(dynamic value) => value == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(_batchInt(value) * 1000, isUtc: true);

/// Expiration policy for the output and error files produced by a batch.
class OpenAIBatchOutputExpirationPolicy {
  final String anchor;
  final int seconds;

  const OpenAIBatchOutputExpirationPolicy({
    this.anchor = 'created_at',
    required this.seconds,
  });

  factory OpenAIBatchOutputExpirationPolicy.fromMap(
    Map<String, dynamic> map,
  ) =>
      OpenAIBatchOutputExpirationPolicy(
        anchor: map['anchor']?.toString() ?? 'created_at',
        seconds: _batchInt(map['seconds']),
      );

  Map<String, dynamic> toMap() => {'anchor': anchor, 'seconds': seconds};
}

/// Counts of completed and failed requests within a Batch.
class OpenAIBatchRequestCounts {
  final int total;
  final int completed;
  final int failed;

  const OpenAIBatchRequestCounts({
    this.total = 0,
    this.completed = 0,
    this.failed = 0,
  });

  factory OpenAIBatchRequestCounts.fromMap(Map<String, dynamic> map) =>
      OpenAIBatchRequestCounts(
        total: _batchInt(map['total']),
        completed: _batchInt(map['completed']),
        failed: _batchInt(map['failed']),
      );

  Map<String, dynamic> toMap() => {
        'total': total,
        'completed': completed,
        'failed': failed,
      };
}

/// A line-level error reported while validating or processing a Batch.
class OpenAIBatchError {
  final String? code;
  final int? line;
  final String? message;
  final String? param;

  const OpenAIBatchError({this.code, this.line, this.message, this.param});

  factory OpenAIBatchError.fromMap(Map<String, dynamic> map) =>
      OpenAIBatchError(
        code: map['code']?.toString(),
        line: map['line'] == null ? null : _batchInt(map['line']),
        message: map['message']?.toString(),
        param: map['param']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        if (code != null) 'code': code,
        if (line != null) 'line': line,
        if (message != null) 'message': message,
        if (param != null) 'param': param,
      };
}

/// Collection of validation and processing errors returned with a Batch.
class OpenAIBatchErrors {
  final List<OpenAIBatchError> data;
  final String object;

  const OpenAIBatchErrors({required this.data, this.object = 'list'});

  factory OpenAIBatchErrors.fromMap(Map<String, dynamic> map) =>
      OpenAIBatchErrors(
        object: map['object']?.toString() ?? 'list',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIBatchError.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
      );
}

/// An asynchronous API batch and its current processing state.
class OpenAIBatchModel {
  final String id;
  final String endpoint;
  final String inputFileId;
  final String completionWindow;
  final String status;
  final String object;
  final DateTime createdAt;
  final String? outputFileId;
  final String? errorFileId;
  final String? model;
  final OpenAIBatchErrors? errors;
  final OpenAIBatchRequestCounts? requestCounts;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic>? usage;
  final OpenAIBatchOutputExpirationPolicy? outputExpiresAfter;
  final DateTime? inProgressAt;
  final DateTime? expiresAt;
  final DateTime? finalizingAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final DateTime? expiredAt;
  final DateTime? cancellingAt;
  final DateTime? cancelledAt;

  const OpenAIBatchModel({
    required this.id,
    required this.endpoint,
    required this.inputFileId,
    required this.completionWindow,
    required this.status,
    required this.createdAt,
    required this.metadata,
    this.object = 'batch',
    this.outputFileId,
    this.errorFileId,
    this.model,
    this.errors,
    this.requestCounts,
    this.usage,
    this.outputExpiresAfter,
    this.inProgressAt,
    this.expiresAt,
    this.finalizingAt,
    this.completedAt,
    this.failedAt,
    this.expiredAt,
    this.cancellingAt,
    this.cancelledAt,
  });

  factory OpenAIBatchModel.fromMap(Map<String, dynamic> map) {
    final errors = map['errors'];
    final counts = map['request_counts'];
    final usage = map['usage'];
    final expiresAfter = map['output_expires_after'];
    return OpenAIBatchModel(
      id: map['id']?.toString() ?? '',
      endpoint: map['endpoint']?.toString() ?? '',
      inputFileId: map['input_file_id']?.toString() ?? '',
      completionWindow: map['completion_window']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      object: map['object']?.toString() ?? 'batch',
      createdAt: _batchDate(map['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      outputFileId: map['output_file_id']?.toString(),
      errorFileId: map['error_file_id']?.toString(),
      model: map['model']?.toString(),
      errors: errors is Map
          ? OpenAIBatchErrors.fromMap(Map<String, dynamic>.from(errors))
          : null,
      requestCounts: counts is Map
          ? OpenAIBatchRequestCounts.fromMap(
              Map<String, dynamic>.from(counts),
            )
          : null,
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : const {},
      usage: usage is Map ? Map<String, dynamic>.from(usage) : null,
      outputExpiresAfter: expiresAfter is Map
          ? OpenAIBatchOutputExpirationPolicy.fromMap(
              Map<String, dynamic>.from(expiresAfter),
            )
          : null,
      inProgressAt: _batchDate(map['in_progress_at']),
      expiresAt: _batchDate(map['expires_at']),
      finalizingAt: _batchDate(map['finalizing_at']),
      completedAt: _batchDate(map['completed_at']),
      failedAt: _batchDate(map['failed_at']),
      expiredAt: _batchDate(map['expired_at']),
      cancellingAt: _batchDate(map['cancelling_at']),
      cancelledAt: _batchDate(map['cancelled_at']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'object': object,
        'endpoint': endpoint,
        'input_file_id': inputFileId,
        'completion_window': completionWindow,
        'status': status,
        'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
        if (outputFileId != null) 'output_file_id': outputFileId,
        if (errorFileId != null) 'error_file_id': errorFileId,
        if (model != null) 'model': model,
        if (errors != null)
          'errors': {
            'object': errors!.object,
            'data': errors!.data.map((error) => error.toMap()).toList(),
          },
        if (requestCounts != null) 'request_counts': requestCounts!.toMap(),
        'metadata': metadata,
        if (usage != null) 'usage': usage,
        if (outputExpiresAfter != null)
          'output_expires_after': outputExpiresAfter!.toMap(),
        if (inProgressAt != null)
          'in_progress_at': inProgressAt!.millisecondsSinceEpoch ~/ 1000,
        if (expiresAt != null)
          'expires_at': expiresAt!.millisecondsSinceEpoch ~/ 1000,
        if (finalizingAt != null)
          'finalizing_at': finalizingAt!.millisecondsSinceEpoch ~/ 1000,
        if (completedAt != null)
          'completed_at': completedAt!.millisecondsSinceEpoch ~/ 1000,
        if (failedAt != null)
          'failed_at': failedAt!.millisecondsSinceEpoch ~/ 1000,
        if (expiredAt != null)
          'expired_at': expiredAt!.millisecondsSinceEpoch ~/ 1000,
        if (cancellingAt != null)
          'cancelling_at': cancellingAt!.millisecondsSinceEpoch ~/ 1000,
        if (cancelledAt != null)
          'cancelled_at': cancelledAt!.millisecondsSinceEpoch ~/ 1000,
      };
}
