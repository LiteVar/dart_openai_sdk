/// A paginated list of heterogeneous items stored in a conversation.
class OpenAIConversationItemsResponse {
  /// Raw API item maps; item shapes vary by type.
  final List<Map<String, dynamic>> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;
  final String object;

  const OpenAIConversationItemsResponse({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIConversationItemsResponse.fromMap(
    Map<String, dynamic> json,
  ) =>
      OpenAIConversationItemsResponse(
        object: json['object']?.toString() ?? 'list',
        data: json['data'] is List
            ? (json['data'] as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList(growable: false)
            : const [],
        hasMore: json['has_more'] == true,
        firstId: json['first_id']?.toString(),
        lastId: json['last_id']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'object': object,
        'data': data,
        'has_more': hasMore,
        if (firstId != null) 'first_id': firstId,
        if (lastId != null) 'last_id': lastId,
      };

  OpenAIConversationItemsResponse copyWith({
    List<Map<String, dynamic>>? data,
    bool? hasMore,
    String? firstId,
    String? lastId,
    String? object,
  }) =>
      OpenAIConversationItemsResponse(
        data: data ?? this.data,
        hasMore: hasMore ?? this.hasMore,
        firstId: firstId ?? this.firstId,
        lastId: lastId ?? this.lastId,
        object: object ?? this.object,
      );

  @override
  String toString() =>
      'OpenAIConversationItemsResponse(data: ${data.length} items, hasMore: $hasMore, firstId: $firstId, lastId: $lastId)';
}
