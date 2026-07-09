import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class OwnerMapScreen extends StatefulWidget {
  const OwnerMapScreen({super.key});

  @override
  State<OwnerMapScreen> createState() => _OwnerMapScreenState();
}

class _OwnerMapScreenState extends State<OwnerMapScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Coordinates representing mock places on our Custom Canvas
  // Map dimensions are conceptually 1000 x 1000
  final Offset _userLocation = const Offset(500, 750); // Euston Road
  
  final List<Map<String, dynamic>> _allCentres = [
    {
      'id': 'c1',
      'name': 'Kings Cross Intermediary Centre',
      'address': 'Euston Rd, London N1 9AL',
      'hours': 'Mon-Sun | 08:00 - 22:00',
      'position': const Offset(650, 450),
      'distance': '0.2 miles',
      'status': 'Verified Partner',
      'lockers': '10 active lockers',
      'isAuthorized': true,
      'instructions': 'Located next to ticket gates, Platform 9.',
    },
    {
      'id': 'c2',
      'name': 'Euston Support Desk',
      'address': 'Euston Station, London NW1 2RT',
      'hours': 'Mon-Sat | 09:00 - 20:00',
      'position': const Offset(350, 600),
      'distance': '0.4 miles',
      'status': 'Verified Partner',
      'lockers': '6 active lockers',
      'isAuthorized': true,
      'instructions': 'Inside main concourse behind WHSmith.',
    },
    {
      'id': 'c3',
      'name': 'St Pancras Reception',
      'address': 'Pancras Rd, London N1C 4QP',
      'hours': 'Mon-Sun | 24 Hours',
      'position': const Offset(550, 350),
      'distance': '0.5 miles',
      'status': 'Pending Verification',
      'lockers': '15 active lockers',
      'isAuthorized': false,
      'instructions': 'Upper level next to Eurostar departures.',
    },
  ];

  Map<String, dynamic>? _selectedCentre;
  bool _drawDirections = false;
  late AnimationController _directionsController;
  late Animation<double> _directionsAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCentre = _allCentres[0]; // Select Kings Cross by default
    _drawDirections = true;

    _directionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _directionsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _directionsController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _directionsController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCentres {
    if (_searchQuery.trim().isEmpty) return _allCentres;
    return _allCentres.where((c) {
      final name = c['name'].toString().toLowerCase();
      final address = c['address'].toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || address.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Custom Canvas Map View
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                // Determine if user tapped near any pin position
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localPos = renderBox.globalToLocal(details.globalPosition);
                
                // Conceptual mapping of screen width/height to 1000x1000 canvas
                final screenWidth = renderBox.size.width;
                final screenHeight = renderBox.size.height;
                
                for (var centre in _allCentres) {
                  final Offset pos = centre['position'];
                  final screenX = (pos.dx / 1000.0) * screenWidth;
                  final screenY = (pos.dy / 1000.0) * screenHeight;
                  
                  final distance = sqrt(pow(localPos.dx - screenX, 2) + pow(localPos.dy - screenY, 2));
                  if (distance < 30.0) { // 30 pixels tap radius
                    setState(() {
                      _selectedCentre = centre;
                      _drawDirections = true;
                    });
                    break;
                  }
                }
              },
              child: AnimatedBuilder(
                animation: _directionsAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: MapCustomPainter(
                      userLocation: _userLocation,
                      centres: _allCentres,
                      selectedCentre: _selectedCentre,
                      drawDirections: _drawDirections,
                      dashOffsetPhase: _directionsAnimation.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // Top Header Overlay with Back Button and Search Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.surface,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/owner');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Partner Centre Finder',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search TextField
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search counter desks...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected Centre Details overlay card at the bottom
          if (_selectedCentre != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Hero(
                tag: 'centre_details_${_selectedCentre!['id']}',
                child: Card(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                              child: const Icon(Icons.store, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCentre!['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_selectedCentre!['distance']} • ${_selectedCentre!['address']}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                                const Text('Hours', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedCentre!['hours'],
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (_selectedCentre!['isAuthorized'] ? AppColors.success : AppColors.warning).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _selectedCentre!['isAuthorized'] ? AppColors.success : AppColors.warning),
                              ),
                              child: Text(
                                _selectedCentre!['status'].toUpperCase(),
                                style: TextStyle(
                                  color: _selectedCentre!['isAuthorized'] ? AppColors.success : AppColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _selectedCentre!['instructions'],
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.navigation),
                          label: const Text('SIMULATE WALKING NAV'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Simulation: Navigating to ${_selectedCentre!['name']}...'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Horizontal Quick list selection overlay if query matches multiple centres
          if (_selectedCentre == null && _filteredCentres.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCentres.length,
                  itemBuilder: (context, index) {
                    final centre = _filteredCentres[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCentre = centre;
                            _drawDirections = true;
                          });
                        },
                        child: Card(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  centre['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  centre['address'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Distance: ${centre['distance']}',
                                  style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom Painter to draw streets, buildings, user location dot, counter pins, and walking path
class MapCustomPainter extends CustomPainter {
  final Offset userLocation;
  final List<Map<String, dynamic>> centres;
  final Map<String, dynamic>? selectedCentre;
  final bool drawDirections;
  final double dashOffsetPhase;

  MapCustomPainter({
    required this.userLocation,
    required this.centres,
    required this.selectedCentre,
    required this.drawDirections,
    required this.dashOffsetPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw solid dark background matching AppColors.background
    final bgPaint = Paint()..color = AppColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines mapping
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 1.0;
    
    const double gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw mock streets (London Euston / Kings Cross style)
    final streetPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.4)
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round;

    final thinStreetPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.2)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    // Euston Road (Horizontal main)
    canvas.drawLine(
      Offset(-50, size.height * 0.75),
      Offset(size.width + 50, size.height * 0.75),
      streetPaint,
    );

    // Pancras Road (Diagonal)
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.9),
      Offset(size.width * 0.75, size.height * 0.2),
      streetPaint,
    );

    // York Way (Vertical right)
    canvas.drawLine(
      Offset(size.width * 0.8, -50),
      Offset(size.width * 0.8, size.height + 50),
      streetPaint,
    );

    // Minor connector streets
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.75),
      Offset(size.width * 0.35, size.height * 0.3),
      thinStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.3),
      thinStreetPaint,
    );

    // 3. Draw walking directions if a centre is selected
    if (drawDirections && selectedCentre != null) {
      final Offset targetPos = selectedCentre!['position'];
      final targetScreenX = (targetPos.dx / 1000.0) * size.width;
      final targetScreenY = (targetPos.dy / 1000.0) * size.height;

      final userScreenX = (userLocation.dx / 1000.0) * size.width;
      final userScreenY = (userLocation.dy / 1000.0) * size.height;

      final pathPaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw standard L-shape walking routing on street grid
      final Path routePath = Path();
      routePath.moveTo(userScreenX, userScreenY);
      
      // Navigate to horizontal intersection first
      final cornerX = targetScreenX;
      final cornerY = userScreenY;
      
      routePath.lineTo(cornerX, cornerY);
      routePath.lineTo(targetScreenX, targetScreenY);

      // Dash path animation
      _drawDashedPath(canvas, routePath, pathPaint);
    }

    // 4. Draw Centre Pins
    for (var centre in centres) {
      final Offset pos = centre['position'];
      final x = (pos.dx / 1000.0) * size.width;
      final y = (pos.dy / 1000.0) * size.height;

      final isSelected = selectedCentre != null && selectedCentre!['id'] == centre['id'];
      final isAuth = centre['isAuthorized'] as bool;

      // Pin Color
      final Color pinColor = isSelected
          ? AppColors.primary
          : (isAuth ? AppColors.success : AppColors.warning);

      // Draw outer pulse glow if selected
      if (isSelected) {
        final glowPaint = Paint()
          ..color = pinColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 24.0, glowPaint);
      }

      // Draw pin base
      final pinPaint = Paint()
        ..color = pinColor
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // Draw droplet/pin shape
      final path = Path();
      path.moveTo(x, y);
      path.quadraticBezierTo(x - 12, y - 20, x - 12, y - 30);
      path.arcToPoint(Offset(x + 12, y - 30), radius: const Radius.circular(12));
      path.quadraticBezierTo(x + 12, y - 20, x, y);
      path.close();

      canvas.drawPath(path, pinPaint);
      canvas.drawPath(path, borderPaint);

      // Draw pin center dot
      final centerDotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y - 30), 4.0, centerDotPaint);
    }

    // 5. Draw User Location Dot
    final userX = (userLocation.dx / 1000.0) * size.width;
    final userY = (userLocation.dy / 1000.0) * size.height;

    // Glowing halo pulse
    final pulsePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(userX, userY), 16.0, pulsePaint);

    final userDotPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(userX, userY), 8.0, userDotPaint);

    final userBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(userX, userY), 8.0, userBorderPaint);
  }

  // Helper method to draw walking dashes with phase animation
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 8.0;
    const double gapWidth = 6.0;
    
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = dashOffsetPhase * (dashWidth + gapWidth);
      while (distance < metric.length) {
        final double nextDistance = min(distance + dashWidth, metric.length);
        final Path extract = metric.extractPath(distance, nextDistance);
        canvas.drawPath(extract, paint);
        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapCustomPainter oldDelegate) {
    return oldDelegate.selectedCentre != selectedCentre ||
        oldDelegate.drawDirections != drawDirections ||
        oldDelegate.dashOffsetPhase != dashOffsetPhase;
  }
}
