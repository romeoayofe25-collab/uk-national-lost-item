import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';

class CollectionDetailsScreen extends StatelessWidget {
  final String itemId;

  const CollectionDetailsScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final itemsService = Provider.of<ItemsService>(context);
    final item = itemsService.getItemById(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collection Info')),
        body: const Center(child: Text('Item not found.')),
      );
    }

    final securePin = item.secureCollectionPin ?? '491-032';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Desk Info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/owner/details/${item.id}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ITEM READY FOR COLLECTION',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Location: Kings Cross Station - Customer Support Desk',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // QR and PIN code card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'YOUR SECURE COLLECTION CODE',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Present this single-use code to the intermediary representative.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Stylized QR code box
                    Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(12, (index) {
                          // Draw a mock barcodes / alignment grids
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(12, (dotIdx) {
                              final isBlack = (index * dotIdx + index) % 3 != 0;
                              return Container(
                                width: 8,
                                height: 8,
                                color: isBlack ? Colors.black : Colors.white,
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PIN: $securePin',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Location details card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CENTRE DETAILS',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    // Mock location map preview
                    GestureDetector(
                      onTap: () => context.push('/owner/map'),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF101622),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: GridPaper(
                                color: Colors.white.withValues(alpha: 0.02),
                                interval: 30,
                                subdivisions: 1,
                              ),
                            ),
                            const Center(
                              child: Icon(Icons.map, color: AppColors.primary, size: 36),
                            ),
                            const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  Icon(Icons.zoom_out_map, size: 12, color: AppColors.textSecondary),
                                  SizedBox(width: 4),
                                  Text('Tap to Open Live Map', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCentreRow(Icons.location_on, 'Location', 'Euston Rd, London N1 9AL'),
                    _buildCentreRow(Icons.access_time, 'Hours', 'Mon-Sun | 08:00 - 22:00'),
                    _buildCentreRow(Icons.directions, 'Directions', 'Located next to ticket gates, Platform 9.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Coordination Chat CTA
            OutlinedButton.icon(
              icon: const Icon(Icons.forum, color: AppColors.primary),
              label: const Text('Secure Chat with Centre Desk'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                context.go('/owner/chat/${item.id}');
              },
            ),
            const SizedBox(height: 12.0),

            // Demo Simulation shortcut
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
              label: const Text('Simulate Desk Staff Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.border,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                await itemsService.simulateHandover(item.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Simulation: Desk scanned PIN. Handover successful.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.go('/owner/details/${item.id}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentreRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                children: [
                  TextSpan(text: value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
