import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../services/items_service.dart';

class ReportIncidentModal extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  final String? reportedUserId;
  final String? reportedUserName;
  final String reporterRole;
  final String reporterId;

  const ReportIncidentModal({
    super.key,
    required this.itemId,
    required this.itemTitle,
    this.reportedUserId,
    this.reportedUserName,
    required this.reporterRole,
    required this.reporterId,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String itemId,
    required String itemTitle,
    String? reportedUserId,
    String? reportedUserName,
    required String reporterRole,
    required String reporterId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReportIncidentModal(
          itemId: itemId,
          itemTitle: itemTitle,
          reportedUserId: reportedUserId,
          reportedUserName: reportedUserName,
          reporterRole: reporterRole,
          reporterId: reporterId,
        ),
      ),
    );
  }

  @override
  State<ReportIncidentModal> createState() => _ReportIncidentModalState();
}

class _ReportIncidentModalState extends State<ReportIncidentModal> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _evidenceController = TextEditingController();

  String _selectedCategory = 'extortionBidding';
  String _selectedSeverity = 'high';
  bool _isSubmitting = false;

  final List<Map<String, String>> _categories = [
    {
      'id': 'extortionBidding',
      'label': 'Reward Extortion / Demanding Payment',
      'rule': 'Rule 9 & 14: Prohibition of private rewards & negotiation',
      'icon': 'attach_money',
    },
    {
      'id': 'stolenGoods',
      'label': 'Suspected Stolen Property',
      'rule': 'Rule 11: National Crime Prevention & Police Registry',
      'icon': 'warning',
    },
    {
      'id': 'fakeProof',
      'label': 'Fake Serial Number / Tampered Proof',
      'rule': 'Rule 18: Verification integrity & anti-counterfeit checks',
      'icon': 'qr_code_scanner',
    },
    {
      'id': 'falseClaim',
      'label': 'Fraudulent Claim / Impersonating Owner',
      'rule': 'Rule 11: Prevention of unauthorized item claims',
      'icon': 'person_off',
    },
    {
      'id': 'unsafeMeeting',
      'label': 'Attempted Direct / Unsafe Meeting',
      'rule': 'Rule 10 & 16: Return only via authorized drop-off desks',
      'icon': 'location_off',
    },
    {
      'id': 'harassment',
      'label': 'Abusive or Coercive Language',
      'rule': 'Rule 4: Monitored chat standards & user safety',
      'icon': 'shield',
    },
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final itemsService = Provider.of<ItemsService>(context, listen: false);

    final success = await itemsService.submitFraudReport(
      reportedItemId: widget.itemId,
      reportedItemTitle: widget.itemTitle,
      reportedUserId: widget.reportedUserId,
      reportedUserName: widget.reportedUserName,
      reporterId: widget.reporterId,
      reporterRole: widget.reporterRole,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      evidenceNotes: _evidenceController.text.trim().isEmpty ? null : _evidenceController.text.trim(),
      severity: _selectedSeverity,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.shield, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Incident report transmitted to Admin Board. Claim placed under review.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.danger,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.danger, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Suspicious Activity',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Case: ${widget.itemTitle}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border),

          // Body Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Confidentiality Reassurance (Rule 2 & 13)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, color: AppColors.secondary, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Strictly Confidential (Rules 2 & 13): Your identity is protected. The reported party will never see this report or your contact details.',
                              style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Category Selection
                    const Text(
                      'INCIDENT CATEGORY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 10),
                    ..._categories.map((cat) {
                      final isSelected = _selectedCategory == cat['id'];
                      return InkWell(
                        onTap: () => setState(() => _selectedCategory = cat['id']!),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.danger.withValues(alpha: 0.12) : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.danger : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? AppColors.danger : Colors.white38,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat['label']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      cat['rule']!,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: isSelected ? AppColors.danger.withValues(alpha: 0.9) : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Severity Selector
                    const Text(
                      'PRIORITY LEVEL',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSeverityChip('high', 'High (Immediate Risk)', AppColors.danger),
                        const SizedBox(width: 8),
                        _buildSeverityChip('medium', 'Medium (Investigation)', AppColors.warning),
                        const SizedBox(width: 8),
                        _buildSeverityChip('low', 'Low', AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Narrative Statement
                    const Text(
                      'INCIDENT DESCRIPTION *',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Describe what happened (e.g. unsolicited payment demand, refusal of intermediary return, suspicious IMEI)...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.danger)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 10) {
                          return 'Please provide at least 10 characters detailing the incident.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Evidence / Identifier Notes
                    const Text(
                      'SUPPORTING EVIDENCE OR OFF-PLATFORM HANDLES (OPTIONAL)',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _evidenceController,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g. Off-platform phone number, account handle, or crime ref number',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        label: Text(
                          _isSubmitting ? 'TRANSMITTING REPORT...' : 'SUBMIT REPORT TO ADMIN BOARD',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                        ),
                        onPressed: _isSubmitting ? null : _submitReport,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String id, String label, Color color) {
    final isSelected = _selectedSeverity == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSeverity = id),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 1.5 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
