class InsightService {
  // Public variables that the UI reads
  String totalCarbonSaved = "24.5 kg";
  String totalRides = "12";
  double rawCarbonSaved = 24.5;
  String totalDistance = "204.2 km";
  List<Map<String, dynamic>> spendingData = [
    {'month': 'Jan', 'amount': 150.0},
    {'month': 'Feb', 'amount': 220.0},
    {'month': 'Mar', 'amount': 180.0},
    {'month': 'Apr', 'amount': 300.0},
    {'month': 'May', 'amount': 250.0},
    {'month': 'Jun', 'amount': 340.0},
  ];
  double maxSpending = 340.0; 
  String currentMonthName = "Jun";

  Future<void> fetchAllInsights() async {
    // Latency Simulation
    await Future.delayed(const Duration(milliseconds: 400));
  }
}