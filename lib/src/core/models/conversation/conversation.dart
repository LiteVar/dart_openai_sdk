int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _mapValue(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

/// A server-side conversation used to persist Responses API context.
class OpenAIConversation {
  final String id;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final String object;

  const OpenAIConversation({
    required this.id,
    required this.createdAt,
    required this.metadata,
    this.object = 'conversation',
  });

  factory OpenAIConversation.fromMap(Map<String, dynamic> json) =>
      OpenAIConversation(
        id: json['id']?.toString() ?? '',
        object: json['object']?.toString() ?? 'conversation',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          _intValue(json['created_at']) * 1000,
          isUtc: true,
        ),
        metadata: _mapValue(json['metadata']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'object': object,
        'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
        'metadata': metadata,
      };

  OpenAIConversation copyWith({
    String? id,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? object,
  }) =>
      OpenAIConversation(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        metadata: metadata ?? this.metadata,
        object: object ?? this.object,
      );
}
