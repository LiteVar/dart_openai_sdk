import 'package:meta/meta.dart';

/// {@template openai_client_config}
/// Configuration class, encapsulating all configuration options for the OpenAI client.
/// Each OpenAIClient instance has its own configuration, solving the concurrency limit of the singleton pattern.
/// {@endtemplate}
@immutable
class OpenAIClientConfig {
  /// OpenAI API key (null means no Authorization header, empty string sends empty Bearer token)
  final String? apiKey;

  /// API base url, default is OpenAI official API
  final String baseUrl;

  /// Organization id (optional)
  final String? organization;

  /// Request timeout
  final Duration requestsTimeOut;

  /// Additional headers
  final Map<String, dynamic> additionalHeaders;

  /// Whether to show debug logs
  final bool showLogs;

  /// Whether to show response logs
  final bool showResponsesLogs;

  /// {@macro openai_client_config}
  const OpenAIClientConfig({
    this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
    this.organization,
    this.requestsTimeOut = const Duration(seconds: 120),
    this.additionalHeaders = const {},
    this.showLogs = true,
    this.showResponsesLogs = false,
  });

  /// Create a copy of the config, optionally overriding some properties
  OpenAIClientConfig copyWith({
    String? apiKey,
    String? baseUrl,
    String? organization,
    Duration? requestsTimeOut,
    Map<String, dynamic>? additionalHeaders,
    bool? showLogs,
    bool? showResponsesLogs,
  }) {
    return OpenAIClientConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      organization: organization ?? this.organization,
      requestsTimeOut: requestsTimeOut ?? this.requestsTimeOut,
      additionalHeaders: additionalHeaders ?? this.additionalHeaders,
      showLogs: showLogs ?? this.showLogs,
      showResponsesLogs: showResponsesLogs ?? this.showResponsesLogs,
    );
  }

  /// Validate the config
  void validate() {
    if (baseUrl.isEmpty) {
      throw ArgumentError('Base URL cannot be empty');
    }
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme) {
      throw ArgumentError('Base URL must be a valid URL with scheme');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIClientConfig &&
        other.apiKey == apiKey &&
        other.baseUrl == baseUrl &&
        other.organization == organization &&
        other.requestsTimeOut == requestsTimeOut &&
        other.showLogs == showLogs &&
        other.showResponsesLogs == showResponsesLogs &&
        _mapsEqual(other.additionalHeaders, additionalHeaders);
  }

  @override
  int get hashCode {
    return Object.hash(
      apiKey,
      baseUrl,
      organization,
      requestsTimeOut,
      showLogs,
      showResponsesLogs,
      additionalHeaders,
    );
  }

  @override
  String toString() {
    final maskedKey = apiKey == null
        ? 'null'
        : apiKey!.length > 7
            ? '${apiKey!.substring(0, 7)}***'
            : '***';
    return 'OpenAIClientConfig('
        'apiKey: $maskedKey, '
        'baseUrl: $baseUrl, '
        'organization: $organization, '
        'requestsTimeOut: $requestsTimeOut, '
        'showLogs: $showLogs, '
        'showResponsesLogs: $showResponsesLogs, '
        'additionalHeaders: ${additionalHeaders.keys.toList()}'
        ')';
  }

  /// Helper method: compare two maps
  bool _mapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }
}