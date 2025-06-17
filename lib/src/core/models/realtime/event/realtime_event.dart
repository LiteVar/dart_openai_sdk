
import '../session/session_config.dart';

/// The types of events in the Realtime API.
enum OpenAIRealtimeEventTypeModel {
  // Client events
  sessionUpdate('session.update'),
  inputAudioBufferAppend('input_audio_buffer.append'),
  inputAudioBufferCommit('input_audio_buffer.commit'),
  inputAudioBufferClear('input_audio_buffer.clear'),
  conversationItemCreate('conversation.item.create'),
  conversationItemTruncate('conversation.item.truncate'),
  conversationItemDelete('conversation.item.delete'),
  responseCreate('response.create'),
  responseCancel('response.cancel'),
  
  // Server events
  error('error'),
  sessionCreated('session.created'),
  sessionUpdated('session.updated'),
  conversationCreated('conversation.created'),
  inputAudioBufferCommitted('input_audio_buffer.committed'),
  inputAudioBufferCleared('input_audio_buffer.cleared'),
  inputAudioBufferSpeechStarted('input_audio_buffer.speech_started'),
  inputAudioBufferSpeechStopped('input_audio_buffer.speech_stopped'),
  conversationItemCreated('conversation.item.created'),
  conversationItemInputAudioTranscriptionCompleted('conversation.item.input_audio_transcription.completed'),
  conversationItemInputAudioTranscriptionFailed('conversation.item.input_audio_transcription.failed'),
  conversationItemTruncated('conversation.item.truncated'),
  conversationItemDeleted('conversation.item.deleted'),
  responseCreated('response.created'),
  responseDone('response.done'),
  responseOutputItemAdded('response.output_item.added'),
  responseOutputItemDone('response.output_item.done'),
  responseContentPartAdded('response.content_part.added'),
  responseContentPartDone('response.content_part.done'),
  responseTextDelta('response.text.delta'),
  responseTextDone('response.text.done'),
  responseAudioTranscriptDelta('response.audio_transcript.delta'),
  responseAudioTranscriptDone('response.audio_transcript.done'),
  responseAudioDelta('response.audio.delta'),
  responseAudioDone('response.audio.done'),
  responseFunctionCallArgumentsDelta('response.function_call_arguments.delta'),
  responseFunctionCallArgumentsDone('response.function_call_arguments.done'),
  rateLimitsUpdated('rate_limits.updated'),
  
  // Custom events for client convenience
  conversationUpdated('conversation.updated'),
  conversationInterrupted('conversation.interrupted'),
  conversationItemAppended('conversation.item.appended'),
  conversationItemCompleted('conversation.item.completed'),
  all('realtime.event'),
  serverAll('server.all'),
  clientAll('client.all');

  const OpenAIRealtimeEventTypeModel(this.value);

  /// The string value of the event type.
  final String value;

  /// Returns the [OpenAIRealtimeEventTypeModel] from the given [value].
  static OpenAIRealtimeEventTypeModel fromValue(String value) {
    return values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown event type: $value'),
    );
  }

  @override
  String toString() => value;
}

/// Base class for all Realtime API events.
abstract class OpenAIRealtimeEventModel {
  /// The unique identifier for the event.
  final String eventId;

  /// The type of the event.
  final OpenAIRealtimeEventTypeModel type;

  /// Creates a new [OpenAIRealtimeEventModel].
  const OpenAIRealtimeEventModel({
    required this.eventId,
    required this.type,
  });

  /// Creates a [OpenAIRealtimeEventModel] from a JSON map.
  factory OpenAIRealtimeEventModel.fromMap(Map<String, dynamic> map) {
    final type = OpenAIRealtimeEventTypeModel.fromValue(map['type']);

    switch (type) {
      case OpenAIRealtimeEventTypeModel.sessionUpdate:
        return OpenAIRealtimeSessionUpdateEvent.fromMap(map);
      case OpenAIRealtimeEventTypeModel.sessionCreated:
        return OpenAIRealtimeSessionCreatedEvent.fromMap(map);
      case OpenAIRealtimeEventTypeModel.error:
        return OpenAIRealtimeErrorEvent.fromMap(map);
      default:
        return OpenAIRealtimeGenericEvent.fromMap(map);
    }
  }

  /// Converts this [OpenAIRealtimeEventModel] to a JSON map.
  Map<String, dynamic> toMap();

  @override
  String toString() {
    return 'OpenAIRealtimeEventModel(eventId: $eventId, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeEventModel &&
        other.eventId == eventId &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(eventId, type);
}

/// Session update event for updating session configuration.
class OpenAIRealtimeSessionUpdateEvent extends OpenAIRealtimeEventModel {
  /// The session configuration to update.
  final OpenAIRealtimeSessionConfigModel session;

  /// Creates a new [OpenAIRealtimeSessionUpdateEvent].
  const OpenAIRealtimeSessionUpdateEvent({
    required String eventId,
    required this.session,
  }) : super(
          eventId: eventId,
          type: OpenAIRealtimeEventTypeModel.sessionUpdate,
        );

  /// Creates a [OpenAIRealtimeSessionUpdateEvent] from a JSON map.
  factory OpenAIRealtimeSessionUpdateEvent.fromMap(Map<String, dynamic> map) {
    return OpenAIRealtimeSessionUpdateEvent(
      eventId: map['event_id'] ?? '',
      session: OpenAIRealtimeSessionConfigModel.fromMap(map['session']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'type': type.value,
      'session': session.toMap(),
    };
  }

  @override
  String toString() {
    return 'OpenAIRealtimeSessionUpdateEvent(eventId: $eventId, session: $session)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeSessionUpdateEvent &&
        other.eventId == eventId &&
        other.session == session;
  }

  @override
  int get hashCode => Object.hash(eventId, session);
}

/// Session created event from server.
class OpenAIRealtimeSessionCreatedEvent extends OpenAIRealtimeEventModel {
  /// The created session configuration.
  final OpenAIRealtimeSessionConfigModel session;

  /// Creates a new [OpenAIRealtimeSessionCreatedEvent].
  const OpenAIRealtimeSessionCreatedEvent({
    required String eventId,
    required this.session,
  }) : super(
          eventId: eventId,
          type: OpenAIRealtimeEventTypeModel.sessionCreated,
        );

  /// Creates a [OpenAIRealtimeSessionCreatedEvent] from a JSON map.
  factory OpenAIRealtimeSessionCreatedEvent.fromMap(Map<String, dynamic> map) {
    return OpenAIRealtimeSessionCreatedEvent(
      eventId: map['event_id'] ?? '',
      session: OpenAIRealtimeSessionConfigModel.fromMap(map['session']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'type': type.value,
      'session': session.toMap(),
    };
  }

  @override
  String toString() {
    return 'OpenAIRealtimeSessionCreatedEvent(eventId: $eventId, session: $session)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeSessionCreatedEvent &&
        other.eventId == eventId &&
        other.session == session;
  }

  @override
  int get hashCode => Object.hash(eventId, session);
}

/// Error event from server.
class OpenAIRealtimeErrorEvent extends OpenAIRealtimeEventModel {
  /// The error details.
  final Map<String, dynamic> error;

  /// Creates a new [OpenAIRealtimeErrorEvent].
  const OpenAIRealtimeErrorEvent({
    required String eventId,
    required this.error,
  }) : super(
          eventId: eventId,
          type: OpenAIRealtimeEventTypeModel.error,
        );

  /// Creates a [OpenAIRealtimeErrorEvent] from a JSON map.
  factory OpenAIRealtimeErrorEvent.fromMap(Map<String, dynamic> map) {
    return OpenAIRealtimeErrorEvent(
      eventId: map['event_id'] ?? '',
      error: map['error'] ?? {},
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'type': type.value,
      'error': error,
    };
  }

  @override
  String toString() {
    return 'OpenAIRealtimeErrorEvent(eventId: $eventId, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeErrorEvent &&
        other.eventId == eventId &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(eventId, error);
}

/// Generic event for unspecified event types.
class OpenAIRealtimeGenericEvent extends OpenAIRealtimeEventModel {
  /// The raw event data.
  final Map<String, dynamic> data;

  /// Creates a new [OpenAIRealtimeGenericEvent].
  const OpenAIRealtimeGenericEvent({
    required String eventId,
    required OpenAIRealtimeEventTypeModel type,
    required this.data,
  }) : super(
          eventId: eventId,
          type: type,
        );

  /// Creates a [OpenAIRealtimeGenericEvent] from a JSON map.
  factory OpenAIRealtimeGenericEvent.fromMap(Map<String, dynamic> map) {
    return OpenAIRealtimeGenericEvent(
      eventId: map['event_id'] ?? '',
      type: OpenAIRealtimeEventTypeModel.fromValue(map['type']),
      data: map,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return data;
  }

  @override
  String toString() {
    return 'OpenAIRealtimeGenericEvent(eventId: $eventId, type: $type, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeGenericEvent &&
        other.eventId == eventId &&
        other.type == type &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(eventId, type, data);
} 