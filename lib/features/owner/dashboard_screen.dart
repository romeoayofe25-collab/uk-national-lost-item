import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/items_service.dart';
import '../../core/models/lost_item_model.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final itemsService = Provider.of<ItemsService>(context);
    final user = authProvider.currentUser;
    final allItems = itemsService.items;

    // Filter items with active matches requiring action
    final matchFoundItems = allItems.where((i) => i.status == 'matchFound').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UK National Lost-Item'),
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
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.textPrimary),
            tooltip: 'Profile & Privacy',
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: _buildBody(context, user, allItems, matchFoundItems),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Public',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Messages',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/owner/report'),
              icon: const Icon(Icons.add),
              label: const Text('Report Lost Item'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, dynamic user, List<LostItem> allItems, List<LostItem> matchFoundItems) {
    if (_currentIndex == 1) {
      return _buildSearchTab(context);
    }
    if (_currentIndex == 2) {
      return _buildMessagesTab(context, allItems);
    }
    return _buildHomeTab(context, user, allItems, matchFoundItems);
  }

  Widget _buildHomeTab(BuildContext context, dynamic user, List<LostItem> allItems, List<LostItem> matchFoundItems) {
    final displayName = user?.displayName ?? 'User';
    final trustScore = user?.trustScore ?? 100;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User greeting and Trust Level badge card
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.push('/profile'),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $displayName!',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 6.0),
                            Row(
                              children: [
                                const Text(
                                  'Trust Level: ',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Excellent ($trustScore Pts)',
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Action Required Banner (Conditional)
            if (matchFoundItems.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  border: const Border(
                    left: BorderSide(color: AppColors.warning, width: 4),
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.warning, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Action Required',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Potential match found for your "${matchFoundItems.first.title}". Verify ownership to proceed.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () {
                        context.go('/owner/verify/${matchFoundItems.first.id}');
                      },
                      child: const Text(
                        'Provide Proof',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
            ],

            // Map Search CTA Card
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/owner/map'),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.map, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16.0),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Partner Desks',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              'Find the nearest safe drop-off & collection counters.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            Text(
              'ACTIVE LOST ITEMS',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 12.0),

            if (allItems.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'No lost items reported yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final item = allItems[idx];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: Icon(
                          _getCategoryIcon(item.category),
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Lost: ${item.lastKnownLocation} • ${item.timeLost}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      trailing: _getStatusPill(context, item.status),
                      onTap: () {
                        context.go('/owner/details/${item.id}');
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: 80.0), // Padding for floating action button
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SEARCH FOUND REGISTRY',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search matching station or category...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Protection Notice',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To prevent fraudulent claims, exact specifications (serial numbers, key patterns, interior marks) are kept hidden from the public database. Contact info is strictly secured, and all matches must be approved by the Administration Board.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab(BuildContext context, List<LostItem> allItems) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ADMIN SUPPORT CHATS',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: allItems.isEmpty
                ? const Center(
                    child: Text('No active support cases.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    itemCount: allItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final item = allItems[idx];
                      final lastMsg = item.messages.isNotEmpty ? item.messages.last.text : 'No messages yet.';
                      return Card(
                        child: ListTile(
                          title: Text('Case regarding: ${item.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          onTap: () {
                            context.go('/owner/chat/${item.id}');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.phone_iphone;
      case 'personal accessories':
      case 'accessories':
        return Icons.wallet;
      case 'documents':
        return Icons.badge;
      case 'keys':
        return Icons.vpn_key;
      case 'clothing':
        return Icons.checkroom;
      default:
        return Icons.shopping_bag;
    }
  }

  Widget _getStatusPill(BuildContext context, String status) {
    String text = 'Searching...';
    Color color = AppColors.textSecondary;

    switch (status) {
      case 'searching':
        text = 'Searching';
        color = AppColors.textSecondary;
        break;
      case 'matchFound':
        text = 'Match Found';
        color = AppColors.warning;
        break;
      case 'underReview':
        text = 'Under Review';
        color = AppColors.warning;
        break;
      case 'readyForCollection':
        text = 'Ready';
        color = AppColors.success;
        break;
      case 'returned':
        text = 'Returned';
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
