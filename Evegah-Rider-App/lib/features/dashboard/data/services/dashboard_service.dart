import 'package:google_maps_flutter/google_maps_flutter.dart';

class DashboardService {
  // --- 1. FETCH LIVE ZONES ---
  Future<List<Map<String, dynamic>>> fetchLiveZonesFromApi() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Latency Simulation
    return [
      {
        'id': 'zone_cp_new_delhi',
        'center': const LatLng(28.6304, 77.2177), // Connaught Place
        'zoneName': 'Connaught Place Zone',
        'zone_address': 'Connaught Place Zone, New Delhi, Delhi 110001',
        'bikeCount': 4,
        'vehicles': [
          {
            'vehicleId': 'EVEGAH_E1',
            'modelName': 'EVegah E1',
            'battery': 92,
            'distance': '2 mins walk',
            'todaysRate': 18.00,
            'rateAfter': 3.00,
            'image': 'assets/mink.png',
            'maxRangeOn100PercentageBatteryKM': 90,
            'latitude': 28.6322,
            'longitude': 77.2190,
          },
          {
            'vehicleId': 'EVEGAH_E2',
            'modelName': 'EVegah E2',
            'battery': 85,
            'distance': '3 mins walk',
            'todaysRate': 20.00,
            'rateAfter': 3.50,
            'image': 'assets/v1.webp',
            'maxRangeOn100PercentageBatteryKM': 110,
            'latitude': 28.6290,
            'longitude': 77.2160,
          },
          {
            'vehicleId': 'EVEGAH_E3',
            'modelName': 'EVegah E3',
            'battery': 78,
            'distance': '4 mins walk',
            'todaysRate': 22.00,
            'rateAfter': 4.00,
            'image': 'assets/v2.webp',
            'maxRangeOn100PercentageBatteryKM': 120,
            'latitude': 28.6335,
            'longitude': 77.2170,
          },
          {
            'vehicleId': 'EVEGAH_E4',
            'modelName': 'EVegah E4',
            'battery': 63,
            'distance': '6 mins walk',
            'todaysRate': 15.00,
            'rateAfter': 2.50,
            'image': 'assets/v1.webp',
            'maxRangeOn100PercentageBatteryKM': 80,
            'latitude': 28.6280,
            'longitude': 77.2210,
          }
        ]
      }
    ];
  }

  // --- 2. FETCH VEHICLE DETAILS ---
  Future<Map<String, dynamic>?> fetchLiveVehicleDetails(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final String cleanId = vehicleId.toUpperCase();
    
    String modelName = 'EVegah E2';
    int battery = 85;
    int maxRange = 110;
    double todaysRate = 20.00;
    double rateAfter = 3.50;
    double lat = 28.6290;
    double lng = 77.2160;

    if (cleanId.contains('E1')) {
      modelName = 'EVegah E1';
      battery = 92;
      maxRange = 90;
      todaysRate = 18.00;
      rateAfter = 3.00;
      lat = 28.6322;
      lng = 77.2190;
    } else if (cleanId.contains('E3')) {
      modelName = 'EVegah E3';
      battery = 78;
      maxRange = 120;
      todaysRate = 22.00;
      rateAfter = 4.00;
      lat = 28.6335;
      lng = 77.2170;
    } else if (cleanId.contains('E4')) {
      modelName = 'EVegah E4';
      battery = 63;
      maxRange = 80;
      todaysRate = 15.00;
      rateAfter = 2.50;
      lat = 28.6280;
      lng = 77.2210;
    } else if (cleanId.contains('MINK')) {
      modelName = 'EVegah Mink';
      battery = 90;
      maxRange = 60;
      todaysRate = 29.00;
      rateAfter = 5.00;
      lat = 28.6304;
      lng = 77.2177;
    }

    return {
      'vehicleId': vehicleId,
      'modelName': modelName,
      'maxRangeOn100PercentageBatteryKM': maxRange.toString(),
      'latitude': lat,
      'longitude': lng,
      'lockDetails': [
        {
          'battery': battery.toString(),
          'latitude': lat.toString(),
          'longitude': lng.toString(),
        }
      ],
      'farePlanData': [
        {
          'todaysRate': todaysRate.toString(),
          'minimumHireMinuts': '30',
          'rateAfter': rateAfter.toString(),
        }
      ]
    };
  }

  // --- 3. FETCH WALLET BALANCE ---
  Future<double> fetchWalletBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 250.00;
  }
}