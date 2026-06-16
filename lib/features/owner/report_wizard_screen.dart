import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';

class ReportWizardScreen extends StatefulWidget {
  const ReportWizardScreen({super.key});

  @override
  State<ReportWizardScreen> createState() => _ReportWizardScreenState();
}

class _ReportWizardScreenState extends State<ReportWizardScreen> {
  int _currentStep = 1;

  // Step 1 controllers
  final _titleController = TextEditingController();
  String _category = 'Electronics';
  final _brandController = TextEditingController();
  final _colourController = TextEditingController();
  final _marksController = TextEditingController();
  final _valueController = TextEditingController();

  // Step 2 controllers
  DateTime _dateLost = DateTime.now();
  TimeOfDay _timeLost = TimeOfDay.now();
  final _locationController = TextEditingController();
  String _selectedStationPin = 'Kings Cross Station';

  // Step 3 controllers
  final List<String> _photos = [];
  final List<String> _proofDocuments = [];
  final _serialController = TextEditingController();

  // Step 4 controllers
  bool _confirmAccuracy = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _colourController.dispose();
    _marksController.dispose();
    _valueController.dispose();
    _locationController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_titleController.text.trim().isEmpty) {
        _showError('Item Title is required.');
        return;
      }
      if (_valueController.text.trim().isEmpty || double.tryParse(_valueController.text.trim()) == null) {
        _showError('Please enter a valid estimated value.');
        return;
      }
    } else if (_currentStep == 2) {
      if (_locationController.text.trim().isEmpty) {
        _showError('Please specify the last known location.');
        return;
      }
    }

    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  Future<void> _submitReport() async {
    if (!_confirmAccuracy) {
      _showError('Please confirm the accuracy declaration.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final itemsService = Provider.of<ItemsService>(context, listen: false);
    final success = await itemsService.reportLostItem(
      title: _titleController.text.trim(),
      category: _category,
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      colour: _colourController.text.trim().isEmpty ? null : _colourController.text.trim(),
      uniqueMarks: _marksController.text.trim().isEmpty ? null : _marksController.text.trim(),
      estimatedValue: double.parse(_valueController.text.trim()),
      dateLost: _dateLost,
      timeLost: '${_timeLost.hour.toString().padLeft(2, '0')}:${_timeLost.minute.toString().padLeft(2, '0')}',
      lastKnownLocation: _locationController.text.trim(),
      photos: _photos,
      proofDocuments: _proofDocuments,
      serialNumber: _serialController.text.trim().isEmpty ? null : _serialController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lost Item successfully reported.'), backgroundColor: AppColors.success),
        );
        context.go('/owner');
      } else {
        _showError('Failed to submit report. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step $_currentStep of 4: ${_getStepTitle()}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep > 1 ? _prevStep : () => context.go('/owner'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator bar
              Row(
                children: List.generate(4, (index) {
                  final stepNum = index + 1;
                  final isActive = stepNum <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24.0),

              // Render current step layout
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildStepContent(),
                ),
              ),
              const SizedBox(height: 24.0),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 1)
                    TextButton(
                      onPressed: _prevStep,
                      child: const Text('Back', style: TextStyle(color: Colors.white70)),
                    )
                  else
                    const SizedBox.shrink(),
                  if (_currentStep < 4)
                    ElevatedButton(
                      onPressed: _nextStep,
                      child: const Text('Next Step'),
                    )
                  else
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            onPressed: _submitReport,
                            child: const Text('Submit Lost Report'),
                          ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Item Details';
      case 2:
        return 'Date & Location';
      case 3:
        return 'Verification';
      case 4:
        return 'Review & Submit';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1ItemDetails();
      case 2:
        return _buildStep2DateLocation();
      case 3:
        return _buildStep3Verification();
      case 4:
        return _buildStep4ReviewSubmit();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: ITEM DETAILS
  Widget _buildStep1ItemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('What did you lose?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Item Title *',
            hintText: 'e.g. iPhone 13 Pro',
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Category *'),
          items: const [
            DropdownMenuItem(value: 'Electronics', child: Text('Electronics (Smartphone, Laptop)')),
            DropdownMenuItem(value: 'Personal Accessories', child: Text('Personal Accessories (Wallet, Bag)')),
            DropdownMenuItem(value: 'Documents', child: Text('Documents (Passport, License)')),
            DropdownMenuItem(value: 'Keys', child: Text('Keys')),
            DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _category = val;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand (Optional)',
                  hintText: 'Apple',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _colourController,
                decoration: const InputDecoration(
                  labelText: 'Colour (Optional)',
                  hintText: 'Graphite',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _marksController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Unique Marks or Engravings (Optional)',
            hintText: 'e.g. Small scratch on the top-left corner, specific keychains',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _valueController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Estimated Value (£) *',
            hintText: '800.00',
            prefixText: '£ ',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: const Text(
            'This value is used internally by the Admin Board to assess return safety and standardized reward options. It is not shared with finders or open to negotiation.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
          ),
        ),
      ],
    );
  }

  // STEP 2: DATE & LOCATION
  Widget _buildStep2DateLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Where and when was it lost?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text('${_dateLost.day}/${_dateLost.month}/${_dateLost.year}'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dateLost,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateLost = picked;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(_timeLost.format(context)),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _timeLost,
                  );
                  if (picked != null) {
                    setState(() {
                      _timeLost = picked;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Last Known Location *',
            hintText: 'e.g. London Kings Cross Station',
          ),
        ),
        const SizedBox(height: 20),
        const Text('MAP LOCATION PIN', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFF101622),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              // Mock Map lines and graphics
              Positioned.fill(
                child: CustomPaint(
                  painter: _MockMapPainter(selectedStation: _selectedStationPin),
                ),
              ),
              // Grid overlay
              Positioned.fill(
                child: GridPaper(
                  color: Colors.white.withValues(alpha: 0.02),
                  interval: 40,
                  subdivisions: 1,
                ),
              ),
              // Quick pin selector buttons
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMapPinChip('Kings Cross Station'),
                      const SizedBox(width: 8),
                      _buildMapPinChip('Euston Rd Cafe'),
                      const SizedBox(width: 8),
                      _buildMapPinChip('Pret Euston'),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_pin, color: AppColors.danger, size: 36),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedStationPin,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPinChip(String label) {
    final isSelected = _selectedStationPin == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStationPin = label;
          _locationController.text = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // STEP 3: VERIFICATION EVIDENCE
  Widget _buildStep3Verification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Provide ownership proof', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text(
          'These details help the Admin Board verify your claim. Uploads and serial numbers are kept completely private and are never exposed to finders or intermediaries.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 20),
        const Text('Item Photos (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _photos.add('photo_lost_item_${_photos.length + 1}.jpg');
                });
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: AppColors.textSecondary),
                    SizedBox(height: 4),
                    Text('Upload', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
                  itemCount: _photos.length,
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
                          child: Center(
                            child: Icon(Icons.image, color: AppColors.primary.withValues(alpha: 0.6), size: 32),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _photos.removeAt(idx);
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
        const Text('Proof of Ownership / Receipt (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _proofDocuments.add('receipt_${_proofDocuments.length + 1}.pdf');
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
                    Icon(Icons.note_add, color: AppColors.textSecondary),
                    SizedBox(height: 4),
                    Text('Upload PDF', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
                  itemCount: _proofDocuments.length,
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
                                _proofDocuments.removeAt(idx);
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
        TextField(
          controller: _serialController,
          decoration: const InputDecoration(
            labelText: 'Serial Number / IMEI (If applicable)',
            hintText: 'e.g. 357283109482716',
          ),
        ),
      ],
    );
  }

  // STEP 4: REVIEW & SUBMIT
  Widget _buildStep4ReviewSubmit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Review your report details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        _buildReviewRow('Item Name', _titleController.text),
        _buildReviewRow('Category', _category),
        _buildReviewRow('Brand/Colour', '${_brandController.text.isEmpty ? 'N/A' : _brandController.text} / ${_colourController.text.isEmpty ? 'N/A' : _colourController.text}'),
        _buildReviewRow('Unique Marks', _marksController.text.isEmpty ? 'None specified' : _marksController.text),
        _buildReviewRow('Estimated Value', '£ ${_valueController.text}'),
        _buildReviewRow('Last Location', _locationController.text),
        _buildReviewRow('Lost Date', '${_dateLost.day}/${_dateLost.month}/${_dateLost.year} at ${_timeLost.format(context)}'),
        _buildReviewRow('Evidence Files', '${_photos.length} Photo(s), ${_proofDocuments.length} Document(s)'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.gavel, color: AppColors.warning, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Filing fraudulent lost claims is an offense under the UK Theft Act 1968. Repeated false listings will result in automatic trust penalty and account lockouts.',
                  style: TextStyle(color: AppColors.warning, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _confirmAccuracy,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _confirmAccuracy = val;
                  });
                }
              },
            ),
            const Expanded(
              child: Text(
                'I confirm that all details provided in this lost report are accurate to the best of my knowledge.',
                style: TextStyle(fontSize: 13, height: 1.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a mock dark railway/station map coordinate preview
class _MockMapPainter extends CustomPainter {
  final String selectedStation;

  _MockMapPainter({required this.selectedStation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw grid paths
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.4, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.6, size.height), paint);

    // Draw stylized station platforms / buildings
    final buildingPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.25, 60, 30), const Radius.circular(4)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.65, size.height * 0.45, 80, 40), const Radius.circular(4)), buildingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
