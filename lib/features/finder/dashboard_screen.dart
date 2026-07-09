import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import '../../core/services/auth_provider.dart';

class FinderDashboardScreen extends StatelessWidget {
  const FinderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Calculate wallet balances dynamically
    final double availableBalance = itemsService.claims
        .where((tx) => tx.status == 'available')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final double pendingEscrow = itemsService.claims
        .where((tx) => tx.status == 'pending')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    // Check if there is any found item held by the finder requiring drop-off action
    final pendingDropOffs = itemsService.foundItems
        .where((item) => item.status == 'heldByFinder' || item.status == 'awaitingDeposit')
        .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0F101A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'UK National Lost-Item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                        onPressed: () {
                          authProvider.signOut();
                          context.go('/');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Profile / Trust Badge Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person_pin, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${user?.displayName ?? 'Marcus'}!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  const Text(
                                    'Trust Score: ',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Very Reliable (95 Pts)',
                                      style: TextStyle(
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
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

              // Simulated Platform Wallet Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'SIMULATED PLATFORM WALLET',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '£${availableBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Available Balance',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 45, color: AppColors.border),
                            Column(
                              children: [
                                Text(
                                  '£${pendingEscrow.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Pending Escrow',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 8.0),
                        TextButton.icon(
                          onPressed: () => context.push('/finder/claims'),
                          icon: const Icon(Icons.wallet, color: AppColors.primary),
                          label: const Text(
                            'View Wallet & Claims History',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16.0)),

              // Action Required Banners (Pending Drop-offs)
              if (pendingDropOffs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Action Required',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pendingDropOffs.first.status == 'awaitingDeposit'
                                ? 'Please complete the physical handover of "${pendingDropOffs.first.title}" at ${pendingDropOffs.first.dropOffCentreName ?? 'the Intermediary Centre'} and present your secure deposit PIN.'
                                : 'Please drop off the "${pendingDropOffs.first.title}" at a verified Intermediary Centre to generate your receipt voucher and activate the claim.',
                            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            icon: Icon(pendingDropOffs.first.status == 'awaitingDeposit' ? Icons.qr_code : Icons.location_on, size: 18),
                            label: Text(
                              pendingDropOffs.first.status == 'awaitingDeposit' ? 'View Deposit Voucher' : 'Select Drop-off Centre',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => context.push('/finder/dropoff/${pendingDropOffs.first.id}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Title Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'YOUR FOUND ITEM REPORTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              // Empty State
              if (itemsService.foundItems.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                    child: Center(
                      child: Text(
                        'You have not reported any found items yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                )
              else
                // Found Items Cards List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, idx) {
                      final item = itemsService.foundItems[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _statusColor(item.status).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _categoryIcon(item.category),
                                      color: _statusColor(item.status),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Found at: ${item.locationFound}',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Date: ${item.dateFound.day}/${item.dateFound.month}/${item.dateFound.year}',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(item.status).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _statusText(item.status),
                                      style: TextStyle(
                                        color: _statusColor(item.status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: AppColors.border, height: 1),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.monetization_on, color: AppColors.success, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Reward: £${item.rewardAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (item.status == 'heldByFinder')
                                        TextButton.icon(
                                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                          icon: const Icon(Icons.location_on, size: 16, color: AppColors.warning),
                                          label: const Text('Drop Off', style: TextStyle(color: AppColors.warning, fontSize: 13)),
                                          onPressed: () => context.push('/finder/dropoff/${item.id}'),
                                        )
                                      else if (item.status == 'awaitingDeposit')
                                        TextButton.icon(
                                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                          icon: const Icon(Icons.qr_code, size: 16, color: AppColors.warning),
                                          label: const Text('Voucher', style: TextStyle(color: AppColors.warning, fontSize: 13)),
                                          onPressed: () => context.push('/finder/dropoff/${item.id}'),
                                        )
                                      else if (item.status == 'deposited')
                                        TextButton.icon(
                                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                          icon: const Icon(Icons.qr_code, size: 16, color: AppColors.success),
                                          label: const Text('Voucher', style: TextStyle(color: AppColors.success, fontSize: 13)),
                                          onPressed: () => context.push('/finder/dropoff/${item.id}'),
                                        ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                        icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primary),
                                        label: const Text('Support', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                                        onPressed: () => context.push('/finder/chat/${item.id}'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: itemsService.foundItems.length,
                  ),
                ),
              
              // Spacing at the bottom of list
              const SliverToBoxAdapter(child: SizedBox(height: 80.0)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Report a Found Item', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => context.push('/finder/report'),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'heldByFinder':
        return AppColors.warning;
      case 'awaitingDeposit':
        return AppColors.warning;
      case 'deposited':
        return AppColors.success;
      case 'matched':
        return AppColors.primary;
      case 'returned':
        return AppColors.textSecondary;
      default:
        return Colors.white;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'heldByFinder':
        return 'Held by Finder';
      case 'awaitingDeposit':
        return 'Awaiting Deposit';
      case 'deposited':
        return 'Deposited';
      case 'matched':
        return 'Matched';
      case 'returned':
        return 'Returned';
      default:
        return status;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.phone_iphone;
      case 'bags':
        return Icons.backpack;
      case 'personal accessories':
        return Icons.wallet;
      case 'keys':
        return Icons.vpn_key;
      default:
        return Icons.widgets;
    }
  }
}
