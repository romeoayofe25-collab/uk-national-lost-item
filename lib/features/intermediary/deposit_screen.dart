import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';

class IntermediaryDepositScreen extends StatefulWidget {
  final String foundItemId;

  const IntermediaryDepositScreen({super.key, required this.foundItemId});

  @override
  State<IntermediaryDepositScreen> createState() => _IntermediaryDepositScreenState();
}

class _IntermediaryDepositScreenState extends State<IntermediaryDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lockerController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _lockerController.dispose();
    super.dispose();
  }

  Future<void> _confirmCheckIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final itemsService = Provider.of<ItemsService>(context, listen: false);
    final success = await itemsService.checkInItem(
      foundItemId: widget.foundItemId,
      storageLocation: _lockerController.text.trim(),
    );
    setState(() => _submitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item successfully checked in and cataloged!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/intermediary');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to check in item.'),
          backgroundColor: AppColors.danger,
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
        appBar: AppBar(title: const Text('Item Check-In')),
        body: const Center(child: Text('Item not found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Confirmation'),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Verification Shield Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield, color: AppColors.primary, size: 28),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification Required',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ensure physical details match the reported items below before allocation.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Item Details Info Card
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
                          'INCOMING ITEM DETAILS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        _detailRow('Item Title', item.title),
                        _detailRow('Category', item.category),
                        _detailRow('Brand', item.brand ?? 'Not reported'),
                        _detailRow('Colour', item.colour ?? 'Not reported'),
                        _detailRow('Public Desc', item.publicDescription),
                        _detailRow('Receipt PIN', item.secureDepositPin ?? 'None'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Storage Allocation Fields
                  const Text(
                    'PHYSICAL STORAGE ALLOCATION',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _lockerController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Locker / Shelf ID *',
                      hintText: 'e.g. Locker #3, Shelf B-12',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Locker or shelf assignment is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _submitting ? null : _confirmCheckIn,
                    child: _submitting
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Confirm Physical Check-In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
