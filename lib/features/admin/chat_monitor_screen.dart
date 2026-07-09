import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import '../../core/models/lost_item_model.dart';

class AdminChatMonitorScreen extends StatefulWidget {
  const AdminChatMonitorScreen({super.key});

  @override
  State<AdminChatMonitorScreen> createState() => _AdminChatMonitorScreenState();
}

class _AdminChatMonitorScreenState extends State<AdminChatMonitorScreen> {
  void _togglePause(ItemsService itemsService, String itemId, bool currentlyPaused) async {
    final success = await itemsService.adminToggleChatStatus(itemId: itemId, isPaused: !currentlyPaused);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentlyPaused ? 'Chat resumed.' : 'Chat paused.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _terminateChat(ItemsService itemsService, String itemId) async {
    final success = await itemsService.sendSupportMessage(
      itemId: itemId,
      senderId: 'system',
      senderName: 'System Alert',
      senderRole: 'system',
      text: 'This chat channel has been terminated by the Administrator.',
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat channel terminated successfully.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showMonitorSheet(BuildContext context, LostItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<ItemsService>(
              builder: (context, itemsService, child) {
                final liveItem = itemsService.getItemById(item.id);
                if (liveItem == null) return const Center(child: Text('Chat not found'));
                final isPaused = itemsService.isChatPaused(liveItem.id);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handlebar / Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'SUPERVISING: Case #${liveItem.id.hashCode.toString().substring(0, 4)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warning),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            liveItem.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Admin Actions Control Panel
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPaused ? AppColors.success : AppColors.warning,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                              label: Text(isPaused ? 'RESUME' : 'PAUSE'),
                              onPressed: () => _togglePause(itemsService, liveItem.id, isPaused),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.stop),
                              label: const Text('TERMINATE'),
                              onPressed: () {
                                _terminateChat(itemsService, liveItem.id);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Transcripts List
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: liveItem.messages.length,
                        itemBuilder: (context, idx) {
                          final msg = liveItem.messages[idx];
                          final isSystem = msg.senderRole == 'system';

                          if (isSystem) {
                            return Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  msg.text,
                                  style: const TextStyle(color: AppColors.warning, fontSize: 11),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${msg.senderName} (${msg.senderRole.toUpperCase()})',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    msg.text,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final activeCases = itemsService.items.where((item) => item.messages.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervised Chat Monitor'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0F101A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: activeCases.length,
          itemBuilder: (context, index) {
            final item = activeCases[index];
            final isPaused = itemsService.isChatPaused(item.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  isPaused ? Icons.pause_circle_filled : Icons.chat_bubble_outline,
                  color: isPaused ? AppColors.warning : AppColors.primary,
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text(
                  'Case ID: #${item.id.hashCode.toString().substring(0, 4)} • Messages: ${item.messages.length}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                onTap: () => _showMonitorSheet(context, item),
              ),
            );
          },
        ),
      ),
    );
  }
}
