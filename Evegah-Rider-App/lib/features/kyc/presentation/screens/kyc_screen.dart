import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/services/kyc_service.dart';
import '../../../../features/profile/data/services/profile_service.dart';
import 'kyc_camera_screen.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final KycService _kycService = KycService();
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    // Sync state from profile service if needed
    if (_profileService.kycStatus == "Approved") {
      _kycService.simulateVerificationApproval();
    } else if (_profileService.kycStatus == "Under Review") {
      _kycService.updateStepStatus("Selfie", "Captured");
      _kycService.updateStepStatus("Aadhaar Front", "Captured");
      _kycService.updateStepStatus("Aadhaar Back", "Captured");
    }
  }

  void _triggerStartKyc() {
    // Check which step is next
    KycStep nextStep = KycStep.selfie;
    if (_kycService.livePhotoStatus == "Captured" || _kycService.livePhotoStatus == "Verified") {
      if (_kycService.aadhaarFrontStatus == "Captured" || _kycService.aadhaarFrontStatus == "Verified") {
        nextStep = KycStep.aadhaarBack;
      } else {
        nextStep = KycStep.aadhaarFront;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KycCameraScreen(step: nextStep),
      ),
    ).then((_) {
      // Rebuild when returning to update checkboxes
      setState(() {});
    });
  }

  void _triggerSpecificStep(KycStep step) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KycCameraScreen(step: step),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = _kycService.kycStatus;

    if (status == "Verified") {
      _profileService.kycStatus = "Approved"; // Sync global status
      return _buildVerifiedView();
    } else if (status == "Under Review") {
      _profileService.kycStatus = "Under Review"; // Sync global status
      return _buildSubmittedView();
    } else {
      return _buildWelcomeView();
    }
  }

  // --- VIEW 1: KYC Welcome/Start Screen ---
  Widget _buildWelcomeView() {
    final bool isSelfieDone = _kycService.isStepCompleted("Selfie");
    final bool isFrontDone = _kycService.isStepCompleted("Aadhaar Front");
    final bool isBackDone = _kycService.isStepCompleted("Aadhaar Back");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("KYC Verification", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Shield user badge center graphic
              Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow ring
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4313B8).withOpacity(0.06),
                          blurRadius: 24,
                          spreadRadius: 4,
                        )
                      ],
                    ),
                  ),
                  // Shield Icon
                  Container(
                    height: 100,
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF4313B8),
                      size: 64,
                    ),
                  ),
                  // Inner user badge icon
                  const Positioned(
                    top: 38,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF4313B8),
                      size: 28,
                    ),
                  ),
                  // Small check badge overlay
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4313B8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 10),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                "Complete your KYC",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "To unlock all features and start your ride journey",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 1),

              // Steps List Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildStepRow(
                      icon: Icons.camera_alt_outlined,
                      title: "Live Photo",
                      subtitle: "Take your live photo",
                      isCompleted: isSelfieDone,
                      onTap: () => _triggerSpecificStep(KycStep.selfie),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100, indent: 64),
                    _buildStepRow(
                      icon: Icons.badge_outlined,
                      title: "Aadhaar Front",
                      subtitle: "Capture front side of Aadhaar",
                      isCompleted: isFrontDone,
                      onTap: () => _triggerSpecificStep(KycStep.aadhaarFront),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100, indent: 64),
                    _buildStepRow(
                      icon: Icons.badge_outlined,
                      title: "Aadhaar Back",
                      subtitle: "Capture back side of Aadhaar",
                      isCompleted: isBackDone,
                      onTap: () => _triggerSpecificStep(KycStep.aadhaarBack),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Start KYC Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _triggerStartKyc,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4313B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Start KYC",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Safe & Secure footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "Your information is safe and secure",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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

  // --- VIEW 2: KYC Submitted/Under Review View ---
  Widget _buildSubmittedView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Complete KYC", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Interactive Shield Icon for simulator debugging
              GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    _kycService.simulateVerificationApproval();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Developer mode: KYC Verification Approved! ✅"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 110,
                      width: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Color(0xFF4313B8),
                        size: 64,
                      ),
                    ),
                    const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "KYC Submitted!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Your KYC is under review",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const Spacer(flex: 1),

              // Review items status
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildStatusRow("Live Photo", "Captured"),
                    Divider(height: 1, color: Colors.grey.shade100, indent: 56),
                    _buildStatusRow("Aadhaar Front", "Captured"),
                    Divider(height: 1, color: Colors.grey.shade100, indent: 56),
                    _buildStatusRow("Aadhaar Back", "Captured"),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Info Alert
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDDD6FE).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF4313B8), size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "It usually takes a few minutes to verify. You will get notified once it's approved.",
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF4313B8).withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Go to Home Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to Home
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4313B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Go to Home",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- VIEW 3: KYC Verified View ---
  Widget _buildVerifiedView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("KYC Verified", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Verified Checkmark with custom confetti rings
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F7F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 80,
                    ),
                  ),
                  // Confetti bits simulation
                  ..._buildConfettiDecorations(),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "KYC Verified!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "You can now enjoy all features",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const Spacer(flex: 1),

              // Verified items list
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildStatusRow("Live Photo", "Verified"),
                    Divider(height: 1, color: Colors.grey.shade100, indent: 56),
                    _buildStatusRow("Aadhaar Front", "Verified"),
                    Divider(height: 1, color: Colors.grey.shade100, indent: 56),
                    _buildStatusRow("Aadhaar Back", "Verified"),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Explore Now Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4313B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Explore Now",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Row builder for Welcome view list
  Widget _buildStepRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF4313B8), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ),
      trailing: isCompleted
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFE6F7F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Color(0xFF10B981), size: 14),
            )
          : IconButton(
              icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14),
              onPressed: onTap,
            ),
      onTap: isCompleted ? null : onTap,
    );
  }

  // Row builder for Submitted/Verified view list
  Widget _buildStatusRow(String stepName, String statusLabel) {
    final bool isVerified = statusLabel == "Verified";
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: isVerified ? const Color(0xFFE6F7F0) : const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: isVerified ? const Color(0xFF10B981) : Colors.grey.shade600,
          size: 16,
        ),
      ),
      title: Text(
        stepName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
      ),
      trailing: Text(
        statusLabel,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isVerified ? const Color(0xFF10B981) : Colors.grey.shade500,
        ),
      ),
    );
  }

  // Simple Confetti decorations
  List<Widget> _buildConfettiDecorations() {
    final List<Color> colors = [Colors.purple, Colors.blue, Colors.orange, Colors.red, Colors.green];
    return List.generate(12, (index) {
      double angle = (index * 30) * 3.14159 / 180;
      double radius = 70.0;
      return Transform.translate(
        offset: Offset(radius * math.cos(angle), radius * math.sin(angle)),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colors[index % colors.length],
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}