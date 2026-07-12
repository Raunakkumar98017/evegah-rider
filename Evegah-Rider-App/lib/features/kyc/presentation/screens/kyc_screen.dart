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
  // =========================================================
  // SERVICES
  // =========================================================

  final KycService _kycService = KycService();
  final ProfileService _profileService = ProfileService();

  // =========================================================
  // EVEGAH BRAND COLORS
  // =========================================================

  static const Color brandPurple = Color(0xFF24105E);
  static const Color brightPurple = Color(0xFF4313B8);
  static const Color limeGreen = Color(0xFFBFFF00);

  static const Color pageBackground = Color(0xFFF8F9FD);
  static const Color darkText = Color(0xFF111827);
  static const Color greyText = Color(0xFF8A93A5);
  static const Color lightBorder = Color(0xFFE6E9F0);

  // =========================================================
  // INITIALIZE KYC STATUS
  // =========================================================

  @override
  void initState() {
    super.initState();

    // Synchronize the KYC status with ProfileService.

    if (_profileService.kycStatus == "Approved") {
      _kycService.simulateVerificationApproval();
    } else if (_profileService.kycStatus == "Under Review") {
      _kycService.updateStepStatus(
        "Selfie",
        "Captured",
      );

      _kycService.updateStepStatus(
        "Aadhaar Front",
        "Captured",
      );

      _kycService.updateStepStatus(
        "Aadhaar Back",
        "Captured",
      );
    }
  }

  // =========================================================
  // START OR CONTINUE THE COMPLETE GUIDED KYC FLOW
  // =========================================================

  void _triggerStartKyc() {
    final bool selfieCompleted =
        _kycService.isStepCompleted("Selfie");

    final bool frontCompleted =
        _kycService.isStepCompleted("Aadhaar Front");

    final bool backCompleted =
        _kycService.isStepCompleted("Aadhaar Back");

    KycStep? nextStep;

    if (!selfieCompleted) {
      nextStep = KycStep.selfie;
    } else if (!frontCompleted) {
      nextStep = KycStep.aadhaarFront;
    } else if (!backCompleted) {
      nextStep = KycStep.aadhaarBack;
    }

    if (nextStep == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All KYC verification steps are completed."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _openKycCamera(
      step: nextStep,
      continueToNextStep: true,
    );
  }

  // =========================================================
  // OPEN ONLY THE SELECTED KYC STEP
  // =========================================================

  void _triggerSpecificStep(KycStep step) {
    final bool selfieCompleted =
        _kycService.isStepCompleted("Selfie");

    final bool frontCompleted =
        _kycService.isStepCompleted("Aadhaar Front");

    if (step == KycStep.selfie) {
      _openKycCamera(
        step: step,
        continueToNextStep: false,
      );
      return;
    }

    if (step == KycStep.aadhaarFront) {
      if (!selfieCompleted) {
        _showLockedStepMessage(
          "Complete Live Photo first to unlock Aadhaar Front.",
        );
        return;
      }

      _openKycCamera(
        step: step,
        continueToNextStep: false,
      );
      return;
    }

    if (!selfieCompleted) {
      _showLockedStepMessage(
        "Complete Live Photo first to unlock Aadhaar Back.",
      );
      return;
    }

    if (!frontCompleted) {
      _showLockedStepMessage(
        "Complete Aadhaar Front first to unlock Aadhaar Back.",
      );
      return;
    }

    _openKycCamera(
      step: step,
      continueToNextStep: false,
    );
  }

  // =========================================================
  // OPEN KYC CAMERA
  // =========================================================

  Future<void> _openKycCamera({
    required KycStep step,
    required bool continueToNextStep,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KycCameraScreen(
          step: step,
          continueToNextStep: continueToNextStep,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // LOCKED-STEP MESSAGE
  // =========================================================

  void _showLockedStepMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brandPurple,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: 21,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SELECT SCREEN ACCORDING TO KYC STATUS
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final String status = _kycService.kycStatus;

    if (status == "Verified") {
      _profileService.kycStatus = "Approved";

      return _buildVerifiedView();
    }

    if (status == "Under Review") {
      _profileService.kycStatus = "Under Review";

      return _buildSubmittedView();
    }

    return _buildWelcomeView();
  }

  // =========================================================
  // KYC WELCOME SCREEN
  // =========================================================

  Widget _buildWelcomeView() {
    final bool isSelfieDone =
        _kycService.isStepCompleted(
      "Selfie",
    );

    final bool isFrontDone =
        _kycService.isStepCompleted(
      "Aadhaar Front",
    );

    final bool isBackDone =
        _kycService.isStepCompleted(
      "Aadhaar Back",
    );

    final bool isFrontLocked =
        !isSelfieDone;

    final bool isBackLocked =
        !isSelfieDone || !isFrontDone;

    final int completedSteps = [
      isSelfieDone,
      isFrontDone,
      isBackDone,
    ].where((step) => step).length;

    final double progress =
        completedSteps / 3;

    return Scaffold(
      backgroundColor: pageBackground,

      body: SafeArea(
        child: Column(
          children: [
            // =================================================
            // TOP HEADER
            // =================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                12,
              ),

              child: Row(
                children: [
                  // Back button

                  Material(
                    color: Colors.transparent,

                    child: InkWell(
                      onTap: () {
                        Navigator.pop(
                          context,
                        );
                      },

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),

                      child: Container(
                        height: 44,
                        width: 44,

                        decoration:
                            BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),

                          border: Border.all(
                            color: lightBorder,
                          ),
                        ),

                        child: const Icon(
                          Icons
                              .arrow_back_ios_new_rounded,

                          color: darkText,

                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      "KYC Verification",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color: darkText,

                        fontSize: 20,

                        fontWeight:
                            FontWeight.w800,

                        letterSpacing: -0.4,
                      ),
                    ),
                  ),

                  // Empty space keeps title centred.

                  const SizedBox(
                    height: 44,
                    width: 44,
                  ),
                ],
              ),
            ),

            // =================================================
            // PAGE CONTENT
            // =================================================

            Expanded(
              child:
                  SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),

                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  28,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // =========================================
                    // MAIN KYC CARD
                    // =========================================

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(
                        22,
                      ),

                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          begin:
                              Alignment.topLeft,

                          end:
                              Alignment.bottomRight,

                          colors: [
                            brandPurple,
                            brightPurple,
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          28,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: brightPurple
                                .withValues(
                              alpha: 0.18,
                            ),

                            blurRadius: 28,

                            offset:
                                const Offset(
                              0,
                              12,
                            ),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          // Icon and progress status

                          Row(
                            children: [
                              Container(
                                height: 62,
                                width: 62,

                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha: 0.12,
                                  ),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),

                                  border:
                                      Border.all(
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha: 0.14,
                                    ),
                                  ),
                                ),

                                child:
                                    const Icon(
                                  Icons
                                      .verified_user_outlined,

                                  color:
                                      limeGreen,

                                  size: 35,
                                ),
                              ),

                              const Spacer(),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha: 0.12,
                                  ),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    30,
                                  ),
                                ),

                                child: Text(
                                  "$completedSteps of 3 completed",

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,

                                    fontSize: 10,

                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          const Text(
                            "Verify your identity",

                            style: TextStyle(
                              color:
                                  Colors.white,

                              fontSize: 25,

                              fontWeight:
                                  FontWeight.w800,

                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          Text(
                            "Complete these simple steps to unlock all Evegah rides and features.",

                            style: TextStyle(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.70,
                              ),

                              fontSize: 12,

                              height: 1.5,
                            ),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          // Progress title

                          Row(
                            children: [
                              const Text(
                                "KYC progress",

                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,

                                  fontSize: 11,

                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),

                              const Spacer(),

                              Text(
                                "${(progress * 100).round()}%",

                                style:
                                    const TextStyle(
                                  color:
                                      limeGreen,

                                  fontSize: 11,

                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 9,
                          ),

                          // Progress bar

                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),

                            child:
                                LinearProgressIndicator(
                              value: progress,

                              minHeight: 7,

                              backgroundColor:
                                  Colors.white
                                      .withValues(
                                alpha: 0.16,
                              ),

                              valueColor:
                                  const AlwaysStoppedAnimation<
                                      Color>(
                                limeGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 29,
                    ),

                    // =========================================
                    // VERIFICATION SECTION
                    // =========================================

                    const Text(
                      "Complete these steps",

                      style: TextStyle(
                        color: darkText,

                        fontSize: 19,

                        fontWeight:
                            FontWeight.w800,

                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    const Text(
                      "Make sure all photos are clear and readable.",

                      style: TextStyle(
                        color: greyText,

                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(
                      height: 17,
                    ),

                    // =========================================
                    // LIVE PHOTO
                    // =========================================

                    _buildKycStepCard(
                      number: "1",

                      title: "Live Photo",

                      subtitle:
                          "Take a clear photo of your face",

                      icon:
                          Icons.camera_alt_rounded,

                      isCompleted:
                          isSelfieDone,

                      isLocked:
                          false,

                      onTap: () {
                        _triggerSpecificStep(
                          KycStep.selfie,
                        );
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =========================================
                    // AADHAAR FRONT
                    // =========================================

                    _buildKycStepCard(
                      number: "2",

                      title: "Aadhaar Front",

                      subtitle:
                          isFrontLocked
                              ? "Complete Live Photo to unlock"
                              : "Capture the front side clearly",

                      icon:
                          Icons.badge_outlined,

                      isCompleted:
                          isFrontDone,

                      isLocked:
                          isFrontLocked,

                      onTap: () {
                        _triggerSpecificStep(
                          KycStep
                              .aadhaarFront,
                        );
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =========================================
                    // AADHAAR BACK
                    // =========================================

                    _buildKycStepCard(
                      number: "3",

                      title: "Aadhaar Back",

                      subtitle:
                          isBackLocked
                              ? "Complete Aadhaar Front to unlock"
                              : "Capture the back side clearly",

                      icon:
                          Icons.contact_mail_outlined,

                      isCompleted:
                          isBackDone,

                      isLocked:
                          isBackLocked,

                      onTap: () {
                        _triggerSpecificStep(
                          KycStep
                              .aadhaarBack,
                        );
                      },
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // =========================================
                    // SECURITY CARD
                    // =========================================

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(
                        15,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF0FDF4,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),

                        border: Border.all(
                          color:
                              const Color(
                            0xFFDCFCE7,
                          ),
                        ),
                      ),

                      child:
                          const Row(
                        children: [
                          Icon(
                            Icons
                                .lock_outline_rounded,

                            color:
                                Color(
                              0xFF16A34A,
                            ),

                            size: 22,
                          ),

                          SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  "Your data is protected",

                                  style:
                                      TextStyle(
                                    color:
                                        Color(
                                      0xFF166534,
                                    ),

                                    fontSize: 12,

                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),

                                SizedBox(
                                  height: 3,
                                ),

                                Text(
                                  "Your information is encrypted and securely stored.",

                                  style:
                                      TextStyle(
                                    color:
                                        Color(
                                      0xFF568164,
                                    ),

                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 21,
                    ),

                    // =========================================
                    // START OR CONTINUE BUTTON
                    // =========================================

                    SizedBox(
                      height: 57,

                      width:
                          double.infinity,

                      child:
                          ElevatedButton(
                        onPressed:
                            _triggerStartKyc,

                        style:
                            ElevatedButton
                                .styleFrom(
                          elevation: 0,

                          backgroundColor:
                              brightPurple,

                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              18,
                            ),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            Text(
                              completedSteps ==
                                      0
                                  ? "Start KYC Verification"
                                  : "Continue Verification",

                              style:
                                  const TextStyle(
                                fontSize: 15,

                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            const SizedBox(
                              width: 9,
                            ),

                            const Icon(
                              Icons
                                  .arrow_forward_rounded,

                              size: 21,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    const Center(
                      child: Text(
                        "It usually takes less than 2 minutes",

                        style: TextStyle(
                          color: greyText,

                          fontSize: 10,

                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // KYC VERIFICATION STEP CARD
  // =========================================================

  Widget _buildKycStepCard({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFFBBF7D0)
                  : isLocked
                      ? const Color(0xFFE5E7EB)
                      : lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFF0FDF4)
                      : isLocked
                          ? const Color(0xFFF3F4F6)
                          : const Color(0xFFF2EEFF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : isLocked
                          ? Icons.lock_outline_rounded
                          : icon,
                  color: isCompleted
                      ? const Color(0xFF16A34A)
                      : isLocked
                          ? const Color(0xFF9CA3AF)
                          : brightPurple,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "STEP $number",
                          style: TextStyle(
                            color: isLocked
                                ? const Color(0xFF9CA3AF)
                                : brightPurple,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 7),
                          _buildStepBadge(
                            text: "DONE",
                            backgroundColor: const Color(0xFFDCFCE7),
                            textColor: const Color(0xFF15803D),
                          ),
                        ] else if (isLocked) ...[
                          const SizedBox(width: 7),
                          _buildStepBadge(
                            text: "LOCKED",
                            backgroundColor: const Color(0xFFF3F4F6),
                            textColor: const Color(0xFF6B7280),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        color: isLocked
                            ? const Color(0xFF6B7280)
                            : darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isCompleted ? "Successfully captured" : subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLocked
                            ? const Color(0xFF9CA3AF)
                            : greyText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFF0FDF4)
                      : isLocked
                          ? const Color(0xFFF3F4F6)
                          : const Color(0xFFF6F3FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : isLocked
                          ? Icons.lock_rounded
                          : Icons.chevron_right_rounded,
                  color: isCompleted
                      ? const Color(0xFF16A34A)
                      : isLocked
                          ? const Color(0xFF9CA3AF)
                          : brightPurple,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // =========================================================
  // KYC UNDER-REVIEW SCREEN
  // =========================================================

  Widget _buildSubmittedView() {
    return Scaffold(
      backgroundColor:
          pageBackground,

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),

          child: Column(
            children: [
              // Header

              Row(
                children: [
                  _buildBackButton(),

                  const Expanded(
                    child: Text(
                      "KYC Verification",

                      textAlign:
                          TextAlign.center,

                      style:
                          TextStyle(
                        color: darkText,

                        fontSize: 20,

                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 44,
                    width: 44,
                  ),
                ],
              ),

              const Spacer(),

              // Double-tap for developer approval

              GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    _kycService
                        .simulateVerificationApproval();
                  });

                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Developer mode: KYC approved",
                      ),

                      backgroundColor:
                          Colors.green,
                    ),
                  );
                },

                child: Container(
                  height: 130,
                  width: 130,

                  decoration:
                      const BoxDecoration(
                    color: Color(
                      0xFFF2EEFF,
                    ),

                    shape:
                        BoxShape.circle,
                  ),

                  child:
                      const Icon(
                    Icons
                        .hourglass_top_rounded,

                    color:
                        brightPurple,

                    size: 65,
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              const Text(
                "KYC Submitted!",

                style: TextStyle(
                  color: darkText,

                  fontSize: 27,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 9,
              ),

              const Text(
                "Your information has been submitted\nand is currently under review.",

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color: greyText,

                  fontSize: 13,

                  height: 1.5,
                ),
              ),

              const Spacer(),

              _buildStatusCard(
                status: "Captured",
              ),

              const SizedBox(
                height: 18,
              ),

              Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF2EEFF,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                ),

                child:
                    const Row(
                  children: [
                    Icon(
                      Icons
                          .info_outline_rounded,

                      color:
                          brightPurple,
                    ),

                    SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        "Verification usually takes a few minutes. You will be notified after approval.",

                        style:
                            TextStyle(
                          color:
                              brandPurple,

                          fontSize: 11,

                          height: 1.4,

                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              _buildBottomButton(
                title: "Go to Home",

                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // KYC VERIFIED SCREEN
  // =========================================================

  Widget _buildVerifiedView() {
    return Scaffold(
      backgroundColor:
          pageBackground,

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),

          child: Column(
            children: [
              // Header

              Row(
                children: [
                  _buildBackButton(),

                  const Expanded(
                    child: Text(
                      "KYC Verified",

                      textAlign:
                          TextAlign.center,

                      style:
                          TextStyle(
                        color: darkText,

                        fontSize: 20,

                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 44,
                    width: 44,
                  ),
                ],
              ),

              const Spacer(),

              Stack(
                alignment:
                    Alignment.center,

                children: [
                  Container(
                    height: 130,
                    width: 130,

                    decoration:
                        const BoxDecoration(
                      color: Color(
                        0xFFF0FDF4,
                      ),

                      shape:
                          BoxShape.circle,
                    ),

                    child:
                        const Icon(
                      Icons
                          .verified_user_rounded,

                      color:
                          Color(
                        0xFF16A34A,
                      ),

                      size: 72,
                    ),
                  ),

                  ..._buildConfettiDecorations(),
                ],
              ),

              const SizedBox(
                height: 29,
              ),

              const Text(
                "KYC Verified!",

                style: TextStyle(
                  color: darkText,

                  fontSize: 27,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 9,
              ),

              const Text(
                "Your identity has been verified.\nYou can now enjoy all Evegah features.",

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color: greyText,

                  fontSize: 13,

                  height: 1.5,
                ),
              ),

              const Spacer(),

              _buildStatusCard(
                status: "Verified",
              ),

              const Spacer(
                flex: 2,
              ),

              _buildBottomButton(
                title: "Explore Now",

                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BACK BUTTON
  // =========================================================

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () {
          Navigator.pop(
            context,
          );
        },

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        child: Container(
          height: 44,
          width: 44,

          decoration:
              BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              14,
            ),

            border: Border.all(
              color: lightBorder,
            ),
          ),

          child: const Icon(
            Icons
                .arrow_back_ios_new_rounded,

            color: darkText,

            size: 18,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BOTTOM BUTTON
  // =========================================================

  Widget _buildBottomButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,

      height: 57,

      child: ElevatedButton(
        onPressed: onPressed,

        style:
            ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor:
              brightPurple,

          foregroundColor:
              Colors.white,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
        ),

        child: Text(
          title,

          style:
              const TextStyle(
            fontSize: 16,

            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // KYC STATUS CARD
  // =========================================================

  Widget _buildStatusCard({
    required String status,
  }) {
    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border: Border.all(
          color: lightBorder,
        ),
      ),

      child: Column(
        children: [
          _buildStatusRow(
            "Live Photo",
            status,
          ),

          const Divider(
            height: 1,
            indent: 64,
          ),

          _buildStatusRow(
            "Aadhaar Front",
            status,
          ),

          const Divider(
            height: 1,
            indent: 64,
          ),

          _buildStatusRow(
            "Aadhaar Back",
            status,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS ROW
  // =========================================================

  Widget _buildStatusRow(
    String stepName,
    String status,
  ) {
    final bool isVerified =
        status == "Verified";

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 4,
      ),

      leading: Container(
        height: 37,
        width: 37,

        decoration:
            BoxDecoration(
          color: isVerified
              ? const Color(
                  0xFFF0FDF4,
                )
              : const Color(
                  0xFFF2EEFF,
                ),

          shape:
              BoxShape.circle,
        ),

        child: Icon(
          Icons.check_rounded,

          color: isVerified
              ? const Color(
                  0xFF16A34A,
                )
              : brightPurple,

          size: 19,
        ),
      ),

      title: Text(
        stepName,

        style:
            const TextStyle(
          color: darkText,

          fontSize: 14,

          fontWeight:
              FontWeight.w700,
        ),
      ),

      trailing: Text(
        status,

        style: TextStyle(
          color: isVerified
              ? const Color(
                  0xFF16A34A,
                )
              : brightPurple,

          fontSize: 11,

          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================
  // CONFETTI DECORATIONS
  // =========================================================

  List<Widget>
      _buildConfettiDecorations() {
    final List<Color> colors = [
      brightPurple,
      limeGreen,
      Colors.orange,
      Colors.blue,
      Colors.green,
    ];

    return List.generate(
      12,
      (index) {
        final double angle =
            (index * 30) *
                math.pi /
                180;

        const double radius = 76;

        return Transform.translate(
          offset: Offset(
            radius *
                math.cos(
                  angle,
                ),

            radius *
                math.sin(
                  angle,
                ),
          ),

          child: Container(
            height: 6,
            width: 6,

            decoration:
                BoxDecoration(
              color: colors[
                  index %
                      colors.length],

              shape:
                  BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}