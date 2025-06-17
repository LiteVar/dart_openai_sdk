import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;


import '../utils/logger.dart';
import '../models/realtime/event/realtime_event.dart';

/// WebSocket client, specifically for OpenAI Realtime API WebSocket connections
class OpenAIRealtimeWebSocketClient {
  /// Connect to the OpenAI Realtime API WebSocket server
  ///
  /// [url] WebSocket server URL
  /// [model] The name of the model to use
  /// [apiKey] API key, if not provided, use headers
  /// [headers] Additional request headers
  /// 
  /// Returns the WebSocket channel
  static Future<WebSocketChannel> connect({
    required String url,
    required String model,
    String? apiKey,
    Map<String, String>? headers,
  }) async {
    try {
      OpenAILogger.logStartRequest(url);

      // Build the URI, including the model parameter
      final uri = Uri.parse('$url?model=$model');

      // Create the WebSocket connection
      final channel = WebSocketChannel.connect(
        uri,
        protocols: ['realtime'],
      );

      // Wait for the connection to be established
      await channel.ready;

      OpenAILogger.log('WebSocket connected to: $url');
      return channel;
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  /// Send an event to the WebSocket server
  ///
  /// [channel] WebSocket channel
  /// [event] The event to send
  static Future<void> sendEvent({
    required WebSocketChannel channel,
    required OpenAIRealtimeEventModel event,
  }) async {
    try {
      final eventJson = event.toMap();
      final eventString = json.encode(eventJson);
      
      OpenAILogger.logStartRequest('WebSocket Send: ${event.type}');
      
      channel.sink.add(eventString);
      
      OpenAILogger.log('WebSocket Sent: ${event.type}');
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  /// Send raw data to the WebSocket server
  ///
  /// [channel] WebSocket channel
  /// [data] The raw data to send
  static Future<void> sendRawData({
    required WebSocketChannel channel,
    required dynamic data,
  }) async {
    try {
      OpenAILogger.logStartRequest('WebSocket Send Raw Data');
      
      channel.sink.add(data);
      
      OpenAILogger.log('WebSocket Sent Raw Data');
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }

  /// Receive event stream from the WebSocket server
  ///
  /// [channel] WebSocket channel
  /// 
  /// Returns the event stream
  static Stream<OpenAIRealtimeEventModel> receiveEvents({
    required WebSocketChannel channel,
  }) {
    return channel.stream.map<OpenAIRealtimeEventModel>((data) {
      try {
        final eventJson = json.decode(data) as Map<String, dynamic>;
        final event = OpenAIRealtimeEventModel.fromMap(eventJson);
        
        OpenAILogger.log('WebSocket Received: ${event.type}');
        
        return event;
      } catch (e) {
        OpenAILogger.errorOcurred(e);
        rethrow;
      }
    });
  }

  /// Receive raw data stream from the WebSocket server
  ///
  /// [channel] WebSocket channel
  /// 
  /// Returns the raw data stream
  static Stream<dynamic> receiveRawData({
    required WebSocketChannel channel,
  }) {
    return channel.stream.map<dynamic>((data) {
      OpenAILogger.log('WebSocket Received Raw Data');
      return data;
    });
  }

  /// Check if the WebSocket connection is active
  ///
  /// [channel] WebSocket channel
  /// 
  /// Returns the connection status
  static bool isConnected(WebSocketChannel? channel) {
    if (channel == null) return false;
    
    try {
      // Try to get the closeCode, if the connection is still active, this property should be null
      return channel.closeCode == null;
    } catch (e) {
      // If an exception is thrown, it means the connection may have been closed
      return false;
    }
  }

  /// Disconnect the WebSocket connection
  ///
  /// [channel] WebSocket channel
  /// [closeCode] Close code, defaults to normal closure
  /// [closeReason] Close reason
  static Future<void> disconnect(
    WebSocketChannel? channel, {
    int closeCode = status.normalClosure,
    String? closeReason,
  }) async {
    if (channel == null) return;
    
    try {
      OpenAILogger.logStartRequest('WebSocket Disconnect');
      
      await channel.sink.close(closeCode, closeReason);
      
      OpenAILogger.log('WebSocket Disconnected');
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      // The error when disconnecting is usually not rethrown
    }
  }

  /// Listen to WebSocket connection errors and close events
  ///
  /// [channel] WebSocket channel
  /// [onError] Error callback
  /// [onDone] Connection close callback
  /// 
  /// Returns the subscription object
  static StreamSubscription<dynamic> listenToConnection({
    required WebSocketChannel channel,
    Function(dynamic error)? onError,
    void Function()? onDone,
  }) {
    return channel.stream.listen(
      (data) {
        // Data processing is handled by other methods, here we just keep the connection active
      },
      onError: (error) {
        OpenAILogger.errorOcurred(error);
        onError?.call(error);
      },
      onDone: () {
        OpenAILogger.log('WebSocket Connection Closed');
        onDone?.call();
      },
    );
  }

  /// Send a ping frame to keep the connection active
  ///
  /// [channel] WebSocket channel
  /// [data] ping data
  static Future<void> sendPing({
    required WebSocketChannel channel,
    Uint8List? data,
  }) async {
    try {
      OpenAILogger.logStartRequest('WebSocket Ping');
      
      // WebSocket ping is usually handled by the underlying implementation
      // Here we send a simple ping event as an alternative
      await sendRawData(
        channel: channel,
        data: json.encode({
          'type': 'ping',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
      
      OpenAILogger.log('WebSocket Ping Sent');
    } catch (e) {
      OpenAILogger.errorOcurred(e);
      rethrow;
    }
  }
} 