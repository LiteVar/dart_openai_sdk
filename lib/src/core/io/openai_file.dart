/// Byte-based file input for multipart uploads.
///
/// The SDK does not read paths itself, so this works on native and web Dart
/// runtimes. Include the file extension in [fileName].
class OpenAIFile {
  final List<int> bytes;
  final String fileName;

  const OpenAIFile({required this.bytes, required this.fileName});
}
