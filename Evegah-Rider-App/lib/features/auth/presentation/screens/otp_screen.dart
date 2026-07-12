import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../dashboard/presentation/screens/main_navigation.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  // 4-Digit OTP Code Controllers & Focus Nodes
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final AuthService _authService = AuthService();

  int _resendTimerSeconds = 45;
  Timer? _timer;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();

    // Auto-focus first digit field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _resendTimerSeconds = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendTimerSeconds > 0) {
        setState(() {
          _resendTimerSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  String _getOtpString() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    final otp = _getOtpString();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Please enter the complete 4-digit OTP code"),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate OTP verification & auto login
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      await SessionService().saveToken("mock_evegah_session_token_12345");
    } catch (se) {
      debugPrint("Error saving token: $se");
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation()),
      (route) => false,
    );
  }

  // Multi-fallback Hero Image Loader for 100% Web & Mobile Reliability
  Widget _buildHeroImage() {
    return Image.asset(
      'assets/hero.png',
      fit: BoxFit.cover,
      alignment: const Alignment(0.2, -0.3),
      errorBuilder: (context, error1, stackTrace1) {
        return Image.asset(
          'assets/Hero.png',
          fit: BoxFit.cover,
          alignment: const Alignment(0.2, -0.3),
          errorBuilder: (context, error2, stackTrace2) {
            return Image.asset(
              'assets/scooter_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error3, stackTrace3) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2a195c), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.electric_scooter, color: Colors.white38, size: 90),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double heroHeight = screenHeight < 700 ? 320 : screenHeight * 0.44;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // --- TOP HERO IMAGE HEADER (NO WHITENESS, NATURAL VIVID PHOTO) ---
            SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  // Natural Hero Photo Background
                  Positioned.fill(
                    child: _buildHeroImage(),
                  ),

                  // Subtle Dark Gradient Overlay (No Whiteness - Keeps Photo Crisp & Vivid)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.black.withOpacity(0.15),
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.3, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Header Content Layer
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button & Shield Icon Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2a195c), size: 20),
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2a195c),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Logo + Slogan
                            Image.asset(
                              'assets/Evegah_login_page_logo.png',
                              height: 34,
                              errorBuilder: (_, __, ___) => Row(
                                children: const [
                                  Icon(Icons.bolt_rounded, color: Color(0xFF8CE600), size: 26),
                                  SizedBox(width: 4),
                                  Text("evegah", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: const [
                                Text("Drive Green. ", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF8CE600))),
                                Text("Live Clean.", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white70)),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Main Headline
                            const Text(
                              "Verify Your",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.4,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2))],
                              ),
                            ),
                            const Text(
                              "Mobile Number",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF8CE600), // Vibrant Green Accent
                                height: 1.1,
                                letterSpacing: -0.4,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2))],
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Phone String & Change Link
                            Row(
                              children: [
                                const Text(
                                  "Enter the 4-digit OTP sent to ",
                                  style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  widget.phoneNumber,
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF8CE600)),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: const Text(
                                    "Change",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- BOTTOM FLOATING WHITE CARD OVERLAY (PRIMARY COLOR = #2a195c) ---
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  transform: Matrix4.translationValues(0, -28, 0),
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 24,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Enter OTP Header Row (#2a195c Theme)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2a195c), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Enter OTP",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Enter the 4-digit code we just sent you",
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // 2. 4-Digit OTP Boxes Row (Large, Clear Boxes)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          final isFocused = _focusNodes[index].hasFocus;
                          final hasValue = _controllers[index].text.isNotEmpty;

                          return SizedBox(
                            width: 58,
                            height: 60,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                hintText: "•",
                                hintStyle: const TextStyle(fontSize: 22, color: Color(0xFFCBD5E1)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: hasValue ? const Color(0xFF2a195c) : const Color(0xFFE2E8F0),
                                    width: 1.8,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF2a195c), width: 2.2),
                                ),
                                fillColor: isFocused ? const Color(0xFFF3F0FF) : const Color(0xFFFAFAFA),
                                filled: true,
                              ),
                              onChanged: (val) => _onDigitChanged(index, val),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),

                      // 3. Security Encryption Notice
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Text(
                            "Your verification is secure and encrypted",
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 4. Timer & Resend Card Box (#2a195c Theme)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F0FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.access_time_rounded, color: Color(0xFF2a195c), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Didn't receive the OTP?",
                                    style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: "Resend OTP in ", style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                        TextSpan(
                                          text: "00:${_resendTimerSeconds.toString().padLeft(2, '0')}",
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2a195c)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: _resendTimerSeconds == 0
                                  ? () {
                                      _startTimer();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("OTP resent successfully!")),
                                      );
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _resendTimerSeconds == 0 ? const Color(0xFF2a195c) : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _resendTimerSeconds == 0 ? const Color(0xFF2a195c) : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 5. Verify & Continue Primary Button (Theme Color = #2a195c)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: InkWell(
                          onTap: _isLoading ? null : _verifyOtp,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2a195c), Color(0xFF1E1044)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2a195c).withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading) ...[
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                const Text(
                                  "Verify & Continue",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. Complete Verification Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF16A34A), size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Complete verification to unlock",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  SizedBox(height: 2),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: "exciting offers ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                                        TextSpan(text: "on your first EV ride!", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF16A34A), size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 7. Legal Disclaimer Footer (#2a195c Links)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                          SizedBox(width: 4),
                          Text("By continuing, you agree to our ", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          Text("Terms & Conditions", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2a195c))),
                          Text(" and ", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          Text("Privacy Policy", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2a195c))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
