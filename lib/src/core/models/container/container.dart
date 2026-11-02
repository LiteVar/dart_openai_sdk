int _containerInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _containerDate(dynamic value) => value == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(_containerInt(value) * 1000,
        isUtc: true);

Map<String, dynamic>? _containerMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

/// A sandboxed execution container managed by the Containers API.
class OpenAIContainerModel {
  final String id;
  final DateTime createdAt;
  final String name;
  final String status;
  final String object;
  final DateTime? lastActiveAt;
  final String? memoryLimit;
  final Map<String, dynamic>? expiresAfter;
  final Map<String, dynamic>? networkPolicy;

  const OpenAIContainerModel({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.status,
    this.object = 'container',
    this.lastActiveAt,
    this.memoryLimit,
    this.expiresAfter,
    this.networkPolicy,
  });

  factory OpenAIContainerModel.fromMap(Map<String, dynamic> map) =>
      OpenAIContainerModel(
        id: map['id']?.toString() ?? '',
        createdAt: _containerDate(map['created_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        name: map['name']?.toString() ?? '',
        status: map['status']?.toString() ?? '',
        object: map['object']?.toString() ?? 'container',
        lastActiveAt: _containerDate(map['last_active_at']),
        memoryLimit: map['memory_limit']?.toString(),
        expiresAfter: _containerMap(map['expires_after']),
        networkPolicy: _containerMap(map['network_policy']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
        'name': name,
        'status': status,
        'object': object,
        if (lastActiveAt != null)
          'last_active_at': lastActiveAt!.millisecondsSinceEpoch ~/ 1000,
        if (memoryLimit != null) 'memory_limit': memoryLimit,
        if (expiresAfter != null) 'expires_after': expiresAfter,
        if (networkPolicy != null) 'network_policy': networkPolicy,
      };
}
