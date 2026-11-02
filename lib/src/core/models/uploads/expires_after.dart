/// Expiration policy for the file produced by a multipart Upload.
class OpenAIUploadExpiresAfter {
  final String anchor;
  final int seconds;

  const OpenAIUploadExpiresAfter({
    required this.anchor,
    required this.seconds,
  });
}
