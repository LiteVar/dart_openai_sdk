/// Metadata for one uploaded byte part.
class OpenAIUploadPartModel {
  final int createdAt;
  final String id;
  final String uploadId;
  final String object;

  const OpenAIUploadPartModel({
    required this.createdAt,
    required this.id,
    required this.uploadId,
    this.object = 'upload.part',
  });

  factory OpenAIUploadPartModel.fromMap(Map<String, dynamic> map) =>
      OpenAIUploadPartModel(
        createdAt: map['created_at'] is num
            ? (map['created_at'] as num).toInt()
            : int.tryParse(map['created_at']?.toString() ?? '') ?? 0,
        id: map['id']?.toString() ?? '',
        uploadId: map['upload_id']?.toString() ?? '',
        object: map['object']?.toString() ?? 'upload.part',
      );
}
