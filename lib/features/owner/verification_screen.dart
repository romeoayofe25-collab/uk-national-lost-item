import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import 'biometric_scan_screen.dart';

class OwnerVerificationScreen extends StatefulWidget {
  final String itemId;

  const OwnerVerificationScreen({super.key, required this.itemId});

  @override
  State<OwnerVerificationScreen> createState() => _OwnerVerificationScreenState();
}

class _OwnerVerificationScreenState extends State<OwnerVerificationScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final _serialController = TextEditingController();
  final List<String> _uploadedDocs = [];
  BiometricScanResult? _biometricResult;
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _openBiometricScanner() async {
    final result = await Navigator.of(context).push<BiometricScanResult>(
      MaterialPageRoute(
        builder: (context) => const BiometricScanScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _biometricResult = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric verification confirmed for ${result.documentType}!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _submit(dynamic item) async {
    // Validate required answers
    for (var q in item.verificationQuestions) {
      final text = _controllers[q.id]?.text.trim() ?? '';
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please answer: "${q.questionText}"'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    final itemsService = Provider.of<ItemsService>(context, listen: false);
    final Map<String, String> answers = {};
    _controllers.forEach((key, controller) {
      answers[key] = controller.text.trim();
    });

    final success = await itemsService.submitVerification(
      itemId: widget.itemId,
      answers: answers,
      serialNumber: _serialController.text.trim().isEmpty ? null : _serialController.text.trim(),
      proofDocs: _uploadedDocs,
      biometricVerified: _biometricResult?.isVerified ?? false,
      biometricConfidence: _biometricResult?.confidence,
      biometricHash: _biometricResult?.biometricHash,
      idDocumentType: _biometricResult?.documentType,
      idDocumentMasked: _biometricResult?.documentMasked,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification submitted to Admin Board successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/owner/details/${widget.itemId}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting verification details.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final item = itemsService.getItemById(widget.itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verification Center')),
        body: const Center(child: Text('Item not found.')),
      );
    }

    // Initialize text controllers for dynamic questions
    for (var q in item.verificationQuestions) {
      _controllers.putIfAbsent(q.id, () => TextEditingController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/owner/details/${widget.itemId}'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'VERIFY OWNERSHIP: ${item.title}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The Admin Board has flagged a potential matching item in storage. Complete the identity and security queries below to confirm ownership.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Biometric Identity Check Card (Rule 18 Strong Verification)
              _buildBiometricSection(),
              const SizedBox(height: 16),

              // Dynamic Admin Security Questions Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'ADMIN SECURITY QUESTIONS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...item.verificationQuestions.map((q) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '* ${q.questionText}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _controllers[q.id],
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  hintText: 'Type your answer here...',
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),

                      // Purchase proof upload field
                      const Text(
                        'Upload Additional Proof of Purchase (Optional)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Upload store receipt, network carrier contract, or original box barcode photos.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _uploadedDocs.add('verification_receipt_${_uploadedDocs.length + 1}.pdf');
                              });
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file, color: AppColors.textSecondary),
                                  SizedBox(height: 4),
                                  Text('Upload File', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _uploadedDocs.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 8),
                                itemBuilder: (context, idx) {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 32),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _uploadedDocs.removeAt(idx);
                                            });
                                          },
                                          child: const CircleAvatar(
                                            radius: 10,
                                            backgroundColor: AppColors.danger,
                                            child: Icon(Icons.close, color: Colors.white, size: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // IMEI / Serial Number
                      const Text(
                        '* Confirm Serial Number / IMEI',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _serialController,
                        decoration: const InputDecoration(
                          hintText: 'Enter serial/IMEI (kept secret from public view)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Legal framework warning banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gavel, color: AppColors.danger, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'LEGAL & ETHICAL RESPONSIBILITY',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Filing false claims is a criminal offense under the UK Theft Act 1968 and Fraud Act 2006. Any attempt to claim items fraudulently is recorded, and the associated accounts are permanently blacklisted and referred to the authorities.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _submit(item),
                      child: const Text('Submit Verification Proof', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSection() {
    if (_biometricResult != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user, color: AppColors.success, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BIOMETRICS VERIFIED ✓',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Liveness Score: 98.4% Confidence',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _openBiometricScanner,
                  child: const Text('Retake', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.badge, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'ID Linked: ${_biometricResult!.documentType}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _biometricResult!.documentMasked,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.face_retouching_natural, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BIOMETRIC IDENTITY CHECK',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Required for high-value claims (Rule 18)',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Complete a 15-second facial liveness scan matched against your Government ID to prevent fraudulent claims.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              backgroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.camera_front, size: 18),
            label: const Text('Start Biometric Face Scan', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _openBiometricScanner,
          ),
        ],
      ),
    );
  }
}
