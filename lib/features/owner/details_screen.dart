import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import '../../core/models/lost_item_model.dart';
import '../../core/widgets/report_incident_modal.dart';

class LostItemDetailsScreen extends StatelessWidget {
  final String itemId;

  const LostItemDetailsScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final item = itemsService.getItemById(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Details')),
        body: const Center(
          child: Text('Item not found in registry.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/owner'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppColors.warning),
            tooltip: 'Report Fraud / Suspicious Activity',
            onPressed: () {
              ReportIncidentModal.show(
                context,
                itemId: item.id,
                itemTitle: item.title,
                reporterRole: 'owner',
                reporterId: 'sarah_jenkins_uid',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS TIMELINE',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeline(context, item.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Conditional Action Panels
            _buildActionCard(context, item),

            // Item Specs Section
            const SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REPORT SPECIFICATIONS',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildSpecRow('Category', item.category),
                    _buildSpecRow('Brand / Model', item.brand ?? 'N/A'),
                    _buildSpecRow('Colour', item.colour ?? 'N/A'),
                    _buildSpecRow('Unique Marks', item.uniqueMarks ?? 'None specified'),
                    _buildSpecRow('Location Lost', item.lastKnownLocation),
                    _buildSpecRow('Date Lost', '${item.dateLost.day}/${item.dateLost.month}/${item.dateLost.year}'),
                    _buildSpecRow('Estimated Value', '£ ${item.estimatedValue.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Chat with Admin CTA Button
            ElevatedButton.icon(
              icon: const Icon(Icons.forum, color: Colors.white),
              label: const Text('Secure Chat with Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                context.go('/owner/chat/${item.id}');
              },
            ),
            const SizedBox(height: 12.0),

            // Report Fraud / Suspicious Activity Button
            OutlinedButton.icon(
              icon: const Icon(Icons.shield_outlined, color: AppColors.danger, size: 18),
              label: const Text('Report Suspicious Activity / Fraud Alert'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                ReportIncidentModal.show(
                  context,
                  itemId: item.id,
                  itemTitle: item.title,
                  reporterRole: 'owner',
                  reporterId: 'sarah_jenkins_uid',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, String currentStatus) {
    // Define steps and whether they are complete/pending/upcoming
    final List<Map<String, dynamic>> steps = [
      {'label': 'Reported', 'status': 'searching'},
      {'label': 'Matching & Searching', 'status': 'searching'},
      {'label': 'Match Found & Under Review', 'status': 'matchFound'},
      {'label': 'Ready for Collection', 'status': 'readyForCollection'},
      {'label': 'Returned', 'status': 'returned'},
    ];

    // Determine completion index
    int currentIndex = 0;
    if (currentStatus == 'searching') {
      currentIndex = 1;
    } else if (currentStatus == 'matchFound') {
      currentIndex = 2;
    } else if (currentStatus == 'underReview') {
      currentIndex = 2; // Under review maps to same timeline stage as Match Found
    } else if (currentStatus == 'readyForCollection') {
      currentIndex = 3;
    } else if (currentStatus == 'returned') {
      currentIndex = 4;
    }

    return Column(
      children: List.generate(steps.length, (idx) {
        final step = steps[idx];
        final isCompleted = idx < currentIndex;
        final isActive = idx == currentIndex;
        final isUpcoming = idx > currentIndex;

        Color dotColor = AppColors.textSecondary;
        if (isCompleted) {
          dotColor = AppColors.success;
        } else if (isActive) {
          dotColor = (currentStatus == 'matchFound' || currentStatus == 'underReview')
              ? AppColors.warning
              : AppColors.success;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: isActive ? 4 : 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Center(child: Icon(Icons.check, size: 10, color: AppColors.success))
                      : null,
                ),
                if (idx < steps.length - 1)
                  Container(
                    width: 2,
                    height: 30,
                    color: isCompleted ? AppColors.success : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['label'],
                    style: TextStyle(
                      fontWeight: (isActive || isCompleted) ? FontWeight.bold : FontWeight.normal,
                      color: isUpcoming ? AppColors.textSecondary : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isActive)
                    Text(
                      _getTimelineSubtext(currentStatus),
                      style: TextStyle(
                        color: dotColor.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getTimelineSubtext(String status) {
    switch (status) {
      case 'searching':
        return 'We are running search matches against reported found items.';
      case 'matchFound':
        return 'A potential match has been flagged by Admin. Action Required.';
      case 'underReview':
        return 'Your verification proof is under Administration Board audit.';
      case 'readyForCollection':
        return 'Item verified! Generated secure PIN pickup voucher.';
      case 'returned':
        return 'Item handed back and verified in possession.';
      default:
        return '';
    }
  }

  Widget _buildActionCard(BuildContext context, LostItem item) {
    if (item.status == 'matchFound') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: AppColors.warning),
                SizedBox(width: 10),
                Text(
                  'ACTION REQUIRED',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Admin requires proof of ownership to verify and approve item collection.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                context.go('/owner/verify/${item.id}');
              },
              child: const Text('Open Verification Center'),
            ),
          ],
        ),
      );
    }

    if (item.status == 'underReview') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_empty, color: AppColors.warning),
                SizedBox(width: 10),
                Text(
                  'PROOF SUBMITTED',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Your details are being validated against the found report serial/visual attributes. This usually takes less than 2 hours. You will receive a notification once approved.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      );
    }

    if (item.status == 'readyForCollection') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 10),
                Text(
                  'CLAIM VERIFIED & APPROVED',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Ownership confirmed! A secure PIN and Drop-off location coordinates have been generated. Present the barcode at the desk.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                context.go('/owner/collection/${item.id}');
              },
              child: const Text('Get Collection Code & Map'),
            ),
          ],
        ),
      );
    }

    if (item.status == 'returned') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.assignment_turned_in, color: AppColors.success),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'This item was returned. The secure collection PIN was verified at Euston Rd support desk.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
