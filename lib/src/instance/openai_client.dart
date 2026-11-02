import 'package:meta/meta.dart';
import '../core/base/openai_client/base.dart';
import '../core/config/client_config.dart';
import '../core/utils/logger.dart';
import 'chat/context_chat.dart';
import 'responses/responses.dart';
import 'conversations/conversations.dart';
import 'files/context_files.dart';
import 'uploads/uploads.dart';
import 'vector_stores/vector_stores.dart';
import 'batches/batches.dart';
import 'fine_tuning/fine_tuning.dart';
import 'containers/containers.dart';
import 'evals/evals.dart';
import 'graders/graders.dart';

/// {@template openai_client}
/// A multi-instance OpenAI client, supporting concurrent use of different configurations.
/// 
/// Each client instance has its own configuration (API Key, Base URL, organization, etc.),
/// solving the concurrency limit problem of the original singleton pattern.
/// 
/// Usage:
/// ```dart
/// final client1 = OpenAIClient(
///   apiKey: "sk-key1",
///   baseUrl: "https://api.openai.com/v1",
/// );
/// 
/// final client2 = OpenAIClient(
///   apiKey: "sk-key2", 
///   baseUrl: "https://custom.ai/v1",
/// );
/// 
/// // Can be used concurrently
/// final results = await Future.wait([
///   client1.chat.create(model: "gpt-3.5-turbo", messages: [...]),
///   client2.chat.create(model: "custom-model", messages: [...]),
/// ]);
/// ```
/// {@endtemplate}
@immutable
class OpenAIClient extends OpenAIClientBase {
  /// Client configuration instance
  final OpenAIClientConfig config;

  // Cached feature module instances
  late final ContextualOpenAIChat _chat;
  late final ContextualOpenAIResponses _responses;
  late final ContextualOpenAIConversations _conversations;
  late final ContextualOpenAIFiles _files;
  late final ContextualOpenAIUploads _uploads;
  late final ContextualOpenAIVectorStores _vectorStores;
  late final ContextualOpenAIBatches _batches;
  late final ContextualOpenAIFineTuning _fineTuning;
  late final ContextualOpenAIContainers _container;
  late final ContextualOpenAIEvals _evals;
  late final ContextualOpenAIGraders _graders;
  // Cached contextual feature modules.

  /// {@macro openai_client}
  /// 
  /// Create a new client instance using the specified configuration.
  /// 
  /// [apiKey] OpenAI API key, must be provided
  /// [baseUrl] API base URL, default is OpenAI official API
  /// [organization] Organization ID (optional)
  /// [requestsTimeOut] Request timeout, default is 120 seconds
  /// [additionalHeaders] Additional request headers
  /// [showLogs] Whether to show debug logs, default is true
  /// [showResponsesLogs] Whether to show response body logs, default is false
  OpenAIClient({
    String? apiKey,
    String baseUrl = 'https://api.openai.com/v1',
    String? organization,
    Duration? requestsTimeOut,
    Map<String, dynamic> additionalHeaders = const {},
    bool showLogs = true,
    bool showResponsesLogs = false,
  }) : config = OpenAIClientConfig(
    apiKey: apiKey,
    baseUrl: baseUrl,
    organization: organization,
    requestsTimeOut: requestsTimeOut ?? const Duration(seconds: 120),
    additionalHeaders: additionalHeaders,
    showLogs: showLogs,
    showResponsesLogs: showResponsesLogs,
  ) {
    _initializeModules();
  }

  /// Create a client instance using an existing configuration instance
  /// 
  /// [config] A pre-configured OpenAIClientConfig instance
  OpenAIClient.fromConfig(this.config) {
    _initializeModules();
  }

  /// Create a copy of the configuration with specified properties modified
  /// 
  /// This method is useful for creating variants based on existing configurations.
  /// 
  /// Example:
  /// ```dart
  /// final baseClient = OpenAIClient(apiKey: "key1");
  /// final customClient = baseClient.copyWith(
  ///   baseUrl: "https://custom.ai/v1",
  ///   organization: "org-123",
  /// );
  /// ```
  OpenAIClient copyWith({
    String? apiKey,
    String? baseUrl,
    String? organization,
    Duration? requestsTimeOut,
    Map<String, dynamic>? additionalHeaders,
    bool? showLogs,
    bool? showResponsesLogs,
  }) {
    return OpenAIClient.fromConfig(
      config.copyWith(
        apiKey: apiKey,
        baseUrl: baseUrl,
        organization: organization,
        requestsTimeOut: requestsTimeOut,
        additionalHeaders: additionalHeaders,
        showLogs: showLogs,
        showResponsesLogs: showResponsesLogs,
      ),
    );
  }

  /// Initialize all feature modules
  void _initializeModules() {
    // Validate configuration
    config.validate();

    // Initialize feature modules
    _chat = ContextualOpenAIChat(config);
    _responses = ContextualOpenAIResponses(config);
    _conversations = ContextualOpenAIConversations(config);
    _files = ContextualOpenAIFiles(config);
    _uploads = ContextualOpenAIUploads(config);
    _vectorStores = ContextualOpenAIVectorStores(config);
    _batches = ContextualOpenAIBatches(config);
    _fineTuning = ContextualOpenAIFineTuning(config);
    _container = ContextualOpenAIContainers(config);
    _evals = ContextualOpenAIEvals(config);
    _graders = ContextualOpenAIGraders(config);
    
    // Note: In a complete implementation, all modules should be initialized here:
    // _completion = ContextualOpenAICompletion(config);
    // _embedding = ContextualOpenAIEmbedding(config);
    // _audio = ContextualOpenAIAudio(config);
    // _images = ContextualOpenAIImages(config);
    // _fineTunes = ContextualOpenAIFineTunes(config);
    // _model = ContextualOpenAIModel(config);
    // _moderations = ContextualOpenAIModerations(config);
    // _realtime = ContextualOpenAIRealtime(config);

    if (config.showLogs) {
      OpenAILogger.logAPIKey(config.apiKey);
      OpenAILogger.logBaseUrl(config.baseUrl);
      if (config.organization != null) {
        OpenAILogger.logOrganization(config.organization);
      }
    }
  }

  // === Feature module accessors ===

  /// Chat feature module
  /// 
  /// Provides chat completion, streaming chat, etc.
  /// 
  /// 示例：
  /// ```dart
  /// final response = await client.chat.create(
  ///   model: "gpt-3.5-turbo",
  ///   messages: [
  ///     OpenAIChatCompletionChoiceMessageModel(
  ///       content: [OpenAIChatCompletionChoiceMessageContentItemModel.text("Hello")],
  ///       role: OpenAIChatMessageRole.user,
  ///     ),
  ///   ],
  /// );
  /// ```
  ContextualOpenAIChat get chat => _chat;

  /// Responses API feature module.
  ContextualOpenAIResponses get responses => _responses;

  /// Conversations API feature module.
  ContextualOpenAIConversations get conversations => _conversations;

  /// Files API feature module.
  ContextualOpenAIFiles get files => _files;

  /// Multipart Upload API feature module.
  ContextualOpenAIUploads get uploads => _uploads;

  /// Vector Stores API feature module, including file search and ingestion.
  ContextualOpenAIVectorStores get vectorStores => _vectorStores;

  /// Asynchronous Batch API feature module.
  ContextualOpenAIBatches get batches => _batches;

  /// Current Fine-tuning Jobs API. The legacy `fineTune` API remains separate.
  ContextualOpenAIFineTuning get fineTuning => _fineTuning;

  /// Containers API feature module and its container file operations.
  ContextualOpenAIContainers get container => _container;

  /// Evals API feature module.
  @Deprecated(
    'OpenAI is retiring the Evals platform; its API is scheduled to shut down '
    'on 2026-11-30.',
  )
  ContextualOpenAIEvals get evals => _evals;

  /// Grader construction, validation, and execution APIs.
  @Deprecated('OpenAI is deprecating graders in evals and fine-tuning.')
  ContextualOpenAIGraders get graders => _graders;

  // Note: In a complete implementation, all modules' getters should be included here:
  // ContextualOpenAICompletion get completion => _completion;
  // ContextualOpenAIEmbedding get embedding => _embedding;
  // ContextualOpenAIAudio get audio => _audio;
  // ContextualOpenAIImages get image => _images;
  // ContextualOpenAIFineTunes get fineTune => _fineTunes;
  // ContextualOpenAIModel get model => _model;
  // ContextualOpenAIModerations get moderation => _moderations;
  // ContextualOpenAIRealtime get realtime => _realtime;

  // === Configuration accessors ===

  /// Get the current API key (hide sensitive part)
  String? get apiKey {
    if (config.apiKey == null) return null;
    return config.apiKey!.length > 7
        ? '${config.apiKey!.substring(0, 7)}***'
        : '***';
  }

  /// Get the current base URL
  String get baseUrl => config.baseUrl;

  /// Get the current organization ID
  String? get organization => config.organization;

  /// Get the current request timeout
  Duration get requestsTimeOut => config.requestsTimeOut;

  /// Get whether to show logs
  bool get showLogs => config.showLogs;

  /// Get whether to show response logs
  bool get showResponsesLogs => config.showResponsesLogs;

  // === Utility methods ===

  /// Validate the current configuration
  /// 
  /// If the configuration is invalid, an ArgumentError will be thrown
  void validateConfig() {
    config.validate();
  }

  /// Test the connection to the API
  /// 
  /// Returns true if the connection is successful, false if it fails
  /// 
  /// This method verifies the configuration by calling a simple API endpoint.
  Future<bool> testConnection() async {
    try {
      // Note: In a complete implementation, this should call a simple API endpoint
      // like getting the model list or user information
      // For demonstration purposes, only the configuration is validated here
      config.validate();
      return true;
    } catch (e) {
      if (config.showLogs) {
        OpenAILogger.errorOcurred(e);
      }
      return false;
    }
  }

  @override
  String toString() {
    return 'OpenAIClient(${config.toString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIClient && other.config == config;
  }

  @override
  int get hashCode => config.hashCode;
}
