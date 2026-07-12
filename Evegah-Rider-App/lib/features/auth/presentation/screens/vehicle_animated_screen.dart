import 'dart:async';
import 'package:flutter/material.dart';
import 'create_profile_screen.dart';

class VehicleAnimatedScreen extends StatefulWidget {
  const VehicleAnimatedScreen({super.key});

  @override
  State<VehicleAnimatedScreen> createState() => _VehicleAnimatedScreenState();
}

class _VehicleAnimatedScreenState extends State<VehicleAnimatedScreen> with TickerProviderStateMixin {
  late AnimationController _roadController;
  late AnimationController _vibrationController;
  late AnimationController _entryController;
  late AnimationController _pulseController;

  late Animation<Offset> _scooterOffsetAnimation;
  late Animation<double> _scooterVibrationAnimation;

  String _statusText = "Initializing electric motor...";
  late Timer _textTimer;
  late Timer _exitTimer;

  @override
  void initState() {
    super.initState();

    // 1. Road scrolling animation controller (continuous scroll)
    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    // 2. Engine vibration animation controller (frequency oscillations)
    _vibrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat(reverse: true);

    _scooterVibrationAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _vibrationController, curve: Curves.easeInOut),
    );

    // 3. Entry slide-in controller
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scooterOffsetAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-2.0, 0), end: const Offset(0.0, 0))
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(Offset.zero),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(3.0, 0))
            .chain(CurveTween(curve: Curves.easeInQuint)),
        weight: 20,
      ),
    ]).animate(_entryController);

    // 4. BLE signal pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start entry animation
    _entryController.forward();

    // Set up status messages timings
    _textTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _statusText = "Syncing with Daly BMS...");
    });
    
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _statusText = "BMS Status: Good. Engine Started!");
    });

    // Schedule navigation transition
    _exitTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const CreateProfileScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _roadController.dispose();
    _vibrationController.dispose();
    _entryController.dispose();
    _pulseController.dispose();
    _textTimer.cancel();
    _exitTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAFBFE),
              Color(0xFFEEF2FF),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Stars / Speed particles in background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _roadController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SpeedLinesPainter(_roadController.value),
                  );
                },
              ),
            ),

            // Center Vehicle and Bluetooth Pulse stack
            Center(
              child: SlideTransition(
                position: _scooterOffsetAnimation,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // BLE signal pulse waves emitting from scooter dashboard
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: PulsePainter(_pulseController.value),
                          );
                        },
                      ),

                      // Bouncing/Vibrating Scooter graphic
                      AnimatedBuilder(
                        animation: _scooterVibrationAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _scooterVibrationAnimation.value),
                            child: Image.asset(
                              "assets/black_scooter_city.png",
                              width: 220,
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Moving Road lines at the bottom
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 12,
                child: AnimatedBuilder(
                  animation: _roadController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ScrollingRoadPainter(_roadController.value),
                    );
                  },
                ),
              ),
            ),

            // Status message
            Positioned(
              bottom: 60,
              child: Column(
                children: [
                  Text(
                    _statusText,
                    style: const TextStyle(
                      color: Color(0xFF0F0933),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Smart. Sustainable. Shared.",
                    style: TextStyle(
                      color: Color(0xFF4313B8), // Brand purple accent
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollingRoadPainter extends CustomPainter {
  final double animationValue;
  ScrollingRoadPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    // Draw main solid thin road baseline
    canvas.drawRect(Rect.fromLTWH(0, size.height - 2, size.width, 2), paint);

    // Draw moving dash lines representing road surface markings
    final double dashWidth = 30.0;
    final double dashSpace = 20.0;
    final double totalWidth = dashWidth + dashSpace;
    final double offset = -animationValue * totalWidth;

    paint.color = const Color(0xFF4313B8).withValues(alpha: 0.35); // Purple dashes

    double startX = offset;
    while (startX < size.width + totalWidth) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, 0, dashWidth, 4),
          const Radius.circular(2),
        ),
        paint,
      );
      startX += totalWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SpeedLinesPainter extends CustomPainter {
  final double animationValue;
  SpeedLinesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Fixed vertical offsets for speed lines
    final List<double> yPositions = [
      size.height * 0.2,
      size.height * 0.35,
      size.height * 0.55,
      size.height * 0.7,
      size.height * 0.82
    ];

    for (int i = 0; i < yPositions.length; i++) {
      final double y = yPositions[i];
      final double speed = (i + 1) * 1.5;
      final double offset = -(animationValue * size.width * speed) % size.width;
      
      final double lineLen = 60.0 + (i * 15);
      
      // Draw first segment
      canvas.drawLine(Offset(offset, y), Offset(offset + lineLen, y), paint);
      // Draw wrap segment
      canvas.drawLine(Offset(offset - size.width, y), Offset(offset - size.width + lineLen, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PulsePainter extends CustomPainter {
  final double progress;
  PulsePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2.5;

    for (int i = 0; i < 2; i++) {
      final double t = (progress + (i * 0.5)) % 1.0;
      final double radius = maxRadius * t;
      final double opacity = (1.0 - t) * 0.25;

      final paint = Paint()
        ..color = const Color(0xFF4313B8).withValues(alpha: opacity) // Purple pulse
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
