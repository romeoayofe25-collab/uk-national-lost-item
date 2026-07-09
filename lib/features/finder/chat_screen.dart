import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import '../../core/services/auth_provider.dart';

class FinderChatScreen extends StatefulWidget {
  final String foundItemId;

  const FinderChatScreen({super.key, required this.foundItemId});

  @override
  State<FinderChatScreen> createState() => _FinderChatScreenState();
}

class _FinderChatScreenState extends State<FinderChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    _messageController.clear();

    final itemsService = Provider.of<ItemsService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    final success = await itemsService.sendFoundItemSupportMessage(
      foundItemId: widget.foundItemId,
      senderId: user?.uid ?? 'finder_uid',
      senderName: user?.displayName ?? 'Marcus',
      senderRole: 'finder',
      text: text,
    );

    setState(() => _sending = false);

    if (success) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final item = itemsService.getFoundItemById(widget.foundItemId);
    final isPaused = itemsService.isChatPaused(widget.foundItemId);


    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Support Chat')),
        body: const Center(child: Text('Item not found', style: TextStyle(color: Colors.white))),
      );
    }

    // Scroll to bottom when build completes
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Support: ${item.title}'),
            const Text(
              'Restricted to Admin & Intermediary Support',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0F101A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Privacy and Redaction Scrub Warning (Rule 10 & 13)
              Container(
                padding: const EdgeInsets.all(12),
                color: AppColors.surface,
                child: const Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PII Shield Active: Direct owner-finder communication is disabled. Messages are filtered for emails, phone numbers, and payment details to protect user privacy (Rules 10 & 13).',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: item.messages.length,
                  itemBuilder: (context, idx) {
                    final message = item.messages[idx];
                    final isMe = message.senderRole == 'finder';
                    final isSystem = message.senderRole == 'system';

                    if (isSystem) {
                      return _buildSystemMessage(message);
                    }

                    return _buildMessageBubble(message, isMe);
                  },
                ),
              ),

              // Chat Input Row
              if (isPaused)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pause_circle_filled, color: AppColors.warning, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'This chat has been paused by the Administrator.',
                        style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                              )
                            : const Icon(Icons.send, color: AppColors.primary),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemMessage(dynamic msg) {
    final isScrubNotice = msg.text.contains('Warning') || msg.text.contains('redacted');
    final color = isScrubNotice ? AppColors.warning : AppColors.primary;
    final icon = isScrubNotice ? Icons.shield_outlined : Icons.info_outline;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg.text,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe) {
    final bubbleColor = isMe ? AppColors.primary : AppColors.surface;
    final textColor = Colors.white;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleRadius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Sender Name Metadata
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            isMe ? 'You' : '${msg.senderName} (${msg.senderRole.toUpperCase()})',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ),
        
        // Bubble itself
        Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: bubbleRadius,
            border: isMe ? null : Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}
