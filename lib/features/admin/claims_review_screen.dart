import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';

class AdminClaimsReviewScreen extends StatefulWidget {
  final String matchId; // This is the lost item ID

  const AdminClaimsReviewScreen({super.key, required this.matchId});

  @override
  State<AdminClaimsReviewScreen> createState() => _AdminClaimsReviewScreenState();
}

class _AdminClaimsReviewScreenState extends State<AdminClaimsReviewScreen> {
  final _rewardController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final itemsService = Provider.of<ItemsService>(context, listen: false);
    final lostItem = itemsService.getItemById(widget.matchId);
    if (lostItem != null) {
      final foundItem = itemsService.foundItems.firstWhere(
        (item) => item.title == lostItem.title,
        orElse: () => itemsService.foundItems.first,
      );
      _rewardController.text = foundItem.rewardAmount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _rewardController.dispose();
    super.dispose();
  }

  void _approveClaim(ItemsService itemsService) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isProcessing = true);
    final reward = double.tryParse(_rewardController.text) ?? 0.0;
    
    final success = await itemsService.adminApproveClaim(
      lostItemId: widget.matchId,
      rewardAmount: reward,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim approved and collection code generated!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error approving claim. Please try again.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _rejectClaim(ItemsService itemsService) async {
    setState(() => _isProcessing = true);
    final success = await itemsService.adminRejectClaim(lostItemId: widget.matchId);
    
    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim rejected. Lost item status reset to searching.'),
            backgroundColor: AppColors.warning,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error rejecting claim. Please try again.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final lostItem = itemsService.getItemById(widget.matchId);

    if (lostItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Claim Verification Review')),
        body: const Center(child: Text('Item not found')),
      );
    }

    final foundItem = itemsService.foundItems.firstWhere(
      (item) => item.title == lostItem.title,
      orElse: () => itemsService.foundItems.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Verification Review'),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Case Details
                      Container(
                        padding: const EdgeInsets.all(16.0),
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
                                Text(
                                  'CASE MATCH #${lostItem.id.hashCode.toString().substring(0, 4)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary),
                                  ),
                                  child: Text(
                                    lostItem.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lostItem.title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Side-by-Side/Tab comparison
                      Text(
                        'MATCH COMPARISON',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 10),

                      // Lost Item Form Inputs
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.person, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'Owner Submissions',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                            const Divider(height: 24, color: AppColors.border),

                            // Biometric Identity Verification Status Card
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: lostItem.biometricVerified
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: lostItem.biometricVerified
                                      ? AppColors.success.withValues(alpha: 0.4)
                                      : AppColors.warning.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    lostItem.biometricVerified ? Icons.verified_user : Icons.gpp_maybe,
                                    color: lostItem.biometricVerified ? AppColors.success : AppColors.warning,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lostItem.biometricVerified
                                              ? 'BIOMETRIC LIVENESS: PASSED'
                                              : 'BIOMETRIC CHECK: NOT PERFORMED',
                                          style: TextStyle(
                                            color: lostItem.biometricVerified ? AppColors.success : AppColors.warning,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        if (lostItem.biometricVerified) ...[
                                          Text(
                                            'Confidence: ${((lostItem.biometricConfidence ?? 0.984) * 100).toStringAsFixed(1)}% • ${lostItem.idDocumentType ?? 'Government ID'} (${lostItem.idDocumentMasked ?? 'GBR-***-001'})',
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Hash: ${lostItem.biometricHash ?? 'BIO-TOKEN-VERIFIED'}',
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontFamily: 'monospace'),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ] else
                                          const Text(
                                            'Standard claim verification without biometric facial match.',
                                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            ...lostItem.verificationQuestions.map((q) {
                              final ans = lostItem.verificationAnswers[q.id] ?? 'No answer provided';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      q.questionText,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ans,
                                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 8),
                            const Text(
                              'Submitted Serial Number / IMEI',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lostItem.verificationSerialNumber ?? 'Not provided',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Proof of Purchase Attachments',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            if (lostItem.proofDocuments.isNotEmpty)
                              Row(
                                children: lostItem.proofDocuments.map((doc) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.picture_as_pdf, color: AppColors.danger, size: 20),
                                        SizedBox(width: 6),
                                        Text('Receipt.pdf', style: TextStyle(fontSize: 12, color: Colors.white)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            else
                              const Text('No documents uploaded', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Found Item details
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.storage, color: AppColors.success),
                                SizedBox(width: 8),
                                Text(
                                  'Finder Report Details',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                            const Divider(height: 24, color: AppColors.border),
                            
                            const Text(
                              'Private Custodian Details (Verification Key)',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              foundItem.privateDetails ?? 'None registered',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            
                            const SizedBox(height: 16),
                            const Text(
                              'Physical Location Stored',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              foundItem.dropOffCentreName ?? 'Not dropped off yet',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            
                            const SizedBox(height: 16),
                            const Text(
                              'Locker / Shelf Reference',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              foundItem.storageLocation ?? 'Unassigned',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Reward setting form
                      Text(
                        'REWARD & DECISION CONTROLS',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _rewardController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              decoration: const InputDecoration(
                                labelText: 'Assessed Finder Reward (GBP)',
                                prefixText: '£ ',
                                labelStyle: TextStyle(color: AppColors.warning),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Reward amount is required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Enter a valid decimal number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.danger),
                                      foregroundColor: AppColors.danger,
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    ),
                                    onPressed: () => _rejectClaim(itemsService),
                                    child: const Text('REJECT CLAIM'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    ),
                                    onPressed: () => _approveClaim(itemsService),
                                    child: const Text('APPROVE CLAIM'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
