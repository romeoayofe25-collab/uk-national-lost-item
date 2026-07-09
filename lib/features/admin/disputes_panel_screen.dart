import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user_model.dart';

class AdminDisputesPanelScreen extends StatefulWidget {
  const AdminDisputesPanelScreen({super.key});

  @override
  State<AdminDisputesPanelScreen> createState() => _AdminDisputesPanelScreenState();
}

class _AdminDisputesPanelScreenState extends State<AdminDisputesPanelScreen> {
  bool _isProcessing = false;

  void _toggleUserStatus(ItemsService itemsService, AppUser user) async {
    setState(() => _isProcessing = true);
    
    bool success;
    if (user.isSuspended) {
      success = await itemsService.adminActivateUser(email: user.email);
    } else {
      success = await itemsService.adminSuspendUser(email: user.email);
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User status updated for ${user.displayName}!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update user status.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final usersList = AuthService.mockUsersList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disputes & Fraud Panel'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0F101A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isProcessing
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // System Security Alerts
                    Text(
                      'SYSTEM SECURITY ALERTS',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning, color: AppColors.danger, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Automatic Suspension Triggered',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'User "suspended@test.com" was suspended after 3 failed verification question attempts on Case #1021.',
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Registered User Accounts List
                    Text(
                      'USER ACCESS & TRUST SCORES',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: usersList.length,
                      itemBuilder: (context, index) {
                        final user = usersList[index];
                        final isSuspended = user.isSuspended;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              children: [
                                // Profile Badge
                                CircleAvatar(
                                  backgroundColor: isSuspended ? AppColors.danger.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2),
                                  child: Icon(
                                    isSuspended ? Icons.block : Icons.person,
                                    color: isSuspended ? AppColors.danger : AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // User Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.displayName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${user.role.toUpperCase()} • Trust: ${user.trustScore} pts',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                      Text(
                                        user.email,
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status Indicator & Action Button
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (isSuspended ? AppColors.danger : AppColors.success).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: isSuspended ? AppColors.danger : AppColors.success),
                                      ),
                                      child: Text(
                                        user.status.toUpperCase(),
                                        style: TextStyle(
                                          color: isSuspended ? AppColors.danger : AppColors.success,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (user.role != 'admin')
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: isSuspended ? AppColors.success : AppColors.danger,
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(60, 30),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () => _toggleUserStatus(itemsService, user),
                                        child: Text(
                                          isSuspended ? 'ACTIVATE' : 'SUSPEND',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
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
}
