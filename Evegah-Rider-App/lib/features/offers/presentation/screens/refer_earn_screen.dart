import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  final String _referralCode = "EVEGAH100";

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Referral code copied to clipboard! 📋"),
        backgroundColor: Color(0xFF4313B8),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFE),
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. TOP HEADER (Back, Logo, Bell, Profile) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 20),
                    ),
                  ),
                  const Text(
                    "evegah",
                    style: TextStyle(
                      color: Color(0xFF4313B8),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 24),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD2FC00),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.account_circle_outlined, color: Colors.black, size: 24),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // --- 2. HERO PURPLE BANNER ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF31108F), Color(0xFF1B0554)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF31108F).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Refer & Earn\nEvePoints",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Invite friends and earn points on every ride!",
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 16),
                                // Bullet 1
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(color: Color(0xFF5B21B6), shape: BoxShape.circle),
                                      child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "They get 50 EvePoints",
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Bullet 2
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(color: Color(0xFF65A30D), shape: BoxShape.circle),
                                      child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "You get 100 EvePoints",
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Image.asset(
                              "assets/gift_box_refer.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- 3. YOUR REFERRAL CODE Container ---
                    const Text(
                      "Your Referral Code",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    CustomPaint(
                      painter: DashedRectPainter(
                        color: const Color(0xFFC084FC), // Dotted purple border
                        strokeWidth: 1.5,
                        gap: 4.0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _referralCode,
                              style: const TextStyle(
                                color: Color(0xFF4313B8),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Row(
                              children: [
                                Container(width: 1.5, height: 20, color: const Color(0xFFDDD6FE)),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: _copyCode,
                                  child: Row(
                                    children: const [
                                      Icon(Icons.copy_rounded, color: Color(0xFF4313B8), size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        "Copy",
                                        style: TextStyle(
                                          color: Color(0xFF4313B8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- 4. OR SHARE VIA DIVIDER & ROW ---
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "or share via",
                            style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildShareBtn("WhatsApp", const Color(0xFF25D366), Icons.chat_rounded),
                        _buildShareBtn("Instagram", const Color(0xFFE1306C), Icons.camera_alt_rounded),
                        _buildShareBtn("Facebook", const Color(0xFF1877F2), Icons.facebook_rounded),
                        _buildShareBtn("X (Twitter)", Colors.black, Icons.tag_rounded),
                        _buildShareBtn("More", const Color(0xFF94A3B8), Icons.more_horiz_rounded),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- 5. YOUR EARNINGS CARD ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Your Earnings",
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                "View History →",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildEarningsColumn(Icons.stars_rounded, "420", "Total EvePoints\nEarned", const Color(0xFFF5F3FF), const Color(0xFF4313B8)),
                              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
                              _buildEarningsColumn(Icons.people_alt_rounded, "12", "Friends\nJoined", const Color(0xFFECFDF5), const Color(0xFF047857)),
                              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
                              _buildEarningsColumn(Icons.account_balance_wallet_rounded, "320", "EvePoints\nRedeemed", const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- 6. HOW IT WORKS SECTION ---
                    const Text(
                      "How it works",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepItem("1", Icons.share_rounded, "Share your code", "Share your referral\ncode with friends"),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: CustomPaint(
                              painter: DashedLinePainter(color: const Color(0xFFDDD6FE)),
                              child: const SizedBox(height: 1),
                            ),
                          ),
                        ),
                        _buildStepItem("2", Icons.person_add_alt_1_rounded, "Friend joins", "Your friend signs up\nand takes their first ride"),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: CustomPaint(
                              painter: DashedLinePainter(color: const Color(0xFFDDD6FE)),
                              child: const SizedBox(height: 1),
                            ),
                          ),
                        ),
                        _buildStepItem("3", Icons.emoji_events_rounded, "You earn points", "You get 100 EvePoints\nthey get 50 EvePoints"),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- 7. REDEEM PROMO BANNER ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDDD6FE)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: Color(0xFF4313B8), shape: BoxShape.circle),
                            child: const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Redeem your EvePoints",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Use your points to get discounts on rides, unlock offers and more!",
                                  style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4313B8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              "Explore Offers →",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareBtn(String name, Color bg, IconData icon) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEarningsColumn(IconData icon, String val, String lbl, Color bg, Color iconColor) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 2),
          Text(
            lbl,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold, height: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String stepNo, IconData icon, String title, String subtitle) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(icon, color: const Color(0xFF4313B8), size: 18),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFF4313B8), shape: BoxShape.circle),
                child: Text(
                  stepNo,
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.w500, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = const Color(0xFFDDD6FE),
    this.strokeWidth = 1.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double length = gap;
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + length),
          paint,
        );
        distance += length * 2;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) => false;
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedLinePainter({
    this.color = const Color(0xFFDDD6FE),
    this.strokeWidth = 1.5,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double dx = 0.0;
    while (dx < size.width) {
      canvas.drawLine(Offset(dx, size.height / 2), Offset(dx + gap, size.height / 2), paint);
      dx += gap * 2;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => false;
}
