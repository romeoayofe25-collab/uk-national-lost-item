import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user_model.dart';
import '../../core/models/fraud_report_model.dart';

class AdminDisputesPanelScreen extends StatefulWidget {
  const AdminDisputesPanelScreen({super.key});

  @override
  State<AdminDisputesPanelScreen> createState() => _AdminDisputesPanelScreenState();
}

class _AdminDisputesPanelScreenState extends State<AdminDisputesPanelScreen> {
  bool _isProcessing = false;
  String _stolenSearchQuery = '';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'User status updated for ${user.displayName}!' : 'Failed to update user status.'),
          backgroundColor: success ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  void _handleFraudAction(ItemsService itemsService, String reportId, String action, String description) async {
    setState(() => _isProcessing = true);
    final success = await itemsService.adminResolveFraudReport(
      reportId: reportId,
      action: action,
      adminNotes: description,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? description : 'Failed to apply resolution.'),
          backgroundColor: action == 'freezeCase' || action == 'suspendUser' ? AppColors.danger : AppColors.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final reports = itemsService.fraudReports;
    final pendingCount = reports.where((r) => r.status == 'pendingReview' || r.status == 'investigating').length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Disputes & Fraud Operations'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                icon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  backgroundColor: AppColors.danger,
                  child: const Icon(Icons.shield_outlined, size: 20),
                ),
                text: 'Incident Queue',
              ),
              const Tab(
                icon: Icon(Icons.manage_accounts_outlined, size: 20),
                text: 'User Access',
              ),
              const Tab(
                icon: Icon(Icons.local_police_outlined, size: 20),
                text: 'Police Stolen DB',
              ),
            ],
          ),
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
              : TabBarView(
                  children: [
                    _buildIncidentQueueTab(context, itemsService, reports),
                    _buildUserAccessTab(context, itemsService),
                    _buildPoliceStolenDbTab(context),
                  ],
                ),
        ),
      ),
    );
  }

  // --- TAB 1: INCIDENT QUEUE ---
  Widget _buildIncidentQueueTab(BuildContext context, ItemsService itemsService, List<FraudReport> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Security Incidents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'All item claims and drop-off custody checks are operating safely.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final pendingCount = reports.where((r) => r.status == 'pendingReview' || r.status == 'investigating').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Status
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (pendingCount > 0 ? AppColors.danger : AppColors.success).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: (pendingCount > 0 ? AppColors.danger : AppColors.success).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  pendingCount > 0 ? Icons.gavel : Icons.verified_user,
                  color: pendingCount > 0 ? AppColors.danger : AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pendingCount > 0 ? '$pendingCount PENDING FRAUD REVIEW(S)' : 'ALL INCIDENTS RESOLVED',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: pendingCount > 0 ? AppColors.danger : AppColors.success,
                          fontSize: 12.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Admin Board holds sole authority to freeze cases, lock reward escrow, and revoke user access (Rule 1).',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Incident Cards
          ...reports.map((report) => _buildReportCard(context, itemsService, report)),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ItemsService itemsService, FraudReport report) {
    final isPending = report.status == 'pendingReview' || report.status == 'investigating';
    final isFrozen = report.status == 'frozen';

    Color severityColor;
    switch (report.severity) {
      case 'high':
        severityColor = AppColors.danger;
        break;
      case 'medium':
        severityColor = AppColors.warning;
        break;
      default:
        severityColor = AppColors.textSecondary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isFrozen
              ? AppColors.danger
              : (isPending ? severityColor.withValues(alpha: 0.4) : AppColors.border),
          width: isFrozen ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: severityColor, width: 1),
                  ),
                  child: Text(
                    '${report.severity.toUpperCase()} PRIORITY',
                    style: TextStyle(color: severityColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: TextStyle(
                      color: isFrozen ? AppColors.danger : (isPending ? Colors.white : AppColors.success),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${DateTime.now().difference(report.timestamp).inHours}h ago',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Incident Category & Case
            Text(
              report.categoryLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Case Item: ${report.reportedItemTitle}',
                  style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                if (report.reportedUserName != null) ...[
                  const SizedBox(width: 10),
                  const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 10),
                  Text(
                    'Subject: ${report.reportedUserName}',
                    style: const TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // Incident Narrative Statement
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_quote, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Reported by ${report.reporterRole.toUpperCase()} (Confidential):',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.description,
                    style: const TextStyle(fontSize: 12.5, color: Colors.white, height: 1.35),
                  ),
                  if (report.evidenceNotes != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'EVIDENCE / RECORD: ${report.evidenceNotes}',
                        style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (report.actionTaken != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Admin Action: ${report.actionTaken}',
                        style: const TextStyle(color: AppColors.success, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons for Pending or Frozen Reports
            if (isPending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.lock, size: 14, color: AppColors.danger),
                      label: const Text('FREEZE CASE & ESCROW', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        _handleFraudAction(
                          itemsService,
                          report.id,
                          'freezeCase',
                          'Case frozen & reward escrow locked pending investigation',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (report.reportedUserId != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.block, size: 14, color: AppColors.warning),
                        label: const Text('SUSPEND USER', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(color: AppColors.warning),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          _handleFraudAction(
                            itemsService,
                            report.id,
                            'suspendUser',
                            'Offending user suspended from all lost-item channels',
                          );
                        },
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                    tooltip: 'Dismiss False Alarm',
                    onPressed: () {
                      _handleFraudAction(
                        itemsService,
                        report.id,
                        'dismiss',
                        'Report verified and dismissed as false alarm',
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- TAB 2: USER ACCESS CONTROLS ---
  Widget _buildUserAccessTab(BuildContext context, ItemsService itemsService) {
    final usersList = AuthService.mockUsersList;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'USER ACCESS & TRUST REPUTATION',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
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
                      CircleAvatar(
                        backgroundColor: isSuspended ? AppColors.danger.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2),
                        child: Icon(
                          isSuspended ? Icons.block : Icons.person,
                          color: isSuspended ? AppColors.danger : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${user.role.toUpperCase()} • Trust: ${user.trustScore} pts',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
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
                          const SizedBox(height: 6),
                          if (user.role != 'admin')
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: isSuspended ? AppColors.success : AppColors.danger,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(60, 28),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _toggleUserStatus(itemsService, user),
                              child: Text(
                                isSuspended ? 'ACTIVATE' : 'SUSPEND',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
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
    );
  }

  // --- TAB 3: POLICE STOLEN PROPERTY REGISTER (RULE 11) ---
  Widget _buildPoliceStolenDbTab(BuildContext context) {
    final List<Map<String, String>> mockPoliceRecords = [
      {
        'title': 'iPhone 13 Pro 128GB (Graphite)',
        'serial': '357283109482716',
        'pncRef': 'PNC-2026-LON-9410',
        'force': 'British Transport Police (Kings Cross)',
        'status': 'FLAGGED STOLEN (MATCHED CLAIM)',
        'reportedDate': '2026-08-01',
      },
      {
        'title': 'MacBook Pro 16 M2 Max',
        'serial': 'C02G8192MD6R',
        'pncRef': 'PNC-2026-MET-4819',
        'force': 'Metropolitan Police (Camden)',
        'status': 'ACTIVE STOLEN REPORT',
        'reportedDate': '2026-07-28',
      },
      {
        'title': 'Rolex Submariner Date',
        'serial': 'R82910398',
        'pncRef': 'PNC-2026-MET-1129',
        'force': 'City of London Police',
        'status': 'ACTIVE STOLEN REPORT',
        'reportedDate': '2026-07-15',
      },
    ];

    final filteredRecords = mockPoliceRecords.where((record) {
      if (_stolenSearchQuery.isEmpty) return true;
      return record['title']!.toLowerCase().contains(_stolenSearchQuery.toLowerCase()) ||
          record['serial']!.toLowerCase().contains(_stolenSearchQuery.toLowerCase()) ||
          record['pncRef']!.toLowerCase().contains(_stolenSearchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_police, color: Colors.lightBlueAccent, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POLICE NATIONAL COMPUTER (PNC) GATEWAY',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlueAccent, fontSize: 12, letterSpacing: 0.8),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Automated cross-referencing against UK National Stolen Property Register to prevent criminal laundering of goods (Rule 11).',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search serial number, IMEI, or PNC Reference...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 18),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (val) => setState(() => _stolenSearchQuery = val),
          ),
          const SizedBox(height: 16),

          Text(
            'STOLEN PROPERTY REGISTER MATCHES (${filteredRecords.length})',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),

          ...filteredRecords.map((record) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.danger),
                            ),
                            child: Text(
                              record['status']!,
                              style: const TextStyle(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Logged: ${record['reportedDate']}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record['title']!,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Serial / IMEI: ${record['serial']}',
                        style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontFamily: 'monospace'),
                      ),
                      Text(
                        'Ref: ${record['pncRef']} • Force: ${record['force']}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
