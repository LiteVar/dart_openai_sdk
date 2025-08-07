import 'package:meta/meta.dart';
import '../config/client_config.dart';
import '../utils/logger.dart';

/// {@template contextual_headers_builder}
/// A utility class for building request headers based on a configuration instance.
/// Unlike HeadersBuilder, this class does not rely on global state, but builds headers based on the incoming configuration instance.
/// {@endtemplate}
@immutable
@internal
abstract class ContextualHeadersBuilder {
  /// {@macro contextual_headers_builder}
  ///
  /// Build HTTP request headers based on the given configuration.
  /// 
  /// [config] The client configuration to use
  /// 
  /// Returns a Map containing authentication information, content type, and other necessary headers.
  /// If the configuration sets the organization, it will include the OpenAI-Organization header.
  @internal
  static Map<String, String> build(OpenAIClientConfig config) {
    // Validate the configuration
    config.validate();

    // Build the base headers
    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${config.apiKey}',
    };

    // Add organization header (if set)
    if (config.organization != null && config.organization!.isNotEmpty) {
      headers['OpenAI-Organization'] = config.organization!;
    }

    // Add additional headers
    if (config.additionalHeaders.isNotEmpty) {
      final additionalStringHeaders = <String, String>{};
      for (final entry in config.additionalHeaders.entries) {
        additionalStringHeaders[entry.key] = entry.value.toString();
      }
      headers.addAll(additionalStringHeaders);
    }

    // Log (if enabled)
    if (config.showLogs) {
      OpenAILogger.logAPIKey(config.apiKey);
      if (config.organization != null) {
        OpenAILogger.logOrganization(config.organization);
      }
      if (config.additionalHeaders.isNotEmpty) {
        OpenAILogger.logIncludedHeaders(config.additionalHeaders);
      }
    }

    return headers;
  }

  /// Build multipart headers for file uploads
  /// The difference from standard headers is that it does not include Content-Type, allowing the HTTP client to set it automatically
  @internal
  static Map<String, String> buildForMultipart(OpenAIClientConfig config) {
    config.validate();

    Map<String, String> headers = <String, String>{
      'Authorization': 'Bearer ${config.apiKey}',
    };

    if (config.organization != null && config.organization!.isNotEmpty) {
      headers['OpenAI-Organization'] = config.organization!;
    }

    if (config.additionalHeaders.isNotEmpty) {
      final additionalStringHeaders = <String, String>{};
      for (final entry in config.additionalHeaders.entries) {
        additionalStringHeaders[entry.key] = entry.value.toString();
      }
      headers.addAll(additionalStringHeaders);
    }

    if (config.showLogs) {
      OpenAILogger.logAPIKey(config.apiKey);
      if (config.organization != null) {
        OpenAILogger.logOrganization(config.organization);
      }
    }

    return headers;
  }

  /// Validate if the headers contain the necessary authentication information
  @internal
  static bool validateHeaders(Map<String, String> headers) {
    return headers.containsKey('Authorization') &&
        headers['Authorization']?.startsWith('Bearer ') == true;
  }
}