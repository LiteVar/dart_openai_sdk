import 'container_file.dart';

/// Cursor-paginated list of files stored in a container.
class OpenAIContainerFileList {
  final List<OpenAIContainerFileModel> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;
  final String object;

  const OpenAIContainerFileList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    this.object = 'list',
  });

  factory OpenAIContainerFileList.fromMap(Map<String, dynamic> map) =>
      OpenAIContainerFileList(
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIContainerFileModel.fromMap(
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
