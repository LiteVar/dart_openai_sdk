import '../entity/interfaces/enpoint.dart';
import 'interfaces/connect.dart';
import 'interfaces/session.dart';
import 'interfaces/conversation.dart';
import 'interfaces/tool.dart';

/// Base class for the Realtime module, defining all realtime-related interfaces
abstract class OpenAIRealtimeBase implements 
  ConnectInterface, 
  SessionInterface, 
  ConversationInterface, 
  ToolInterface, 
  EndpointInterface {
} 