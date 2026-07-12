import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'kyc_preview_screen.dart';

enum KycStep {
  selfie,
  aadhaarFront,
  aadhaarBack,
}

class KycCameraScreen extends StatefulWidget {
  final KycStep step;

  // true  = Start Verification flow
  // false = User opened one individual KYC step
  final bool continueToNextStep;

  const KycCameraScreen({
    super.key,
    required this.step,
    this.continueToNextStep = true,
  });

  @override
  State<KycCameraScreen> createState() =>
      _KycCameraScreenState();
}

class _KycCameraScreenState
    extends State<KycCameraScreen>
    with WidgetsBindingObserver {
  // =========================================================
  // BRAND COLORS
  // =========================================================

  static const Color brandPurple =
      Color(0xFF4B16C8);

  static const Color darkPurple =
      Color(0xFF24105E);

  static const Color brandGreen =
      Color(0xFF12B981);

  static const Color pageBackground =
      Color(0xFFF8F9FD);

  static const Color darkText =
      Color(0xFF111827);

  static const Color greyText =
      Color(0xFF64748B);

  // =========================================================
  // CAMERA VARIABLES
  // =========================================================

  CameraController? _cameraController;

  List<CameraDescription> _cameras = [];

  bool _isCameraReady = false;

  bool _isCapturing = false;

  bool _isPositionReady = false;

  int _selectedCameraIndex = 0;

  Timer? _positionTimer;

  final ImagePicker _imagePicker =
      ImagePicker();

  // =========================================================
  // INITIALIZE
  // =========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeCamera();

    // This only changes the UI status.
    // It is not real face detection.
    _positionTimer = Timer(
      const Duration(
        milliseconds: 1500,
      ),
      () {
        if (mounted) {
          setState(() {
            _isPositionReady = true;
          });
        }
      },
    );
  }

  // =========================================================
  // APP LIFECYCLE
  // =========================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    final CameraController? controller =
        _cameraController;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (
        state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // =========================================================
  // INITIALIZE CAMERA
  // =========================================================

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        return;
      }

      // Use front camera for Live Photo.
      if (widget.step == KycStep.selfie) {
        final int frontCameraIndex =
            _cameras.indexWhere(
          (camera) =>
              camera.lensDirection ==
              CameraLensDirection.front,
        );

        _selectedCameraIndex =
            frontCameraIndex >= 0
                ? frontCameraIndex
                : 0;
      } else {
        // Use back camera for Aadhaar.
        final int backCameraIndex =
            _cameras.indexWhere(
          (camera) =>
              camera.lensDirection ==
              CameraLensDirection.back,
        );

        _selectedCameraIndex =
            backCameraIndex >= 0
                ? backCameraIndex
                : 0;
      }

      await _startCamera(
        _selectedCameraIndex,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        "Unable to open the camera.",
      );
    }
  }

  // =========================================================
  // START CAMERA
  // =========================================================

  Future<void> _startCamera(
    int cameraIndex,
  ) async {
    setState(() {
      _isCameraReady = false;
    });

    await _cameraController?.dispose();

    final CameraController controller =
        CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup:
          ImageFormatGroup.jpeg,
    );

    _cameraController = controller;

    try {
      await controller.initialize();

      if (!mounted) {
        return;
      }

      setState(() {
        _isCameraReady = true;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        "Camera initialization failed.",
      );
    }
  }

  // =========================================================
  // CAPTURE PHOTO
  // =========================================================

  Future<void> _capturePhoto() async {
    final CameraController? controller =
        _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final XFile capturedImage =
          await controller.takePicture();

      if (!mounted) {
        return;
      }

      await _openPreview(
        capturedImage.path,
      );
    } catch (error) {
      if (mounted) {
        _showMessage(
          "Unable to capture the photo.",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  // =========================================================
  // SELECT FROM GALLERY
  // =========================================================

  Future<void> _selectFromGallery() async {
    try {
      final XFile? selectedImage =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (selectedImage == null ||
          !mounted) {
        return;
      }

      await _openPreview(
        selectedImage.path,
      );
    } catch (error) {
      if (mounted) {
        _showMessage(
          "Unable to select the image.",
        );
      }
    }
  }

  // =========================================================
  // OPEN PREVIEW
  // =========================================================

  Future<void> _openPreview(
    String imagePath,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            KycPreviewScreen(
          step: widget.step,
          imagePath: imagePath,
          continueToNextStep:
              widget.continueToNextStep,
        ),
      ),
    );
  }

  // =========================================================
  // SWITCH CAMERA
  // =========================================================

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) {
      _showMessage(
        "No other camera is available.",
      );

      return;
    }

    _selectedCameraIndex =
        (_selectedCameraIndex + 1) %
            _cameras.length;

    await _startCamera(
      _selectedCameraIndex,
    );
  }

  // =========================================================
  // SCREEN DATA
  // =========================================================

  String get _screenTitle {
    switch (widget.step) {
      case KycStep.selfie:
        return "Live Photo";

      case KycStep.aadhaarFront:
        return "Aadhaar Front";

      case KycStep.aadhaarBack:
        return "Aadhaar Back";
    }
  }

  String get _mainInstruction {
    switch (widget.step) {
      case KycStep.selfie:
        return "Position your face";

      case KycStep.aadhaarFront:
        return "Position Aadhaar front";

      case KycStep.aadhaarBack:
        return "Position Aadhaar back";
    }
  }

  String get _secondaryInstruction {
    switch (widget.step) {
      case KycStep.selfie:
        return "Keep your face inside the guide";

      case KycStep.aadhaarFront:
        return "Keep all four corners visible";

      case KycStep.aadhaarBack:
        return "Keep all details clear and readable";
    }
  }

  int get _currentStep {
    switch (widget.step) {
      case KycStep.selfie:
        return 1;

      case KycStep.aadhaarFront:
        return 2;

      case KycStep.aadhaarBack:
        return 3;
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this);

    _positionTimer?.cancel();

    _cameraController?.dispose();

    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: pageBackground,

      body: SafeArea(
        child: Column(
          children: [
            // =================================================
            // HEADER
            // =================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                4,
              ),
              child: Row(
                children: [
                  _buildBackButton(),

                  Expanded(
                    child: Text(
                      _screenTitle,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color: darkText,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF0EBFF,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                    child: Text(
                      "$_currentStep of 3",
                      style:
                          const TextStyle(
                        color:
                            brandPurple,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // PAGE CONTENT
            // =================================================

            Expanded(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(
      20,
      10,
      20,
      14,
    ),
    child: Column(
      children: [
        // Progress indicator

        _buildProgressIndicator(),

        const SizedBox(
          height: 14,
        ),

        // Main instruction

        Text(
          _mainInstruction,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: darkText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        // Secondary instruction

        Text(
          _secondaryInstruction,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: greyText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        // Camera automatically uses the remaining space

        Expanded(
          child: _buildCameraCard(),
        ),

        const SizedBox(
          height: 10,
        ),

        // Bottom instruction

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.light_mode_outlined,
              color: brandPurple,
              size: 16,
            ),

            const SizedBox(
              width: 6,
            ),

            Flexible(
              child: Text(
                widget.step == KycStep.selfie
                    ? "Use good lighting and look straight at the camera"
                    : "Avoid glare and keep the document details visible",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: greyText,
                  fontSize: 10,
                ),
              ),
            ),
          ],
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
  // BACK BUTTON
  // =========================================================

  Widget _buildBackButton() {
    return Material(
      color: Colors.white,

      shape: const CircleBorder(),

      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },

        customBorder:
            const CircleBorder(),

        child: Container(
          height: 42,
          width: 42,

          decoration:
              BoxDecoration(
            shape: BoxShape.circle,

            border: Border.all(
              color:
                  const Color(
                0xFFE6E9F0,
              ),
            ),
          ),

          child: const Icon(
            Icons
                .arrow_back_rounded,
            color: darkText,
            size: 21,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PROGRESS INDICATOR
  // =========================================================

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep(
          number: 1,
          title: "Live Photo",
        ),

        _buildProgressLine(
          completed:
              _currentStep > 1,
        ),

        _buildProgressStep(
          number: 2,
          title: "Aadhaar Front",
        ),

        _buildProgressLine(
          completed:
              _currentStep > 2,
        ),

        _buildProgressStep(
          number: 3,
          title: "Aadhaar Back",
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required int number,
    required String title,
  }) {
    final bool isCompleted =
        number < _currentStep;

    final bool isActive =
        number == _currentStep;

    return SizedBox(
      width: 78,

      child: Column(
        children: [
          AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 250,
            ),

            height: 34,
            width: 34,

            decoration:
                BoxDecoration(
              color: isCompleted ||
                      isActive
                  ? brandPurple
                  : Colors.white,

              shape: BoxShape.circle,

              border: Border.all(
                color:
                    isCompleted ||
                            isActive
                        ? brandPurple
                        : const Color(
                            0xFFDCE2EA,
                          ),
                width: 2,
              ),
            ),

            child: Icon(
              isCompleted
                  ? Icons
                      .check_rounded
                  : null,

              color: Colors.white,

              size: 18,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            title,

            maxLines: 1,

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color: isActive
                  ? brandPurple
                  : greyText,

              fontSize: 9,

              fontWeight:
                  isActive
                      ? FontWeight
                          .w800
                      : FontWeight
                          .w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine({
    required bool completed,
  }) {
    return Expanded(
      child: Container(
        height: 3,

        margin:
            const EdgeInsets.only(
          bottom: 23,
        ),

        decoration:
            BoxDecoration(
          color: completed
              ? brandPurple
              : const Color(
                  0xFFDCE2EA,
                ),

          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CAMERA CARD
  // =========================================================

  Widget _buildCameraCard() {
    return Container(

      clipBehavior: Clip.antiAlias,

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF080D15,
        ),

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.14,
            ),

            blurRadius: 30,

            offset:
                const Offset(
              0,
              15,
            ),
          ),
        ],
      ),

      child: Stack(
        fit: StackFit.expand,

        children: [
          // Camera preview

          if (_isCameraReady &&
              _cameraController !=
                  null)
            _buildCameraPreview()
          else
            const Center(
              child:
                  CircularProgressIndicator(
                color:
                    brandGreen,
              ),
            ),

          // Dark gradient

          Positioned.fill(
            child: DecoratedBox(
              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topCenter,

                  end:
                      Alignment.bottomCenter,

                  colors: [
                    Colors.black
                        .withValues(
                      alpha: 0.35,
                    ),

                    Colors
                        .transparent,

                    Colors.black
                        .withValues(
                      alpha: 0.78,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Instruction badge

          Positioned(
            top: 20,
            left: 20,
            right: 20,

            child: Center(
              child:
                  AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds:
                      300,
                ),

                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      _isPositionReady
                          ? brandGreen
                          : Colors.black
                              .withValues(
                            alpha:
                                0.55,
                          ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    30,
                  ),
                ),

                child: Row(
                  mainAxisSize:
                      MainAxisSize
                          .min,

                  children: [
                    Icon(
                      _isPositionReady
                          ? Icons
                              .check_circle_rounded
                          : Icons
                              .center_focus_strong_rounded,

                      color:
                          Colors.white,

                      size: 17,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Text(
                      _isPositionReady
                          ? "POSITION READY"
                          : "ALIGN IN THE GUIDE",

                      style:
                          const TextStyle(
                        color:
                            Colors.white,

                        fontSize: 11,

                        fontWeight:
                            FontWeight
                                .w800,

                        letterSpacing:
                            0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Face or document guide

          Center(
            child:
                _buildCaptureGuide(),
          ),

          // Camera controls

          Positioned(
            left: 18,
            right: 18,
            bottom: 20,

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                _buildSmallControl(
                  icon: Icons
                      .photo_library_outlined,

                  onTap:
                      _selectFromGallery,
                ),

                _buildCaptureButton(),

                _buildSmallControl(
                  icon: Icons
                      .cameraswitch_rounded,

                  onTap:
                      _switchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CAMERA PREVIEW
  // =========================================================

  Widget _buildCameraPreview() {
    final CameraController
        controller =
        _cameraController!;

    return Center(
      child: CameraPreview(
        controller,
      ),
    );
  }

  // =========================================================
  // CAPTURE GUIDE
  // =========================================================

  Widget _buildCaptureGuide() {
    final bool isSelfie =
        widget.step ==
            KycStep.selfie;

    return Container(
      height:
          isSelfie
              ? 250
              : 215,

      width:
          isSelfie
              ? 245
              : 310,

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          isSelfie
              ? 125
              : 25,
        ),

        border: Border.all(
          color:
              _isPositionReady
                  ? brandGreen
                  : Colors.white70,

          width: 3,
        ),

        boxShadow: [
          BoxShadow(
            color:
                (_isPositionReady
                        ? brandGreen
                        : Colors.white)
                    .withValues(
              alpha: 0.25,
            ),

            blurRadius: 20,

            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SMALL CAMERA CONTROL
  // =========================================================

  Widget _buildSmallControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white
          .withValues(
        alpha: 0.14,
      ),

      shape:
          const CircleBorder(),

      child: InkWell(
        onTap: onTap,

        customBorder:
            const CircleBorder(),

        child: SizedBox(
          height: 54,
          width: 54,

          child: Icon(
            icon,

            color:
                Colors.white,

            size: 24,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CAPTURE BUTTON
  // =========================================================

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap:
          _isCapturing
              ? null
              : _capturePhoto,

      child: Container(
        height: 78,
        width: 78,

        padding:
            const EdgeInsets.all(
          5,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          shape:
              BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color: brandGreen
                  .withValues(
                alpha: 0.45,
              ),

              blurRadius: 22,

              spreadRadius: 4,
            ),
          ],
        ),

        child: Container(
          decoration:
              BoxDecoration(
            color:
                brandGreen,

            shape:
                BoxShape.circle,

            border:
                Border.all(
              color:
                  const Color(
                0xFF083B35,
              ),

              width: 2,
            ),
          ),

          child:
              _isCapturing
                  ? const Padding(
                      padding:
                          EdgeInsets
                              .all(
                        17,
                      ),

                      child:
                          CircularProgressIndicator(
                        color:
                            Colors
                                .white,

                        strokeWidth:
                            3,
                      ),
                    )
                  : const Icon(
                      Icons
                          .camera_alt_rounded,

                      color:
                          Colors.white,

                      size: 29,
                    ),
        ),
      ),
    );
  }
}