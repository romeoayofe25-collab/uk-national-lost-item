import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';


class AdminCentreManagerScreen extends StatefulWidget {
  const AdminCentreManagerScreen({super.key});

  @override
  State<AdminCentreManagerScreen> createState() => _AdminCentreManagerScreenState();
}

class _AdminCentreManagerScreenState extends State<AdminCentreManagerScreen> {
  // Local mock list for intermediary drop-off centre authorization states
  final List<Map<String, dynamic>> _mockCentres = [
    {
      'name': 'Kings Cross Intermediary Centre',
      'lockers': 10,
      'occupied': 2,
      'isAuthorized': true,
      'status': 'Verified Partner',
    },
    {
      'name': 'Euston Support Desk',
      'lockers': 6,
      'occupied': 0,
      'isAuthorized': true,
      'status': 'Verified Partner',
    },
    {
      'name': 'St Pancras Reception',
      'lockers': 15,
      'occupied': 0,
      'isAuthorized': false,
      'status': 'Pending Verification',
    },
  ];

  bool _isProcessing = false;

  void _toggleAuthorization(int index) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    
    setState(() {
      final isAuth = _mockCentres[index]['isAuthorized'] as bool;
      _mockCentres[index]['isAuthorized'] = !isAuth;
      _mockCentres[index]['status'] = !isAuth ? 'Verified Partner' : 'Suspended Partner';
      _isProcessing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_mockCentres[index]['name']} authorization status updated!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drop-off Centre Management'),
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
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _mockCentres.length,
                itemBuilder: (context, index) {
                  final centre = _mockCentres[index];
                  final isAuth = centre['isAuthorized'] as bool;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isAuth ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.store,
                                  color: isAuth ? AppColors.success : AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      centre['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      centre['status'],
                                      style: TextStyle(
                                        color: isAuth ? AppColors.success : AppColors.warning,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Locker Capacity', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${centre['lockers']} total lockers',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Occupancy Volume', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${centre['occupied']} items in custody',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                                icon: const Icon(Icons.inventory, size: 18),
                                label: const Text('VIEW INVENTORY'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Inventory ledger for ${centre['name']} loaded.'),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAuth ? AppColors.danger : AppColors.success,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                                onPressed: () => _toggleAuthorization(index),
                                child: Text(isAuth ? 'REVOKE AUTH' : 'AUTHORIZE'),
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
    );
  }
}
