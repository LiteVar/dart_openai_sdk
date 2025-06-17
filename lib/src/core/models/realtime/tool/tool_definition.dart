/// The tool choice modes supported by the Realtime API.
enum OpenAIRealtimeToolChoiceModeModel {
  /// No tools are called.
  none('none'),

  /// Automatically decide when to call tools.
  auto('auto'),

  /// Force a specific tool to be called.
  required('required');

  const OpenAIRealtimeToolChoiceModeModel(this.value);

  /// The string value of the tool choice mode.
  final String value;

  /// Returns the [OpenAIRealtimeToolChoiceModeModel] from the given [value].
  static OpenAIRealtimeToolChoiceModeModel fromValue(String value) {
    return values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => throw ArgumentError('Unknown tool choice mode: $value'),
    );
  }

  @override
  String toString() => value;
}

/// Tool choice configuration for the Realtime API.
class OpenAIRealtimeToolChoiceModel {
  /// The mode of tool choice.
  final OpenAIRealtimeToolChoiceModeModel? mode;

  /// The specific tool to force (when mode is 'required').
  final OpenAIRealtimeToolDefinitionModel? tool;

  /// Creates a new [OpenAIRealtimeToolChoiceModel].
  const OpenAIRealtimeToolChoiceModel({
    this.mode,
    this.tool,
  });

  /// Creates a tool choice with mode 'auto'.
  const OpenAIRealtimeToolChoiceModel.auto() : mode = OpenAIRealtimeToolChoiceModeModel.auto, tool = null;

  /// Creates a tool choice with mode 'none'.
  const OpenAIRealtimeToolChoiceModel.none() : mode = OpenAIRealtimeToolChoiceModeModel.none, tool = null;

  /// Creates a tool choice with mode 'required' for a specific tool.
  const OpenAIRealtimeToolChoiceModel.required(this.tool) : mode = OpenAIRealtimeToolChoiceModeModel.required;

  /// Creates a [OpenAIRealtimeToolChoiceModel] from a JSON value.
  factory OpenAIRealtimeToolChoiceModel.fromMap(dynamic value) {
    if (value is String) {
      return OpenAIRealtimeToolChoiceModel(
        mode: OpenAIRealtimeToolChoiceModeModel.fromValue(value),
      );
    }
    
    if (value is Map<String, dynamic>) {
      return OpenAIRealtimeToolChoiceModel(
        mode: value['mode'] != null
            ? OpenAIRealtimeToolChoiceModeModel.fromValue(value['mode'])
            : null,
        tool: value['tool'] != null
            ? OpenAIRealtimeToolDefinitionModel.fromMap(value['tool'])
            : null,
      );
    }
    
    throw ArgumentError('Invalid tool choice format: $value');
  }

  /// Converts this [OpenAIRealtimeToolChoiceModel] to a JSON value.
  dynamic toMap() {
    if (mode != null && tool == null) {
      return mode!.value;
    }
    
    return {
      if (mode != null) 'mode': mode!.value,
      if (tool != null) 'tool': tool!.toMap(),
    };
  }

  @override
  String toString() {
    return 'OpenAIRealtimeToolChoiceModel(mode: $mode, tool: $tool)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeToolChoiceModel &&
        other.mode == mode &&
        other.tool == tool;
  }

  @override
  int get hashCode => Object.hash(mode, tool);
}

/// Tool definition for the Realtime API.
class OpenAIRealtimeToolDefinitionModel {
  /// The type of the tool (always 'function').
  final String type;

  /// The name of the function.
  final String name;

  /// The description of the function.
  final String? description;

  /// The parameters of the function.
  final Map<String, dynamic>? parameters;

  /// Creates a new [OpenAIRealtimeToolDefinitionModel].
  const OpenAIRealtimeToolDefinitionModel({
    this.type = 'function',
    required this.name,
    this.description,
    this.parameters,
  });

  /// Creates a [OpenAIRealtimeToolDefinitionModel] from a JSON map.
  factory OpenAIRealtimeToolDefinitionModel.fromMap(Map<String, dynamic> map) {
    return OpenAIRealtimeToolDefinitionModel(
      type: map['type'] ?? 'function',
      name: map['name'],
      description: map['description'],
      parameters: map['parameters'],
    );
  }

  /// Converts this [OpenAIRealtimeToolDefinitionModel] to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      if (description != null) 'description': description,
      if (parameters != null) 'parameters': parameters,
    };
  }

  @override
  String toString() {
    return 'OpenAIRealtimeToolDefinitionModel(type: $type, name: $name, description: $description, parameters: $parameters)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIRealtimeToolDefinitionModel &&
        other.type == type &&
        other.name == name &&
        other.description == description &&
        other.parameters == parameters;
  }

  @override
  int get hashCode => Object.hash(type, name, description, parameters);
} 