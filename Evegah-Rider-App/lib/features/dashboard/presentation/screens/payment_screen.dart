import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String selectedZone;
  final String pickupDateTime;
  final String dropDateTime;
  final String? pickupRaw;
  final String? dropRaw;
  final Map<String, dynamic> selectedVehicle;
  final Map<String, dynamic>? zonePricing;

  const PaymentScreen({
    super.key,
    required this.selectedZone,
    required this.pickupDateTime,
    required this.dropDateTime,
    this.pickupRaw,
    this.dropRaw,
    required this.selectedVehicle,
    this.zonePricing,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  final TextEditingController _couponController = TextEditingController();
  
  String _appliedCoupon = "";
  double _couponDiscount = 0.0;
  bool _isProcessing = false;

  int get _calculatedDurationDays {
    if (widget.pickupRaw != null && widget.dropRaw != null) {
      try {
        final start = DateTime.parse(widget.pickupRaw!);
        final end = DateTime.parse(widget.dropRaw!);
        final diff = end.difference(start);
        int days = diff.inDays;
        if (diff.inHours % 24 > 2) {
          days += 1;
        }
        return days > 0 ? days : 1;
      } catch (e) {
        debugPrint("Error parsing duration days: $e");
      }
    }
    return 3; // Fallback default
  }

  int get _calculatedDurationHours {
    if (widget.pickupRaw != null && widget.dropRaw != null) {
      try {
        final start = DateTime.parse(widget.pickupRaw!);
        final end = DateTime.parse(widget.dropRaw!);
        final diff = end.difference(start);
        final hours = diff.inHours;
        return hours > 0 ? hours : 24;
      } catch (e) {
        debugPrint("Error parsing duration hours: $e");
      }
    }
    return 72; // Fallback default
  }

  double get _baseRent {
    final String pricingModel = widget.zonePricing != null 
        ? widget.zonePricing!['pricingModel'] ?? 'Hourly Based' 
        : 'Hourly Based';
        
    if (pricingModel == 'Hourly Based') {
      final double hourlyRate = double.tryParse(widget.selectedVehicle['realPrice']?.toString() ?? '35') ?? 35.0;
      return hourlyRate * _calculatedDurationHours;
    } else {
      final double dailyRate = double.tryParse(widget.selectedVehicle['realPrice']?.toString() ?? '299') ?? 299.0;
      return dailyRate * _calculatedDurationDays;
    }
  }

  double get _securityDeposit {
    return double.tryParse(widget.selectedVehicle['realDeposit']?.toString() ?? '500') ?? 500.0;
  }

  double get _subtotal => _baseRent + _securityDeposit;
  double get _totalPayable => _subtotal - _couponDiscount;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      if (code == "SAVE20") {
        _appliedCoupon = "SAVE20";
        _couponDiscount = _baseRent * 0.20;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SAVE20 Applied! 20% discount on rent."), backgroundColor: Color(0xFF16A34A)),
        );
      } else if (code == "EVEGAH50") {
        _appliedCoupon = "EVEGAH50";
        _couponDiscount = _baseRent > 50 ? 50.0 : _baseRent;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("EVEGAH50 Applied! Flat ₹50 off on rent."), backgroundColor: Color(0xFF16A34A)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Coupon Code"), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = "";
      _couponDiscount = 0.0;
      _couponController.clear();
    });
  }

  void _startCheckout() {
    if (kIsWeb) {
      setState(() => _isProcessing = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _isProcessing = false);
          _showSuccessDialog("MOCK_WEB_PAY_${DateTime.now().millisecondsSinceEpoch}");
        }
      });
      return;
    }

    setState(() => _isProcessing = true);
    
    var options = {
      'key': 'rzp_test_TBHSeBmkjslGFz',
      'amount': (_totalPayable * 100).toInt(), // Amount in paise
      'name': 'Evegah Mobility',
      'description': '${widget.selectedVehicle['name']} Rental booking',
      'timeout': 180,
      'prefill': {
        'contact': '9876543210',
        'email': 'rider@evegah.com'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error initiating Razorpay: $e")),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    _showSuccessDialog(response.paymentId ?? "PAY_SUCCESS_101");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}"), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
  }

  void _showSuccessDialog(String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Checkmark
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF16A34A),
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Booking Confirmed!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your vehicle ${widget.selectedVehicle['name']} is reserved.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildDialogRow("Payment ID", paymentId),
                      const SizedBox(height: 6),
                      _buildDialogRow("Amount Paid", "₹${_totalPayable.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Dismiss Dialog
                      Navigator.of(context).popUntil((route) => route.isFirst); // Go back to Home
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF200F54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String pricingModel = widget.zonePricing != null 
        ? widget.zonePricing!['pricingModel'] ?? 'Hourly Based' 
        : 'Hourly Based';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment Checkout",
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. VEHICLE SUMMARY CARD ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      widget.selectedVehicle['image'] ?? "assets/v2.webp",
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.electric_scooter_rounded, color: Color(0xFF200F54), size: 36),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedVehicle['name'] ?? 'Evegah Premium',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Color(0xFF4313B8), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              widget.selectedZone,
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Model: ${widget.selectedVehicle['category'] ?? 'EV Bike'}",
                            style: const TextStyle(fontSize: 9, color: Color(0xFF475569), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // --- 2. BOOKING DURATION DETAILS CARD ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF200F54), size: 14),
                      const SizedBox(width: 8),
                      const Text(
                        "Rental Period",
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      Text(
                        pricingModel == 'Hourly Based'
                            ? "$_calculatedDurationHours Hours"
                            : "$_calculatedDurationDays Days",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4313B8)),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("PICKUP", style: TextStyle(fontSize: 8.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(widget.pickupDateTime, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFFCBD5E1), size: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("DROP", style: TextStyle(fontSize: 8.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(widget.dropDateTime, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // --- 3. COUPON SECTION ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Promo Coupons",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _couponController,
                            enabled: _appliedCoupon.isEmpty,
                            decoration: const InputDecoration(
                              hintText: "Enter SAVE20 or EVEGAH50",
                              hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 90,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _appliedCoupon.isEmpty ? _applyCoupon : _removeCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _appliedCoupon.isEmpty ? const Color(0xFF200F54) : Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            _appliedCoupon.isEmpty ? "Apply" : "Remove",
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_appliedCoupon.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer_rounded, color: Color(0xFF16A34A), size: 12),
                          const SizedBox(width: 6),
                          Text(
                            "Coupon '$_appliedCoupon' active!",
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // --- 4. FARE BREAKDOWN CARD ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Price Breakdown",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 14),
                  _buildFareRow(
                    "EV Rental Charge (${pricingModel == 'Hourly Based' ? '$_calculatedDurationHours hrs' : '$_calculatedDurationDays days'})", 
                    "₹${_baseRent.toStringAsFixed(2)}"
                  ),
                  const SizedBox(height: 10),
                  _buildFareRow("Security Deposit (Refundable)", "₹${_securityDeposit.toStringAsFixed(2)}"),
                  if (_couponDiscount > 0) ...[
                    const SizedBox(height: 10),
                    _buildFareRow("Coupon Discount", "-₹${_couponDiscount.toStringAsFixed(2)}", isPromo: true),
                  ],
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Payable Amount",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        "₹${_totalPayable.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF200F54)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 5. CHECKOUT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _startCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF200F54),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "PROCEED TO PAY",
                        style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Secured payment powered by Razorpay",
                style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(String label, String value, {bool isPromo = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        Text(
          value, 
          style: TextStyle(
            fontSize: 11.5, 
            color: isPromo ? const Color(0xFF16A34A) : const Color(0xFF0F172A), 
            fontWeight: isPromo ? FontWeight.bold : FontWeight.w700
          )
        ),
      ],
    );
  }
}
