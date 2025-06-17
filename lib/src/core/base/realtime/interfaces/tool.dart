import 'dart:async';
import '../../../models/realtime/tool/tool_definition.dart';

/// Tool processing function type definition
typedef ToolHandler = Future<String> Function(Map<String, dynamic> arguments);

/// Tool calling interface, defining tool-related operations for the realtime module
abstract class ToolInterface {
  /// Add tool
  ///
  /// [tool] Tool definition
  /// [handler] Tool processing function
  void addTool({
    required OpenAIRealtimeToolDefinitionModel tool,
    required ToolHandler handler,
  });

  /// Remove tool
  ///
  /// [name] Tool name
  void removeTool(String name);

  /// Get all registered tools
  ///
  /// Returns a map of tool names to tool definitions
  Map<String, OpenAIRealtimeToolDefinitionModel> get tools;

  /// Check if tool exists
  ///
  /// [name] Tool name
  /// Returns true if tool exists, otherwise returns false
  bool hasTool(String name);

  /// Call tool
  ///
  /// [name] Tool name
  /// [arguments] Tool arguments
  /// Returns tool execution result
  Future<String> callTool({
    required String name,
    required Map<String, dynamic> arguments,
  });
} 