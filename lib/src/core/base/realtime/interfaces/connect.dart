import 'dart:async';
import 'package:meta/meta.dart';
import '../../../models/realtime/session/session_config.dart';
import '../../../models/realtime/event/realtime_event.dart';

/// Connect management interface, defining connection-related operations for the realtime module
@immutable
abstract class ConnectInterface {
  /// Connect to OpenAI Realtime API
  ///
  /// [model] The model to use, defaults to gpt-4o-realtime-preview-2024-10-01
  /// [sessionConfig] Session configuration
  /// [headers] Additional request headers
  /// [debug] Whether to enable debug mode
  /// 
  /// Returns session information
  Future<OpenAIRealtimeSessionConfigModel> connect({
    String model = 'gpt-4o-realtime-preview-2024-10-01',
    OpenAIRealtimeSessionConfigModel? sessionConfig,
    Map<String, String>? headers,
    bool debug = false,
  });

  /// Disconnect from OpenAI Realtime API
  Future<void> disconnect();

  /// Get event stream
  /// 
  /// Returns a stream of all events received from the server
  Stream<OpenAIRealtimeEventModel> get eventStream;

  /// Check connection status
  /// 
  /// Returns true if currently connected, otherwise returns false
  bool get isConnected;
} 