class RideService {
  static final RideService _instance = RideService._internal();
  factory RideService() => _instance;
  RideService._internal();

  // --- 1. FETCH RIDE HISTORY ---
  Future<List<Map<String, dynamic>>> fetchRideHistory() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return [
      {
        "rideId": "RIDE-9021",
        "date": "18-06-2026",
        "vehicleId": "EVEGAH_E1",
        "distance": "5.2 km",
        "time": "22 mins",
        "cost": "₹ 45"
      },
      {
        "rideId": "RIDE-8942",
        "date": "15-06-2026",
        "vehicleId": "EVEGAH_E2",
        "distance": "3.1 km",
        "time": "15 mins",
        "cost": "₹ 30"
      },
      {
        "rideId": "RIDE-8711",
        "date": "10-06-2026",
        "vehicleId": "EVEGAH_E3",
        "distance": "8.4 km",
        "time": "40 mins",
        "cost": "₹ 75"
      }
    ];
  }

  // --- 2. POLL LIVE RIDE DETAILS ---
  Future<Map<String, dynamic>> getLiveRideDetails(String vehicleId, int rideBookingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulate battery ticking down and variable speed
    return {
      "batteryPercentage": 82,
      "speed": 24,
      "distanceCovered": 1.4,
      "durationMinutes": 6,
      "currentCost": 18.00,
    };
  }

  // --- 3. END THE RIDE ---
  Future<bool> endRide(int rideBookingId, double endLat, double endLng) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // --- 4. SUBMIT FEEDBACK ---
  Future<bool> submitFeedback({
    required String vehicleId,
    required int rideBookingId,
    required int rating,
    required List<String> issues,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}