import 'container.dart';

/// Cursor-paginated list of Containers API objects.
class OpenAIContainerList {
  final List<OpenAIContainerModel> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;
  final String object;

  const OpenAIContainerList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIContainerList.fromMap(Map<String, dynamic> map) =>
      OpenAIContainerList(
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIContainerModel.fromMap(
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
