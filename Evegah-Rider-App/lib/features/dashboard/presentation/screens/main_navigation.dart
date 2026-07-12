import 'package:flutter/material.dart';
import '../../../../core/widgets/app_sidebar_drawer.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../rides/presentation/screen/ride_history_screen.dart'; 
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../../core/services/session_service.dart';
import '../../../unlock/presentation/screens/scan_qr_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (_currentIndex == 2) {
      _currentIndex = 3; // Wallet is index 3
    } else if (_currentIndex == 3 || _currentIndex == 4) {
      _currentIndex = 4; // Profile is index 4
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const RideHistoryScreen();
      case 3:
        return const WalletScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }

  Future<void> _handleTabTap(int index) async {
    // If tapping Scan to Ride (2)
    if (index == 2) {
      final loggedIn = await SessionService().isLoggedIn();
      if (!mounted) return;
      if (!loggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanQrScreen()),
        );
      }
      return;
    }

    // Other tabs (Bookings: 1, Wallet: 3, Profile: 4) require login check
    if (index == 1 || index == 3 || index == 4) {
      final loggedIn = await SessionService().isLoggedIn();
      if (!mounted) return;
      if (!loggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final bool isSelected = _currentIndex == index;
    final Color color = isSelected ? const Color(0xFF4313B8) : const Color(0xFF94A3B8);
    final IconData icon = isSelected ? filledIcon : outlineIcon;

    return Expanded(
      child: InkWell(
        onTap: () => _handleTabTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanToRideNavItem() {
    return Expanded(
      child: InkWell(
        onTap: () => _handleTabTap(2),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Transform.translate(
          offset: const Offset(0, -6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF200F54), // Deep brand purple
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF200F54).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Scan to Ride",
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebarDrawer(),
      body: _getBody(),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, "Home"),
              _buildNavItem(1, Icons.motorcycle_outlined, Icons.motorcycle_rounded, "My Rides"),
              _buildScanToRideNavItem(),
              _buildNavItem(3, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, "Wallet"),
              _buildNavItem(4, Icons.person_outline, Icons.person, "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}