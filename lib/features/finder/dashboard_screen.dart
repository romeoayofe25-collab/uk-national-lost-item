import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class FinderDashboardScreen extends StatelessWidget {
  const FinderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finder Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Marcus!',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                const Text('Trust Level: '),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.2),
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
              const SizedBox(height: 16.0),
              Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'SIMULATED PLATFORM WALLET',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                '£45.00',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const Text('Available Balance'),
                            ],
                          ),
                          Container(width: 1, height: 40, color: AppColors.border),
                          Column(
                            children: [
                              Text(
                                '£20.00',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                              const Text('Pending Escrow'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to Wallet details
                        },
                        child: const Text('View Wallet & Claims History'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
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
                    const Text(
                      'Please drop off the "Blue Backpack" at a verified centre.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () {
                        // TODO: Route to Drop-off selector
                      },
                      child: const Text('Select Drop-off Location', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'ACTIVE FOUND POSTS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12.0),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone_iphone, color: AppColors.success, size: 36),
                  title: const Text('iPhone 13 Pro'),
                  subtitle: const Text('Location: Kings Cross • Found: 1 day ago'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Deposited',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.backpack, color: AppColors.warning, size: 36),
                  title: const Text('Blue Canvas Backpack'),
                  subtitle: const Text('Location: Hyde Park • Found: 2 hrs ago'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Held by Finder',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Report a Found Item'),
                onPressed: () {
                  // TODO: Route to Wizard
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
