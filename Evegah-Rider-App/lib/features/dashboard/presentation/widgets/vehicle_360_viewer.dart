import 'dart:math' as math;
import 'package:flutter/material.dart';

class Vehicle360Viewer extends StatefulWidget {
  final String vehicleModel;
  final String imageAsset;

  const Vehicle360Viewer({
    super.key,
    required this.vehicleModel,
    required this.imageAsset,
  });

  @override
  State<Vehicle360Viewer> createState() => _Vehicle360ViewerState();
}

class _Vehicle360ViewerState extends State<Vehicle360Viewer> with SingleTickerProviderStateMixin {
  double _rotationAngle = 0.0; // In radians
  bool _isAutoRotating = true;
  late AnimationController _autoRotateController;
  int? _selectedHotspotIndex;

  // Hotspots definitions with local coordinates (relative from 0.0 to 1.0)
  // X: 0.0 (left) to 1.0 (right), Y: 0.0 (top) to 1.0 (bottom)
  final List<Map<String, dynamic>> _hotspots = [
    {
      'name': 'Smart LCD Console',
      'x': 0.38,
      'y': 0.22,
      'desc': 'Sleek display showcasing speed, battery status, and active ride mode.',
      'icon': Icons.speed,
    },
    {
      'name': 'Removable Battery',
      'x': 0.52,
      'y': 0.62,
      'desc': 'High density Li-Ion battery pack. 60 km range, swappable in 30 seconds.',
      'icon': Icons.battery_charging_full,
    },
    {
      'name': 'Comfort Saddle',
      'x': 0.65,
      'y': 0.44,
      'desc': 'Premium high-density foam seat designed for relaxed urban rides.',
      'icon': Icons.airline_seat_recline_normal,
    },
    {
      'name': 'High-torque Hub Motor',
      'x': 0.76,
      'y': 0.78,
      'desc': 'Electric brushless DC motor with 25 km/h top speed and smooth acceleration.',
      'icon': Icons.bolt,
    },
    {
      'name': 'Responsive Disc Brake',
      'x': 0.22,
      'y': 0.82,
      'desc': 'Hydraulic disc brakes ensuring immediate stopping power in all weather.',
      'icon': Icons.lens_blur_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _autoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
        if (_isAutoRotating) {
          setState(() {
            _rotationAngle = _autoRotateController.value * 2 * math.pi;
          });
        }
      });

    if (_isAutoRotating) {
      _autoRotateController.repeat();
    }
  }

  @override
  void dispose() {
    _autoRotateController.dispose();
    super.dispose();
  }

  void _toggleAutoRotate() {
    setState(() {
      _isAutoRotating = !_isAutoRotating;
      if (_isAutoRotating) {
        _autoRotateController.forward(from: _rotationAngle / (2 * math.pi));
        _autoRotateController.repeat();
      } else {
        _autoRotateController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine horizontal flip based on rotation angle (to make it look like a full 360 spin)
    final double normalizedAngle = _rotationAngle % (2 * math.pi);
    final bool isFlipped = normalizedAngle > math.pi / 2 && normalizedAngle < 3 * math.pi / 2;
    
    // Scale slightly dynamically during rotation for a 3D depth effect
    final double depthScale = 0.9 + 0.1 * math.cos(normalizedAngle * 2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          // Header / Angle Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vehicleModel,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Drag to rotate vehicle 360°",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Auto-rotate badge button
              GestureDetector(
                onTap: _toggleAutoRotate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isAutoRotating ? const Color(0xFFEEF2FF) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isAutoRotating ? const Color(0xFF818CF8) : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sync,
                        size: 14,
                        color: _isAutoRotating ? const Color(0xFF4F46E5) : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isAutoRotating ? "Auto Spin" : "Paused",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isAutoRotating ? const Color(0xFF4F46E5) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          // Main 360 Spin viewport with gesture detector
          GestureDetector(
            onHorizontalDragStart: (_) {
              if (_isAutoRotating) {
                _toggleAutoRotate();
              }
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                // Adjust sensitivity
                _rotationAngle -= details.delta.dx * 0.012;
                if (_rotationAngle < 0) _rotationAngle += 2 * math.pi;
                _rotationAngle %= 2 * math.pi;
                _selectedHotspotIndex = null; // Clear details on drag
              });
            },
            child: Container(
              height: 240,
              width: double.infinity,
              color: Colors.transparent, // Ensures catchable gestures
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Pedestal / Shadow Platform at bottom
                  Positioned(
                    bottom: 25,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateX(1.3),
                      alignment: Alignment.center,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4313B8).withValues(alpha: 0.15),
                              blurRadius: 25,
                              spreadRadius: 5,
                            )
                          ],
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF4313B8).withValues(alpha: 0.2),
                              const Color(0xFF4313B8).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Main Vehicle Image with Y-rotation transform
                  Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..scale(depthScale, depthScale)
                      ..rotateY(_rotationAngle),
                    alignment: Alignment.center,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..scale(isFlipped ? -1.0 : 1.0, 1.0), // horizontal flip to simulate continuous rotation
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Image.asset(
                          widget.imageAsset,
                          fit: BoxFit.contain,
                          height: 170,
                        ),
                      ),
                    ),
                  ),

                  // 3. Hotspots overlays
                  if (!_isAutoRotating)
                    ...List.generate(_hotspots.length, (index) {
                      final spot = _hotspots[index];
                      // Transform hotspot coordinates based on current spin angle
                      final double currentRotation = _rotationAngle % (2 * math.pi);
                      
                      // Calculate mock movement of hotspots to follow rotation
                      final double originalX = spot['x'];
                      final double centerOffsetX = originalX - 0.5;
                      final double rotatedOffsetX = centerOffsetX * math.cos(currentRotation);
                      final double finalX = 0.5 + rotatedOffsetX;
                      
                      // Fade out hotspots if they rotate to the back
                      final double opacity = math.sin(currentRotation + (originalX * math.pi)) > 0.0 ? 1.0 : 0.15;
                      if (opacity < 0.2) return const SizedBox.shrink(); // hide back spots

                      return Positioned(
                        left: MediaQuery.of(context).size.width * 0.75 * finalX,
                        top: 240 * (spot['y'] as num).toDouble(),
                        child: Opacity(
                          opacity: opacity,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedHotspotIndex == index) {
                                  _selectedHotspotIndex = null;
                                } else {
                                  _selectedHotspotIndex = index;
                                }
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing anchor ring
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 8.0, end: 18.0),
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                  builder: (context, val, child) {
                                    return Container(
                                      width: val,
                                      height: val,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF4313B8).withValues(alpha: 0.5),
                                          width: 1.5,
                                        ),
                                      ),
                                    );
                                  },
                                  onEnd: () {},
                                ),
                                // Solid center dot
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _selectedHotspotIndex == index ? Colors.white : const Color(0xFF4313B8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF4313B8),
                                      width: _selectedHotspotIndex == index ? 2 : 0,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // Bottom Dial Compass
          Container(
            height: 35,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CustomPaint(
              painter: _CompassPainter(rotationAngle: _rotationAngle),
            ),
          ),
          const SizedBox(height: 16),

          // Display selected hotspot details
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _selectedHotspotIndex != null
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4313B8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _hotspots[_selectedHotspotIndex!]['icon'],
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hotspots[_selectedHotspotIndex!]['name'],
                                style: const TextStyle(
                                  color: Color(0xFF1E1452),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _hotspots[_selectedHotspotIndex!]['desc'],
                                style: const TextStyle(
                                  color: Color(0xFF5B21B6),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, size: 16, color: Color(0xFF8B5CF6)),
                          onPressed: () {
                            setState(() {
                              _selectedHotspotIndex = null;
                            });
                          },
                        )
                      ],
                    ),
                  )
                : const SizedBox(height: 0),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double rotationAngle;

  _CompassPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    final double midX = size.width / 2;
    final double midY = size.height / 2;

    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), paint);

    final double step = size.width / 12;
    final double offset = (rotationAngle / (2 * math.pi)) * size.width;

    for (int i = -10; i < 20; i++) {
      double tickX = midX + (i * step) - (offset % step);
      if (tickX < 0 || tickX > size.width) continue;

      final double distanceFromCenter = (tickX - midX).abs();
      final double normalizedDistance = 1.0 - (distanceFromCenter / (size.width / 2)).clamp(0.0, 1.0);
      
      final tickPaint = Paint()
        ..color = Color.lerp(Colors.grey.shade300, const Color(0xFF4313B8), normalizedDistance)!
        ..strokeWidth = 1.5;

      final double tickHeight = 6.0 + 8.0 * normalizedDistance;
      canvas.drawLine(
        Offset(tickX, midY - tickHeight / 2),
        Offset(tickX, midY + tickHeight / 2),
        tickPaint,
      );
    }

    final needlePaint = Paint()
      ..color = const Color(0xFF4313B8)
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(midX, midY - 12), Offset(midX, midY + 12), needlePaint);
    
    final path = Path()
      ..moveTo(midX - 4, midY - 12)
      ..lineTo(midX + 4, midY - 12)
      ..lineTo(midX, midY - 16)
      ..close();
    
    final fillPaint = Paint()
      ..color = const Color(0xFF4313B8)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle;
  }
}
