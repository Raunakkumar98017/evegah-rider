import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/rent_ev_screen.dart';
import '../../features/dashboard/presentation/screens/select_location_screen.dart';
import '../../features/dashboard/presentation/screens/select_date_time_screen.dart';
import '../../features/dashboard/presentation/screens/vehicle_list_screen.dart';

import '../../features/offers/presentation/screens/offer_screen.dart';
import '../../features/rides/presentation/screen/ride_history_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/kyc/presentation/screens/kyc_screen.dart';
import '../../features/unlock/presentation/screens/scan_qr_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

class AppSidebarDrawer extends StatelessWidget {
  const AppSidebarDrawer({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close Drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFAFBFE),
      child: Column(
        children: [
          // --- HEADER WITH LOGO & BRANDING ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF200F54), // Deep brand purple
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/Evegah_login_page_logo.png',
                            height: 24,
                            errorBuilder: (_, __, ___) => const Icon(Icons.bolt, color: Color(0xFF8CE600), size: 24),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "evegah",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Ride Green, Save More",
                  style: TextStyle(
                    color: Color(0xFF8CE600),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Navigation Menu & Quick Page Inspector",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // --- MENU ITEMS LIST ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                // SECTION 1: BOOKING & VEHICLES
                _buildSectionHeader("EV BOOKING & FLOWS"),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  title: "Dashboard Home",
                  subtitle: "Main rider dashboard",
                  badge: "Home",
                  badgeColor: const Color(0xFF4313B8),
                  onTap: () => _navigateTo(context, const DashboardScreen()),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.electric_scooter_rounded,
                  title: "Rent Your EV",
                  subtitle: "Search & overview page",
                  badge: "New UI",
                  badgeColor: const Color(0xFF16A34A),
                  onTap: () => _navigateTo(context, const RentEvScreen()),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.location_on_rounded,
                  title: "Select Zone & Location",
                  subtitle: "Find zones near you",
                  badge: "Zones",
                  badgeColor: const Color(0xFF0284C7),
                  onTap: () => _navigateTo(
                    context,
                    SelectLocationScreen(
                      currentCity: "Vadodara",
                      onLocationSelected: (city) {},
                    ),
                  ),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.calendar_month_rounded,
                  title: "Select Package & Dates",
                  subtitle: "Package & hourly date picker",
                  badge: "Dates",
                  badgeColor: const Color(0xFFEA580C),
                  onTap: () => _navigateTo(context, const SelectDateTimeScreen()),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.two_wheeler_rounded,
                  title: "Choose Your EV",
                  subtitle: "Vehicle selection list",
                  badge: "Fleet",
                  badgeColor: const Color(0xFF4313B8),
                  onTap: () => _navigateTo(context, const VehicleListScreen()),
                ),


                const Divider(height: 24, indent: 12, endIndent: 12),

                // SECTION 2: RIDER SERVICES & ACCOUNT
                _buildSectionHeader("SERVICES & ACCOUNT"),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.payments_rounded,
                  title: "Payments & Offers",
                  subtitle: "Checkout & promo discounts",
                  onTap: () => _navigateTo(context, const OfferScreen()),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.history_rounded,
                  title: "My Rides & History",
                  subtitle: "Active and past bookings",
                  onTap: () => _navigateTo(context, const RideHistoryScreen()),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.account_balance_wallet_rounded,
                  title: "Wallet & Transactions",
                  subtitle: "Balance and payment methods",
                  onTap: () => _navigateTo(context, const WalletScreen()),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.person_rounded,
                  title: "My Profile",
                  subtitle: "Personal information & stats",
                  onTap: () => _navigateTo(context, const ProfileScreen()),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.verified_user_rounded,
                  title: "KYC Verification",
                  subtitle: "Identity & Aadhaar OCR flow",
                  badge: "E-KYC",
                  badgeColor: const Color(0xFF16A34A),
                  onTap: () => _navigateTo(context, const KycScreen()),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.qr_code_scanner_rounded,
                  title: "Scan to Ride (QR)",
                  subtitle: "QR scanner vehicle unlock",
                  onTap: () => _navigateTo(context, const ScanQrScreen()),
                ),
                _buildDrawerTile(
                  context: context,
                  icon: Icons.login_rounded,
                  title: "Auth / Login",
                  subtitle: "Phone & Google sign-in",
                  onTap: () => _navigateTo(context, const LoginScreen()),
                ),
              ],
            ),
          ),

          // --- FOOTER NOTE ---
          Container(
            padding: const EdgeInsets.all(14),
            color: const Color(0xFFF1F5F9),
            child: Row(
              children: const [
                Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF16A34A)),
                SizedBox(width: 8),
                Text(
                  "Evegah Rider App v1.0 • All Pages Mapped",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4313B8), size: 20),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? const Color(0xFF4313B8)).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: badgeColor ?? const Color(0xFF4313B8),
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF64748B),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
