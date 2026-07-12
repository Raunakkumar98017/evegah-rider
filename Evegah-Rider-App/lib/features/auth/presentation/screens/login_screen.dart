import 'package:flutter/material.dart';
import 'otp_screen.dart';
import '../../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;
  bool isPhoneValid = false;
  String selectedCountryCode = "+91";

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _features = [
    {
      "icon": Icons.electric_scooter_rounded,
      "title": "Quick\nRentals",
    },
    {
      "icon": Icons.verified_user_rounded,
      "title": "Safe &\nSecure",
    },
    {
      "icon": Icons.bolt_rounded,
      "title": "Instant\nBooking",
    },
    {
      "icon": Icons.account_balance_wallet_rounded,
      "title": "Best Prices\nGuaranteed",
    },
  ];

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_validatePhone);

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
  }

  void _validatePhone() {
    final text = phoneController.text.trim();
    final valid = text.length == 10 && RegExp(r'^[0-9]+$').hasMatch(text);
    if (valid != isPhoneValid) {
      setState(() {
        isPhoneValid = valid;
      });
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void sendOtp() {
    final phone = phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Please enter a valid 10-digit mobile number"),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(phoneNumber: "$selectedCountryCode $phone"),
      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo + Slogan
                            Row(
                              children: [
                                Image.asset(
                                  'assets/Evegah_login_page_logo.png',
                                  height: 38,
                                  errorBuilder: (_, __, ___) => Row(
                                    children: const [
                                      Icon(Icons.bolt_rounded, color: Color(0xFF8CE600), size: 30),
                                      SizedBox(width: 4),
                                      Text("evegah", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: const [
                                Text("Drive Green. ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF8CE600))),
                                Text("Live Clean.", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70)),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Main Headline
                            const Text(
                              "Smart Rides.",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.4,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2))],
                              ),
                            ),
                            const Text(
                              "Better Tomorrow.",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF8CE600), // Vibrant Green Accent on Dark
                                height: 1.1,
                                letterSpacing: -0.4,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2))],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            const Text(
                              "Rent premium EVs and enjoy a clean & smooth ride.",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                                shadows: [Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1))],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Zero Emission Pill Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a195c).withOpacity(0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white38, width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.eco_rounded, color: Color(0xFF8CE600), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    "Zero Emission  •  100% Electric",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
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
                  transform: Matrix4.translationValues(0, -28, 0), // Floating Overlap Effect
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
                      // 1. Header Title Row (#2a195c Theme)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF), // Soft Purple Box
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.smartphone_rounded, color: Color(0xFF2a195c), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Get Started",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Enter your mobile number to continue",
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. Phone Input Box (Single Merged Box)
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPhoneValid ? const Color(0xFF2a195c) : const Color(0xFFE2E8F0),
                            width: isPhoneValid ? 1.8 : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            // Country code prefix
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text("🇮🇳", style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text("+91", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
                              ],
                            ),
                            const SizedBox(width: 10),
                            // Thin vertical divider line
                            Container(
                              height: 24,
                              width: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                            const SizedBox(width: 12),
                            // Mobile Number Input Field
                            Expanded(
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.5),
                                decoration: const InputDecoration(
                                  hintText: "Enter mobile number",
                                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500, letterSpacing: 0),
                                  border: InputBorder.none,
                                  counterText: "",
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Security Notice Banner (4-Digit OTP Text & #2a195c Theme)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F0FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9D8FD)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.verified_user_outlined, color: Color(0xFF2a195c), size: 16),
                            SizedBox(width: 8),
                            Text(
                              "We will send a 4-digit OTP to verify your number",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2a195c)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 4. Send OTP Primary Button (Theme Color = #2a195c)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: InkWell(
                          onTap: sendOtp,
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
                              children: const [
                                Text(
                                  "Send OTP",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 5. 4-Features Icons Strip (#2a195c Theme)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: _features.map((f) {
                                return Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(9),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF3F0FF),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(f["icon"] as IconData, color: const Color(0xFF2a195c), size: 19),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        f["title"] as String,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.2),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            // Dot indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 16, height: 4, decoration: BoxDecoration(color: const Color(0xFF2a195c), borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 4),
                                Container(width: 4, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. Legal Disclaimer Footer (#2a195c Links)
                     // 🚨 FIX: Using Wrap instead of Row to allow text to automatically go to the next line
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
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
