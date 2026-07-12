import 'package:flutter/material.dart';
import '../../../rides/presentation/screen/booking_confirmed_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Visa'; // 'Visa', 'Mastercard', 'UPI', 'GPay', etc.
  bool _showPriceDetails = false;
  bool _isProcessing = false;

  void _processPayment() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment process delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      // Navigate to Booking Confirmed Screen with deposit paid
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BookingConfirmedScreen(isDepositPaid: true),
        ),
      );
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified_user, color: Color(0xFF4313B8), size: 14),
                SizedBox(width: 4),
                Text(
                  "100% Secure",
                  style: TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
          )
        ],
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Color(0xFF4313B8)),
                  SizedBox(height: 16),
                  Text(
                    "Processing Payment...",
                    style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Please do not close the app or press back",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Scooter Summary Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset("assets/mink.png", fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "EVegah Mink",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.speed, color: Color(0xFF4313B8), size: 10),
                                      const SizedBox(width: 3),
                                      const Text("60 km range  •  ", style: TextStyle(color: Colors.grey, fontSize: 9)),
                                      const Icon(Icons.bolt, color: Color(0xFF4313B8), size: 10),
                                      const SizedBox(width: 3),
                                      const Text("25 km/h  •  ", style: TextStyle(color: Colors.grey, fontSize: 9)),
                                      const Icon(Icons.airline_seat_recline_normal, color: Color(0xFF4313B8), size: 10),
                                      const SizedBox(width: 3),
                                      const Text("1 Seat", style: TextStyle(color: Colors.grey, fontSize: 9)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("₹29/hr", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4313B8))),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text("Available", style: TextStyle(color: Color(0xFF16A34A), fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
                        // Schedule Summary Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildScheduleItem(Icons.calendar_today_outlined, "15 May 2024\n09:00 AM", "Pickup"),
                            _buildScheduleItem(Icons.access_time_outlined, "15 May 2024\n11:00 AM", "Return"),
                            _buildScheduleItem(Icons.location_on_outlined, "Koramangala\nParking 2", "Pickup Zone"),
                            _buildScheduleItem(Icons.timer_outlined, "\n2 Hours", "Duration"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Pricing Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Total Payable", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Text("₹65.50", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    SizedBox(width: 4),
                                    Icon(Icons.info_outline, color: Colors.grey, size: 14),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text("Incl. of all taxes", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showPriceDetails = !_showPriceDetails;
                                });
                              },
                              icon: const Text("View Price Details", style: TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold, fontSize: 11)),
                              label: Icon(
                                _showPriceDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 14,
                                color: const Color(0xFF4313B8),
                              ),
                            ),
                          ],
                        ),
                        if (_showPriceDetails) ...[
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 12),
                          _buildPriceBreakdownRow("Rental Charges (2 Hours)", "₹58.00"),
                          const SizedBox(height: 8),
                          _buildPriceBreakdownRow("Platform Fee", "₹5.00"),
                          const SizedBox(height: 8),
                          _buildPriceBreakdownRow("Taxes & GST", "₹2.50"),
                          const SizedBox(height: 8),
                          _buildPriceBreakdownRow("GET100 discount applied", "-₹100.00", isDiscount: true),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Saved Payment Methods
                  const Text("Saved Payment Methods", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildPaymentMethodTile('Visa', "Visa  •••• 4242", "Expires 08/26", Icons.credit_card, const Color(0xFF1A1F71)),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        _buildPaymentMethodTile('Mastercard', "Mastercard  •••• 1123", "Expires 11/25", Icons.credit_card, const Color(0xFFEB001B)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Color(0xFF4313B8), size: 18),
                          SizedBox(width: 6),
                          Text("Add New Card / UPI", style: TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. UPI / Other Options
                  const Text("UPI / Other Options", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildUpiOption('UPI', "UPI", "Pay using any UPI app", Icons.qr_code),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        _buildUpiOption('GPay', "GPay", "Google Pay", Icons.account_balance),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        _buildUpiOption('PhonePe', "PhonePe", null, Icons.payment),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        _buildUpiOption('Paytm', "Paytm", null, Icons.wallet),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        _buildUpiOption('AmazonPay', "Amazon Pay", null, Icons.shopping_bag_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Safe & Secure Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security, color: Color(0xFF16A34A), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Safe & Secure Payments",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF16A34A)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Your payment details are encrypted and secure.",
                                style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.lock_outline, color: Color(0xFF16A34A), size: 16),
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
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B0B78), // Deep purple
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Pay ₹65.50", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4313B8), size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: isDiscount ? const Color(0xFF16A34A) : Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDiscount ? const Color(0xFF16A34A) : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(String methodId, String title, String subtitle, IconData icon, Color brandColor) {
    final isSelected = _selectedMethod == methodId;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = methodId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: brandColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4313B8) : Colors.grey.shade300,
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiOption(String methodId, String title, String? subtitle, IconData icon) {
    final isSelected = _selectedMethod == methodId;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = methodId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF4313B8) : Colors.grey.shade600, size: 16),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? const Color(0xFF4313B8) : const Color(0xFF1E293B),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ]
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.chevron_right,
              size: 16,
              color: isSelected ? const Color(0xFF4313B8) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
