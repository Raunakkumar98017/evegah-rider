import 'package:flutter/material.dart';
import '../../data/services/profile_service.dart';
import 'basic_profile_screen.dart';
import '../../../offers/presentation/screens/offer_screen.dart';
import '../../../offers/presentation/screens/refer_earn_screen.dart';
import '../../../preferences/presentation/screens/preferences_screen.dart';
import '../../../support/presentation/screens/faq_screen.dart';
import '../../../support/presentation/screens/help_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../rides/presentation/screen/ride_history_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../../core/services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  void _refreshProfile() {
    setState(() {});
  }

  Future<void> _handleLogout() async {
    await SessionService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. TOP HEADER (Logo, Bell, Profile) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // spacer to align center
                    const SizedBox(width: 48),
                    // evegah logo
                    const Text(
                      "evegah",
                      style: TextStyle(
                        color: Color(0xFF4313B8),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    // Bell & Profile
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

              const SizedBox(height: 12),

              // --- 2. USER DETAILS CARD WITH STATS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // User Info Row
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BasicProfileScreen()),
                          );
                          _refreshProfile();
                        },
                        child: Row(
                          children: [
                            // Avatar initials with Edit button
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 38,
                                  backgroundColor: const Color(0xFF31108F),
                                  child: Text(
                                    _profileService.userName.isNotEmpty
                                        ? _profileService.userName.split(' ').map((e) => e[0]).take(2).join()
                                        : "AO",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD2FC00),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.black, size: 12),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            // Name, phone, email & verification status
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _profileService.userName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _profileService.phoneNumber,
                                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    _profileService.email,
                                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  // Verified Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F3FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.check_rounded, color: Color(0xFF4313B8), size: 10),
                                        SizedBox(width: 3),
                                        Text(
                                          "Verified",
                                          style: TextStyle(
                                            color: Color(0xFF4313B8),
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey, size: 18),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      const SizedBox(height: 14),

                      // Stats row (3 columns)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(Icons.electric_scooter_outlined, "32", "Total Rides"),
                          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
                          _buildStatColumn(Icons.eco_outlined, "18.4 kg", "CO₂ Saved"),
                          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
                          _buildStatColumnWithInfo(Icons.stars_outlined, "420", "EvePoints"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- 3. REFER & EARN EVEPOINTS BANNER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FEE7), // Soft yellow-green
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD9F99D)),
                  ),
                  child: Row(
                    children: [
                      // 3D-like gift box image
                      Image.asset(
                        "assets/gift_box_refer.png",
                        width: 52,
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Refer & Earn EvePoints",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Invite friends and earn points on every ride!",
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReferEarnScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF65A30D),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: const Text(
                          "Refer Now →",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- 4. EVECLUB MEMBER PROGRESS CARD ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF), // Soft purple/lavender
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF4313B8), shape: BoxShape.circle),
                            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "EveClub Member",
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    const SizedBox(width: 6),
                                    // Silver Tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E7FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "Silver",
                                        style: TextStyle(color: Color(0xFF4313B8), fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "You're 80 points away from Gold level",
                                  style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            "420",
                            style: TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                          const Text(
                            " / 500 pts",
                            style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey, size: 16),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Linear progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 420 / 500,
                          minHeight: 6,
                          backgroundColor: Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4313B8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- 5. PROFILE MENU ITEMS LIST ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(Icons.access_time_rounded, "Ride History", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RideHistoryScreen()));
                      }),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      _buildMenuItem(Icons.credit_card_rounded, "Payment Methods", () {}),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      _buildMenuItem(Icons.account_balance_wallet_outlined, "Wallet", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
                      }),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      _buildMenuItem(Icons.local_offer_outlined, "Promotions & Offers", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OfferScreen()));
                      }),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      _buildMenuItem(Icons.shield_outlined, "Safety & Help", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
                      }),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      _buildMenuItem(Icons.settings_outlined, "Settings", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferencesScreen()));
                      }),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      _buildMenuItem(Icons.info_outline_rounded, "About Evegah", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()));
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- 6. LOG OUT BUTTON ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: _handleLogout,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                        SizedBox(width: 12),
                        Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String val, String lbl) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4313B8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4313B8), size: 20),
        ),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
        const SizedBox(height: 2),
        Text(lbl, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatColumnWithInfo(IconData icon, String val, String lbl) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4313B8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4313B8), size: 20),
        ),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lbl, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(width: 3),
            const Icon(Icons.info_outline_rounded, color: Colors.grey, size: 10),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4313B8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF4313B8), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}