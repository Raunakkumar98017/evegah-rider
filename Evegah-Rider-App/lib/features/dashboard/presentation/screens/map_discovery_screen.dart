import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import 'vehicle_details_screen.dart';

class MapDiscoveryScreen extends StatefulWidget {
  const MapDiscoveryScreen({super.key});

  @override
  State<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends State<MapDiscoveryScreen> {
  GoogleMapController? _mapController;
  int _currentNavIndex = 0; // Bottom nav state

  // Connaught Place center
  final LatLng _center = const LatLng(28.6304, 77.2177);

  Set<Polygon> _polygons = {};
  bool _isLoadingZones = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveZones();
  }

  Future<void> _fetchLiveZones() async {
    setState(() {
      _isLoadingZones = true;
    });

    try {
      final response = await http.get(Uri.parse(AppConstants.getLiveZones));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final List<dynamic> zonesList = decoded['data'];
          final Set<Polygon> loadedPolygons = {};

          for (var zone in zonesList) {
            final List<dynamic> pts = zone['points'] ?? [];
            if (pts.length >= 3) {
              final List<LatLng> pointsList = pts.map<LatLng>((p) {
                return LatLng(
                  (p['lat'] as num).toDouble(),
                  (p['lng'] as num).toDouble(),
                );
              }).toList();

              loadedPolygons.add(
                Polygon(
                  polygonId: PolygonId("ZONE_${zone['id']}"),
                  points: pointsList,
                  strokeColor: const Color(0xFF7C3AED), // Premium purple outline
                  strokeWidth: 2,
                  fillColor: const Color(0xFF7C3AED).withOpacity(0.12), // 12% fill opacity
                ),
              );
            }
          }

          setState(() {
            _polygons = loadedPolygons;
            _isLoadingZones = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching live zones, falling back to mock CP zone: $e");
    }

    // Fallback to mock CP zone boundary when local backend is offline/unreachable
    setState(() {
      _polygons = {
        Polygon(
          polygonId: const PolygonId("ZONE_FALLBACK_CP"),
          points: const [
            LatLng(28.6315, 77.2197),
            LatLng(28.6328, 77.2289),
            LatLng(28.6261, 77.2314),
            LatLng(28.6198, 77.2190),
            LatLng(28.6181, 77.2093),
            LatLng(28.6232, 77.2051),
            LatLng(28.6289, 77.2078),
            LatLng(28.6315, 77.2197),
          ],
          strokeColor: const Color(0xFF7C3AED),
          strokeWidth: 2,
          fillColor: const Color(0xFF7C3AED).withOpacity(0.12),
        )
      };
      _isLoadingZones = false;
    });
  }

  // Custom marker positions and battery levels
  final List<Map<String, dynamic>> _scooters = [
    {
      'id': 'EVEGAH_E1',
      'name': 'EVegah E1',
      'range': 'Range 90 km',
      'battery': 92,
      'walkTime': '2 mins walk',
      'price': '₹18.00',
      'rateAfter': '₹3.00',
      'latLng': const LatLng(28.6322, 77.2190),
      'isPopular': true,
      'image': 'assets/mink.png',
    },
    {
      'id': 'EVEGAH_E2',
      'name': 'EVegah E2',
      'range': 'Range 110 km',
      'battery': 85,
      'walkTime': '3 mins walk',
      'price': '₹20.00',
      'rateAfter': '₹3.50',
      'latLng': const LatLng(28.6290, 77.2160),
      'isPopular': false,
      'image': 'assets/v1.webp',
    },
    {
      'id': 'EVEGAH_E3',
      'name': 'EVegah E3',
      'range': 'Range 120 km',
      'battery': 78,
      'walkTime': '4 mins walk',
      'price': '₹22.00',
      'rateAfter': '₹4.00',
      'latLng': const LatLng(28.6335, 77.2170),
      'isPopular': false,
      'image': 'assets/v2.webp',
    },
    {
      'id': 'EVEGAH_E4',
      'name': 'EVegah E4',
      'range': 'Range 80 km',
      'battery': 63,
      'walkTime': '6 mins walk',
      'price': '₹15.00',
      'rateAfter': '₹2.50',
      'latLng': const LatLng(28.6280, 77.2210),
      'isPopular': false,
      'image': 'assets/v1.webp',
    }
  ];

  Set<Marker> _buildMarkers() {
    return _scooters.map((scooter) {
      return Marker(
        markerId: MarkerId(scooter['id']),
        position: scooter['latLng'],
        infoWindow: InfoWindow(
          title: scooter['name'],
          snippet: "Battery: ${scooter['battery']}%",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          scooter['battery'] > 80 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFE),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "evegah",
                    style: TextStyle(
                      color: Color(0xFF4313B8),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.notifications_outlined, color: Colors.black, size: 20),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80",
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- MAIN LIST / CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TITLE & SUBTITLE ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Choose Your EV",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Select a scooter near you and unlock to start your ride.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.help_outline, color: Color(0xFF4313B8), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "How it works?",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF4313B8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- CURRENT LOCATION ZONE BAR ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location, color: Color(0xFF4313B8), size: 18),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Connaught Place Zone, New Delhi",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                              child: const Text(
                                "Change",
                                style: TextStyle(
                                  color: Color(0xFF4313B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- MAP WIDGET CONTAINER ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            GoogleMap(
                              onMapCreated: (controller) => _mapController = controller,
                              initialCameraPosition: CameraPosition(target: _center, zoom: 15.0),
                              markers: _buildMarkers(),
                              polygons: _polygons,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                            ),
                            // Re-center Floating button
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: GestureDetector(
                                onTap: () {
                                  _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: const Icon(Icons.gps_fixed, color: Color(0xFF4313B8), size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- AVAILABLE EV SCOOTERS LIST ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Available EV Scooters",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Row(
                            children: const [
                              Text(
                                "Filter",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4313B8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.tune, color: Color(0xFF4313B8), size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Scooter Cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _scooters.length,
                      itemBuilder: (context, index) {
                        final scooter = _scooters[index];
                        return _buildScooterCard(scooter);
                      },
                    ),

                    // --- RIDE GREEN PROMO BANNER ---
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.eco, color: Colors.green, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Ride Green. Save More.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Zero emissions, less noise, a better tomorrow.",
                                    style: TextStyle(fontSize: 11, color: Color(0xFF388E3C), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (idx) {
            setState(() {
              _currentNavIndex = idx;
            });
            // If they tap Home (idx 0), pop back
            if (idx == 0) {
              Navigator.pop(context);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4313B8),
          unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 22), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month, size: 22), label: "Bookings"),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF4313B8),
                child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
              ),
              label: "Scan",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded, size: 22), label: "Wallet"),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 22), label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildScooterCard(Map<String, dynamic> scooter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (scooter['isPopular']) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.green, size: 10),
                  SizedBox(width: 4),
                  Text(
                    "Most Popular",
                    style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              // Scooter Image
              Expanded(
                flex: 2,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(scooter['image'], fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 16),
              // Scooter specs
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scooter['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        scooter['range'],
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.battery_charging_full, color: Colors.green, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          "${scooter['battery']}% Battery",
                          style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.directions_walk, color: Colors.grey, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          scooter['walkTime'],
                          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "${scooter['price']} ",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
                        ),
                        const Text(
                          "/ 30 mins",
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(
                      "${scooter['rateAfter']} / min after",
                      style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              // Select button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleDetailsScreen(
                        vehicleId: scooter['id'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B0B78),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 0,
                ),
                child: const Text(
                  "Select",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}