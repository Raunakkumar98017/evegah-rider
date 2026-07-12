import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'unlocking_screen.dart';
import 'package:evegah_rider_app/core/constants/app_constants.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with SingleTickerProviderStateMixin {

  // =================================================
  // BRAND COLORS
  // =================================================

  static const Color primaryPurple = Color(0xFF200F54);
  static const Color brandPurple = Color(0xFF4313B8);
  static const Color accentGreen = Color(0xFF8CE600);

  // =================================================
  // SCANNER CONTROLLER
  // =================================================

  final MobileScannerController controller =
      MobileScannerController();

  late AnimationController animationController;

  late Animation<double> animation;

  bool flashOn = false;

  bool scanned = false;

  bool isProcessingApi = false;

  // =================================================
  // INITIALIZE SCANNER ANIMATION
  // =================================================

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    )..repeat(
        reverse: true,
      );

    animation = Tween<double>(
      begin: 0,
      end: 220,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // =================================================
  // DISPOSE CONTROLLERS
  // =================================================

  @override
  void dispose() {
    controller.dispose();

    animationController.dispose();

    super.dispose();
  }

  // =================================================
  // VERIFY VEHICLE AND UNLOCK
  // =================================================

  Future<void> _verifyAndUnlock(
    String code, {
    required bool isManual,
  }) async {

    // Remove unnecessary spaces

    final String vehicleCode = code.trim();

    // Validate empty vehicle ID

    if (vehicleCode.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid Vehicle ID.",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // =================================================
    // TEST VEHICLE BYPASS
    // =================================================

    if (vehicleCode.toUpperCase() == "TEST123") {

      if (isManual &&
          Navigator.canPop(context)) {

        Navigator.pop(context);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder: (context) =>
              const UnlockingScreen(
            vehicleId: "TEST123",
          ),
        ),
      );

      return;
    }

    setState(() {
      isProcessingApi = true;
    });

    try {

      // =================================================
      // GET ACCESS TOKEN
      // =================================================

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      final String? token =
          preferences.getString(
        'access_token',
      );

      if (token == null ||
          token.isEmpty) {

        throw Exception(
          "User is not logged in",
        );
      }

      // =================================================
      // CALL VEHICLE API
      // =================================================

      final response = await http.post(

        Uri.parse(
          '${AppConstants.apiBaseUrl}'
          '/qrDecrypted'
          '?access_token=$token',
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode(
          {

            "qrString":
                isManual
                    ? null
                    : vehicleCode,

            "userId": 0,

            "lockNumber":
                isManual
                    ? vehicleCode
                    : null,
          },
        ),
      );

      // =================================================
      // SUCCESS RESPONSE
      // =================================================

      if (response.statusCode == 200) {

        final dynamic decoded =
            jsonDecode(
          response.body,
        );

        if (
            decoded["data"] != null &&
            decoded["data"].isNotEmpty
        ) {

          final dynamic realLockNumber =
              decoded["data"][0]
              ["lockNumber"];

          if (!mounted) return;

          // Close manual-entry sheet

          if (isManual &&
              Navigator.canPop(context)) {

            Navigator.pop(context);
          }

          Navigator.pushReplacement(
            context,

            MaterialPageRoute(
              builder: (context) =>
                  UnlockingScreen(

                vehicleId:
                    realLockNumber
                        .toString(),
              ),
            ),
          );

        } else {

          throw Exception(
            "Vehicle not found",
          );
        }

      } else {

        throw Exception(
          "Vehicle API error",
        );
      }

    } catch (error) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Invalid Vehicle QR or ID. Please try again.",
          ),

          backgroundColor:
              Colors.red,
        ),
      );

      setState(() {

        scanned = false;

      });

    } finally {

      if (mounted) {

        setState(() {

          isProcessingApi = false;

        });
      }
    }
  }

  // =================================================
  // DETECT QR CODE
  // =================================================

  void onDetectBarcode(
    BarcodeCapture capture,
  ) {

    if (
        scanned ||
        isProcessingApi
    ) {

      return;
    }

    final List<Barcode> barcodes =
        capture.barcodes;

    for (
      final Barcode barcode
      in barcodes
    ) {

      final String code =
          barcode.rawValue ?? "";

      if (code.isNotEmpty) {

        setState(() {

          scanned = true;

        });

        // =================================================
        // VEHICLE FOUND DIALOG
        // =================================================

        showDialog(

          context: context,

          barrierDismissible: false,

          builder: (
            BuildContext dialogContext,
          ) {

            return AlertDialog(

              backgroundColor:
                  Colors.white,

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),

              contentPadding:
                  const EdgeInsets.all(
                24,
              ),

              content: Column(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  // Success icon

                  Container(

                    height: 68,

                    width: 68,

                    decoration:
                        BoxDecoration(

                      color:
                          accentGreen
                              .withValues(
                        alpha: 0.18,
                      ),

                      shape:
                          BoxShape.circle,
                    ),

                    child:
                        const Icon(

                      Icons
                          .electric_scooter_rounded,

                      color:
                          primaryPurple,

                      size: 34,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  const Text(

                    "Vehicle Found!",

                    style:
                        TextStyle(

                      color:
                          Color(
                        0xFF0F172A,
                      ),

                      fontSize: 21,

                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(

                    "Your EV QR code was scanned successfully. Would you like to unlock this vehicle?",

                    textAlign:
                        TextAlign
                            .center,

                    style:
                        TextStyle(

                      color:
                          Color(
                        0xFF64748B,
                      ),

                      fontSize: 12,

                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  Row(

                    children: [

                      // Cancel button

                      Expanded(

                        child:
                            OutlinedButton(

                          onPressed:
                              () {

                            setState(
                              () {

                                scanned =
                                    false;

                              },
                            );

                            Navigator.pop(
                              dialogContext,
                            );
                          },

                          style:
                              OutlinedButton
                                  .styleFrom(

                            minimumSize:
                                const Size(
                              0,
                              50,
                            ),

                            foregroundColor:
                                const Color(
                              0xFF64748B,
                            ),

                            side:
                                const BorderSide(

                              color:
                                  Color(
                                0xFFE2E8F0,
                              ),
                            ),

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                14,
                              ),
                            ),
                          ),

                          child:
                              const Text(

                            "Cancel",

                            style:
                                TextStyle(

                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      // Unlock button

                      Expanded(

                        child:
                            ElevatedButton(

                          onPressed:
                              () async {

                            Navigator.pop(
                              dialogContext,
                            );

                            await
                                _verifyAndUnlock(

                              code,

                              isManual:
                                  false,
                            );
                          },

                          style:
                              ElevatedButton
                                  .styleFrom(

                            backgroundColor:
                                primaryPurple,

                            foregroundColor:
                                Colors.white,

                            elevation: 0,

                            minimumSize:
                                const Size(
                              0,
                              50,
                            ),

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                14,
                              ),
                            ),
                          ),

                          child:
                              const Text(

                            "Unlock EV",

                            style:
                                TextStyle(

                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );

        break;
      }
    }
  }

  // =================================================
  // MANUAL VEHICLE-ID BOTTOM SHEET
  // =================================================

  void _showManualEntrySheet() {

    final TextEditingController
        vehicleController =
        TextEditingController();

    showModalBottomSheet(

      context: context,

      backgroundColor:
          Colors.white,

      isScrollControlled:
          true,

      shape:
          const RoundedRectangleBorder(

        borderRadius:
            BorderRadius.vertical(

          top:
              Radius.circular(
            30,
          ),
        ),
      ),

      builder: (
        BuildContext sheetContext,
      ) {

        return StatefulBuilder(

          builder: (
            BuildContext context,
            StateSetter
                setModalState,
          ) {

            return Padding(

              padding:
                  EdgeInsets.only(

                bottom:
                    MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom,
              ),

              child:
                  SingleChildScrollView(

                child: Padding(

                  padding:
                      const EdgeInsets
                          .fromLTRB(

                    24,
                    14,
                    24,
                    30,
                  ),

                  child: Column(

                    mainAxisSize:
                        MainAxisSize.min,

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      // Bottom-sheet handle

                      Center(

                        child:
                            Container(

                          height: 5,

                          width: 45,

                          decoration:
                              BoxDecoration(

                            color:
                                const Color(
                              0xFFE2E8F0,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      // Vehicle icon

                      Container(

                        height: 52,

                        width: 52,

                        decoration:
                            BoxDecoration(

                          color:
                              accentGreen
                                  .withValues(
                            alpha: 0.20,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),

                        child:
                            const Icon(

                          Icons
                              .electric_scooter_rounded,

                          color:
                              primaryPurple,

                          size: 28,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const Text(

                        "Enter Vehicle ID",

                        style:
                            TextStyle(

                          color:
                              Color(
                            0xFF0F172A,
                          ),

                          fontSize: 23,

                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      const Text(

                        "Enter the Vehicle ID printed below the QR sticker.",

                        style:
                            TextStyle(

                          color:
                              Color(
                            0xFF64748B,
                          ),

                          fontSize: 12,

                          height: 1.5,
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // Vehicle ID label

                      const Text(

                        "VEHICLE ID",

                        style:
                            TextStyle(

                          color:
                              Color(
                            0xFF64748B,
                          ),

                          fontSize: 10,

                          fontWeight:
                              FontWeight
                                  .w700,

                          letterSpacing:
                              1,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // Vehicle ID input

                      TextField(

                        controller:
                            vehicleController,

                        textCapitalization:
                            TextCapitalization
                                .characters,

                        decoration:
                            InputDecoration(

                          hintText:
                              "Example: EVM1025029",

                          prefixIcon:
                              const Icon(

                            Icons
                                .confirmation_number_outlined,

                            color:
                                brandPurple,
                          ),

                          filled: true,

                          fillColor:
                              const Color(
                            0xFFF8F7FC,
                          ),

                          enabledBorder:
                              OutlineInputBorder(

                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),

                            borderSide:
                                const BorderSide(

                              color:
                                  Color(
                                0xFFE2E8F0,
                              ),
                            ),
                          ),

                          focusedBorder:
                              OutlineInputBorder(

                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),

                            borderSide:
                                const BorderSide(

                              color:
                                  brandPurple,

                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Text(

                        "You can use TEST123 for testing.",

                        style:
                            TextStyle(

                          color:
                              Color(
                            0xFF94A3B8,
                          ),

                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // Unlock vehicle button

                      SizedBox(

                        width:
                            double.infinity,

                        height: 56,

                        child:
                            ElevatedButton(

                          onPressed:
                              isProcessingApi
                                  ? null
                                  : () async {

                            final String
                                vehicleId =

                                vehicleController
                                    .text
                                    .trim();

                            if (
                                vehicleId
                                    .isEmpty
                            ) {

                              ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(

                                const SnackBar(

                                  content:
                                      Text(

                                    "Please enter a Vehicle ID.",
                                  ),

                                  backgroundColor:
                                      Colors.red,
                                ),
                              );

                              return;
                            }

                            setModalState(
                              () {

                                isProcessingApi =
                                    true;

                              },
                            );

                            await
                                _verifyAndUnlock(

                              vehicleId,

                              isManual:
                                  true,
                            );

                            if (
                                mounted
                            ) {

                              setModalState(
                                () {

                                  isProcessingApi =
                                      false;

                                },
                              );
                            }
                          },

                          style:
                              ElevatedButton
                                  .styleFrom(

                            backgroundColor:
                                primaryPurple,

                            foregroundColor:
                                Colors.white,

                            disabledBackgroundColor:
                                primaryPurple
                                    .withValues(

                              alpha:
                                  0.60,
                            ),

                            elevation: 0,

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                17,
                              ),
                            ),
                          ),

                          child:
                              isProcessingApi

                                  ? const SizedBox(

                                      height:
                                          23,

                                      width:
                                          23,

                                      child:
                                          CircularProgressIndicator(

                                        color:
                                            Colors.white,

                                        strokeWidth:
                                            2.5,
                                      ),
                                    )

                                  : const Row(

                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,

                                      children: [

                                        Icon(

                                          Icons
                                              .lock_open_rounded,

                                          size:
                                              20,
                                        ),

                                        SizedBox(
                                          width:
                                              9,
                                        ),

                                        Text(

                                          "Unlock Vehicle",

                                          style:
                                              TextStyle(

                                            fontSize:
                                                15,

                                            fontWeight:
                                                FontWeight
                                                    .w800,
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(
      () {

        vehicleController
            .dispose();

      },
    );
  }

  // =================================================
  // SCREEN UI
  // =================================================

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      body: Stack(

        children: [

          // =================================================
          // CAMERA
          // =================================================

          Positioned.fill(

            child:
                MobileScanner(

              controller:
                  controller,

              onDetect:
                  onDetectBarcode,
            ),
          ),

          // Camera dark overlay

          Positioned.fill(

            child:
                Container(

              color:
                  Colors.black
                      .withValues(

                alpha:
                    0.52,
              ),
            ),
          ),

          // =================================================
          // MAIN CONTENT
          // =================================================

          SafeArea(

            child:
                Column(

              children: [

                // =================================================
                // HEADER
                // =================================================

                Padding(

                  padding:
                      const EdgeInsets
                          .fromLTRB(

                    20,
                    14,
                    20,
                    0,
                  ),

                  child:
                      Row(

                    children: [

                      // Back button

                      Material(

                        color:
                            Colors.white
                                .withValues(

                          alpha:
                              0.14,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),

                        child:
                            InkWell(

                          onTap:
                              () {

                            Navigator.pop(
                              context,
                            );
                          },

                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          child:
                              const SizedBox(

                            height:
                                48,

                            width:
                                48,

                            child:
                                Icon(

                              Icons
                                  .arrow_back_rounded,

                              color:
                                  Colors.white,

                              size:
                                  25,
                            ),
                          ),
                        ),
                      ),

                      // Screen title

                      const Expanded(

                        child:
                            Column(

                          children: [

                            Text(

                              "Scan EV QR",

                              style:
                                  TextStyle(

                                color:
                                    Colors.white,

                                fontSize:
                                    22,

                                fontWeight:
                                    FontWeight
                                        .w800,

                                letterSpacing:
                                    -0.3,
                              ),
                            ),

                            SizedBox(
                              height:
                                  3,
                            ),

                            Text(

                              "Unlock your ride instantly",

                              style:
                                  TextStyle(

                                color:
                                    Colors.white60,

                                fontSize:
                                    10,

                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Flash button

                      Material(

                        color:
                            flashOn

                                ? accentGreen

                                : Colors
                                    .white
                                    .withValues(

                                    alpha:
                                        0.14,
                                  ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),

                        child:
                            InkWell(

                          onTap:
                              () async {

                            await
                                controller
                                    .toggleTorch();

                            setState(
                              () {

                                flashOn =
                                    !flashOn;

                              },
                            );
                          },

                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          child:
                              SizedBox(

                            height:
                                48,

                            width:
                                48,

                            child:
                                Icon(

                              flashOn

                                  ? Icons
                                      .flash_on_rounded

                                  : Icons
                                      .flash_off_rounded,

                              color:
                                  flashOn

                                      ? primaryPurple

                                      : Colors.white,

                              size:
                                  24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // =================================================
                // QR SCANNING FRAME
                // =================================================

                Center(

                  child:
                      SizedBox(

                    height:
                        290,

                    width:
                        290,

                    child:
                        Stack(

                      children: [

                        // Scanner background

                        Container(

                          decoration:
                              BoxDecoration(

                            color:
                                Colors.black
                                    .withValues(

                              alpha:
                                  0.12,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              30,
                            ),
                          ),
                        ),

                        // Top-left corner

                        const Positioned(

                          top: 0,

                          left: 0,

                          child:
                              ScannerCorner(),
                        ),

                        // Top-right corner

                        const Positioned(

                          top: 0,

                          right: 0,

                          child:
                              RotatedBox(

                            quarterTurns:
                                1,

                            child:
                                ScannerCorner(),
                          ),
                        ),

                        // Bottom-right corner

                        const Positioned(

                          bottom:
                              0,

                          right:
                              0,

                          child:
                              RotatedBox(

                            quarterTurns:
                                2,

                            child:
                                ScannerCorner(),
                          ),
                        ),

                        // Bottom-left corner

                        const Positioned(

                          bottom:
                              0,

                          left:
                              0,

                          child:
                              RotatedBox(

                            quarterTurns:
                                3,

                            child:
                                ScannerCorner(),
                          ),
                        ),

                        // Animated scanner line

                        AnimatedBuilder(

                          animation:
                              animation,

                          builder: (
                            context,
                            child,
                          ) {

                            return Positioned(

                              top:
                                  animation
                                          .value +
                                      32,

                              left:
                                  20,

                              right:
                                  20,

                              child:
                                  Container(

                                height:
                                    3,

                                decoration:
                                    BoxDecoration(

                                  color:
                                      accentGreen,

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),

                                  boxShadow: [

                                    BoxShadow(

                                      color:
                                          accentGreen
                                              .withValues(

                                        alpha:
                                            0.85,
                                      ),

                                      blurRadius:
                                          15,

                                      spreadRadius:
                                          2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // QR icon

                        Center(

                          child:
                              Container(

                            height:
                                54,

                            width:
                                54,

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors.black
                                      .withValues(

                                alpha:
                                    0.35,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),

                            child:
                                const Icon(

                              Icons
                                  .qr_code_2_rounded,

                              color:
                                  Colors.white38,

                              size:
                                  32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                      28,
                ),

                // =================================================
                // SCANNER INSTRUCTION
                // =================================================

                Container(

                  margin:
                      const EdgeInsets
                          .symmetric(

                    horizontal:
                        30,
                  ),

                  padding:
                      const EdgeInsets
                          .symmetric(

                    horizontal:
                        17,

                    vertical:
                        12,
                  ),

                  decoration:
                      BoxDecoration(

                    color:
                        Colors.black
                            .withValues(

                      alpha:
                          0.40,
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      30,
                    ),

                    border:
                        Border.all(

                      color:
                          Colors.white
                              .withValues(

                        alpha:
                            0.12,
                      ),
                    ),
                  ),

                  child:
                      const Row(

                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      Icon(

                        Icons
                            .center_focus_strong_rounded,

                        color:
                            accentGreen,

                        size:
                            18,
                      ),

                      SizedBox(
                        width:
                            9,
                      ),

                      Flexible(

                        child:
                            Text(

                          "Align the EV QR code inside the frame",

                          textAlign:
                              TextAlign
                                  .center,

                          style:
                              TextStyle(

                            color:
                                Colors.white,

                            fontSize:
                                12,

                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // =================================================
                // MANUAL VEHICLE ID BUTTON
                // =================================================

                Padding(

                  padding:
                      const EdgeInsets
                          .symmetric(

                    horizontal:
                        24,
                  ),

                  child:
                      SizedBox(

                    width:
                        double.infinity,

                    height:
                        58,

                    child:
                        ElevatedButton(

                      onPressed:
                          _showManualEntrySheet,

                      style:
                          ElevatedButton
                              .styleFrom(

                        backgroundColor:
                            accentGreen,

                        foregroundColor:
                            primaryPurple,

                        elevation:
                            0,

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                      ),

                      child:
                          const Row(

                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          Icon(

                            Icons
                                .keyboard_alt_outlined,

                            size:
                                21,
                          ),

                          SizedBox(
                            width:
                                10,
                          ),

                          Text(

                            "Enter Vehicle ID Manually",

                            style:
                                TextStyle(

                              fontSize:
                                  15,

                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                      13,
                ),

                const Text(

                  "Having trouble scanning?",

                  style:
                      TextStyle(

                    color:
                        Colors.white54,

                    fontSize:
                        10,

                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),

                const SizedBox(
                  height:
                      28,
                ),
              ],
            ),
          ),

          // =================================================
          // API LOADING SCREEN
          // =================================================

          if (
              isProcessingApi
          )

            Positioned.fill(

              child:
                  Container(

                color:
                    Colors.black
                        .withValues(

                  alpha:
                      0.78,
                ),

                child:
                    const Center(

                  child:
                      Column(

                    mainAxisSize:
                        MainAxisSize
                            .min,

                    children: [

                      CircularProgressIndicator(

                        color:
                            accentGreen,

                        strokeWidth:
                            3,
                      ),

                      SizedBox(
                        height:
                            18,
                      ),

                      Text(

                        "Verifying vehicle...",

                        style:
                            TextStyle(

                          color:
                              Colors.white,

                          fontSize:
                              14,

                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =================================================
// QR SCANNER CORNER WIDGET
// =================================================

class ScannerCorner extends StatelessWidget {

  const ScannerCorner({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return SizedBox(

      height: 62,

      width: 62,

      child:
          CustomPaint(

        painter:
            ScannerCornerPainter(),
      ),
    );
  }
}

// =================================================
// QR SCANNER CORNER PAINTER
// =================================================

class ScannerCornerPainter
    extends CustomPainter {

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    final Paint paint =
        Paint()

          ..color =
              const Color(
            0xFF8CE600,
          )

          ..strokeWidth =
              6

          ..strokeCap =
              StrokeCap.round

          ..style =
              PaintingStyle.stroke;

    final Path path =
        Path();

    // Vertical scanner line

    path.moveTo(
      3,
      size.height,
    );

    path.lineTo(
      3,
      23,
    );

    // Rounded scanner corner

    path.quadraticBezierTo(
      3,
      3,
      23,
      3,
    );

    // Horizontal scanner line

    path.lineTo(
      size.width,
      3,
    );

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant
        ScannerCornerPainter
            oldDelegate,
  ) {

    return false;
  }
}