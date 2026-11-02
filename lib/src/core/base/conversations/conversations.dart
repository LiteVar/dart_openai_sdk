import 'package:http/http.dart' as http;

import '../../models/conversation/conversation.dart';
import '../../models/conversation/conversation_items_response.dart';

/// Contract for the Conversations API, bound to one configured client.
abstract class OpenAIConversationsBase {
  String get endpoint;

  Future<OpenAIConversation> create({
    List? items,
    Map<String, dynamic>? metadata,
    http.Client? client,
  });

  Future<OpenAIConversation> get({
    required String conversationId,
    http.Client? client,
  });

  Future<OpenAIConversation> update({
    required String conversationId,
    required Map<String, dynamic> metadata,
    http.Client? client,
  });

  Future<void> delete({
    required String conversationId,
    http.Client? client,
  });

  Future<OpenAIConversationItemsResponse> listItems({
    required String conversationId,
    int? limit,
    String? order,
    String? after,
    List<String>? include,
    http.Client? client,
  });

  Future<OpenAIConversationItemsResponse> createItems({
    required String conversationId,
    required List<Map<String, dynamic>> items,
    List<String>? include,
    http.Client? client,
  });

  Future<Map<String, dynamic>> getItem({
    required String conversationId,
    required String itemId,
    List<String>? include,
    http.Client? client,
  });

  Future<void> deleteItem({
    required String conversationId,
    required String itemId,
    http.Client? client,
  });
}
