import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';

class IntermediaryInventoryScreen extends StatefulWidget {
  const IntermediaryInventoryScreen({super.key});

  @override
  State<IntermediaryInventoryScreen> createState() => _IntermediaryInventoryScreenState();
}

class _IntermediaryInventoryScreenState extends State<IntermediaryInventoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);

    // Merge found items in custody and lost items that are approved for collection
    final storedFound = itemsService.foundItems
        .where((item) => item.status == 'deposited' || item.status == 'matched')
        .toList();

    final approvedLost = itemsService.items
        .where((item) => item.status == 'readyForCollection')
        .toList();

    // Combine them into a unified list representation
    final List<Map<String, dynamic>> ledger = [];

    for (var f in storedFound) {
      ledger.add({
        'id': f.id,
        'title': f.title,
        'category': f.category,
        'type': 'found',
        'status': f.status,
        'location': f.storageLocation ?? 'Shelf A-1',
        'details': f.publicDescription,
        'date': f.dropOffTimestamp ?? f.dateFound,
      });
    }

    for (var l in approvedLost) {
      ledger.add({
        'id': l.id,
        'title': l.title,
        'category': l.category,
        'type': 'lost',
        'status': l.status,
        'location': l.storageLocation ?? 'Locker #4',
        'details': l.uniqueMarks ?? '',
        'date': l.dateLost,
      });
    }

    // Filter list by query
    final filteredLedger = ledger.where((item) {
      final q = _searchQuery.toLowerCase();
      return item['title'].toString().toLowerCase().contains(q) ||
          item['category'].toString().toLowerCase().contains(q) ||
          item['location'].toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custody Storage Ledger'),
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
          child: Column(
            children: [
              // Search Input Row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by title, category, or locker...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
              ),

              // Ledger List
              Expanded(
                child: filteredLedger.isEmpty
                    ? const Center(
                        child: Text(
                          'No items found matching query.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredLedger.length,
                        itemBuilder: (context, idx) {
                          final item = filteredLedger[idx];
                          final isLostClaim = item['type'] == 'lost';
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
                                      Text(
                                        item['title'],
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (isLostClaim ? AppColors.warning : AppColors.primary).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isLostClaim ? 'Ready for Pickup' : 'Deposited Stored',
                                          style: TextStyle(
                                            color: isLostClaim ? AppColors.warning : AppColors.primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Category: ${item['category']} • Location: ${item['location']}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Logged: ${item['date'].day}/${item['date'].month}/${item['date'].year}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(color: AppColors.border, height: 1),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.storage, color: AppColors.textSecondary, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            item['location'],
                                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          if (isLostClaim)
                                            TextButton.icon(
                                              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                              icon: const Icon(Icons.check, color: AppColors.success, size: 16),
                                              label: const Text('Handover', style: TextStyle(color: AppColors.success, fontSize: 13)),
                                              onPressed: () => context.push('/intermediary/handover/${item['id']}'),
                                            ),
                                          const SizedBox(width: 8),
                                          TextButton.icon(
                                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 16),
                                            label: const Text('Chat Logs', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                                            onPressed: () => context.push('/intermediary/chat/${item['id']}'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
