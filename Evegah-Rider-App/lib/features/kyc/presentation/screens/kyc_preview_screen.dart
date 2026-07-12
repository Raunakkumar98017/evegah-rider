import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/kyc_service.dart';
import '../../data/services/kyc_ocr_service.dart';
import 'kyc_camera_screen.dart';

class KycPreviewScreen extends StatefulWidget {
  final KycStep step;
  final String imagePath;

  const KycPreviewScreen({
    super.key,
    required this.step,
    required this.imagePath,
  });

  @override
  State<KycPreviewScreen> createState() => _KycPreviewScreenState();
}

class _KycPreviewScreenState extends State<KycPreviewScreen> {
  final KycService _kycService = KycService();
  final KycOcrService _ocrService = KycOcrService();
  bool _isOcrRunning = false;

  @override
  void initState() {
    super.initState();
    if (widget.step == KycStep.aadhaarFront || widget.step == KycStep.aadhaarBack) {
      _runOcrExtraction();
    }
  }

  Future<void> _runOcrExtraction() async {
    setState(() {
      _isOcrRunning = true;
    });

    try {
      if (widget.step == KycStep.aadhaarFront) {
        final details = await _ocrService.extractDetails(widget.imagePath);
        if (mounted) {
          setState(() {
            _kycService.ocrName = details['name'] ?? "";
            _kycService.ocrAadhaarNumber = details['aadhaarNumber'] ?? "";
            _kycService.ocrDob = details['dob'] ?? "";
            _kycService.ocrGender = details['gender'] ?? "";
            _isOcrRunning = false;
          });
          _showOcrDetailsBottomSheet();
        }
      } else if (widget.step == KycStep.aadhaarBack) {
        final details = await _ocrService.extractBackDetails(widget.imagePath);
        if (mounted) {
          setState(() {
            _kycService.ocrAddress = details['address'] ?? "";
            _kycService.ocrPinCode = details['pinCode'] ?? "";
            _isOcrRunning = false;
          });
          _showOcrBackDetailsBottomSheet();
        }
      }
    } catch (e) {
      debugPrint("OCR trigger error: $e");
      if (mounted) {
        setState(() {
          _isOcrRunning = false;
        });
      }
    }
  }

  void _showOcrDetailsBottomSheet() {
    final TextEditingController nameController = TextEditingController(text: _kycService.ocrName);
    final TextEditingController numberController = TextEditingController(text: _kycService.ocrAadhaarNumber);
    final TextEditingController dobController = TextEditingController(text: _kycService.ocrDob);
    final TextEditingController genderController = TextEditingController(text: _kycService.ocrGender);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.document_scanner, color: Color(0xFF4313B8), size: 28),
                    SizedBox(width: 12),
                    Text(
                      "Extracted ID Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "We've collected these details using OCR. Please verify or edit them to ensure accuracy.",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // Form Fields
                _buildTextField(label: "Full Name", controller: nameController, icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(label: "Aadhaar Card Number", controller: numberController, icon: Icons.badge_outlined),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(label: "Date of Birth", controller: dobController, icon: Icons.calendar_today_outlined),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(label: "Gender", controller: genderController, icon: Icons.wc_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      _kycService.ocrName = nameController.text;
                      _kycService.ocrAadhaarNumber = numberController.text;
                      _kycService.ocrDob = dobController.text;
                      _kycService.ocrGender = genderController.text;
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4313B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Confirm Details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOcrBackDetailsBottomSheet() {
    final TextEditingController addressController = TextEditingController(text: _kycService.ocrAddress);
    final TextEditingController pinCodeController = TextEditingController(text: _kycService.ocrPinCode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.document_scanner, color: Color(0xFF4313B8), size: 28),
                    SizedBox(width: 12),
                    Text(
                      "Extracted Address Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "We've collected these details from the Aadhaar back side. Please verify or edit them to ensure accuracy.",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // Form Fields
                _buildTextField(label: "Full Address", controller: addressController, icon: Icons.home_outlined, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField(label: "PIN Code", controller: pinCodeController, icon: Icons.pin_drop_outlined),
                const SizedBox(height: 28),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      _kycService.ocrAddress = addressController.text;
                      _kycService.ocrPinCode = pinCodeController.text;
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4313B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Confirm Details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF4313B8), size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4313B8), width: 1.5),
            ),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _handleContinue() {
    KycStep? nextStep;

    switch (widget.step) {
      case KycStep.selfie:
        nextStep = KycStep.aadhaarFront;
        _kycService.updateStepStatus("Selfie", "Captured", filePath: widget.imagePath);
        break;
      case KycStep.aadhaarFront:
        nextStep = KycStep.aadhaarBack;
        _kycService.updateStepStatus("Aadhaar Front", "Captured", filePath: widget.imagePath);
        break;
      case KycStep.aadhaarBack:
        nextStep = null; // Done with all captures!
        _kycService.updateStepStatus("Aadhaar Back", "Captured", filePath: widget.imagePath);
        break;
    }

    if (nextStep != null) {
      // Go to next capture screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => KycCameraScreen(step: nextStep!),
        ),
      );
    } else {
      // Completed all steps! Go back to KycScreen (which will now show KYC Submitted state)
      // Pop all the way back to the root KycScreen
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    String successTitle = "";
    String successSubtitle = "";
    String continueBtnText = "Continue";
    int currentStep = 1;

    switch (widget.step) {
      case KycStep.selfie:
        successTitle = "Photo Captured!";
        successSubtitle = "Your live photo has been captured successfully.";
        continueBtnText = "Continue";
        currentStep = 2; // Active step on stepper is 2 during live photo captured view
        break;
      case KycStep.aadhaarFront:
        successTitle = "Front Captured!";
        successSubtitle = "Aadhaar front side captured successfully.";
        continueBtnText = "Continue";
        currentStep = 2; // Active step is 2
        break;
      case KycStep.aadhaarBack:
        successTitle = "Back Captured!";
        successSubtitle = "Aadhaar back side captured successfully.";
        continueBtnText = "Continue";
        currentStep = 3; // Active step is 3
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.step == KycStep.selfie ? "Live Photo" : (widget.step == KycStep.aadhaarFront ? "Aadhaar Front" : "Aadhaar Back"),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Stepper Header
              KycStepperHeader(activeStep: currentStep),
              const SizedBox(height: 36),

              // Success Icon & Confetti/Dots simulation
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 32),
                  ),
                  // Decorative confetti dots
                  ..._buildConfettiDecorations(),
                ],
              ),
              const SizedBox(height: 18),

              // Status messages
              Text(
                successTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                successSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Rounded Preview Image Container
              Expanded(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: kIsWeb
                        ? Image.network(
                            widget.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 80),
                          )
                        : (widget.imagePath.startsWith('/') ||
                                widget.imagePath.contains(':') ||
                                widget.imagePath.startsWith('file://'))
                            ? Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.broken_image, size: 80),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Loading OCR overlay if running
              if (_isOcrRunning)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4313B8)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Scanning details with OCR...",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),

              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context), // Go back to retake
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4313B8),
                        side: const BorderSide(color: Color(0xFF4313B8), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        widget.step == KycStep.selfie ? "Retake Photo" : "Retake",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isOcrRunning
                          ? null
                          : () {
                              if (widget.step == KycStep.aadhaarFront && _kycService.ocrName.isEmpty) {
                                _showOcrDetailsBottomSheet();
                              } else if (widget.step == KycStep.aadhaarBack && _kycService.ocrAddress.isEmpty) {
                                _showOcrBackDetailsBottomSheet();
                              } else {
                                _handleContinue();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4313B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        continueBtnText,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to generate some colorful dots around the green check circle
  List<Widget> _buildConfettiDecorations() {
    final List<Color> colors = [Colors.purple, Colors.blue, Colors.orange, Colors.red, Colors.green];
    return List.generate(8, (index) {
      double angle = (index * 45) * 3.14159 / 180;
      double radius = 42.0;
      return Transform.translate(
        offset: Offset(radius * math.cos(angle), radius * math.sin(angle)),
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: colors[index % colors.length],
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}
