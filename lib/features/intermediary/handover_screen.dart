import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';

class IntermediaryHandoverScreen extends StatefulWidget {
  final String lostItemId;

  const IntermediaryHandoverScreen({super.key, required this.lostItemId});

  @override
  State<IntermediaryHandoverScreen> createState() => _IntermediaryHandoverScreenState();
}

class _IntermediaryHandoverScreenState extends State<IntermediaryHandoverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();

  bool _verifiedId = false;
  bool _collectedSignature = false;
  bool _submitting = false;
  String _errorMsg = '';

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _processHandover() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_verifiedId || !_collectedSignature) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check all verification requirements first.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _errorMsg = '';
    });

    final itemsService = Provider.of<ItemsService>(context, listen: false);
    final success = await itemsService.verifyAndHandover(
      lostItemId: widget.lostItemId,
      pin: _pinController.text.trim(),
    );

    setState(() => _submitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item successfully returned to owner. Escrow reward released!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/intermediary');
    } else if (mounted) {
      setState(() => _errorMsg = 'Incorrect Collection PIN. Please verify code.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final item = itemsService.getItemById(widget.lostItemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Handover')),
        body: const Center(child: Text('Item not found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Owner Handover'),
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
                  // Verification Shield Header (Rule 19 Compliance)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, color: AppColors.danger, size: 28),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rule 19 Handover Verification',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Perform physical checks to avoid false release or fraud.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Claim details info card
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
                          'CLAIM & ITEM SUMMARY',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        _detailRow('Item Name', item.title),
                        _detailRow('Category', item.category),
                        _detailRow('Brand', item.brand ?? 'N/A'),
                        _detailRow('Colour', item.colour ?? 'N/A'),
                        _detailRow('Storage Loc', item.storageLocation ?? 'Locker #4'),
                        _detailRow('Expected PIN', item.secureCollectionPin ?? 'None'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Checklists
                  const Text(
                    'SECURITY VERIFICATION CHECKLIST',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8),

                  CheckboxListTile(
                    value: _verifiedId,
                    title: const Text(
                      'Physically verify owner\'s Photo ID (Passport or Driving License) matches profile name.',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      if (val != null) setState(() => _verifiedId = val);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  CheckboxListTile(
                    value: _collectedSignature = _collectedSignature,
                    title: const Text(
                      'Obtain physical handover signature and complete liability release declaration.',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      if (val != null) setState(() => _collectedSignature = val);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // Enter Collection PIN Code field
                  TextFormField(
                    controller: _pinController,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Enter 6-Digit Collection PIN *',
                      hintText: 'e.g. 491-032',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Collection PIN verification is required';
                      }
                      return null;
                    },
                  ),
                  if (_errorMsg.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMsg,
                      style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _submitting ? null : _processHandover,
                    child: _submitting
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Complete Handover & Release Escrow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
