import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/services/items_service.dart';

class ReportFoundItemScreen extends StatefulWidget {
  const ReportFoundItemScreen({super.key});

  @override
  State<ReportFoundItemScreen> createState() => _ReportFoundItemScreenState();
}

class _ReportFoundItemScreenState extends State<ReportFoundItemScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  final _titleController = TextEditingController();
  String _category = 'Electronics';
  final _brandController = TextEditingController();
  final _colourController = TextEditingController();
  final _publicDescriptionController = TextEditingController();
  
  DateTime _dateFound = DateTime.now();
  String _timeFound = '12:00';
  String _locationFound = '';
  final double _latitude = 51.5308; // Kings Cross default
  final double _longitude = -0.1238;

  final _privateDetailsController = TextEditingController();
  final List<String> _photos = [];
  
  bool _acceptedTerms = false;
  bool _submitting = false;

  final List<String> _categories = [
    'Electronics',
    'Bags',
    'Personal Accessories',
    'Keys',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _colourController.dispose();
    _publicDescriptionController.dispose();
    _privateDetailsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitReport() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the legal compliance declaration')),
      );
      return;
    }

    setState(() => _submitting = true);
    final itemsService = Provider.of<ItemsService>(context, listen: false);

    final success = await itemsService.reportFoundItem(
      title: _titleController.text.trim(),
      category: _category,
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      colour: _colourController.text.trim().isEmpty ? null : _colourController.text.trim(),
      publicDescription: _publicDescriptionController.text.trim(),
      privateDetails: _privateDetailsController.text.trim().isEmpty ? null : _privateDetailsController.text.trim(),
      dateFound: _dateFound,
      timeFound: _timeFound,
      locationFound: _locationFound.isEmpty ? 'Kings Cross Station' : _locationFound,
      latitude: _latitude,
      longitude: _longitude,
      photos: _photos,
    );

    setState(() => _submitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Found item reported successfully! Please proceed to drop off.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/finder');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit report. Please try again.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Found Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep > 0 ? _prevStep : () => context.pop(),
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
        child: SafeArea(
          child: Column(
            children: [
              // Step Indicators
              _buildStepIndicator(),
              const SizedBox(height: 16),
              
              // Wizard Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStepContent(),
                  ),
                ),
              ),

              // Bottom Actions
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;
          return Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isActive
                    ? AppColors.primary
                    : (isCompleted ? AppColors.success : AppColors.border),
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive || isCompleted ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
              ),
              if (index < 3) ...[
                const SizedBox(width: 8),
                Container(
                  width: 35,
                  height: 2,
                  color: isCompleted ? AppColors.success : AppColors.border,
                ),
                const SizedBox(width: 8),
              ]
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Form();
      case 1:
        return _buildStep2Location();
      case 2:
        return _buildStep3PrivateDetails();
      case 3:
        return _buildStep4Summary();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1Form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 1: Public Item Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the general features of the item. Remember to keep this description generic and exclude highly identifying details.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Item Name / Title *',
              hintText: 'e.g. iPhone 13 Pro',
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name or title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category *'),
            dropdownColor: AppColors.surface,
            items: _categories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _category = val);
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _brandController,
            decoration: const InputDecoration(
              labelText: 'Brand (Optional)',
              hintText: 'e.g. Apple, Nike, etc.',
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _colourController,
            decoration: const InputDecoration(
              labelText: 'Primary Colour (Optional)',
              hintText: 'e.g. Black, Blue, Graphite',
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _publicDescriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Public General Description *',
              hintText: 'e.g. Found on the lobby chairs, looks like it has a blue case.',
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a public general description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2: Date & Location Found',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pinpoint where and when you found this item to aid matching algorithms.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        // Date Picker Field
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dateFound,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => _dateFound = picked);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Date Found *'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_dateFound.day}/${_dateFound.month}/${_dateFound.year}',
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(Icons.calendar_today, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Time Picker Field
        InkWell(
          onTap: () async {
            final tod = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 12, minute: 0),
            );
            if (tod != null) {
              setState(() {
                _timeFound = '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Time Found *'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_timeFound, style: const TextStyle(color: Colors.white)),
                const Icon(Icons.access_time, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          initialValue: _locationFound,
          decoration: const InputDecoration(
            labelText: 'Location / Centre Name (Optional)',
            hintText: 'e.g. Kings Cross Station, Hyde Park',
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => _locationFound = val,
        ),
        const SizedBox(height: 16),

        // Stylized Mock Map
        const Text(
          'Pinpoint Map Location (Simulated GPS Pin)',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              // Grid Background representing a mock dark obsidian glass map
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: GridPaper(
                    color: AppColors.primary,
                    divisions: 2,
                    subdivisions: 1,
                  ),
                ),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_pin, color: AppColors.danger, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Kings Cross Station area selected',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'GPS Coordinates: 51.5308° N, 0.1238° W',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'GPS LOCK ACTIVE',
                    style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3PrivateDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3: Private Characteristic Verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        
        // PII & Rule 5 Warning Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield, color: AppColors.primary, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rule 5 Compliant: Data Protection Warning',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'To prevent fraudulent claims, do NOT include highly specific details (such as stickers, passcode patterns, serial numbers, or wallpaper images) in the public description fields.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _privateDetailsController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Private Unique Details (Admin Only) *',
            hintText: 'e.g. lock screen wallpaper photo, unique sticker on back, serial numbers, passcode info.',
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),

        const Text(
          'Photo Upload (Optional)',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Mock Attach Photo'),
              onPressed: () {
                setState(() {
                  _photos.add('mock_photo_url_${_photos.length + 1}.jpg');
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Simulated photo added successfully')),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${_photos.length} photos uploaded',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep4Summary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4: Review & Legal Submission',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'Verify all inputs are correct before finalizing. False declarations are punishable.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Title', _titleController.text),
              _summaryRow('Category', _category),
              _summaryRow('Brand', _brandController.text.isEmpty ? 'N/A' : _brandController.text),
              _summaryRow('Colour', _colourController.text.isEmpty ? 'N/A' : _colourController.text),
              _summaryRow('Public Desc', _publicDescriptionController.text),
              _summaryRow('Date Found', '${_dateFound.day}/${_dateFound.month}/${_dateFound.year}'),
              _summaryRow('Time Found', _timeFound),
              _summaryRow('Location', _locationFound.isEmpty ? 'Kings Cross Station (GPS Lock)' : _locationFound),
              _summaryRow('Private Details', _privateDetailsController.text.isEmpty ? 'None provided' : _privateDetailsController.text),
              _summaryRow('Photos count', '${_photos.length}'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Theft Act Warning
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.gavel, color: AppColors.danger, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'LEGAL DECLARATION & WARNING',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'By submitting this found report, you confirm that you are in lawful possession of the item and will deposit it at a verified Drop-off Centre. Dishonest claim submissions or withholding found properties can constitute theft under the UK Theft Act 1968 or fraud under the Fraud Act 2006.',
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 11, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        CheckboxListTile(
          value: _acceptedTerms,
          title: const Text(
            'I certify that this found report is accurate and I understand my legal obligations to hand the item over to authorised centres.',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          activeColor: AppColors.primary,
          checkColor: Colors.white,
          onChanged: (val) {
            if (val != null) setState(() => _acceptedTerms = val);
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: _prevStep,
              child: const Text('Back'),
            )
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: _currentStep == 3
                ? (_submitting ? null : _submitReport)
                : _nextStep,
            child: _currentStep == 3
                ? (_submitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Found Report'))
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
