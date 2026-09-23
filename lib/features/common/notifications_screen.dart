import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import '../../core/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final allNotifs = itemsService.notifications;
    final unreadCount = itemsService.unreadNotificationsCount;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Audit Activity Feed'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              icon: const Icon(Icons.done_all, size: 16, color: AppColors.secondary),
              label: const Text(
                'Mark All Read',
                style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              onPressed: () => itemsService.markAllNotificationsAsRead(),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Claims & Custody'),
            Tab(text: 'Rewards'),
            Tab(text: 'Security'),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationList(itemsService, allNotifs),
            _buildNotificationList(
              itemsService,
              allNotifs.where((n) => n.category == 'claims' || n.category == 'custody').toList(),
            ),
            _buildNotificationList(
              itemsService,
              allNotifs.where((n) => n.category == 'rewards').toList(),
            ),
            _buildNotificationList(
              itemsService,
              allNotifs.where((n) => n.category == 'security').toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(ItemsService service, List<AppNotification> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_off_outlined, color: AppColors.textSecondary, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'You are all caught up on all recovery events.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final notif = list[index];
        return _buildNotificationCard(service, notif);
      },
    );
  }

  Widget _buildNotificationCard(ItemsService service, AppNotification notif) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case 'rewardAssessed':
      case 'escrowReleased':
        icon = Icons.payments_outlined;
        iconColor = Colors.amberAccent;
        break;
      case 'biometricVerified':
        icon = Icons.verified_user_outlined;
        iconColor = AppColors.success;
        break;
      case 'custodyDeposited':
        icon = Icons.meeting_room_outlined;
        iconColor = Colors.lightBlueAccent;
        break;
      case 'voucherReady':
        icon = Icons.qr_code_2_outlined;
        iconColor = AppColors.secondary;
        break;
      case 'securityAlert':
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.danger;
        break;
      case 'matchFound':
        icon = Icons.find_in_page_outlined;
        iconColor = AppColors.primary;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = AppColors.textSecondary;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        service.removeNotification(notif.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification removed.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: notif.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.4),
            width: notif.isRead ? 1 : 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            service.markNotificationAsRead(notif.id);
            if (notif.actionRoute != null) {
              context.push(notif.actionRoute!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (!notif.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notif.message,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: notif.isRead ? 0.65 : 0.85),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Footer Row: Item Tag, Timestamp & Action CTA
                      Row(
                        children: [
                          if (notif.relatedItemTitle != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${notif.relatedItemTitle}',
                                style: const TextStyle(fontSize: 10.5, color: AppColors.secondary, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _formatTimestamp(notif.timestamp),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          if (notif.actionRoute != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _actionLabel(notif.type),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.chevron_right, size: 14, color: AppColors.secondary),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _actionLabel(String type) {
    switch (type) {
      case 'voucherReady':
        return 'VIEW VOUCHER';
      case 'rewardAssessed':
      case 'escrowReleased':
        return 'VIEW ESCROW';
      case 'securityAlert':
        return 'VIEW INCIDENT';
      default:
        return 'VIEW CASE';
    }
  }
}
