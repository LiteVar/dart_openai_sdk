import 'package:meta/meta.dart';
import '../config/client_config.dart';

/// {@template contextual_api_url_builder}
/// A utility class for building API URLs based on a configuration instance.
/// Unlike BaseApiUrlBuilder, this class does not rely on global configuration, but builds URLs based on the incoming configuration instance.
/// {@endtemplate}
@immutable
@internal
abstract class ContextualApiUrlBuilder {
  /// The default API version
  static const String _defaultVersion = 'v1';

  /// {@macro contextual_api_url_builder}
  ///
  /// Build a complete API URL based on the given configuration and endpoint.
  /// 
  /// [config] The client configuration to use
  /// [endpoint] API endpoint path
  /// [id] Optional resource ID
  /// [query] Optional query string
  /// 
  /// Returns the built complete URL string.
  @internal
  static String build(
    OpenAIClientConfig config,
    String endpoint, [
    String? id,
    String? query,
  ]) {
    // Validate the configuration
    config.validate();

    // Validate the endpoint
    if (endpoint.isEmpty) {
      throw ArgumentError('Endpoint cannot be empty');
    }

    // Process baseUrl, ensure it does not end with a slash
    final baseUrl = config.baseUrl.endsWith('/')
        ? config.baseUrl.substring(0, config.baseUrl.length - 1)
        : config.baseUrl;

    // Process the endpoint, ensure it starts with a slash
    final normalizedEndpoint = _normalizeEndpoint(endpoint);

    // Build the base URL
    String apiUrl = baseUrl;

    // If baseUrl does not contain a version, add the version
    if (!baseUrl.contains('/v1') && !baseUrl.contains('/v2')) {
      apiUrl += '/$_defaultVersion';
    }

    // Add the endpoint
    apiUrl += normalizedEndpoint;

    // Add resource ID or query parameters
    if (id != null && id.isNotEmpty) {
      apiUrl += '/$id';
    } else if (query != null && query.isNotEmpty) {
      apiUrl += '?$query';
    }

    // Validate the final URL
    final uri = Uri.tryParse(apiUrl);
    if (uri == null || !uri.hasScheme) {
      throw ArgumentError('Invalid URL: $apiUrl');
    }

    return apiUrl;
  }

  /// Build a WebSocket URL for real-time connections
  @internal
  static String buildWebSocketUrl(
    OpenAIClientConfig config,
    String endpoint, [
    Map<String, String>? queryParams,
  ]) {
    config.validate();

    if (endpoint.isEmpty) {
      throw ArgumentError('Endpoint cannot be empty');
    }

    // Convert HTTP(S) URL to WebSocket URL
    String wsUrl = config.baseUrl.replaceFirst('http://', 'ws://');
    wsUrl = wsUrl.replaceFirst('https://', 'wss://');

    // Remove the trailing slash
    if (wsUrl.endsWith('/')) {
      wsUrl = wsUrl.substring(0, wsUrl.length - 1);
    }

    // Add the version (if needed)
    if (!wsUrl.contains('/v1') && !wsUrl.contains('/v2')) {
      wsUrl += '/$_defaultVersion';
    }

    // Add the endpoint
    wsUrl += _normalizeEndpoint(endpoint);

    // Add query parameters
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      wsUrl += '?$queryString';
    }

    return wsUrl;
  }

  /// Build a URL for streaming responses
  @internal
  static String buildStreamUrl(
    OpenAIClientConfig config,
    String endpoint, [
    String? id,
    Map<String, String>? queryParams,
  ]) {
    String baseUrl = build(config, endpoint, id);

    if (queryParams != null && queryParams.isNotEmpty) {
      final separator = baseUrl.contains('?') ? '&' : '?';
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      baseUrl += '$separator$queryString';
    }

    return baseUrl;
  }

  /// Normalize the endpoint path, ensuring it starts with a slash
  static String _normalizeEndpoint(String endpoint) {
    if (endpoint.startsWith('/')) {
      return endpoint;
    }
    return '/$endpoint';
  }

  /// Validate if the URL is valid
  @internal
  static bool validateUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  /// Extract the base domain from the URL
  @internal
  static String? extractBaseHost(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    } catch (e) {
      return null;
    }
  }
}