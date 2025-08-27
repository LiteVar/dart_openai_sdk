import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:dart_openai_sdk/dart_openai_sdk.dart';

import 'env/env.dart';

// Configuration Constants
class RealtimeConfig {
  static const String model = 'gpt-4o-realtime-preview';
  static const int sampleRate = 24000; // 24kHz
  static const int bitsPerSample = 16;
  static const int channels = 1; // mono
  static const double threshold = 0.5;
  static const int silenceDurationMs = 1000;
  static const int chunkSize = 4096; // 4KB chunks
  static const String instructions = 'You are a helpful AI assistant.';
  static const Duration connectionStabilizationDelay = Duration(seconds: 2);
  static const Duration processingDelay = Duration(seconds: 10);
  
  // Audio file paths
  static const List<String> audioFiles = [
    'voice/beijing_weather.wav'
  ];
}

// Global State Variables
List<Uint8List> _audioResponseChunks = [];
String? _currentResponseId;
int _responseCounter = 0;

String _currentAITranscript = '';
String? _currentAITranscriptResponseId;
List<String> _completedAITranscripts = [];

void main() async {
  
  OpenAI.apiKey = Env.apiKey;

  OpenAIRealtime realtime = OpenAI.instance.realtime;

  try {
    // Connect to realtime API
    print('🔌 Connecting to OpenAI Realtime API...');
    await realtime.connect(
      model: RealtimeConfig.model,
      debug: true,
    );

    print('✅ Connection established successfully!');

    // Configure session with audio input transcription support
    final sessionConfig = OpenAIRealtimeSessionConfigModel(
      modalities: [OpenAIRealtimeModalityModel.text, OpenAIRealtimeModalityModel.audio],
      instructions: RealtimeConfig.instructions,
      inputAudioTranscription: const OpenAIRealtimeTranscriptionConfigModel(
        model: 'whisper-1'
      ),
      turnDetection: OpenAIRealtimeTurnDetectionModel(
        type: OpenAIRealtimeTurnDetectionTypeModel.serverVad,
        threshold: RealtimeConfig.threshold,
        silenceDurationMs: RealtimeConfig.silenceDurationMs,
      ),
      toolChoice: const OpenAIRealtimeToolChoiceModel.auto(),
    );
    await realtime.updateSession(sessionConfig: sessionConfig);
    print('✅ Session configuration updated successfully');

    // Setup event listeners
    _setupEventListeners(realtime);

    // Add tools
    _addTools(realtime);

    // Wait for connection stabilization
    await Future.delayed(RealtimeConfig.connectionStabilizationDelay);

    // Demonstrate Base64 audio functionality
    await _demonstrateBase64Audio(realtime);

    // Wait for processing completion
    await Future.delayed(RealtimeConfig.processingDelay);

    // Disconnect
    await realtime.disconnect();
    print('✅ Connection closed successfully');

  } catch (e) {
    print('❌ Error: $e');
    try {
      await realtime.disconnect();
    } catch (disconnectError) {
      print('❌ Failed to disconnect: $disconnectError');
    }
  }
}

/// Setup event listeners for realtime API events
void _setupEventListeners(OpenAIRealtime realtime) {
  realtime.eventStream.listen((event) {
    print('📨 Received event: ${event.type.value}');
    
    // Listen for error events and display detailed information
    if (event.type.value == 'error') {
      _handleErrorEvent(event);
      return; // Early return to avoid duplicate processing
    }
    
    // Listen for response creation events
    if (event.type.value == 'response.created') {
      if (event is OpenAIRealtimeGenericEvent) {
        _currentResponseId = event.data['response']?['id'];
        _audioResponseChunks.clear();
        
        // Clear AI transcription state
        _currentAITranscript = '';
        _currentAITranscriptResponseId = null;
        
        _responseCounter++;
        print('🎬 Starting new audio response #$_responseCounter (ID: $_currentResponseId)');
      }
    }
    
    // Listen for transcription results
    if (event.type.value == 'conversation.item.input_audio_transcription.completed') {
      if (event is OpenAIRealtimeGenericEvent) {
        final transcript = event.data['transcript'];
        print('🎤 Audio transcription result: $transcript');
      }
    }
    
    // Listen for audio response data and save
    if (event.type.value == 'response.audio.delta') {
      if (event is OpenAIRealtimeGenericEvent) {
        final audioDelta = event.data['delta'] as String?;
        if (audioDelta != null) {
          try {
            // Decode base64 audio data
            final audioBytes = base64Decode(audioDelta);
            _audioResponseChunks.add(audioBytes);
            
            print('🔊 Received audio response data: ${audioDelta.length} characters (decoded: ${audioBytes.length} bytes)');
          } catch (e) {
            print('❌ Failed to decode audio data: $e');
          }
        }
      }
    }
    
    // Listen for audio response completion events
    if (event.type.value == 'response.audio.done') {
      _saveAudioResponse();
    }
    
    // Listen for AI audio transcription delta events
    if (event.type.value == 'response.audio_transcript.delta') {
      if (event is OpenAIRealtimeGenericEvent) {
        final transcriptDelta = event.data['delta'] as String?;
        final responseId = event.data['response_id'] as String?;
        
        if (transcriptDelta != null && responseId != null) {
          // Reset transcription content if this is a new response
          if (_currentAITranscriptResponseId != responseId) {
            _currentAITranscriptResponseId = responseId;
            _currentAITranscript = '';
          }
          
          _currentAITranscript += transcriptDelta;
          // print('🤖 AI audio transcription delta: $transcriptDelta');
          print('🤖 AI audio transcription current content: $_currentAITranscript');
        }
      }
    }
    
    // Listen for AI audio transcription completion events
    if (event.type.value == 'response.audio_transcript.done') {
      if (event is OpenAIRealtimeGenericEvent) {
        final finalTranscript = event.data['transcript'] as String?;
        final responseId = event.data['response_id'] as String?;
        
        if (finalTranscript != null && responseId != null) {
          _completedAITranscripts.add(finalTranscript);
          print('✅ AI audio transcription completed: $finalTranscript');
          print('📊 Total completed AI transcriptions: ${_completedAITranscripts.length}');
          
          // Save transcription result to file
          _saveAITranscript(finalTranscript, responseId);
        }
      }
    }
    
    // Listen for function call events
    if (event.type.value == 'response.function_call_arguments.delta') {
      if (event is OpenAIRealtimeGenericEvent) {
        final functionName = event.data['name'] as String?;
        final argumentsDelta = event.data['delta'] as String?;
        print('🔧 Function call arguments delta: $functionName - $argumentsDelta');
      }
    }
    
    if (event.type.value == 'response.function_call_arguments.done') {
      if (event is OpenAIRealtimeGenericEvent) {
        final functionName = event.data['name'] as String?;
        final arguments = event.data['arguments'] as String?;
        print('✅ Function call arguments completed: $functionName - $arguments');
      }
    }
    
    // Listen for tool call outputs
    if (event.type.value == 'response.output_item.added') {
      if (event is OpenAIRealtimeGenericEvent) {
        final item = event.data['item'];
        if (item is Map && item['type'] == 'function_call') {
          print('🛠️ Tool call added: ${item['name']}');
        }
      }
    }
    
    // Listen for complete response.created events to check for tool calls
    if (event.type.value == 'conversation.item.created') {
      if (event is OpenAIRealtimeGenericEvent) {
        final item = event.data['item'];
        if (item is Map) {
          print('📝 Conversation item created: ${item['type']} - ${item.toString()}');
          if (item['type'] == 'function_call') {
            print('🔨 Tool call item detected!');
          }
        }
      }
    }
  });
}

/// Add tools to the realtime session
void _addTools(OpenAIRealtime realtime) {
    print('🛠️ Adding tools...');
    // Add weather tool
    realtime.addTool(
      tool: const OpenAIRealtimeToolDefinitionModel(
        type: 'function',
        name: 'get_weather',
        description: 'Get weather information for a specified city',
        parameters: {
          'type': 'object',
          'properties': {
            'city': {
              'type': 'string',
              'description': 'City name',
            },
          },
          'required': ['city'],
        },
      ),
      handler: (arguments) async {
        print('🔧 Tool called: get_weather, arguments: $arguments');
        final city = arguments['city'] as String? ?? 'Beijing'; // Default to Beijing
        // Here you can call a real weather API
        final result = '{"city": "$city", "temperature": "22°C", "weather": "Sunny"}';
        print('📋 Tool result: $result');
        return result;
      },
    );
    print('✅ Tools added successfully');
}

/// Save audio response to file
Future<void> _saveAudioResponse() async {
  if (_audioResponseChunks.isEmpty) {
    print('⚠️ No audio data available to save');
    return;
  }

  try {
    // Combine all audio chunks
    final totalBytes = _audioResponseChunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
    final combinedAudio = Uint8List(totalBytes);
    
    int offset = 0;
    for (final chunk in _audioResponseChunks) {
      combinedAudio.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    // Generate filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'ai_response_${_responseCounter}_$timestamp';
    
    // // Save raw PCM data
    // final pcmFile = File('${filename}.pcm');
    // await pcmFile.writeAsBytes(combinedAudio);
    // print('💾 Audio response saved as PCM format: ${pcmFile.path}');
    // print('   Size: ${combinedAudio.length} bytes');
    
    // Try to create WAV file (with WAV header)
    try {
      await _createWavFile(combinedAudio, '${filename}.wav');
    } catch (e) {
      print('⚠️ Failed to create WAV file: $e');
    }
    
  } catch (e) {
    print('❌ Failed to save audio file: $e');
  }
}

/// Handle error events with structured output
void _handleErrorEvent(OpenAIRealtimeEventModel event) {
  print('\n🚨 ===== ERROR EVENT DETAILS =====');
  
  try {
    if (event is OpenAIRealtimeGenericEvent) {
      final errorData = event.data['error'] as Map<String, dynamic>?;
      
      if (errorData != null) {
        final errorType = errorData['type'] as String?;
        final errorCode = errorData['code'] as String?;
        final errorMessage = errorData['message'] as String?;
        final errorParam = errorData['param'] as String?;
        final eventId = errorData['event_id'] as String?;
        
        print('🔸 Error Type: ${errorType ?? "Unknown"}');
        print('🔸 Error Code: ${errorCode ?? "None"}');
        print('🔸 Error Message: ${errorMessage ?? "No detailed message"}');
        if (errorParam != null) print('🔸 Error Parameter: $errorParam');
        if (eventId != null) print('🔸 Event ID: $eventId');
        
        // Provide specific troubleshooting advice based on error type
        _provideTroubleshootingAdvice(errorType, errorCode, errorMessage);
      } else {
        print('🔸 Error Information: ${event.data}');
      }
    } else if (event is OpenAIRealtimeErrorEvent) {
      final errorData = event.error;
      print('🔸 Error Details: $errorData');
      
      final errorType = errorData['type'] as String?;
      final errorCode = errorData['code'] as String?;
      final errorMessage = errorData['message'] as String?;
      
      _provideTroubleshootingAdvice(errorType, errorCode, errorMessage);
    } else {
      print('🔸 Unknown error event format: $event');
    }
  } catch (e) {
    print('🔸 Exception occurred while parsing error event: $e');
    print('🔸 Raw event data: $event');
  }
  
  print('=============================\n');
}

/// Provide troubleshooting advice based on error details
void _provideTroubleshootingAdvice(String? errorType, String? errorCode, String? errorMessage) {
  print('\n💡 TROUBLESHOOTING SUGGESTIONS:');
  
  // Provide specific advice based on error type
  if (errorType != null) {
    switch (errorType.toLowerCase()) {
      case 'invalid_request_error':
        print('   • Check if request parameters are correct');
        print('   • Verify audio format meets requirements (PCM 16-bit, 24kHz)');
        print('   • Validate base64 encoding');
        break;
      case 'authentication_error':
        print('   • Verify API key is correct');
        print('   • Ensure API key has Realtime API access permissions');
        break;
      case 'permission_error':
        print('   • Your account may not have Realtime API access');
        print('   • Contact OpenAI support or check billing status');
        break;
      case 'rate_limit_error':
        print('   • Request frequency too high, please retry later');
        print('   • Consider increasing request intervals');
        break;
      case 'server_error':
        print('   • OpenAI server issue, please retry later');
        print('   • If problem persists, contact OpenAI support');
        break;
      default:
        print('   • Unknown error type: $errorType');
        break;
    }
  }
  
  // Provide advice based on error code
  if (errorCode != null) {
    switch (errorCode) {
      case 'invalid_audio_format':
        print('   • Invalid audio format, ensure using PCM 16-bit, 24kHz, mono');
        break;
      case 'audio_too_long':
        print('   • Audio data too long, send in chunks or reduce length');
        break;
      case 'session_expired':
        print('   • Session expired, please reconnect');
        break;
      default:
        if (errorCode.isNotEmpty) {
          print('   • Error code: $errorCode');
        }
        break;
    }
  }
  
  // Provide advice based on error message
  if (errorMessage != null) {
    final lowerMessage = errorMessage.toLowerCase();
    if (lowerMessage.contains('transcription')) {
      print('   • Transcription-related error, check audio quality and format');
    } else if (lowerMessage.contains('audio')) {
      print('   • Audio-related error, check audio data and format');
    } else if (lowerMessage.contains('base64')) {
      print('   • Base64 encoding error, check audio data encoding');
    }
  }
}

/// Save AI audio transcription result to file
Future<void> _saveAITranscript(String transcript, String responseId) async {
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'ai_transcript_${_responseCounter}_$timestamp.txt';
    
    // Ensure output directory exists
    final outputDir = Directory('ai_response');
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    
    final content = '''AI Audio Transcription Result
Response ID: $responseId
Transcription Time: ${DateTime.now().toIso8601String()}
Transcription Content: $transcript

''';
    
    final file = File('ai_response/$filename');
    await file.writeAsString(content, mode: FileMode.write);
    
    print('💾 AI audio transcription saved to file: ${file.path}');
  } catch (e) {
    print('❌ Failed to save AI audio transcription: $e');
  }
}

/// Create WAV file with proper header structure
Future<void> _createWavFile(Uint8List pcmData, String filename) async {
  final dataSize = pcmData.length;
  final fileSize = 36 + dataSize;
  
  final wavHeader = ByteData(44);
  
  // RIFF header
  wavHeader.setUint8(0, 0x52); // 'R'
  wavHeader.setUint8(1, 0x49); // 'I'
  wavHeader.setUint8(2, 0x46); // 'F'
  wavHeader.setUint8(3, 0x46); // 'F'
  wavHeader.setUint32(4, fileSize, Endian.little);
  
  // WAVE format
  wavHeader.setUint8(8, 0x57);  // 'W'
  wavHeader.setUint8(9, 0x41);  // 'A'
  wavHeader.setUint8(10, 0x56); // 'V'
  wavHeader.setUint8(11, 0x45); // 'E'
  
  // fmt subchunk
  wavHeader.setUint8(12, 0x66); // 'f'
  wavHeader.setUint8(13, 0x6D); // 'm'
  wavHeader.setUint8(14, 0x74); // 't'
  wavHeader.setUint8(15, 0x20); // ' '
  wavHeader.setUint32(16, 16, Endian.little); // subchunk1 size
  wavHeader.setUint16(20, 1, Endian.little);  // audio format (PCM)
  wavHeader.setUint16(22, RealtimeConfig.channels, Endian.little);
  wavHeader.setUint32(24, RealtimeConfig.sampleRate, Endian.little);
  wavHeader.setUint32(28, RealtimeConfig.sampleRate * RealtimeConfig.channels * RealtimeConfig.bitsPerSample ~/ 8, Endian.little); // byte rate
  wavHeader.setUint16(32, RealtimeConfig.channels * RealtimeConfig.bitsPerSample ~/ 8, Endian.little); // block align
  wavHeader.setUint16(34, RealtimeConfig.bitsPerSample, Endian.little);
  
  // data subchunk
  wavHeader.setUint8(36, 0x64); // 'd'
  wavHeader.setUint8(37, 0x61); // 'a'
  wavHeader.setUint8(38, 0x74); // 't'
  wavHeader.setUint8(39, 0x61); // 'a'
  wavHeader.setUint32(40, dataSize, Endian.little);
  
  // Ensure output directory exists
  final outputDir = Directory('ai_response');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }
  
  // Combine header and data
  final wavFile = File('${outputDir.path}/$filename');
  final wavData = Uint8List(44 + dataSize);
  wavData.setRange(0, 44, wavHeader.buffer.asUint8List());
  wavData.setRange(44, 44 + dataSize, pcmData);
  
  await wavFile.writeAsBytes(wavData);
  print('💾 Audio response saved as WAV format: ${wavFile.path}');
  print('   Format: ${RealtimeConfig.sampleRate}Hz, ${RealtimeConfig.bitsPerSample}bit, ${RealtimeConfig.channels == 1 ? 'mono' : 'stereo'}');
}

/// Demonstrate Base64 audio functionality
Future<void> _demonstrateBase64Audio(OpenAIRealtime realtime) async {
  print('\n=== Base64 Audio Input Functionality Demo ===');
  
  // Example 1: Send complete audio file
  await _demonstrateCompleteAudioFile(realtime);
  
  // // Example 2: Send audio in chunks
  // await _demonstrateChunkedAudio(realtime);
}

/// Example 1: Send complete audio file
Future<void> _demonstrateCompleteAudioFile(OpenAIRealtime realtime) async {
  print('\n📋 Example 1: Send complete base64 audio message');
  
  try {
    // Find audio files
    String? audioFilePath;
    for (final path in RealtimeConfig.audioFiles) {
      final file = File(path);
      if (await file.exists()) {
        audioFilePath = path;
        break;
      }
    }
    
    if (audioFilePath != null) {
      print('✅ Audio file found: $audioFilePath');
      
      // Load and send audio
      final audioBytes = await _loadAudioFile(audioFilePath);
      await _sendAudioData(realtime, audioBytes);
      
      print('✅ Complete audio file sent successfully');
    } else {
      print('⚠️ No audio file found, skipping this example');
    }
    
  } catch (e) {
    print('❌ Failed to send complete audio file: $e');
  }
}

/// Example 2: Send audio in chunks
Future<void> _demonstrateChunkedAudio(OpenAIRealtime realtime) async {
  print('\n📋 Example 2: Send audio data in chunks');
  
  try {
    final testFile = File('voice.pcm');
    if (await testFile.exists()) {
      final audioBytes = await testFile.readAsBytes();
      
      // Send in chunks
      final totalChunks = (audioBytes.length / RealtimeConfig.chunkSize).ceil();
      
      print('Starting chunked audio transmission ($totalChunks chunks)...');
      
      for (int i = 0; i < totalChunks; i++) {
        final start = i * RealtimeConfig.chunkSize;
        final end = math.min(start + RealtimeConfig.chunkSize, audioBytes.length);
        final chunk = audioBytes.sublist(start, end);
        
        await realtime.sendAudioData(audioData: chunk);
        print('Sent chunk ${i + 1}/$totalChunks');
        
        // Brief delay
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Commit audio buffer
      await realtime.commitAudioBuffer();
      print('✅ Chunked audio transmission completed');
      
    } else {
      print('⚠️ Skipping chunked transmission example (no audio file)');
    }
  } catch (e) {
    print('❌ Failed chunked audio transmission: $e');
  }
}

/// Load audio file from disk
Future<Uint8List> _loadAudioFile(String filePath) async {
  print('📁 Loading audio file: $filePath');
  
  final file = File(filePath);
  final audioBytes = await file.readAsBytes();
  
  print('✅ File loaded successfully, size: ${audioBytes.length} bytes');
  
  // Validate audio format
  _validateAudioFormat(audioBytes);
  
  return audioBytes;
}

/// Send audio data to the realtime API
Future<void> _sendAudioData(OpenAIRealtime realtime, Uint8List audioBytes) async {
  print('📤 Sending audio data...');
  
  try {
    // Use SDK's sendAudioData method
    await realtime.sendAudioData(audioData: audioBytes);
    
    // Commit audio buffer
    await realtime.commitAudioBuffer();
    
    // Trigger response generation with tool usage
    await realtime.createResponse(
      instructions: '',
      tools: [
        {
          'type': 'function',
          'name': 'get_weather',
          'description': 'Get weather information for a specified city',
          'parameters': {
            'type': 'object',
            'properties': {
              'city': {
                'type': 'string',
                'description': 'City name',
              },
            },
            'required': ['city'],
          },
        },
      ],
      toolChoice: 'auto', // Allow automatic tool usage
      modalities: [OpenAIRealtimeModalityModel.text, OpenAIRealtimeModalityModel.audio],
    );
    
    print('✅ Audio data sent successfully');
    
  } catch (e) {
    print('❌ Failed to send audio data: $e');
    rethrow;
  }
}

/// Validate audio format and provide feedback
void _validateAudioFormat(Uint8List audioBytes) {
  if (audioBytes.length < 1000) {
    print('⚠️ Audio data too short, may not be a valid audio file');
    return;
  }
  
  // Check WAV file header
  if (audioBytes.length >= 4) {
    final riffHeader = String.fromCharCodes(audioBytes.take(4));
    if (riffHeader == 'RIFF') {
      print('✅ WAV format file detected');
      return;
    }
  }
  
  print('📋 Possible PCM format file detected');
}