import 'dart:async';
import 'dart:typed_data';
import '../../../models/realtime/event/realtime_event.dart';
import '../../../models/realtime/common/modality.dart';

/// Conversation management interface, defining conversation-related operations for the realtime module
abstract class ConversationInterface {
  /// Send user text message
  ///
  /// [content] Message content
  /// [modality] Modality type, defaults to text
  Future<void> sendUserMessage({
    required String content,
    OpenAIRealtimeModalityModel modality = OpenAIRealtimeModalityModel.text,
  });

  /// Send audio data
  ///
  /// [audioData] Audio data
  Future<void> sendAudioData({
    required Uint8List audioData,
  });

  /// Submit input audio buffer
  Future<void> commitAudioBuffer();

  /// Clear input audio buffer
  Future<void> clearAudioBuffer();

  /// Create response
  ///
  /// [instructions] Optional instruction override
  /// [modalities] Optional modality override
  /// [voice] Optional voice override
  /// [outputAudioFormat] Optional output audio format override
  /// [tools] Optional tool override
  /// [toolChoice] Optional tool choice override
  /// [temperature] Optional temperature override
  /// [maxOutputTokens] Optional maximum output token override
  Future<void> createResponse({
    String? instructions,
    List<OpenAIRealtimeModalityModel>? modalities,
    String? voice,
    String? outputAudioFormat,
    List<Map<String, dynamic>>? tools,
    dynamic toolChoice,
    double? temperature,
    dynamic maxOutputTokens,
  });

  /// Cancel current response
  Future<void> cancelResponse();

  /// Truncate conversation item
  ///
  /// [itemId] Item ID to truncate
  /// [contentIndex] Content index
  /// [audioEndMs] Audio end time (milliseconds)
  Future<void> truncateItem({
    required String itemId,
    required int contentIndex,
    required int audioEndMs,
  });

  /// Delete conversation item
  ///
  /// [itemId] Item ID to delete
  Future<void> deleteItem({
    required String itemId,
  });

  /// Listen to conversation events
  ///
  /// Returns a stream of conversation-related events
  Stream<OpenAIRealtimeEventModel> get conversationEventStream;
} 