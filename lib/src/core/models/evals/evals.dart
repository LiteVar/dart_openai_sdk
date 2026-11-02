Map<String, dynamic> _evalMap(dynamic value) => value is Map
    ? Map<String, dynamic>.unmodifiable(Map<String, dynamic>.from(value))
    : const <String, dynamic>{};

int _evalInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _evalDate(dynamic value) => value == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(_evalInt(value) * 1000, isUtc: true);

/// Evaluation definition returned by the Evals API.
class OpenAIEval {
  final Map<String, dynamic> raw;

  OpenAIEval(Map<String, dynamic> raw)
      : raw = Map<String, dynamic>.unmodifiable(raw);

  factory OpenAIEval.fromMap(Map<String, dynamic> map) => OpenAIEval(map);

  String get id => raw['id']?.toString() ?? '';
  String? get name => raw['name']?.toString();
  String? get object => raw['object']?.toString();
  DateTime? get createdAt => _evalDate(raw['created_at']);
  Map<String, dynamic> get dataSourceConfig =>
      _evalMap(raw['data_source_config']);
  List<Map<String, dynamic>> get testingCriteria =>
      raw['testing_criteria'] is List
          ? (raw['testing_criteria'] as List)
              .whereType<Map>()
              .map((item) => _evalMap(item))
              .toList(growable: false)
          : const [];
  Map<String, dynamic> get metadata => _evalMap(raw['metadata']);

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(raw);
}

/// A cursor-paginated collection of evaluations.
class OpenAIEvalsList {
  final List<OpenAIEval> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;
  final String object;

  const OpenAIEvalsList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIEvalsList.fromMap(Map<String, dynamic> map) => OpenAIEvalsList(
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIEval.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
        hasMore: map['has_more'] == true,
        firstId: map['first_id']?.toString(),
        lastId: map['last_id']?.toString(),
        object: map['object']?.toString() ?? 'list',
      );
}

/// An evaluation run and its source-specific result fields.
class OpenAIEvalRun {
  final Map<String, dynamic> raw;

  OpenAIEvalRun(Map<String, dynamic> raw)
      : raw = Map<String, dynamic>.unmodifiable(raw);

  factory OpenAIEvalRun.fromMap(Map<String, dynamic> map) => OpenAIEvalRun(map);

  String get id => raw['id']?.toString() ?? '';
  String? get status => raw['status']?.toString();
  String? get object => raw['object']?.toString();
  DateTime? get createdAt => _evalDate(raw['created_at']);
  Map<String, dynamic> get dataSource => _evalMap(raw['data_source']);
  Map<String, dynamic> get metadata => _evalMap(raw['metadata']);

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(raw);
}

/// A cursor-paginated collection of evaluation runs.
class OpenAIEvalRunsList {
  final List<OpenAIEvalRun> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;
  final String object;

  const OpenAIEvalRunsList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIEvalRunsList.fromMap(Map<String, dynamic> map) =>
      OpenAIEvalRunsList(
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIEvalRun.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
        hasMore: map['has_more'] == true,
        firstId: map['first_id']?.toString(),
        lastId: map['last_id']?.toString(),
        object: map['object']?.toString() ?? 'list',
      );
}

/// One evaluated data-source item with its grading and sample details.
class OpenAIEvalRunOutputItem {
  final Map<String, dynamic> raw;

  OpenAIEvalRunOutputItem(Map<String, dynamic> raw)
      : raw = Map<String, dynamic>.unmodifiable(raw);

  factory OpenAIEvalRunOutputItem.fromMap(Map<String, dynamic> map) =>
      OpenAIEvalRunOutputItem(map);

  String get id => raw['id']?.toString() ?? '';
  String? get status => raw['status']?.toString();
  DateTime? get createdAt => _evalDate(raw['created_at']);
  Map<String, dynamic> toMap() => Map<String, dynamic>.from(raw);
}

/// A cursor-paginated collection of evaluation run output items.
class OpenAIEvalRunOutputItemsList {
  final List<OpenAIEvalRunOutputItem> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;
  final String object;

  const OpenAIEvalRunOutputItemsList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIEvalRunOutputItemsList.fromMap(Map<String, dynamic> map) =>
      OpenAIEvalRunOutputItemsList(
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIEvalRunOutputItem.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
        hasMore: map['has_more'] == true,
        firstId: map['first_id']?.toString(),
        lastId: map['last_id']?.toString(),
        object: map['object']?.toString() ?? 'list',
      );
}
