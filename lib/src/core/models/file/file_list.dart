import 'file.dart';

/// A paginated response from the Files list endpoint.
class OpenAIFileListModel {
  final List<OpenAIFileModel> data;
  final String? firstId;
  final String? lastId;
  final bool hasMore;
  final String object;

  const OpenAIFileListModel({
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
    this.object = 'list',
  });

  factory OpenAIFileListModel.fromMap(Map<String, dynamic> map) =>
      OpenAIFileListModel(
        object: map['object']?.toString() ?? 'list',
        data: map['data'] is List
            ? (map['data'] as List)
                .whereType<Map>()
                .map((item) => OpenAIFileModel.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
                .toList(growable: false)
            : const [],
        firstId: map['first_id']?.toString(),
        lastId: map['last_id']?.toString(),
        hasMore: map['has_more'] == true,
      );
}
