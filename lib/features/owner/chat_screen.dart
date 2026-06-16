import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/items_service.dart';
import '../../core/models/lost_item_model.dart';

class OwnerAdminChatScreen extends StatefulWidget {
  final String itemId;

  const OwnerAdminChatScreen({super.key, required this.itemId});

  @override
  State<OwnerAdminChatScreen> createState() => _OwnerAdminChatScreenState();
}

class _OwnerAdminChatScreenState extends State<OwnerAdminChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final itemsService = Provider.of<ItemsService>(context, listen: false);

    _messageController.clear();

    final success = await itemsService.sendSupportMessage(
      itemId: widget.itemId,
      senderId: authProvider.currentUser?.uid ?? 'mock_user',
      senderName: authProvider.currentUser?.displayName ?? 'Sarah Jenkins',
      senderRole: 'owner',
      text: text,
    );

    if (success) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final itemsService = Provider.of<ItemsService>(context);
    final item = itemsService.getItemById(widget.itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Support')),
        body: const Center(child: Text('Support Case not found.')),
      );
    }

    final isClosed = item.status == 'returned';

    // Trigger scroll to bottom on load
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Support: Case #${item.id.hashCode.toString().substring(0, 4)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Regarding: ${item.title}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/owner/details/${item.id}'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Security persistent warning banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                border: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.security, color: AppColors.primary, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Monitored Support Channel: Sharing telephone numbers, email addresses, or payment card details is restricted to protect your safety and privacy.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            // Message list thread
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: item.messages.length,
                itemBuilder: (context, index) {
                  final msg = item.messages[index];
                  return _buildMessageBubble(context, msg, authProvider.currentUser?.uid);
                },
              ),
            ),

            // Input bar / Closed message banner
            if (isClosed)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.archive, color: AppColors.textSecondary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'This support channel has been closed & archived.',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          filled: false,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primary),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg, String? currentUserId) {
    final isMe = msg.senderRole == 'owner';
    final isSystem = msg.senderRole == 'system';

    if (isSystem) {
      final isWarning = msg.text.contains('Warning') || msg.text.contains('redacted');
      final accentColor = isWarning ? AppColors.warning : AppColors.textSecondary;
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
          ),
          child: Text(
            msg.text,
            style: TextStyle(color: accentColor, fontSize: 12, height: 1.3),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? AppColors.primary : AppColors.surface;
    final textColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Name and timestamp
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isMe ? 'You' : msg.senderName,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Text(
                '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Bubble text container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: isMe ? null : Border.all(color: AppColors.border),
            ),
            child: Text(
              msg.text,
              style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
