import 'package:http/http.dart' as http;

import '../../core/base/conversations/conversations.dart';
import '../../core/builder/context_api_url.dart';
import '../../core/config/client_config.dart';
import '../../core/constants/strings.dart';
import '../../core/models/conversation/conversation.dart';
import '../../core/models/conversation/conversation_items_response.dart';
import '../../core/networking/context_client.dart';

/// Conversations API methods bound to one [OpenAIClientConfig].
class ContextualOpenAIConversations extends OpenAIConversationsBase {
  final OpenAIClientConfig config;

  @override
  String get endpoint => OpenAIStrings.endpoints.conversations;

  ContextualOpenAIConversations(this.config);

  @override
  Future<OpenAIConversation> create({
    List? items,
    Map<String, dynamic>? metadata,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIConversation>(
        to: ContextualApiUrlBuilder.build(config, endpoint),
        body: {
          if (items != null) 'items': items,
          if (metadata != null) 'metadata': metadata,
        },
        onSuccess: OpenAIConversation.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIConversation> get({
    required String conversationId,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<OpenAIConversation>(
        from: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(conversationId),
        ),
        onSuccess: OpenAIConversation.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<OpenAIConversation> update({
    required String conversationId,
    required Map<String, dynamic> metadata,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIConversation>(
        to: ContextualApiUrlBuilder.build(
          config,
          endpoint,
          Uri.encodeComponent(conversationId),
        ),
        body: {'metadata': metadata},
        onSuccess: OpenAIConversation.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<void> delete({
    required String conversationId,
    http.Client? client,
  }) async {
    await ContextualNetworkingClient.deleteChecked<bool>(
      from: ContextualApiUrlBuilder.build(
        config,
        endpoint,
        Uri.encodeComponent(conversationId),
      ),
      onSuccess: (response) => response['deleted'] == true,
      config: config,
      client: client,
    );
  }

  @override
  Future<OpenAIConversationItemsResponse> listItems({
    required String conversationId,
    int? limit,
    String? order,
    String? after,
    List<String>? include,
    http.Client? client,
  }) {
    final query = <String, String>{
      if (limit != null) 'limit': limit.toString(),
      if (order != null) 'order': order,
      if (after != null) 'after': after,
      if (include != null) 'include': include.join(','),
    };
    return ContextualNetworkingClient.getChecked<
        OpenAIConversationItemsResponse>(
      from: _urlWithQuery(
        ContextualApiUrlBuilder.build(
          config,
          endpoint,
          '${Uri.encodeComponent(conversationId)}/items',
        ),
        query,
      ),
      onSuccess: OpenAIConversationItemsResponse.fromMap,
      config: config,
      client: client,
    );
  }

  @override
  Future<OpenAIConversationItemsResponse> createItems({
    required String conversationId,
    required List<Map<String, dynamic>> items,
    List<String>? include,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.postChecked<OpenAIConversationItemsResponse>(
        to: _urlWithQuery(
          ContextualApiUrlBuilder.build(
            config,
            endpoint,
            '${Uri.encodeComponent(conversationId)}/items',
          ),
          {if (include != null) 'include': include.join(',')},
        ),
        body: {'items': items},
        onSuccess: OpenAIConversationItemsResponse.fromMap,
        config: config,
        client: client,
      );

  @override
  Future<Map<String, dynamic>> getItem({
    required String conversationId,
    required String itemId,
    List<String>? include,
    http.Client? client,
  }) =>
      ContextualNetworkingClient.getChecked<Map<String, dynamic>>(
        from: _urlWithQuery(
          ContextualApiUrlBuilder.build(
            config,
            endpoint,
            '${Uri.encodeComponent(conversationId)}/items/${Uri.encodeComponent(itemId)}',
          ),
          {if (include != null) 'include': include.join(',')},
        ),
        onSuccess: (response) => response,
        config: config,
        client: client,
      );

  @override
  Future<void> deleteItem({
    required String conversationId,
    required String itemId,
    http.Client? client,
  }) async {
    await ContextualNetworkingClient.deleteChecked<bool>(
      from: ContextualApiUrlBuilder.build(
        config,
        endpoint,
        '${Uri.encodeComponent(conversationId)}/items/${Uri.encodeComponent(itemId)}',
      ),
      onSuccess: (_) => true,
      config: config,
      client: client,
    );
  }

  String _urlWithQuery(String url, Map<String, String> query) => query.isEmpty
      ? url
      : Uri.parse(url).replace(queryParameters: query).toString();
}
