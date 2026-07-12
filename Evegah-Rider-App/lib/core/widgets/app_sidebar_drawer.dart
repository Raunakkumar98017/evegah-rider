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

  // 1. Dashboard Helper (Wipes stack)
  void _navigateToDashboard(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  // 2. Sub-page Helper (Keeps dashboard in stack so 'Back' works)
  void _navigateToSubPage(BuildContext context, Widget screen) {
    Navigator.pop(context);
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
          // =================================================
// RIDER PROFILE HEADER
// =================================================

Container(
  width: double.infinity,

  padding: EdgeInsets.fromLTRB(
    22,
    MediaQuery.of(context).padding.top + 28,
    20,
    30,
  ),

  decoration: const BoxDecoration(
    color: Color(0xFF24105E),

    borderRadius: BorderRadius.only(
      bottomRight: Radius.circular(42),
    ),
  ),

  child: Material(
    color: Colors.transparent,

    child: InkWell(
      onTap: () {
  _navigateToSubPage(
    context,
    const ProfileScreen(),
  );
},

      borderRadius: BorderRadius.circular(24),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          // =================================================
          // PROFILE ICON
          // =================================================

          Container(
            height: 55,
            width: 55,

            decoration: BoxDecoration(
              color: const Color(0xFF8CE600),

              borderRadius: BorderRadius.circular(23),
            ),

            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF24105E),
              size: 32,
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          // =================================================
          // PROFILE INFORMATION
          // =================================================

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // Rider name

                const Text(
                  "Hello, Rider!",

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 21,

                    fontWeight: FontWeight.w800,

                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                // Profile description

                 Transform.translate(
                  offset: Offset(-3, 0),

                  child: Row(
                    children: [

                      Icon(
                        Icons.bolt_rounded,

                        color: Color(
                          0xFF8CE600,
                        ),

                        size: 18,
                      ),

                      SizedBox(
                        width: 1,
                      ),

                      Expanded(
                        child: Text(
                          "View and edit your profile",

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style: TextStyle(
                            color: Colors.white70,

                            fontSize: 10,

                            fontWeight:
                                FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          // =================================================
          // ARROW BUTTON
          // =================================================

          Container(
            height: 43,
            width: 43,

            decoration: BoxDecoration(
              color: Colors.white12,

              borderRadius: BorderRadius.circular(
                14,
              ),
            ),

            child: const Icon(
              Icons.chevron_right_rounded,

              color: Colors.white70,

              size: 28,
            ),
          ),
        ],
      ),
    ),
  ),
),
          // Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                _buildSectionHeader("EV BOOKING & FLOWS"),
                _buildDrawerTile(context, Icons.dashboard_rounded, "Dashboard Home", "Main rider dashboard", () => _navigateToDashboard(context)),
                _buildDrawerTile(context, Icons.electric_scooter_rounded, "Rent Your EV", "Search & overview page", () => _navigateToSubPage(context, const RentEvScreen())),
                _buildDrawerTile(context, Icons.location_on_rounded, "Select Zone & Location", "Find zones near you", () => _navigateToSubPage(context, SelectLocationScreen(currentCity: "Vadodara", onLocationSelected: (city) {}))),
                _buildDrawerTile(context, Icons.calendar_month_rounded, "Select Package & Dates", "Package & hourly date picker", () => _navigateToSubPage(context, const SelectDateTimeScreen())),
                _buildDrawerTile(context, Icons.two_wheeler_rounded, "Choose Your EV", "Vehicle selection list", () => _navigateToSubPage(context, const VehicleListScreen())),
                
                const Divider(height: 24, indent: 12, endIndent: 12),
                
                _buildSectionHeader("SERVICES & ACCOUNT"),
                _buildDrawerTile(context, Icons.payments_rounded, "Payments & Offers", "Checkout & promo discounts", () => _navigateToSubPage(context, const OfferScreen())),
                _buildDrawerTile(context, Icons.history_rounded, "My Rides & History", "Active and past bookings", () => _navigateToSubPage(context, const RideHistoryScreen())),
                _buildDrawerTile(context, Icons.account_balance_wallet_rounded, "Wallet & Transactions", "Balance and payment methods", () => _navigateToSubPage(context, const WalletScreen())),
                _buildDrawerTile(context, Icons.person_rounded, "My Profile", "Personal information & stats", () => _navigateToSubPage(context, const ProfileScreen())),
                _buildDrawerTile(context, Icons.verified_user_rounded, "KYC Verification", "Identity & Aadhaar [Redacted]", () => _navigateToSubPage(context, const KycScreen())),
                _buildDrawerTile(context, Icons.qr_code_scanner_rounded, "Scan to Ride (QR)", "QR scanner vehicle unlock", () => _navigateToSubPage(context, const ScanQrScreen())),
                _buildDrawerTile(context, Icons.login_rounded, "Auth / Login", "Phone & Google sign-in", () => _navigateToSubPage(context, const LoginScreen())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 6), child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.8)));
  }

  Widget _buildDrawerTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF4313B8), size: 20)),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
      ),
    );
  }
}