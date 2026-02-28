import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import '../../core/base/realtime/realtime.dart';
import '../../core/constants/strings.dart';
import '../../core/models/realtime/session/session_config.dart';
import '../../core/models/realtime/event/realtime_event.dart';
import '../../core/models/realtime/common/modality.dart';
import '../../core/models/realtime/tool/tool_definition.dart';
import '../../core/base/realtime/interfaces/tool.dart';
import '../../core/utils/realtime/event_handler.dart';
import '../../core/utils/realtime/conversation_manager.dart';
import '../../core/utils/logger.dart';
import '../../core/builder/headers.dart';


class OpenAIRealtime implements OpenAIRealtimeBase {

  WebSocketChannel? _channel;

  final OpenAIRealtimeEventHandler _eventHandler = OpenAIRealtimeEventHandler();

  final OpenAIRealtimeConversationManager _conversationManager = OpenAIRealtimeConversationManager();

  OpenAIRealtimeSessionConfigModel? _currentSession;

  final Map<String, (OpenAIRealtimeToolDefinitionModel, ToolHandler)> _tools = {};

  final StreamController<OpenAIRealtimeEventModel> _eventStreamController = 
      StreamController<OpenAIRealtimeEventModel>.broadcast();

  bool _debugMode = false;

  StreamSubscription<dynamic>? _connectionSubscription;

  @override
  String get endpoint => OpenAIStrings.endpoints.realtime;

  @override
  bool get isConnected => _channel != null && _channel!.closeCode == null;

  @override
  OpenAIRealtimeSessionConfigModel? get currentSession => _currentSession;

  @override
  Stream<OpenAIRealtimeEventModel> get eventStream => _eventStreamController.stream;

  @override
  Stream<OpenAIRealtimeEventModel> get sessionEventStream => 
      eventStream.where((event) => _isSessionEvent(event.type));

  @override
  Stream<OpenAIRealtimeEventModel> get conversationEventStream => 
      eventStream.where((event) => _isConversationEvent(event.type));

  @override
  Map<String, OpenAIRealtimeToolDefinitionModel> get tools => 
      Map.fromEntries(_tools.entries.map((e) => MapEntry(e.key, e.value.$1)));

  OpenAIRealtime() {
    OpenAILogger.logEndpoint(endpoint);
    _setupEventHandlers();
  }

  @override
  Future<OpenAIRealtimeSessionConfigModel> connect({
    String model = 'gpt-4o-realtime-preview-2024-10-01',
    OpenAIRealtimeSessionConfigModel? sessionConfig,
    Map<String, String>? headers,
    bool debug = false,
  }) async {
    if (isConnected) {
      throw Exception('Already connected to Realtime API');
    }

    _debugMode = debug;
    
    try {
      OpenAILogger.logStartRequest('Realtime Connect: $endpoint');

      final uri = Uri.parse('$endpoint?model=$model');

      final apiKey = HeadersBuilder.apiKey;

      final connectionHeaders = <String, String>{
        if (apiKey != null) 'Authorization': 'Bearer $apiKey',
        'OpenAI-Beta': 'realtime=v1',
        ...?headers,
      };

      _channel = IOWebSocketChannel.connect(
        uri,
        headers: connectionHeaders,
      );

      await _channel!.ready;

      _connectionSubscription = _channel!.stream.listen(
        _handleIncomingMessage,
        onError: _handleConnectionError,
        onDone: _handleConnectionClosed,
      );

      final sessionCreatedEvent = await _eventHandler.waitForNext(
        OpenAIRealtimeEventTypeModel.sessionCreated,
        timeout: const Duration(seconds: 10),
      );

      if (sessionCreatedEvent == null) {
        throw Exception('Failed to receive session created event within timeout. This may indicate authentication failure or API access issues. Please verify your API key and ensure you have access to the Realtime API.');
      }

      if (sessionCreatedEvent is OpenAIRealtimeSessionCreatedEvent) {
        _currentSession = sessionCreatedEvent.session;
      } else if (sessionCreatedEvent is OpenAIRealtimeGenericEvent) {
        final sessionData = sessionCreatedEvent.data['session'] as Map<String, dynamic>?;
        if (sessionData != null) {
          _currentSession = OpenAIRealtimeSessionConfigModel.fromMap(sessionData);
        }
      }

      if (sessionConfig != null) {
        await updateSession(sessionConfig: sessionConfig);
      }

      OpenAILogger.requestFinishedSuccessfully();

      return _currentSession ?? const OpenAIRealtimeSessionConfigModel();
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      await disconnect();

      if (e.toString().contains('401') || e.toString().contains('authentication')) {
        throw Exception('Authentication failed. Please verify your OpenAI API key is valid and has access to the Realtime API.');
      } else if (e.toString().contains('403')) {
        throw Exception('Access denied. Your API key may not have permission to use the Realtime API.');
      } else if (e.toString().contains('WebSocket')) {
        throw Exception('WebSocket connection failed: ${e.toString()}. Please check your network connection.');
      }
      
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      OpenAILogger.logStartRequest('Realtime Disconnect');

      await _connectionSubscription?.cancel();
      _connectionSubscription = null;

      if (_channel != null) {
        await _channel!.sink.close();
        _channel = null;
      }

      _currentSession = null;
      _conversationManager.clear();
      _eventHandler.clearAllHandlers();

      OpenAILogger.requestFinishedSuccessfully();
    } catch (e) {
      OpenAILogger.errorOcurred(e);
    }
  }

  @override
  Future<void> updateSession({
    required OpenAIRealtimeSessionConfigModel sessionConfig,
  }) async {
    if (!isConnected) {
      throw Exception('Not connected to Realtime API');
    }

    try {
      final event = OpenAIRealtimeSessionUpdateEvent(
        eventId: _generateEventId(),
        session: sessionConfig,
      );

      await _sendEvent(event);
      
      final sessionUpdatedEvent = await _eventHandler.waitForNext(
        OpenAIRealtimeEventTypeModel.sessionUpdated,
        timeout: const Duration(seconds: 5),
      );

      if (sessionUpdatedEvent != null) {
        _currentSession = sessionConfig;
      }
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  @override
  Future<void> sendUserMessage({
    required String content,
    OpenAIRealtimeModalityModel modality = OpenAIRealtimeModalityModel.text,
  }) async {
    if (!isConnected) {
      throw Exception('Not connected to Realtime API');
    }

    try {
      final event = OpenAIRealtimeGenericEvent(
        eventId: _generateEventId(),
        type: OpenAIRealtimeEventTypeModel.conversationItemCreate,
        data: {
          'event_id': _generateEventId(),
          'type': 'conversation.item.create',
          'item': {
            'id': _generateEventId(),
            'type': 'message',
            'role': 'user',
            'content': [
              {
                'type': modality == OpenAIRealtimeModalityModel.text ? 'input_text' : 'input_audio',
                if (modality == OpenAIRealtimeModalityModel.text) 'text': content,
              },
            ],
          },
        },
      );

      await _sendEvent(event);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  @override
  Future<void> sendAudioData({
    required Uint8List audioData,
  }) async {
    if (!isConnected) {
      throw Exception('Not connected to Realtime API');
    }

    try {
      final base64Audio = base64Encode(audioData);
      
      final event = OpenAIRealtimeGenericEvent(
        eventId: _generateEventId(),
        type: OpenAIRealtimeEventTypeModel.inputAudioBufferAppend,
        data: {
          'event_id': _generateEventId(),
          'type': 'input_audio_buffer.append',
          'audio': base64Audio,
        },
      );

      await _sendEvent(event);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  @override
  Future<void> commitAudioBuffer() async {
    if (!isConnected) {
      throw Exception('Not connected to Realtime API');
    }

    try {
      final event = OpenAIRealtimeGenericEvent(
        eventId: _generateEventId(),
        type: OpenAIRealtimeEventTypeModel.inputAudioBufferCommit,
        data: {
          'event_id': _generateEventId(),
          'type': 'input_audio_buffer.commit',
        },
      );

      await _sendEvent(event);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  @override
  Future<void> clearAudioBuffer() async {
    if (!isConnected) {
      throw Exception('Not connected to Realtime API');
    }

    try {
      final event = OpenAIRealtimeGenericEvent(
        eventId: _generateEventId(),
        type: OpenAIRealtimeEventTypeModel.inputAudioBufferClear,
        data: {
          'event_id': _generateEventId(),
          'type': 'input_audio_buffer.clear',
        },
      );

      await _sendEvent(event);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  @override
  Future<void> createResponse({
    String? instructions,
    List<OpenAIRealtimeModalityModel>? modalities,
    String? voice,
    String? outputAudioFormat,
    List<Map<String, dynamic>>? tools,
    dynamic toolChoice,
    double? temperature,
    dynamic maxOutputTokens,
  }) async {
    if (!isConnected) {
      throw Exception('Not connected to Realtime API');
    }

    try {
      final responseData = <String, dynamic>{
        'event_id': _generateEventId(),
        'type': 'response.create',
      };

      final response = <String, dynamic>{};

      if (instructions != null) response['instructions'] = instructions;
      if (modalities != null) {
        response['modalities'] = modalities.map((m) => m.value).toList();
      }
      if (voice != null) response['voice'] = voice;
      if (outputAudioFormat != null) response['output_audio_format'] = outputAudioFormat;
      if (tools != null) response['tools'] = tools;
      if (toolChoice != null) response['tool_choice'] = toolChoice;
      if (temperature != null) response['temperature'] = temperature;
      if (maxOutputTokens != null) response['max_output_tokens'] = maxOutputTokens;

      if (response.isNotEmpty) {
        responseData['response'] = response;
      }

      final event = OpenAIRealtimeGenericEvent(
        eventId: _generateEventId(),
        type: OpenAIRealtimeEventTypeModel.responseCreate,
        data: responseData,
      );

      await _sendEvent(event);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  @override
  Future<void> cancelResponse() async {
    if (!isConnected) {
      throw Exception('Not connected to Realtime API');
    }

    try {
      final event = OpenAIRealtimeGenericEvent(
        eventId: _generateEventId(),
        type: OpenAIRealtimeEventTypeModel.responseCancel,
        data: {
          'event_id': _generateEventId(),
          'type': 'response.cancel',
        },
      );

      await _sendEvent(event);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  @override
  Future<void> truncateItem({
    required String itemId,
    required int contentIndex,
    required int audioEndMs,
  }) async {
    if (!isConnected) {
      throw Exception('Not connected to Realtime API');
    }

    try {
      final event = OpenAIRealtimeGenericEvent(
        eventId: _generateEventId(),
        type: OpenAIRealtimeEventTypeModel.conversationItemTruncate,
        data: {
          'event_id': _generateEventId(),
          'type': 'conversation.item.truncate',
          'item_id': itemId,
          'content_index': contentIndex,
          'audio_end_ms': audioEndMs,
        },
      );

      await _sendEvent(event);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteItem({
    required String itemId,
  }) async {
    if (!isConnected) {
      throw Exception('Not connected to Realtime API');
    }

    try {
      final event = OpenAIRealtimeGenericEvent(
        eventId: _generateEventId(),
        type: OpenAIRealtimeEventTypeModel.conversationItemDelete,
        data: {
          'event_id': _generateEventId(),
          'type': 'conversation.item.delete',
          'item_id': itemId,
        },
      );

      await _sendEvent(event);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  @override
  void addTool({
    required OpenAIRealtimeToolDefinitionModel tool,
    required ToolHandler handler,
  }) {
    _tools[tool.name] = (tool, handler);
  }

  @override
  void removeTool(String name) {
    _tools.remove(name);
  }

  @override
  bool hasTool(String name) {
    return _tools.containsKey(name);
  }

  @override
  Future<String> callTool({
    required String name,
    required Map<String, dynamic> arguments,
  }) async {
    final toolEntry = _tools[name];
    if (toolEntry == null) {
      throw Exception('Tool "$name" not found');
    }

    try {
      return await toolEntry.$2(arguments);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  void _setupEventHandlers() {
    _eventHandler.on(OpenAIRealtimeEventTypeModel.conversationItemCreated, (event) async {
      final result = _conversationManager.processEvent(event);
      if (result != null) {
        _dispatchCustomEvent(OpenAIRealtimeEventTypeModel.conversationUpdated, {
          'item': result,
        });
      }
    });

    _eventHandler.on(OpenAIRealtimeEventTypeModel.responseOutputItemDone, (event) async {
      if (event is OpenAIRealtimeGenericEvent) {
        final item = event.data['item'] as Map<String, dynamic>?;
        if (item != null && item['type'] == 'function_call') {
          final name = item['name'] as String?;
          final callId = item['call_id'] as String?;
          final argumentsRaw = item['arguments'];
          Map<String, dynamic>? arguments;
          
          if (argumentsRaw is String) {
            try {
              arguments = json.decode(argumentsRaw) as Map<String, dynamic>;
            } catch (e) {
              arguments = {};
            }
          } else if (argumentsRaw is Map<String, dynamic>) {
            arguments = argumentsRaw;
          } else {
            arguments = {};
          }
          
          if (name != null && callId != null && arguments != null) {
            try {
              if (_debugMode) {
                OpenAILogger.log('Calling tool: $name with arguments: $arguments');
              }
              
              final result = await callTool(name: name, arguments: arguments);
              
              if (_debugMode) {
                OpenAILogger.log('Tool result: $result');
              }
              
              // 发送工具调用结果
              final responseEvent = OpenAIRealtimeGenericEvent(
                eventId: _generateEventId(),
                type: OpenAIRealtimeEventTypeModel.conversationItemCreate,
                data: {
                  'event_id': _generateEventId(),
                  'type': 'conversation.item.create',
                  'item': {
                    'id': _generateEventId(),
                    'type': 'function_call_output',
                    'call_id': callId,
                    'output': result,
                  },
                },
              );
              
              await _sendEvent(responseEvent);
              
              await createResponse();
              
            } catch (e) {
              OpenAILogger.errorOcurred(e);
              
              final errorEvent = OpenAIRealtimeGenericEvent(
                eventId: _generateEventId(),
                type: OpenAIRealtimeEventTypeModel.conversationItemCreate,
                data: {
                  'event_id': _generateEventId(),
                  'type': 'conversation.item.create',
                  'item': {
                    'id': _generateEventId(),
                    'type': 'function_call_output',
                    'call_id': callId,
                    'output': json.encode({'error': e.toString()}),
                  },
                },
              );
              
              await _sendEvent(errorEvent);
              await createResponse();
            }
          }
        }
      }
    });
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final eventData = json.decode(data) as Map<String, dynamic>;
      final event = OpenAIRealtimeEventModel.fromMap(eventData);

      if (_debugMode) {
        OpenAILogger.log('Received Event: ${event.type}');
      }

      _eventHandler.dispatch(event);

      _eventStreamController.add(event);
    } catch (e) {
      OpenAILogger.errorOcurred(e);
    }
  }

  void _handleConnectionError(dynamic error) {
    OpenAILogger.errorOcurred(error);
    _dispatchCustomEvent(OpenAIRealtimeEventTypeModel.error, {
      'error': {'message': error.toString()},
    });
  }

  void _handleConnectionClosed() {
    OpenAILogger.log('Connection Closed');
    _channel = null;
    _currentSession = null;
  }

  Future<void> _sendEvent(OpenAIRealtimeEventModel event) async {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }

    try {
      final eventData = event.toMap();
      final eventString = json.encode(eventData);

      if (_debugMode) {
        OpenAILogger.logStartRequest('Sending Event: ${event.type}');
      }

      _channel!.sink.add(eventString);

      if (_debugMode) {
        OpenAILogger.log('Sent Event: ${event.type}');
      }
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  void _dispatchCustomEvent(OpenAIRealtimeEventTypeModel type, Map<String, dynamic> data) {
    final event = OpenAIRealtimeGenericEvent(
      eventId: _generateEventId(),
      type: type,
      data: data,
    );
    
    _eventStreamController.add(event);
  }

  String _generateEventId() {
    return 'event_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  bool _isSessionEvent(OpenAIRealtimeEventTypeModel type) {
    return type == OpenAIRealtimeEventTypeModel.sessionCreated ||
           type == OpenAIRealtimeEventTypeModel.sessionUpdated;
  }

  bool _isConversationEvent(OpenAIRealtimeEventTypeModel type) {
    const conversationEvents = {
      OpenAIRealtimeEventTypeModel.conversationCreated,
      OpenAIRealtimeEventTypeModel.conversationItemCreated,
      OpenAIRealtimeEventTypeModel.conversationItemTruncated,
      OpenAIRealtimeEventTypeModel.conversationItemDeleted,
      OpenAIRealtimeEventTypeModel.conversationItemInputAudioTranscriptionCompleted,
      OpenAIRealtimeEventTypeModel.conversationUpdated,
      OpenAIRealtimeEventTypeModel.conversationInterrupted,
      OpenAIRealtimeEventTypeModel.conversationItemAppended,
      OpenAIRealtimeEventTypeModel.conversationItemCompleted,
    };
    
    return conversationEvents.contains(type);
  }

  void dispose() {
    disconnect();
    _eventStreamController.close();
    _eventHandler.clearAllHandlers();
  }
} 