import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';

class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({super.key});

  @override
  State<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
  bool _withdrawing = false;

  Future<void> _handleWithdraw() async {
    setState(() => _withdrawing = true);
    final itemsService = Provider.of<ItemsService>(context, listen: false);
    final success = await itemsService.withdrawFunds();
    setState(() => _withdrawing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal initiated! Funds will credit your registered UK bank account within 2 hours.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available funds to withdraw.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final claims = itemsService.claims;

    // Calculate balances
    final double availableBalance = claims
        .where((tx) => tx.status == 'available')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final double pendingEscrow = claims
        .where((tx) => tx.status == 'pending')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet & Rewards'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Wallet Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                '£${availableBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Available Balance',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 50, color: AppColors.border),
                          Column(
                            children: [
                              Text(
                                '£${pendingEscrow.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Pending Escrow',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.black,
                        ),
                        icon: _withdrawing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Icon(Icons.account_balance_wallet),
                        label: const Text(
                          'Withdraw Available Funds',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        onPressed: availableBalance <= 0 || _withdrawing ? null : _handleWithdraw,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Compliance footnote (Rule 11 & 14)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.gavel_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Compliance note: Reward assessments are controlled solely by the Admin Board. Finders cannot request specific amounts or bargain privately (Rules 11 & 14). Available balances are released only after owner pickup confirmation.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'TRANSACTION HISTORY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),

                // Transactions List
                if (claims.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Text('No transaction history available.', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...claims.reversed.map((tx) => _buildTransactionItem(tx)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(dynamic tx) {
    final isWithdrawal = tx.type == 'cashOut';
    final isPending = tx.status == 'pending';

    Color textAccent;
    IconData icon;
    String sign;

    if (isWithdrawal) {
      textAccent = AppColors.danger;
      icon = Icons.upload;
      sign = '-';
    } else if (isPending) {
      textAccent = AppColors.warning;
      icon = Icons.hourglass_empty;
      sign = '+';
    } else {
      textAccent = AppColors.success;
      icon = Icons.download;
      sign = '+';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: textAccent.withValues(alpha: 0.15),
              child: Icon(icon, color: textAccent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year} • ${tx.status.toUpperCase()}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '$sign£${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isWithdrawal ? Colors.white : textAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
