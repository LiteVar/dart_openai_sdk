import 'dart:typed_data';
import '../../models/realtime/event/realtime_event.dart';

/// The status of a conversation item
enum ConversationItemStatus {
  /// In progress
  inProgress('in_progress'),
  
  /// Completed
  completed('completed'),
  
  /// Incomplete
  incomplete('incomplete');

  const ConversationItemStatus(this.value);
  final String value;

  static ConversationItemStatus fromValue(String value) {
    return values.firstWhere(
      (status) => status.value == value,
      orElse: () => ConversationItemStatus.incomplete,
    );
  }
}

/// Formatted data for a conversation item
class FormattedItem {
  /// Item ID
  final String id;
  
  /// Item status
  final ConversationItemStatus status;
  
  /// Formatted audio data
  final Uint8List? audio;
  
  /// Formatted text content
  final String? text;
  
  /// Formatted transcript content
  final String? transcript;
  
  /// Tool call information
  final Map<String, dynamic>? tool;
  
  /// Raw event data
  final Map<String, dynamic> rawData;

  const FormattedItem({
    required this.id,
    required this.status,
    this.audio,
    this.text,
    this.transcript,
    this.tool,
    required this.rawData,
  });

  /// Create a copy and update the specified fields
  FormattedItem copyWith({
    String? id,
    ConversationItemStatus? status,
    Uint8List? audio,
    String? text,
    String? transcript,
    Map<String, dynamic>? tool,
    Map<String, dynamic>? rawData,
  }) {
    return FormattedItem(
      id: id ?? this.id,
      status: status ?? this.status,
      audio: audio ?? this.audio,
      text: text ?? this.text,
      transcript: transcript ?? this.transcript,
      tool: tool ?? this.tool,
      rawData: rawData ?? this.rawData,
    );
  }
}

/// Realtime conversation status manager
/// 
/// Responsible for maintaining conversation status, caching conversation items, and handling related events
class OpenAIRealtimeConversationManager {
  /// Conversation item mapping (ID -> formatted item)
  final Map<String, FormattedItem> _items = {};
  
  /// Response mapping (ID -> response data)
  final Map<String, Map<String, dynamic>> _responses = {};
  
  /// Queued speech items
  final Map<String, Uint8List> _queuedSpeechItems = {};
  
  /// Queued transcript items
  final Map<String, String> _queuedTranscriptItems = {};
  
  /// Queued input audio
  Uint8List? _queuedInputAudio;
  
  /// Default audio frequency
  static const int defaultFrequency = 24000;

  /// Get all conversation items
  Map<String, FormattedItem> get items => Map.unmodifiable(_items);

  /// Get all responses
  Map<String, Map<String, dynamic>> get responses => Map.unmodifiable(_responses);

  /// Get a specific item
  FormattedItem? getItem(String itemId) => _items[itemId];

  /// Get a specific response
  Map<String, dynamic>? getResponse(String responseId) => _responses[responseId];

  /// Process conversation-related events
  /// 
  /// [event] The event to process
  /// [additionalData] Additional data (e.g. audio data)
  /// 
  /// Returns the processing result
  FormattedItem? processEvent(
    OpenAIRealtimeEventModel event, [
    dynamic additionalData,
  ]) {
    switch (event.type) {
      case OpenAIRealtimeEventTypeModel.conversationItemCreated:
        return _handleItemCreated(event);
      case OpenAIRealtimeEventTypeModel.conversationItemTruncated:
        return _handleItemTruncated(event);
      case OpenAIRealtimeEventTypeModel.conversationItemDeleted:
        return _handleItemDeleted(event);
      case OpenAIRealtimeEventTypeModel.conversationItemInputAudioTranscriptionCompleted:
        return _handleTranscriptionCompleted(event);
      case OpenAIRealtimeEventTypeModel.responseTextDelta:
        return _handleTextDelta(event);
      case OpenAIRealtimeEventTypeModel.responseAudioDelta:
        return _handleAudioDelta(event);
      case OpenAIRealtimeEventTypeModel.responseAudioTranscriptDelta:
        return _handleAudioTranscriptDelta(event);
      case OpenAIRealtimeEventTypeModel.responseFunctionCallArgumentsDelta:
        return _handleFunctionCallArgumentsDelta(event);
      case OpenAIRealtimeEventTypeModel.responseOutputItemDone:
        return _handleOutputItemDone(event);
      case OpenAIRealtimeEventTypeModel.inputAudioBufferSpeechStopped:
        return _handleSpeechStopped(event, additionalData);
      default:
        return null;
    }
  }

  /// Handle item creation event
  FormattedItem? _handleItemCreated(OpenAIRealtimeEventModel event) {
    if (event is! OpenAIRealtimeGenericEvent) return null;
    
    final itemData = event.data['item'] as Map<String, dynamic>?;
    if (itemData == null) return null;

    final itemId = itemData['id'] as String?;
    if (itemId == null) return null;

    var item = FormattedItem(
      id: itemId,
      status: ConversationItemStatus.fromValue(itemData['status'] ?? 'incomplete'),
      rawData: itemData,
    );

    // Handle queued speech data
    if (_queuedSpeechItems.containsKey(itemId)) {
      item = item.copyWith(audio: _queuedSpeechItems.remove(itemId));
    }

    // Handle text content
    final content = itemData['content'] as List?;
    if (content != null) {
      final textParts = content
          .where((c) => c['type'] == 'text' || c['type'] == 'input_text')
          .map((c) => c['text'] as String?)
          .where((text) => text != null)
          .join();
      if (textParts.isNotEmpty) {
        item = item.copyWith(text: textParts);
      }
    }

    // Handle queued transcript data
    if (_queuedTranscriptItems.containsKey(itemId)) {
      item = item.copyWith(transcript: _queuedTranscriptItems.remove(itemId));
    }

    // Handle user audio
    final role = itemData['role'] as String?;
    if (role == 'user' && _queuedInputAudio != null) {
      item = item.copyWith(
        audio: _queuedInputAudio,
        status: ConversationItemStatus.completed,
      );
      _queuedInputAudio = null;
    }

    // Handle function call
    if (itemData['type'] == 'function_call') {
      final tool = {
        'type': 'function',
        'name': itemData['name'],
        'call_id': itemData['call_id'],
        'arguments': itemData['arguments'],
      };
      item = item.copyWith(
        tool: tool,
        status: ConversationItemStatus.inProgress,
      );
    }

    // Handle function call output
    if (itemData['type'] == 'function_call_output') {
      item = item.copyWith(status: ConversationItemStatus.completed);
    }

    _items[itemId] = item;
    return item;
  }

  /// Handle item truncation event
  FormattedItem? _handleItemTruncated(OpenAIRealtimeEventModel event) {
    if (event is! OpenAIRealtimeGenericEvent) return null;
    
    final itemId = event.data['item_id'] as String?;
    final audioEndMs = event.data['audio_end_ms'] as int?;
    
    if (itemId == null || audioEndMs == null) return null;

    final existingItem = _items[itemId];
    if (existingItem == null) return null;

    // Truncate audio
    Uint8List? truncatedAudio;
    if (existingItem.audio != null) {
      final endIndex = audioEndMs * defaultFrequency ~/ 1000;
      if (endIndex < existingItem.audio!.length) {
        truncatedAudio = Uint8List.fromList(
          existingItem.audio!.sublist(0, endIndex),
        );
      }
    }

    final updatedItem = existingItem.copyWith(
      audio: truncatedAudio,
      transcript: '', // Clear transcript
    );

    _items[itemId] = updatedItem;
    return updatedItem;
  }

  /// Handle item deletion event
  FormattedItem? _handleItemDeleted(OpenAIRealtimeEventModel event) {
    if (event is! OpenAIRealtimeGenericEvent) return null;
    
    final itemId = event.data['item_id'] as String?;
    if (itemId == null) return null;

    return _items.remove(itemId);
  }

  /// Handle transcription completion event
  FormattedItem? _handleTranscriptionCompleted(OpenAIRealtimeEventModel event) {
    if (event is! OpenAIRealtimeGenericEvent) return null;
    
    final itemId = event.data['item_id'] as String?;
    final transcript = event.data['transcript'] as String?;
    
    if (itemId == null || transcript == null) return null;

    final existingItem = _items[itemId];
    if (existingItem == null) {
      // If the item doesn't exist, queue the transcript data
      _queuedTranscriptItems[itemId] = transcript.isEmpty ? ' ' : transcript;
      return null;
    }

    final updatedItem = existingItem.copyWith(
      transcript: transcript.isEmpty ? ' ' : transcript,
    );

    _items[itemId] = updatedItem;
    return updatedItem;
  }

  /// Handle text delta event
  FormattedItem? _handleTextDelta(OpenAIRealtimeEventModel event) {
    if (event is! OpenAIRealtimeGenericEvent) return null;
    
    final itemId = event.data['item_id'] as String?;
    final delta = event.data['delta'] as String?;
    
    if (itemId == null || delta == null) return null;

    final existingItem = _items[itemId];
    if (existingItem == null) return null;

    final updatedText = (existingItem.text ?? '') + delta;
    final updatedItem = existingItem.copyWith(text: updatedText);

    _items[itemId] = updatedItem;
    return updatedItem;
  }

  /// Handle audio delta event
  FormattedItem? _handleAudioDelta(OpenAIRealtimeEventModel event) {
    if (event is! OpenAIRealtimeGenericEvent) return null;
    
    final itemId = event.data['item_id'] as String?;
    final delta = event.data['delta'] as String?;
    
    if (itemId == null || delta == null) return null;

    final existingItem = _items[itemId];
    if (existingItem == null) return null;

    // Decode base64 audio data and append
    // Here we simplify the processing, in reality, base64 decoding should be done
    final existingAudio = existingItem.audio ?? Uint8List(0);
    final deltaBytes = Uint8List.fromList(delta.codeUnits); // Simplified processing
    
    final combinedAudio = Uint8List(existingAudio.length + deltaBytes.length);
    combinedAudio.setAll(0, existingAudio);
    combinedAudio.setAll(existingAudio.length, deltaBytes);

    final updatedItem = existingItem.copyWith(audio: combinedAudio);

    _items[itemId] = updatedItem;
    return updatedItem;
  }

  /// Handle audio transcript delta event
  FormattedItem? _handleAudioTranscriptDelta(OpenAIRealtimeEventModel event) {
    if (event is! OpenAIRealtimeGenericEvent) return null;
    
    final itemId = event.data['item_id'] as String?;
    final delta = event.data['delta'] as String?;
    
    if (itemId == null || delta == null) return null;

    final existingItem = _items[itemId];
    if (existingItem == null) return null;

    final updatedTranscript = (existingItem.transcript ?? '') + delta;
    final updatedItem = existingItem.copyWith(transcript: updatedTranscript);

    _items[itemId] = updatedItem;
    return updatedItem;
  }

  /// Handle function call arguments delta event
  FormattedItem? _handleFunctionCallArgumentsDelta(OpenAIRealtimeEventModel event) {
    if (event is! OpenAIRealtimeGenericEvent) return null;
    
    final itemId = event.data['item_id'] as String?;
    final delta = event.data['delta'] as String?;
    
    if (itemId == null || delta == null) return null;

    final existingItem = _items[itemId];
    if (existingItem == null) return null;

    final existingTool = Map<String, dynamic>.from(existingItem.tool ?? {});
    final currentArgs = existingTool['arguments'] as String? ?? '';
    existingTool['arguments'] = currentArgs + delta;

    final updatedItem = existingItem.copyWith(tool: existingTool);

    _items[itemId] = updatedItem;
    return updatedItem;
  }

  /// Handle output item completion event
  FormattedItem? _handleOutputItemDone(OpenAIRealtimeEventModel event) {
    if (event is! OpenAIRealtimeGenericEvent) return null;
    
    final itemId = event.data['item_id'] as String?;
    if (itemId == null) return null;

    final existingItem = _items[itemId];
    if (existingItem == null) return null;

    final updatedItem = existingItem.copyWith(
      status: ConversationItemStatus.completed,
    );

    _items[itemId] = updatedItem;
    return updatedItem;
  }

  /// Handle speech stopped event
  FormattedItem? _handleSpeechStopped(
    OpenAIRealtimeEventModel event, 
    dynamic audioData,
  ) {
    if (audioData is Uint8List) {
      _queuedInputAudio = audioData;
    }
    return null;
  }

  /// Clear
  void clear() {
    _items.clear();
    _responses.clear();
    _queuedSpeechItems.clear();
    _queuedTranscriptItems.clear();
    _queuedInputAudio = null;
  }

  /// Get conversation history
  List<FormattedItem> getConversationHistory() {
    return _items.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  /// Get completed items
  List<FormattedItem> getCompletedItems() {
    return _items.values
        .where((item) => item.status == ConversationItemStatus.completed)
        .toList();
  }

  /// Get in progress items
  List<FormattedItem> getInProgressItems() {
    return _items.values
        .where((item) => item.status == ConversationItemStatus.inProgress)
        .toList();
  }
} 