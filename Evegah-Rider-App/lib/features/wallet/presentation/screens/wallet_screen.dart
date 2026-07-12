import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../data/services/wallet_service.dart';
import '../../../offers/presentation/screens/offer_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();

  late Razorpay _razorpay;
  bool isProcessingPayment = false;
  bool _showBalance = true;

  // UI State Variables for Real Data
  bool isLoadingData = true;
  double _walletBalance = 2450.00; // Mock balance matching mockup 2
  double _bonusBalance = 150.00;  // Mock bonus matching mockup 2

  final List<Map<String, dynamic>> _mockTransactions = [
    {
      "title": "Ride Payment",
      "subtitle": "E-Scooter • Lekki Phase 1",
      "date": "Today, 09:20 AM",
      "amount": "- Rs. 250.00",
      "isCredit": false,
      "type": "scooter"
    },
    {
      "title": "Money Added",
      "subtitle": "From Access Bank •••• 5678",
      "date": "Today, 08:45 AM",
      "amount": "+ Rs. 1,000.00",
      "isCredit": true,
      "type": "wallet"
    },
    {
      "title": "Ride Payment",
      "subtitle": "E-Bike • Chevron Drive",
      "date": "Yesterday, 06:15 PM",
      "amount": "- Rs. 400.00",
      "isCredit": false,
      "type": "bike"
    },
    {
      "title": "Bonus Received",
      "subtitle": "Welcome Bonus",
      "date": "Yesterday, 10:30 AM",
      "amount": "+ Rs. 150.00",
      "isCredit": true,
      "type": "bonus"
    },
    {
      "title": "Ride Payment",
      "subtitle": "E-Scooter Pro • Lekki Phase 1",
      "date": "May 12, 07:40 PM",
      "amount": "- Rs. 300.00",
      "isCredit": false,
      "type": "scooter"
    }
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => isLoadingData = true);
    try {
      double balance = await _walletService.fetchWalletBalance();
      if (balance > 0) {
        _walletBalance = balance;
      }
    } catch (e) {
      // Keep fallback mock data
    }
    if (mounted) {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful! Wallet Recharged."), backgroundColor: Colors.green),
    );
    _loadWalletData();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}"), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => isProcessingPayment = false);
  }

  Future<void> _startPayment(double amount) async {
    setState(() => isProcessingPayment = true);

    Map<String, String>? orderData = await _walletService.createOrder(amount.toInt());

    if (orderData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to secure payment connection."), backgroundColor: Colors.red),
        );
      }
      setState(() => isProcessingPayment = false);
      return;
    }

    var options = {
      'key': orderData["keyId"],
      'amount': (amount * 100).toInt(),
      'name': 'EVegah Mobility',
      'description': 'Wallet Recharge',
      'order_id': orderData["orderId"],
      'timeout': 120,
      'prefill': {
        'contact': '9876543210',
        'email': 'user@evegah.com'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => isProcessingPayment = false);
    }
  }

  void _showAddMoneySheet() {
    final List<int> quickAmounts = [500, 1000, 2000, 5000];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Add Money to Wallet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: "Rs. ",
                      hintText: "Enter amount",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onChanged: (value) => setModalState(() {}),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: quickAmounts.map((amount) {
                      return GestureDetector(
                        onTap: () => setModalState(() => _amountController.text = amount.toString()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDDD6FE)),
                          ),
                          child: Text(
                            "Rs. $amount",
                            style: const TextStyle(color: Color(0xFF4313B8), fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isProcessingPayment ? null : () async {
                        double amount = double.tryParse(_amountController.text) ?? 0;
                        if (amount > 0) {
                          Navigator.pop(context);
                          await _startPayment(amount);
                          _amountController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4313B8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isProcessingPayment
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Proceed to Pay", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Withdraw Balance"),
        content: const Text("Withdrawal option is currently unavailable in mock mode."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFF4313B8))),
          )
        ],
      ),
    );
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
              // --- 1. TOP HEADER (Hamburger Menu, Logo, Bell, Profile) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Hamburger Menu
                    const Icon(Icons.menu_rounded, color: Colors.black, size: 24),
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
                                  color: Colors.green,
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

              // --- 2. TITLE & SUBTITLE ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Wallet",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Manage your balance and payments",
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- 3. PURPLE BALANCE CARD WITH 3D WALLET ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                        color: const Color(0xFF31108F).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Wallet Balance",
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                _showBalance ? "Rs. ${_walletBalance.toStringAsFixed(2)}" : "Rs. ••••••",
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => setState(() => _showBalance = !_showBalance),
                                child: Icon(
                                  _showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Bonus balance pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  "Bonus Balance: Rs. ${_bonusBalance.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Add Money & Withdraw buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _showAddMoneySheet,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD2FC00),
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    minimumSize: const Size(0, 44),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add, size: 16),
                                      SizedBox(width: 4),
                                      Text("Add Money", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _showWithdrawDialog,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.12),
                                    side: BorderSide.none,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 44),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.north_east_rounded, size: 16),
                                      SizedBox(width: 4),
                                      Text("Withdraw", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // 3D Wallet Graphic aligned on the right
                      Positioned(
                        right: 0,
                        top: 0,
                        child: _build3DWalletGraphic(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- 4. QUICK ACTIONS SECTION ---
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildQuickActionItem(Icons.history_edu_rounded, "Transaction\nHistory", Colors.lime.shade700, () {}),
                    const SizedBox(width: 10),
                    _buildQuickActionItem(Icons.local_offer_rounded, "Promotions\n& Offers", Colors.purple.shade600, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OfferScreen()),
                      );
                    }),
                    const SizedBox(width: 10),
                    _buildQuickActionItem(Icons.credit_card_rounded, "Payment\nMethods", Colors.blue.shade600, () {}),
                    const SizedBox(width: 10),
                    _buildQuickActionItem(Icons.headset_mic_rounded, "Help &\nSupport", Colors.purple.shade600, () {}),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- 5. RECENT TRANSACTIONS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "View All →",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: _mockTransactions.map((tx) => _buildTransactionRow(tx)).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // --- 6. BOTTOM PROMO BANNER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/gift_box_refer.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "More rides, more rewards!",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Top up your wallet and get exciting cashback and offers.",
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
                            MaterialPageRoute(builder: (context) => const OfferScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4313B8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text("View Offers", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 10, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
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

  // 3D Wallet Drawer
  Widget _build3DWalletGraphic() {
    return SizedBox(
      width: 75,
      height: 75,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Green Card peaking out
          Positioned(
            top: 4,
            right: 12,
            child: Transform.rotate(
              angle: 0.15,
              child: Container(
                width: 42,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD2FC00),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          // Main Wallet Body
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 62,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B21B6), Color(0xFF3B0764)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Clasp
                  Positioned(
                    right: 0,
                    top: 15,
                    child: Container(
                      width: 18,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E1065),
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD2FC00),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> tx) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (tx["type"]) {
      case "scooter":
        icon = Icons.electric_scooter_rounded;
        iconColor = Colors.green.shade700;
        iconBg = Colors.green.shade50;
        break;
      case "bike":
        icon = Icons.electric_bike_rounded;
        iconColor = Colors.green.shade700;
        iconBg = Colors.green.shade50;
        break;
      case "wallet":
        icon = Icons.account_balance_wallet_rounded;
        iconColor = Colors.purple.shade700;
        iconBg = Colors.purple.shade50;
        break;
      default:
        icon = Icons.card_giftcard_rounded;
        iconColor = Colors.purple.shade700;
        iconBg = Colors.purple.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                const SizedBox(height: 2),
                Text(tx["subtitle"], style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx["amount"],
                style: TextStyle(
                  color: tx["isCredit"] ? Colors.green.shade700 : Colors.black87,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(tx["date"], style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}