import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../dashboard/presentation/screens/main_navigation.dart';
import '../../../kyc/presentation/screens/kyc_screen.dart';
import '../../../wallet/presentation/screens/payment_screen.dart';
import '../../../../core/services/session_service.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final bool isDepositPaid;
  final String reservationId;

  const BookingConfirmedScreen({
    super.key,
    this.isDepositPaid = false,
    this.reservationId = '',
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  late bool _depositPaid;

  @override
  void initState() {
    super.initState();
    _depositPaid = widget.isDepositPaid;
    SessionService().setFirstRideBooked(true);
  }

  void _copyBookingId() {
    final id = widget.reservationId.isNotEmpty ? widget.reservationId : 'EVG12345678';
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Booking ID copied to clipboard!"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // Go back to main navigation (index 0 - Home)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 0)),
              (route) => false,
            );
          },
        ),
        title: Row(
          children: const [
            Text(
              "Booking Confirmed!",
              style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(width: 6),
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.headset_mic_outlined, size: 16, color: Color(0xFF4313B8)),
            label: const Text(
              "Help",
              style: TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Subtitle
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: const Text(
                "Pay anytime before ride starts",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),

            // 1. Booking ID Header Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Booking ID", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            widget.reservationId.isNotEmpty ? widget.reservationId : "EVG12345678",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _copyBookingId,
                            child: const Icon(Icons.copy, size: 16, color: Color(0xFF4313B8)),
                          ),
                        ],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Booking Status", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Confirmed",
                          style: TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            // 2. Payment Pending Alert (only if unpaid)
            if (!_depositPaid)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF16A34A), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Payment Pending",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF15803D)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "You can pay the refundable deposit anytime before ride starts",
                            style: TextStyle(color: Colors.grey, fontSize: 10, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Pay Now", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

            // 3. Vehicle Detail Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset("assets/mink.png", fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "EVegah Mink",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Self-Drive",
                                style: TextStyle(color: Color(0xFF4313B8), fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.speed, color: Color(0xFF4313B8), size: 12),
                            SizedBox(width: 4),
                            Text("60 km range", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.bolt, color: Color(0xFF4313B8), size: 12),
                            SizedBox(width: 4),
                            Text("25 km/h top speed", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.airline_seat_recline_normal, color: Color(0xFF4313B8), size: 12),
                            SizedBox(width: 4),
                            Text("1 Seat", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.battery_charging_full, color: Color(0xFF4313B8), size: 12),
                            SizedBox(width: 4),
                            Text("Removable Battery", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "₹29/hr",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Text(
                          "Available",
                          style: TextStyle(color: Color(0xFF16A34A), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Ride Schedule
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_month, color: Color(0xFF4313B8), size: 18),
                      SizedBox(width: 8),
                      Text("Ride Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: const [
                        Icon(Icons.my_location, color: Color(0xFF4313B8), size: 14),
                        SizedBox(width: 4),
                        Text("View on Map", style: TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Dotted Schedule Cards
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  // Timeline column
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4313B8), width: 3),
                        ),
                      ),
                      Container(
                        width: 1.5,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4313B8), width: 3),
                        ),
                      ),
                      Container(
                        width: 1.5,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pickup
                        const Text("Pickup", style: TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 2),
                        const Text("15 May 2024, 09:00 AM", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 14),
                        // Return
                        const Text("Return", style: TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 2),
                        const Text("15 May 2024, 11:00 AM", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 14),
                        // Duration
                        const Text("Duration", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 2),
                        const Text("2 Hours", style: TextStyle(color: Color(0xFF1E293B), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Location Summary column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Koramangala Parking 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E293B))),
                        const SizedBox(height: 2),
                        const Text("Basavanagudi Main Rd,\nKoramangala, Bengaluru 560034", style: TextStyle(color: Colors.grey, fontSize: 9, height: 1.3)),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () {},
                          child: const Text("Same as Pickup", style: TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.underline)),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 5. What's next banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
                    child: const Icon(Icons.info, color: Color(0xFF4313B8), size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("What's next?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4313B8))),
                        SizedBox(height: 4),
                        Text(
                          "Reach your pickup zone 10 mins before your pickup time.\nComplete E-KYC and pay the deposit anytime before your ride starts.",
                          style: TextStyle(color: Color(0xFF5B21B6), fontSize: 10, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF8B5CF6)),
                ],
              ),
            ),

            // 6. Complete E-KYC Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.shield_outlined, color: Color(0xFF4313B8), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text("Complete E-KYC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                                  child: const Text("Required before ride start", style: TextStyle(color: Color(0xFF4313B8), fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text("Complete your E-KYC now to unlock your ride at pickup.", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const KycScreen(),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4313B8),
                          side: const BorderSide(color: Color(0xFF4313B8)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text("Start E-KYC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildKycMetric(Icons.check_circle_outline, "Quick & Secure", "Takes less than 2 mins"),
                      _buildKycMetric(Icons.badge_outlined, "Aadhaar Verified", "100% secure verification"),
                      _buildKycMetric(Icons.lock_open, "Required for Unlock", "Complete before ride start"),
                    ],
                  ),
                ],
              ),
            ),

            // 7. Booking Summary Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Booking Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                  const SizedBox(height: 14),
                  _buildSummaryRow("Rental Charges (2 Hours)", "₹58.00"),
                  const SizedBox(height: 10),
                  _buildSummaryRow("Platform Fee", "₹5.00"),
                  const SizedBox(height: 10),
                  _buildSummaryRow("Taxes", "₹2.50"),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Total Payable", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                      Text("₹65.50", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4313B8))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Refundable Deposit row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 16),
                            SizedBox(width: 8),
                            Text("Refundable Deposit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF16A34A))),
                          ],
                        ),
                        Text(
                          "₹1,000",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: const Color(0xFF16A34A),
                            decoration: _depositPaid ? TextDecoration.none : TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: _depositPaid
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaymentScreen()),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4313B8),
                    side: const BorderSide(color: Color(0xFFDDD6FE), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _depositPaid ? "Deposit Paid" : "Pay Now",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _depositPaid ? "Successfully paid" : "Pay the deposit anytime",
                        style: const TextStyle(color: Colors.grey, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B0B78), // Deep purple
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Navigate to Pickup Zone", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text("Reach 10 mins before pickup time", style: TextStyle(color: Colors.white70, fontSize: 8)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFooterNavButton(Icons.calendar_today_outlined, "Add to Calendar", () {}),
              _buildFooterNavButton(Icons.share_outlined, "Share Booking", () {}),
              _buildFooterNavButton(Icons.receipt_long_outlined, "View My Bookings", () {
                // Navigate to bookings list (MainNavigation at index 1)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 1)),
                  (route) => false,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildKycMetric(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4313B8), size: 16),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Color(0xFF1E293B))),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 8)),
      ],
    );
  }

  Widget _buildFooterNavButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF4313B8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
