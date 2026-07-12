class UnlockService {
  // --- 1. FETCH VEHICLE LOCATION ---
  Future<Map<String, double>?> fetchVehicleLocation(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      "lat": 28.6304,
      "lng": 77.2177,
    };
  }

  // --- 2. UNLOCK VEHICLE ---
  Future<int?> unlockVehicle(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Delay to simulate bluetooth/server unlock
    return 999; // Mock booking ID
  }
}