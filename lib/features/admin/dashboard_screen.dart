import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/items_service.dart';
import '../../core/services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Dynamic metrics
    final underReviewClaims = itemsService.items
        .where((item) => item.status == 'underReview')
        .toList();

    final activeChatsCount = itemsService.items
        .where((item) => item.messages.isNotEmpty)
        .length;

    final suspendedUsersCount = AuthService.mockUsersList
        .where((u) => u.isSuspended)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UK National Lost-Item Admin Console'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: itemsService.unreadNotificationsCount > 0,
              label: Text('${itemsService.unreadNotificationsCount}'),
              child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            ),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0F101A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dashboard header
              Text(
                'SYSTEM QUEUES & STATUS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12.0),

              // Grid counter indicators
              Row(
                children: [
                  // Match Under Review Counter
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              '${underReviewClaims.length}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.warning,
                                fontSize: 26,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Under Review', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Chat Monitor Counter
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              '$activeChatsCount',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontSize: 26,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Active Chats', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Suspended Accounts Counter
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              '$suspendedUsersCount',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.danger,
                                fontSize: 26,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Suspensions', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Quick Action Navigation Panel
              Text(
                'ADMINISTRATIVE CONTROL PANELS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12.0),
              
              Row(
                children: [
                  Expanded(
                    child: _buildPanelButton(
                      context,
                      title: 'Disputes & Fraud',
                      subtitle: 'Bans & Suspensions',
                      icon: Icons.gavel,
                      color: AppColors.danger,
                      route: '/admin/disputes',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPanelButton(
                      context,
                      title: 'Supervised Chats',
                      subtitle: 'Pause & Terminate',
                      icon: Icons.supervisor_account,
                      color: AppColors.primary,
                      route: '/admin/chats',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPanelButton(
                      context,
                      title: 'Drop-off Centres',
                      subtitle: 'Authorize & Monitor',
                      icon: Icons.store,
                      color: AppColors.success,
                      route: '/admin/centres',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Dynamic Claims Review List
              Text(
                'PENDING CLAIMS VERIFICATION REVIEW',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12.0),

              if (underReviewClaims.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      'No claims currently pending verification.',
                      style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: underReviewClaims.length,
                  itemBuilder: (context, index) {
                    final item = underReviewClaims[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.verified_user, color: AppColors.warning),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Text(
                          'Owner: Sarah Jenkins • Claim ID: #${item.id.hashCode.toString().substring(0, 4)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'REVIEW',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          context.push('/admin/claims/${item.id}');
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
