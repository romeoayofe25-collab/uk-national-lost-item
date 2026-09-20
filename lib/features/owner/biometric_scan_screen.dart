import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class BiometricScanResult {
  final bool isVerified;
  final double confidence;
  final String biometricHash;
  final String documentType;
  final String documentMasked;

  BiometricScanResult({
    required this.isVerified,
    required this.confidence,
    required this.biometricHash,
    required this.documentType,
    required this.documentMasked,
  });
}

class BiometricScanScreen extends StatefulWidget {
  final String? preselectedDocType;

  const BiometricScanScreen({super.key, this.preselectedDocType});

  @override
  State<BiometricScanScreen> createState() => _BiometricScanScreenState();
}

enum ScanStage {
  ready,
  aligning,
  livenessPrompt,
  extracting,
  verified,
}

class _BiometricScanScreenState extends State<BiometricScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  ScanStage _stage = ScanStage.ready;
  String _selectedDocType = 'UK Passport';
  final _docNumberController = TextEditingController(text: '948201948');
  Timer? _stageTimer;

  final List<String> _docTypes = [
    'UK Passport',
    'UK Driving Licence',
    'CitizenCard / National ID',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedDocType != null && _docTypes.contains(widget.preselectedDocType)) {
      _selectedDocType = widget.preselectedDocType!;
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _animationController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }

  void _startScanProcess() {
    setState(() {
      _stage = ScanStage.aligning;
    });

    // Step 1: Aligning (2 seconds)
    _stageTimer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() {
        _stage = ScanStage.livenessPrompt;
      });

      // Step 2: Liveness blink action (2.5 seconds)
      _stageTimer = Timer(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        setState(() {
          _stage = ScanStage.extracting;
        });

        // Step 3: Biometric feature extraction (2 seconds)
        _stageTimer = Timer(const Duration(milliseconds: 2200), () {
          if (!mounted) return;
          setState(() {
            _stage = ScanStage.verified;
          });
        });
      });
    });
  }

  String _getMaskedDocNumber() {
    final raw = _docNumberController.text.trim();
    if (raw.length <= 4) return 'GBR-***-001';
    final prefix = _selectedDocType.startsWith('UK P') ? 'GBR-PAS' : (_selectedDocType.startsWith('UK D') ? 'GBR-DRV' : 'GBR-ID');
    return '$prefix-***-${raw.substring(raw.length - 4)}';
  }

  void _confirmAndReturn() {
    final result = BiometricScanResult(
      isVerified: true,
      confidence: 0.984,
      biometricHash: 'BIO-SHA256-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}-VERIFIED',
      documentType: _selectedDocType,
      documentMasked: _getMaskedDocNumber(),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        title: const Text('Biometric Identity Check'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, color: AppColors.primary, size: 14),
                SizedBox(width: 4),
                Text(
                  '256-Bit Encrypted',
                  style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Document Type Configuration Bar
            if (_stage == ScanStage.ready)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MATCHING GOVERNMENT ID',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDocType,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      dropdownColor: AppColors.surface,
                      items: _docTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDocType = val);
                      },
                    ),
                  ],
                ),
              ),

            // Scanning Viewfinder Area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Scanning Reticle Canvas
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(320, 420),
                        painter: BiometricReticlePainter(
                          progress: _animationController.value,
                          stage: _stage,
                        ),
                      );
                    },
                  ),

                  // Center Status Overlay UI
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: _buildStageInstructionCard(),
                  ),
                ],
              ),
            ),

            // Bottom Action Controls
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_stage == ScanStage.ready)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.face_retouching_natural),
                      label: const Text('Start Biometric Face Scan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      onPressed: _startScanProcess,
                    )
                  else if (_stage == ScanStage.verified)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirm & Attach Biometric Token', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      onPressed: _confirmAndReturn,
                    )
                  else
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      icon: const Icon(Icons.cancel, color: AppColors.textSecondary),
                      label: const Text('Cancel Scan', style: TextStyle(color: AppColors.textSecondary)),
                      onPressed: () {
                        _stageTimer?.cancel();
                        setState(() => _stage = ScanStage.ready);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageInstructionCard() {
    IconData icon;
    Color color;
    String title;
    String subtitle;

    switch (_stage) {
      case ScanStage.ready:
        icon = Icons.camera_front;
        color = AppColors.primary;
        title = 'Position Face Inside Oval';
        subtitle = 'Ensure your face is clearly lit without sunglasses or masks.';
        break;
      case ScanStage.aligning:
        icon = Icons.center_focus_strong;
        color = AppColors.primary;
        title = 'Holding Steady...';
        subtitle = 'Aligning 3D facial feature points and skin tone.';
        break;
      case ScanStage.livenessPrompt:
        icon = Icons.remove_red_eye;
        color = AppColors.warning;
        title = 'Liveness Check: Please Blink Slowly';
        subtitle = 'Detecting natural biological movement and eye reflectance.';
        break;
      case ScanStage.extracting:
        icon = Icons.memory;
        color = AppColors.secondary;
        title = 'Matching with ID Cryptographic Signature';
        subtitle = 'Comparing facial embeddings with $_selectedDocType...';
        break;
      case ScanStage.verified:
        icon = Icons.verified_user;
        color = AppColors.success;
        title = 'Biometric Identity Verified ✓';
        subtitle = 'Match Confidence: 98.4% • Liveness Confirmed';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BiometricReticlePainter extends CustomPainter {
  final double progress;
  final ScanStage stage;

  BiometricReticlePainter({required this.progress, required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ovalRect = Rect.fromCenter(center: center, width: size.width * 0.78, height: size.height * 0.82);

    Color themeColor;
    switch (stage) {
      case ScanStage.ready:
        themeColor = AppColors.primary.withValues(alpha: 0.6);
        break;
      case ScanStage.aligning:
        themeColor = AppColors.primary;
        break;
      case ScanStage.livenessPrompt:
        themeColor = AppColors.warning;
        break;
      case ScanStage.extracting:
        themeColor = AppColors.secondary;
        break;
      case ScanStage.verified:
        themeColor = AppColors.success;
        break;
    }

    // Draw dark vignette around the oval
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );

    // Draw main oval boundary
    final ovalPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stage == ScanStage.verified ? 3.5 : 2.0;
    canvas.drawOval(ovalRect, ovalPaint);

    // Draw corner reticle brackets
    final bracketPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;
    final r = ovalRect;

    // Top-left bracket
    canvas.drawLine(Offset(r.left, r.top + cornerLength), Offset(r.left, r.top), bracketPaint);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left + cornerLength, r.top), bracketPaint);

    // Top-right bracket
    canvas.drawLine(Offset(r.right - cornerLength, r.top), Offset(r.right, r.top), bracketPaint);
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right, r.top + cornerLength), bracketPaint);

    // Bottom-left bracket
    canvas.drawLine(Offset(r.left, r.bottom - cornerLength), Offset(r.left, r.bottom), bracketPaint);
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left + cornerLength, r.bottom), bracketPaint);

    // Bottom-right bracket
    canvas.drawLine(Offset(r.right - cornerLength, r.bottom), Offset(r.right, r.bottom), bracketPaint);
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right, r.bottom - cornerLength), bracketPaint);

    // Animated vertical laser scan line when actively scanning
    if (stage == ScanStage.aligning || stage == ScanStage.livenessPrompt || stage == ScanStage.extracting) {
      final laserY = r.top + (r.height * progress);
      final halfWidth = (r.width / 2) * math.sqrt(1 - math.pow((laserY - center.dy) / (r.height / 2), 2).clamp(0.0, 1.0));

      final laserPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.0),
            themeColor.withValues(alpha: 0.9),
            themeColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(center.dx - halfWidth, laserY, halfWidth * 2, 3))
        ..strokeWidth = 2.5;

      canvas.drawLine(
        Offset(center.dx - halfWidth, laserY),
        Offset(center.dx + halfWidth, laserY),
        laserPaint,
      );

      // Draw simulated biometric landmark points
      final landmarkPaint = Paint()
        ..color = themeColor.withValues(alpha: 0.6 + 0.3 * progress)
        ..style = PaintingStyle.fill;

      final dots = [
        Offset(center.dx - 35, center.dy - 30), // left eye
        Offset(center.dx + 35, center.dy - 30), // right eye
        Offset(center.dx, center.dy),          // nose bridge
        Offset(center.dx - 20, center.dy + 35), // left mouth
        Offset(center.dx + 20, center.dy + 35), // right mouth
        Offset(center.dx, center.dy + 70),     // chin
        Offset(center.dx - 60, center.dy + 10), // left cheek
        Offset(center.dx + 60, center.dy + 10), // right cheek
      ];

      for (var dot in dots) {
        canvas.drawCircle(dot, 3.0, landmarkPaint);
      }
    }

    // Success checkmark circle in center if verified
    if (stage == ScanStage.verified) {
      final checkBgPaint = Paint()
        ..color = AppColors.success.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 42, checkBgPaint);

      final checkCirclePaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, 42, checkCirclePaint);

      final checkPath = Path()
        ..moveTo(center.dx - 16, center.dy)
        ..lineTo(center.dx - 4, center.dy + 12)
        ..lineTo(center.dx + 16, center.dy - 12);
      canvas.drawPath(
        checkPath,
        Paint()
          ..color = AppColors.success
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BiometricReticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.stage != stage;
  }
}
