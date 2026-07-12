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
  // 1. Close the drawer
  Navigator.pop(context);

  // 2. Clear the entire navigation stack and push the new screen as the new "home"
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => screen,
      settings: RouteSettings(name: screen.runtimeType.toString()),
    ),
    (route) => false, // This wipes the history clean
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
            // 🚨 FIX: Removed the hardcoded 'height: 170' so it adapts to the large logo without crashing
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
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
              mainAxisSize: MainAxisSize.min, // 🚨 FIX: Tells the purple box to wrap tightly around the content
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start, // Keeps the X button aligned near the top
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 80, // Your large logo size
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.bolt, color: Color(0xFF8CE600), size: 48),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Space between your large logo and the text below
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Ride Green, Save More",
                      style: TextStyle(
                        color: Color(0xFF8CE600),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Navigation Menu & Quick Page Inspector",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
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
          /*Container(
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
          ),*/
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
            // Expanded allows the text to take up the full row width, preventing overflows
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
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