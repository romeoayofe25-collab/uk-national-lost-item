import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import '../../core/models/found_item_model.dart';

class DropOffScreen extends StatefulWidget {
  final String foundItemId;

  const DropOffScreen({super.key, required this.foundItemId});

  @override
  State<DropOffScreen> createState() => _DropOffScreenState();
}

class _DropOffScreenState extends State<DropOffScreen> {
  bool _depositing = false;
  
  // Handover checklist states
  bool _checkedPackage = false;
  bool _checkedTag = false;
  bool _checkedHandover = false;

  final List<Map<String, dynamic>> _mockCentres = [
    {
      'name': 'Kings Cross Intermediary Centre',
      'distance': '0.1 miles',
      'address': 'Euston Road Counter A, London, N1 9AL',
      'hours': '24 Hours / 7 Days',
    },
    {
      'name': 'Bloomsbury Community Hub',
      'distance': '0.6 miles',
      'address': 'Tavistock Place Reception, London, WC1H 9SE',
      'hours': '08:00 - 20:00',
    },
    {
      'name': 'Islington Library Drop-off',
      'distance': '1.2 miles',
      'address': '222 Upper St Service Counter, London, N1 1XR',
      'hours': '09:00 - 17:00',
    },
  ];

  Future<void> _handleDeposit(String centreName) async {
    setState(() => _depositing = true);
    final itemsService = Provider.of<ItemsService>(context, listen: false);
    final success = await itemsService.selectDropOffCentre(
      foundItemId: widget.foundItemId,
      centreName: centreName,
    );
    setState(() => _depositing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voucher generated for $centreName!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _simulateStaffScan(ItemsService itemsService, String foundItemId) async {
    setState(() => _depositing = true);
    final success = await itemsService.checkInItem(
      foundItemId: foundItemId,
      storageLocation: 'Kings Cross Counter A - Locker 14',
    );
    setState(() => _depositing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simulation: Desk scanned voucher. Deposit completed!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final item = itemsService.getFoundItemById(widget.foundItemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Drop-off Centre')),
        body: const Center(child: Text('Item not found', style: TextStyle(color: Colors.white))),
      );
    }

    final hasAwaiting = item.status == 'awaitingDeposit';
    final isDeposited = item.status == 'deposited' || item.status == 'matched' || item.status == 'returned';

    return Scaffold(
      appBar: AppBar(
        title: Text(isDeposited ? 'Deposit Voucher' : (hasAwaiting ? 'Deposit Voucher' : 'Select Drop-off Centre')),
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
                // Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Item: ${item.title} (${item.category})',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (isDeposited) ...[
                  // VOUCHER CARD VIEW (DEPOSITED SUCCESS)
                  _buildDepositedCard(item),
                ] else if (hasAwaiting) ...[
                  // SELECTION CONFIRMED (AWAITING DEPOSIT CHECKS)
                  _buildAwaitingCard(item, itemsService),
                ] else ...[
                  // SELECTION VIEW
                  const Text(
                    'RECOMMENDED DROP-OFF CENTRES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_depositing)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else
                    ..._mockCentres.map((centre) => _buildCentreCard(centre)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCentreCard(Map<String, dynamic> centre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    centre['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    centre['distance'],
                    style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              centre['address'],
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Hours: ${centre['hours']}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                backgroundColor: AppColors.primary,
              ),
              onPressed: () => _handleDeposit(centre['name']),
              child: const Text('Deposit at this Centre', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwaitingCard(FoundItem item, ItemsService itemsService) {
    final allChecked = _checkedPackage && _checkedTag && _checkedHandover;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            children: [
              const Icon(Icons.hourglass_empty, color: AppColors.warning, size: 64),
              const SizedBox(height: 16),
              const Text(
                'AWAITING PHYSICAL DEPOSIT',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Deposit voucher generated for ${item.dropOffCentreName}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // PIN Display
              const Text(
                'DEPOSIT SECURITY PIN',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              const SizedBox(height: 4),
              Text(
                item.secureDepositPin ?? 'DEP-XXX',
                style: const TextStyle(color: AppColors.success, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
              const SizedBox(height: 20),

              // Mock QR Code
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, color: Colors.black, size: 90),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'SCAN AT DESK TO COMPLETE HANDOVER',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Handover Checklist Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PHYSICAL HANDOVER CHECKLIST',
                style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),
              Material(
                type: MaterialType.transparency,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I confirm the item is safely packed and sealed.', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: _checkedPackage,
                  activeColor: AppColors.warning,
                  onChanged: (val) => setState(() => _checkedPackage = val ?? false),
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I have labeled the item with my found reference ID.', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: _checkedTag,
                  activeColor: AppColors.warning,
                  onChanged: (val) => setState(() => _checkedTag = val ?? false),
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I am ready to hand it to the verified desk agent.', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: _checkedHandover,
                  activeColor: AppColors.warning,
                  onChanged: (val) => setState(() => _checkedHandover = val ?? false),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Simulate Handover CTA (Demo ONLY)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: allChecked ? AppColors.success : AppColors.border.withValues(alpha: 0.3),
            foregroundColor: allChecked ? Colors.black : AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('SIMULATE DESK STAFF SCAN (DEMO)', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: allChecked ? () => _simulateStaffScan(itemsService, item.id) : null,
        ),
        const SizedBox(height: 12),
        
        OutlinedButton(
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          onPressed: () => context.go('/finder'),
          child: const Text('Back to Dashboard'),
        ),
      ],
    );
  }

  Widget _buildDepositedCard(FoundItem item) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 64),
          const SizedBox(height: 16),
          const Text(
            'PHYSICAL DEPOSIT VERIFIED',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Custody confirmed at ${item.dropOffCentreName}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Locker Storage detail
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.store, color: AppColors.success, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CUSTODY STORAGE LOCATION',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.storageLocation ?? 'Locker Vault B-12',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ledger notification
          const Text(
            'WALLET UPDATE',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '£${item.rewardAmount.toStringAsFixed(2)} Escrow Pending',
            style: const TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Dashboard'),
            onPressed: () => context.go('/finder'),
          ),
        ],
      ),
    );
  }
}
