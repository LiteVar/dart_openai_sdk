import 'dart:async';
import '../../models/realtime/event/realtime_event.dart';

typedef EventCallback = Future<void> Function(OpenAIRealtimeEventModel event);

class OpenAIRealtimeEventHandler {
  final Map<OpenAIRealtimeEventTypeModel, List<EventCallback>> _eventHandlers = {};
  
  final Map<OpenAIRealtimeEventTypeModel, List<EventCallback>> _nextEventHandlers = {};

  void on(OpenAIRealtimeEventTypeModel eventType, EventCallback callback) {
    _eventHandlers.putIfAbsent(eventType, () => []).add(callback);
  }

  void onNext(OpenAIRealtimeEventTypeModel eventType, EventCallback callback) {
    _nextEventHandlers.putIfAbsent(eventType, () => []).add(callback);
  }

  void off(OpenAIRealtimeEventTypeModel eventType, [EventCallback? callback]) {
    if (callback == null) {
      _eventHandlers.remove(eventType);
    } else {
      _eventHandlers[eventType]?.remove(callback);
      if (_eventHandlers[eventType]?.isEmpty == true) {
        _eventHandlers.remove(eventType);
      }
    }
  }

  void offNext(OpenAIRealtimeEventTypeModel eventType, [EventCallback? callback]) {
    if (callback == null) {
      _nextEventHandlers.remove(eventType);
    } else {
      _nextEventHandlers[eventType]?.remove(callback);
      if (_nextEventHandlers[eventType]?.isEmpty == true) {
        _nextEventHandlers.remove(eventType);
      }
    }
  }

  Future<OpenAIRealtimeEventModel?> waitForNext(
    OpenAIRealtimeEventTypeModel eventType, {
    Duration? timeout,
  }) {
    final completer = Completer<OpenAIRealtimeEventModel?>();

    Future<void> eventHandler(OpenAIRealtimeEventModel event) async {
      if (!completer.isCompleted) {
        completer.complete(event);
      }
    }

    onNext(eventType, eventHandler);

    if (timeout != null) {
      Timer(timeout, () {
        if (!completer.isCompleted) {
          offNext(eventType, eventHandler);
          completer.complete(null);
        }
      });
    }

    return completer.future;
  }

  Future<void> dispatch(OpenAIRealtimeEventModel event) async {
    final eventType = event.type;

    final handlers = List<EventCallback>.from(_eventHandlers[eventType] ?? []);
    for (final handler in handlers) {
      try {
        await handler(event);
      } catch (e) {
        print('OpenAIRealtimeEventHandler: $e');
      }
    }

    final nextHandlers = List<EventCallback>.from(_nextEventHandlers[eventType] ?? []);
    _nextEventHandlers.remove(eventType);
    
    for (final handler in nextHandlers) {
      try {
        await handler(event);
      } catch (e) {
        print('OpenAIRealtimeEventHandler: $e');
      }
    }

    if (eventType != OpenAIRealtimeEventTypeModel.all) {
      await _dispatchToGeneric(event, OpenAIRealtimeEventTypeModel.all);
    }
    
    if (eventType != OpenAIRealtimeEventTypeModel.serverAll && 
        eventType != OpenAIRealtimeEventTypeModel.clientAll) {
      if (_isServerEvent(eventType)) {
        await _dispatchToGeneric(event, OpenAIRealtimeEventTypeModel.serverAll);
      } else {
        await _dispatchToGeneric(event, OpenAIRealtimeEventTypeModel.clientAll);
      }
    }
  }

  Future<void> _dispatchToGeneric(
    OpenAIRealtimeEventModel event, 
    OpenAIRealtimeEventTypeModel genericType,
  ) async {
    final handlers = List<EventCallback>.from(_eventHandlers[genericType] ?? []);
    for (final handler in handlers) {
      try {
        await handler(event);
      } catch (e) {
        print('OpenAIRealtimeEventHandler: $e');
      }
    }

    final nextHandlers = List<EventCallback>.from(_nextEventHandlers[genericType] ?? []);
    _nextEventHandlers.remove(genericType);
    
    for (final handler in nextHandlers) {
      try {
        await handler(event);
      } catch (e) {
        print('OpenAIRealtimeEventHandler: $e');
      }
    }
  }

  bool _isServerEvent(OpenAIRealtimeEventTypeModel eventType) {
    const serverEvents = {
      OpenAIRealtimeEventTypeModel.error,
      OpenAIRealtimeEventTypeModel.sessionCreated,
      OpenAIRealtimeEventTypeModel.sessionUpdated,
      OpenAIRealtimeEventTypeModel.conversationCreated,
      OpenAIRealtimeEventTypeModel.inputAudioBufferCommitted,
      OpenAIRealtimeEventTypeModel.inputAudioBufferCleared,
      OpenAIRealtimeEventTypeModel.inputAudioBufferSpeechStarted,
      OpenAIRealtimeEventTypeModel.inputAudioBufferSpeechStopped,
      OpenAIRealtimeEventTypeModel.conversationItemCreated,
      OpenAIRealtimeEventTypeModel.conversationItemInputAudioTranscriptionCompleted,
      OpenAIRealtimeEventTypeModel.conversationItemInputAudioTranscriptionFailed,
      OpenAIRealtimeEventTypeModel.conversationItemTruncated,
      OpenAIRealtimeEventTypeModel.conversationItemDeleted,
      OpenAIRealtimeEventTypeModel.responseCreated,
      OpenAIRealtimeEventTypeModel.responseDone,
      OpenAIRealtimeEventTypeModel.responseOutputItemAdded,
      OpenAIRealtimeEventTypeModel.responseOutputItemDone,
      OpenAIRealtimeEventTypeModel.responseContentPartAdded,
      OpenAIRealtimeEventTypeModel.responseContentPartDone,
      OpenAIRealtimeEventTypeModel.responseTextDelta,
      OpenAIRealtimeEventTypeModel.responseTextDone,
      OpenAIRealtimeEventTypeModel.responseAudioTranscriptDelta,
      OpenAIRealtimeEventTypeModel.responseAudioTranscriptDone,
      OpenAIRealtimeEventTypeModel.responseAudioDelta,
      OpenAIRealtimeEventTypeModel.responseAudioDone,
      OpenAIRealtimeEventTypeModel.responseFunctionCallArgumentsDelta,
      OpenAIRealtimeEventTypeModel.responseFunctionCallArgumentsDone,
      OpenAIRealtimeEventTypeModel.rateLimitsUpdated,
    };
    
    return serverEvents.contains(eventType);
  }

  void clearAllHandlers() {
    _eventHandlers.clear();
    _nextEventHandlers.clear();
  }

  int getHandlerCount(OpenAIRealtimeEventTypeModel eventType) {
    final continuous = _eventHandlers[eventType]?.length ?? 0;
    final oneTime = _nextEventHandlers[eventType]?.length ?? 0;
    return continuous + oneTime;
  }

  bool hasHandlers(OpenAIRealtimeEventTypeModel eventType) {
    return getHandlerCount(eventType) > 0;
  }
} 