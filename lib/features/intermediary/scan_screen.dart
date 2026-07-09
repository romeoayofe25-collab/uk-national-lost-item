import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';
import '../../core/models/found_item_model.dart';
import '../../core/models/lost_item_model.dart';

class IntermediaryScanScreen extends StatefulWidget {
  const IntermediaryScanScreen({super.key});

  @override
  State<IntermediaryScanScreen> createState() => _IntermediaryScanScreenState();
}

class _IntermediaryScanScreenState extends State<IntermediaryScanScreen> {
  final _pinController = TextEditingController();
  String _errorMsg = '';
  bool _processing = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onKeyPress(String val) {
    setState(() {
      _errorMsg = '';
      if (val == 'CLEAR') {
        _pinController.clear();
      } else if (val == 'BACK') {
        if (_pinController.text.isNotEmpty) {
          _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
        }
      } else {
        if (_pinController.text.length < 10) {
          _pinController.text += val;
        }
      }
    });
  }

  Future<void> _submitPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    setState(() {
      _processing = true;
      _errorMsg = '';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final itemsService = Provider.of<ItemsService>(context, listen: false);
    final result = itemsService.getItemByPin(pin);

    setState(() => _processing = false);

    if (result == null) {
      setState(() => _errorMsg = 'PIN not recognized. Verify format (e.g. DEP-XXX or XXX-XXX).');
    } else {
      if (result is FoundItem) {
        if (mounted) {
          context.pushReplacement('/intermediary/deposit/${result.id}');
        }
      } else if (result is LostItem) {
        if (mounted) {
          context.pushReplacement('/intermediary/handover/${result.id}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In / Pickup Scanner'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Simulated Camera Viewfinder
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Viewfinder scanning target bracket outline
                        Center(
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.success, width: 3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        
                        // Animated Scanning Line simulation
                        Positioned(
                          top: 100,
                          left: 40,
                          right: 40,
                          child: Container(
                            height: 2,
                            color: AppColors.success.withValues(alpha: 0.8),
                          ),
                        ),

                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 120),
                              Icon(Icons.camera_alt, color: AppColors.textSecondary, size: 24),
                              SizedBox(height: 8),
                              Text(
                                'Align voucher QR code in bracket',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // PIN Input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _pinController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                      decoration: const InputDecoration(
                        hintText: 'OR ENTER PIN CODE',
                        hintStyle: TextStyle(fontSize: 16, color: AppColors.textSecondary, letterSpacing: 0),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    if (_errorMsg.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMsg,
                        style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Custom Keypad
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      _buildKeypadRow(['1', '2', '3']),
                      _buildKeypadRow(['4', '5', '6']),
                      _buildKeypadRow(['7', '8', '9']),
                      _buildKeypadRow(['DEP-', '0', '-']),
                      _buildKeypadActionsRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.background.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _onKeyPress(key),
                child: Text(
                  key,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadActionsRow() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _onKeyPress('CLEAR'),
                child: const Text('CLEAR', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _onKeyPress('BACK'),
                child: const Icon(Icons.backspace, color: AppColors.textSecondary, size: 20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _processing ? null : _submitPin,
                child: _processing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('ENTER', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
