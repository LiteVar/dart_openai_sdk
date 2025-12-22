import 'package:meta/meta.dart';

/// 流式转写事件类型
enum OpenAITranscriptionStreamEventType {
  /// 增量文本事件
  transcriptTextDelta,
  /// 转写完成事件
  transcriptTextDone,
}

/// {@template openai_transcription_stream_event}
/// 流式转写事件模型，用于表示流式 STT 返回的事件
/// {@endtemplate}
@immutable
final class OpenAITranscriptionStreamEvent {
  /// 事件类型
  final OpenAITranscriptionStreamEventType type;
  
  /// 增量文本（仅在 delta 事件中有值）
  final String? delta;
  
  /// 完整文本（仅在 done 事件中有值）
  final String? text;
  
  /// 对数概率（可选）
  final List<double>? logprobs;

  /// {@macro openai_transcription_stream_event}
  const OpenAITranscriptionStreamEvent({
    required this.type,
    this.delta,
    this.text,
    this.logprobs,
  });

  /// 从 SSE 事件数据创建事件对象
  factory OpenAITranscriptionStreamEvent.fromMap(Map<String, dynamic> map) {
    final eventType = map['type'] as String?;
    
    OpenAITranscriptionStreamEventType type;
    if (eventType == 'transcript.text.delta') {
      type = OpenAITranscriptionStreamEventType.transcriptTextDelta;
    } else if (eventType == 'transcript.text.done') {
      type = OpenAITranscriptionStreamEventType.transcriptTextDone;
    } else {
      // 默认为 delta 类型
      type = OpenAITranscriptionStreamEventType.transcriptTextDelta;
    }

    return OpenAITranscriptionStreamEvent(
      type: type,
      delta: map['delta'] as String?,
      text: map['text'] as String?,
      logprobs: map['logprobs'] != null 
          ? List<double>.from(map['logprobs']) 
          : null,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'type': type == OpenAITranscriptionStreamEventType.transcriptTextDelta 
          ? 'transcript.text.delta' 
          : 'transcript.text.done',
      if (delta != null) 'delta': delta,
      if (text != null) 'text': text,
      if (logprobs != null) 'logprobs': logprobs,
    };
  }

  @override
  String toString() {
    return 'OpenAITranscriptionStreamEvent(type: $type, delta: $delta, text: $text, logprobs: $logprobs)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAITranscriptionStreamEvent &&
        other.type == type &&
        other.delta == delta &&
        other.text == text;
  }

  @override
  int get hashCode => Object.hash(type, delta, text);
}
