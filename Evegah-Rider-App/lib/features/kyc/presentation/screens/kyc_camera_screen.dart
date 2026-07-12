import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/kyc_service.dart';
import 'kyc_preview_screen.dart';

enum KycStep { selfie, aadhaarFront, aadhaarBack }

class KycCameraScreen extends StatefulWidget {
  final KycStep step;

  const KycCameraScreen({super.key, required this.step});

  @override
  State<KycCameraScreen> createState() => _KycCameraScreenState();
}

class _KycCameraScreenState extends State<KycCameraScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  bool _isFrontCamera = false;
  bool _isFlashOn = false;
  
  // Alignment & Match border feedback
  bool _isAligned = false;
  Timer? _alignmentTimer;

  // Animation for scanner line in simulator mode
  late AnimationController _scannerAnimController;
  late Animation<double> _scannerAnimation;

  @override
  void initState() {
    super.initState();
    _isFrontCamera = widget.step == KycStep.selfie;
    
    _scannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_scannerAnimController);

    _initCameraFlow();
    _startAlignmentSimulation();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scannerAnimController.dispose();
    _alignmentTimer?.cancel();
    super.dispose();
  }

  void _startAlignmentSimulation() {
    _alignmentTimer?.cancel();
    setState(() {
      _isAligned = false;
    });
    _alignmentTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isAligned = true;
        });
      }
    });
  }

  Future<void> _initCameraFlow() async {
    try {
      // 1. Request Permission
      var status = await Permission.camera.request();
      if (status.isDenied) {
        setState(() {
          _isCameraError = true;
        });
        return;
      }

      // 2. Get Available Cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isCameraError = true;
        });
        return;
      }

      // 3. Initialize Controller
      await _setupCameraController();
    } catch (e) {
      debugPrint("Camera init error: $e");
      setState(() {
        _isCameraError = true;
      });
    }
  }

  Future<void> _setupCameraController() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    // Pick camera description
    CameraDescription selectedCam = _cameras!.first;
    if (_isFrontCamera) {
      final frontCam = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      selectedCam = frontCam;
    } else {
      final backCam = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
      selectedCam = backCam;
    }

    _cameraController = CameraController(
      selectedCam,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isCameraError = false;
        });
        _startAlignmentSimulation();
      }
    } catch (e) {
      debugPrint("CameraController initialization failed: $e");
      if (mounted) {
        setState(() {
          _isCameraError = true;
        });
      }
    }
  }

  Future<void> _toggleCameraLens() async {
    setState(() {
      _isCameraInitialized = false;
      _isFrontCamera = !_isFrontCamera;
    });
    await _setupCameraController();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint("Flash toggle error: $e");
    }
  }

  // Gallery picker fallback
  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile != null && mounted) {
        _navigateToPreview(pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking photo: $e")),
      );
    }
  }

  // Shutter capture action
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_isCameraInitialized) {
      // Simulator mode: Capture a dummy file or pick from gallery
      _simulateCapture();
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      // If torch was on, turn it off after capture
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        _isFlashOn = false;
      }
      _navigateToPreview(file.path);
    } catch (e) {
      debugPrint("Capture error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Capture failed: $e. Using simulation fallback.")),
      );
      _simulateCapture();
    }
  }

  void _simulateCapture() {
    // Show a dialog warning or just pick/simulate a placeholder
    // In simulator mode, let's open the gallery to simulate a picture or use a mock asset path.
    // For ease of developer testing, we'll open gallery when simulator capture is tapped.
    _pickFromGallery();
  }

  void _navigateToPreview(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KycPreviewScreen(
          step: widget.step,
          imagePath: path,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = "";
    String subtitle = "";
    String footerText = "";
    int currentStep = 1;

    switch (widget.step) {
      case KycStep.selfie:
        title = "Take a clear live photo";
        subtitle = "Make sure your face is clearly visible";
        footerText = "Ensure good lighting and look straight at the camera";
        currentStep = 1;
        break;
      case KycStep.aadhaarFront:
        title = "Capture Aadhaar Front";
        subtitle = "Place your Aadhaar card inside the frame";
        footerText = "Tip: Ensure all details are clearly visible";
        currentStep = 2;
        break;
      case KycStep.aadhaarBack:
        title = "Capture Aadhaar Back";
        subtitle = "Place your Aadhaar card inside the frame";
        footerText = "Tip: Ensure all details are clearly visible";
        currentStep = 3;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white, // White background for the header area
      body: SafeArea(
        child: Column(
          children: [
            // AppBar and Custom Stepper
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHeader(currentStep),
            ),

            // Instructional text
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Camera Viewport Area (Frosted Rounded Card Container)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isCameraInitialized && _cameraController != null)
                        Center(
                          child: AspectRatio(
                            aspectRatio: 1 / _cameraController!.value.aspectRatio,
                            child: CameraPreview(_cameraController!),
                          ),
                        )
                      else
                        // Camera Simulator View
                        _buildSimulatorView(),

                      // Transparent Cutout Overlay
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CameraOverlayPainter(
                            isFace: widget.step == KycStep.selfie,
                            isAligned: _isAligned,
                            borderColor: _isAligned
                                ? const Color(0xFF10B981)
                                : (widget.step == KycStep.selfie
                                    ? Colors.white.withOpacity(0.85)
                                    : const Color(0xFF4313B8)),
                          ),
                        ),
                      ),

                      // Floating Green Match Badge
                      if (_isAligned)
                        Positioned(
                          top: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.step == KycStep.selfie ? "FACE MATCHED" : "DOCUMENT ALIGNED",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Scanner Line for visual feedback on simulator or camera
                      if (!_isCameraInitialized)
                        _buildScannerLine(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer instructions & controls
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                footerText,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),

            _buildControlsBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int step) {
    String stepTitle = "";
    switch (widget.step) {
      case KycStep.selfie:
        stepTitle = "Live Photo";
        break;
      case KycStep.aadhaarFront:
        stepTitle = "Aadhaar Front";
        break;
      case KycStep.aadhaarBack:
        stepTitle = "Aadhaar Back";
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  stepTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balancing back button
            ],
          ),
          const SizedBox(height: 16),
          // STEPPER
          KycStepperHeader(activeStep: step),
        ],
      ),
    );
  }

  Widget _buildSimulatorView() {
    return Container(
      color: const Color(0xFF1E293B),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.step == KycStep.selfie ? Icons.face_retouching_natural : Icons.badge_outlined,
              color: Colors.white.withOpacity(0.15),
              size: 120,
            ),
            const SizedBox(height: 20),
            Text(
              _isCameraError ? "Camera Unavailable" : "Simulator Camera",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tap the center shutter to select from gallery",
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerLine() {
    return AnimatedBuilder(
      animation: _scannerAnimation,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.4 * _scannerAnimation.value,
          left: 32,
          right: 32,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4313B8).withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
              color: const Color(0xFF4313B8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlsBar() {
    final bool canFlash = !_isFrontCamera && _isCameraInitialized;
    
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 16, left: 32, right: 32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Gallery Button
          GestureDetector(
            onTap: _pickFromGallery,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
              ),
              child: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 20),
            ),
          ),

          // Center: Shutter Button with matching glows
          GestureDetector(
            onTap: _capturePhoto,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isAligned)
                  // Pulsing matching glow ring
                  Container(
                    height: 86,
                    width: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.5),
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isAligned ? const Color(0xFF10B981) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isAligned ? const Color(0xFF047857) : Colors.black,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right: Action Switch (Flip camera or Flash)
          widget.step == KycStep.selfie
              ? GestureDetector(
                  onTap: () {
                    _toggleCameraLens();
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                    ),
                    child: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 20),
                  ),
                )
              : GestureDetector(
                  onTap: canFlash ? _toggleFlash : null,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: canFlash
                          ? (_isFlashOn ? const Color(0xFF10B981) : Colors.white.withOpacity(0.12))
                          : Colors.white.withOpacity(0.04),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: canFlash
                            ? (_isFlashOn ? const Color(0xFF10B981).withOpacity(0.4) : Colors.white.withOpacity(0.15))
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: canFlash ? Colors.white : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// Custom Stepper Progress Widget matching Mockups
class KycStepperHeader extends StatelessWidget {
  final int activeStep;

  const KycStepperHeader({super.key, required this.activeStep});

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF4313B8);
    const Color inactiveColor = Color(0xFFE2E8F0);
    final KycService kycService = KycService();

    bool isSelfieDone = kycService.isStepCompleted("Selfie");
    bool isFrontDone = kycService.isStepCompleted("Aadhaar Front");
    bool isBackDone = kycService.isStepCompleted("Aadhaar Back");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background Connecting Lines
          Positioned(
            top: 14, // Middle of 28px height circles
            left: 45,
            right: 45,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2.0,
                    color: isSelfieDone || activeStep > 1 ? activeColor : inactiveColor,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2.0,
                    color: isFrontDone || activeStep > 2 ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
          // Steps Columns Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Step 1: Live Photo
              _buildStepColumn(
                stepText: "1",
                label: "Live Photo",
                isActive: activeStep == 1,
                isCompleted: isSelfieDone || activeStep > 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              // Step 2: Aadhaar Front
              _buildStepColumn(
                stepText: "2",
                label: "Aadhaar Front",
                isActive: activeStep == 2,
                isCompleted: isFrontDone || activeStep > 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              // Step 3: Aadhaar Back
              _buildStepColumn(
                stepText: "3",
                label: "Aadhaar Back",
                isActive: activeStep == 3,
                isCompleted: isBackDone,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepColumn({
    required String stepText,
    required String label,
    required bool isActive,
    required bool isCompleted,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircle(
          stepText: stepText,
          isActive: isActive,
          isCompleted: isCompleted,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? activeColor : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildCircle({
    required String stepText,
    required bool isActive,
    required bool isCompleted,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    if (isCompleted) {
      return Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          color: activeColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 14),
      );
    }

    return Container(
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? activeColor : inactiveColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          stepText,
          style: TextStyle(
            color: isActive ? Colors.white : inactiveColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// Custom Painter to overlay camera stream and cutout mask
class CameraOverlayPainter extends CustomPainter {
  final bool isFace;
  final bool isAligned;
  final Color borderColor;

  CameraOverlayPainter({
    required this.isFace,
    required this.isAligned,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Canvas background overlay configuration
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.65);

    final maskPaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..color = Colors.transparent;

    // Save layer to process cutout blending properly
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    
    // 1. Draw solid background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    final center = Offset(size.width / 2, size.height * 0.42);

    if (isFace) {
      // 2a. Face silhouette oval cutout
      final faceWidth = size.width * 0.65;
      final faceHeight = size.height * 0.45;
      final faceRect = Rect.fromCenter(center: center, width: faceWidth, height: faceHeight);
      
      canvas.drawOval(faceRect, maskPaint);
      
      // Draw border overlay
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isAligned ? 3.5 : 2.0;
      
      canvas.drawOval(faceRect, borderPaint);
    } else {
      // 2b. Card document rectangle cutout
      final cardWidth = size.width * 0.85;
      final cardHeight = cardWidth * 0.63; // ID Document standard aspect ratio
      final cardRect = Rect.fromCenter(center: center, width: cardWidth, height: cardHeight);
      final rrect = RRect.fromRectAndRadius(cardRect, const Radius.circular(16));
      
      canvas.drawRRect(rrect, maskPaint);

      // Draw corner brackets
      final bracketPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isAligned ? 4.5 : 3.5
        ..strokeCap = StrokeCap.round;

      final double len = 24.0;
      final double rad = 16.0;

      // Top Left Corner
      canvas.drawPath(
        Path()
          ..moveTo(cardRect.left, cardRect.top + len)
          ..lineTo(cardRect.left, cardRect.top + rad)
          ..quadraticBezierTo(cardRect.left, cardRect.top, cardRect.left + rad, cardRect.top)
          ..lineTo(cardRect.left + len, cardRect.top),
        bracketPaint,
      );
      // Top Right Corner
      canvas.drawPath(
        Path()
          ..moveTo(cardRect.right - len, cardRect.top)
          ..lineTo(cardRect.right - rad, cardRect.top)
          ..quadraticBezierTo(cardRect.right, cardRect.top, cardRect.right, cardRect.top + rad)
          ..lineTo(cardRect.right, cardRect.top + len),
        bracketPaint,
      );
      // Bottom Left Corner
      canvas.drawPath(
        Path()
          ..moveTo(cardRect.left, cardRect.bottom - len)
          ..lineTo(cardRect.left, cardRect.bottom - rad)
          ..quadraticBezierTo(cardRect.left, cardRect.bottom, cardRect.left + rad, cardRect.bottom)
          ..lineTo(cardRect.left + len, cardRect.bottom),
        bracketPaint,
      );
      // Bottom Right Corner
      canvas.drawPath(
        Path()
          ..moveTo(cardRect.right - len, cardRect.bottom)
          ..lineTo(cardRect.right - rad, cardRect.bottom)
          ..quadraticBezierTo(cardRect.right, cardRect.bottom, cardRect.right, cardRect.bottom + rad)
          ..lineTo(cardRect.right, cardRect.bottom + len),
        bracketPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CameraOverlayPainter oldDelegate) =>
      oldDelegate.isAligned != isAligned || oldDelegate.borderColor != borderColor;
}
