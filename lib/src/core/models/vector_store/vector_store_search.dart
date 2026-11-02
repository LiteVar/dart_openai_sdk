/// One text chunk returned by a vector store search or file-content request.
class OpenAIVectorStoreContentChunk {
  final String type;
  final String? text;

  const OpenAIVectorStoreContentChunk({this.type = 'text', this.text});

  factory OpenAIVectorStoreContentChunk.fromMap(Map<String, dynamic> map) =>
      OpenAIVectorStoreContentChunk(
        type: map['type']?.toString() ?? 'text',
        text: map['text']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        if (text != null) 'text': text,
      };
}

/// One ranked result returned from a vector store search.
class OpenAIVectorStoreSearchResult {
  final String fileId;
  final String filename;
  final double score;
  final Map<String, dynamic> attributes;
  final List<OpenAIVectorStoreContentChunk> content;

  const OpenAIVectorStoreSearchResult({
    required this.fileId,
    required this.filename,
    required this.score,
    required this.attributes,
    required this.content,
  });

  factory OpenAIVectorStoreSearchResult.fromMap(Map<String, dynamic> map) {
    final score = map['score'];
    return OpenAIVectorStoreSearchResult(
      fileId: map['file_id']?.toString() ?? '',
      filename: map['filename']?.toString() ?? '',
      score: score is num ? score.toDouble() : 0,
      attributes: map['attributes'] is Map
          ? Map<String, dynamic>.from(map['attributes'] as Map)
          : const {},
      content: map['content'] is List
          ? (map['content'] as List)
              .whereType<Map>()
              .map((item) => OpenAIVectorStoreContentChunk.fromMap(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : const [],
    );
  }
}

/// Search response page from a vector store.
class OpenAIVectorStoreSearchResponse {
  final List<OpenAIVectorStoreSearchResult> data;
  final List<String> searchQuery;
  final bool hasMore;
  final String? nextPage;
  final String object;

  const OpenAIVectorStoreSearchResponse({
    required this.data,
    required this.searchQuery,
    required this.hasMore,
    this.nextPage,
    this.object = 'vector_store.search_results.page',
  });

  factory OpenAIVectorStoreSearchResponse.fromMap(Map<String, dynamic> map) =>
      OpenAIVectorStoreSearchResponse(
        object: map['object']?.toString() ?? 'vector_store.search_results.page',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIVectorStoreSearchResult.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
        searchQuery: map['search_query'] is List
            ? (map['search_query'] as List)
                .map((item) => item.toString())
                .toList(growable: false)
            : const [],
        hasMore: map['has_more'] == true,
        nextPage: map['next_page']?.toString(),
      );
}

/// Parsed file-content page from a vector store.
class OpenAIVectorStoreFileContentPage {
  final List<OpenAIVectorStoreContentChunk> data;
  final bool hasMore;
  final String? nextPage;
  final String object;

  const OpenAIVectorStoreFileContentPage({
    required this.data,
    required this.hasMore,
    this.nextPage,
    this.object = 'vector_store.file_content.page',
  });

  factory OpenAIVectorStoreFileContentPage.fromMap(
    Map<String, dynamic> map,
  ) =>
      OpenAIVectorStoreFileContentPage(
        object: map['object']?.toString() ?? 'vector_store.file_content.page',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIVectorStoreContentChunk.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
        hasMore: map['has_more'] == true,
        nextPage: map['next_page']?.toString(),
      );
}

/// Filter expression for vector store file attributes.
class OpenAIVectorStoreFilter {
  final String type;
  final String? key;
  final Object? value;
  final List<OpenAIVectorStoreFilter>? filters;

  const OpenAIVectorStoreFilter._({
    required this.type,
    this.key,
    this.value,
    this.filters,
  });

  factory OpenAIVectorStoreFilter.compare({
    required String key,
    required String operator,
    required Object value,
  }) =>
      OpenAIVectorStoreFilter._(type: operator, key: key, value: value);

  factory OpenAIVectorStoreFilter.and(
    List<OpenAIVectorStoreFilter> filters,
  ) =>
      OpenAIVectorStoreFilter._(type: 'and', filters: filters);

  factory OpenAIVectorStoreFilter.or(
    List<OpenAIVectorStoreFilter> filters,
  ) =>
      OpenAIVectorStoreFilter._(type: 'or', filters: filters);

  Map<String, dynamic> toMap() => filters == null
      ? {'type': type, 'key': key, 'value': value}
      : {
          'type': type,
          'filters': filters!.map((item) => item.toMap()).toList()
        };
}

/// Ranking options for vector store search.
class OpenAIVectorStoreRankingOptions {
  final String? ranker;
  final double? scoreThreshold;

  const OpenAIVectorStoreRankingOptions({this.ranker, this.scoreThreshold});

  Map<String, dynamic> toMap() => {
        if (ranker != null) 'ranker': ranker,
        if (scoreThreshold != null) 'score_threshold': scoreThreshold,
      };
}
