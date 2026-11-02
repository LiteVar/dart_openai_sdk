/// Expiration policy for an uploaded file.
class OpenAIFileExpiresAfter {
  final String anchor;
  final int seconds;

  const OpenAIFileExpiresAfter({
    required this.anchor,
    required this.seconds,
  });

  Map<String, dynamic> toMap() => {'anchor': anchor, 'seconds': seconds};
}
