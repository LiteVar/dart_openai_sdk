import 'dart:async';
import '../../../models/realtime/session/session_config.dart';
import '../../../models/realtime/event/realtime_event.dart';

/// Session management interface, defining session-related operations for the realtime module
abstract class SessionInterface {
  /// Update session configuration
  ///
  /// [sessionConfig] New session configuration
  Future<void> updateSession({
    required OpenAIRealtimeSessionConfigModel sessionConfig,
  });

  /// Get current session configuration
  ///
  /// Returns the current session configuration, or null if the session has not been created
  OpenAIRealtimeSessionConfigModel? get currentSession;

  /// Listen to session events
  ///
  /// Returns a stream of session-related events
  Stream<OpenAIRealtimeEventModel> get sessionEventStream;
} 