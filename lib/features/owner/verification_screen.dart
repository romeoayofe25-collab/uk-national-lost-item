import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';

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
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _serialController.dispose();
    super.dispose();
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
                'The Admin Board has flagged a potential matching item in storage. Answer the security queries below to confirm ownership.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Dynamic Admin Security Questions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
}
