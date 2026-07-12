class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  double _currentBalance = 250.00;
  final List<Map<String, dynamic>> _mockTransactions = [
    {
      "title": "Wallet Recharge",
      "date": "18-06-2026",
      "amount": "+₹500.00",
      "isCredit": true
    },
    {
      "title": "Ride Payment",
      "date": "17-06-2026",
      "amount": "-₹120.00",
      "isCredit": false
    },
    {
      "title": "Ride Payment",
      "date": "15-06-2026",
      "amount": "-₹80.00",
      "isCredit": false
    },
    {
      "title": "Wallet Recharge",
      "date": "10-06-2026",
      "amount": "+₹200.00",
      "isCredit": true
    },
    {
      "title": "Ride Payment",
      "date": "08-06-2026",
      "amount": "-₹150.00",
      "isCredit": false
    }
  ];

  // --- 1. FETCH LIVE WALLET BALANCE ---
  Future<double> fetchWalletBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentBalance;
  }

  // --- 2. FETCH TRANSACTION HISTORY ---
  Future<List<Map<String, dynamic>>> fetchRecentTransactions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_mockTransactions);
  }

  // --- 3. CREATE RAZORPAY ORDER ---
  Future<Map<String, String>?> createOrder(int amountInRupees) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simulate successful order creation locally
    final String orderId = "order_mock_${DateTime.now().millisecondsSinceEpoch}";
    final String keyId = "rzp_test_mockkey12345";
    
    // Add transaction locally after fake successful pay
    _currentBalance += amountInRupees;
    _mockTransactions.insert(0, {
      "title": "Wallet Recharge",
      "date": "18-06-2026",
      "amount": "+₹${amountInRupees.toStringAsFixed(2)}",
      "isCredit": true
    });

    return {
      "orderId": orderId,
      "keyId": keyId
    };
  }
}