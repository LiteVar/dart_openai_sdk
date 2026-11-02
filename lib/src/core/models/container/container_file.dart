int _containerFileInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _containerFileDate(dynamic value) => value == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(
        _containerFileInt(value) * 1000,
        isUtc: true,
      );

/// A file stored in a sandboxed container.
class OpenAIContainerFileModel {
  final String id;
  final int bytes;
  final String containerId;
  final DateTime createdAt;
  final String object;
  final String path;
  final String source;

  const OpenAIContainerFileModel({
    required this.id,
    required this.bytes,
    required this.containerId,
    required this.createdAt,
    required this.path,
    required this.source,
    this.object = 'container.file',
  });

  factory OpenAIContainerFileModel.fromMap(Map<String, dynamic> map) =>
      OpenAIContainerFileModel(
        id: map['id']?.toString() ?? '',
        bytes: _containerFileInt(map['bytes']),
        containerId: map['container_id']?.toString() ?? '',
        createdAt: _containerFileDate(map['created_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        object: map['object']?.toString() ?? 'container.file',
        path: map['path']?.toString() ?? '',
        source: map['source']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'bytes': bytes,
        'container_id': containerId,
        'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
        'object': object,
        'path': path,
        'source': source,
      };
}
