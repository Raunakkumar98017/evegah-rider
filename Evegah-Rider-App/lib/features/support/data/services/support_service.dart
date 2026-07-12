class SupportService {
  final String supportEmail = "support@evegah.com";
  final String supportPhone = "+91 98765 43210";
  final String operatingHours = "Mon - Sun, 8:00 AM to 10:00 PM";

  Future<List<Map<String, String>>> fetchFaqs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        "question": "How do I unlock an EVegah scooter?",
        "answer": "Simply open the app, scan the QR code on the handlebar, or enter the vehicle ID directly to start your ride."
      },
      {
        "question": "What happens if my battery dies mid-ride?",
        "answer": "If your battery drops below 10%, please park the vehicle in a designated zone and finish the ride. You can swap vehicles."
      },
      {
        "question": "Where should I park the scooter?",
        "answer": "You must park in any of the authorized EVegah Parking Zones highlighted on the map."
      },
      {
        "question": "How do I top up my wallet?",
        "answer": "Go to the Wallet tab, select or enter an amount, and complete the recharge using UPI, Card, or NetBanking."
      }
    ];
  }
}