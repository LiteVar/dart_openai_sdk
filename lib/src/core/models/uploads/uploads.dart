/// Metadata and completion state for a multipart Upload.
class OpenAIUploadModel {
  final int bytes;
  final int createdAt;
  final int expiresAt;
  final dynamic file;
  final String filename;
  final String id;
  final String purpose;
  final String status;
  final String object;

  const OpenAIUploadModel({
    required this.bytes,
    required this.createdAt,
    required this.expiresAt,
    required this.file,
    required this.filename,
    required this.id,
    required this.purpose,
    required this.status,
    this.object = 'upload',
  });

  factory OpenAIUploadModel.fromMap(Map<String, dynamic> map) =>
      OpenAIUploadModel(
        bytes: _intValue(map['bytes']),
        createdAt: _intValue(map['created_at']),
        expiresAt: _intValue(map['expires_at']),
        file: map['file'],
        filename: map['filename']?.toString() ?? '',
        id: map['id']?.toString() ?? '',
        purpose: map['purpose']?.toString() ?? '',
        status: map['status']?.toString() ?? '',
        object: map['object']?.toString() ?? 'upload',
      );
}

int _intValue(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
