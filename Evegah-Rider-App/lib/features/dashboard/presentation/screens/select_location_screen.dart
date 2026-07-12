import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/franchise_service.dart';
import '../../../../core/constants/app_constants.dart';
import 'zone_map_screen.dart';

class SelectLocationScreen extends StatefulWidget {
  final String currentCity;
  final Function(dynamic) onLocationSelected;

  const SelectLocationScreen({
    super.key,
    required this.currentCity,
    required this.onLocationSelected,
  });

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedZoneIndex = 0;
  List<Map<String, dynamic>> _nearestZones = [];
  Position? _currentPosition;
  String _currentAddress = "Locating your position...";
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    FranchiseService().init();

    _searchController.addListener(() {
      setState(() {});
    });
    
    // Set fallback zones initially
    final activeFran = FranchiseService().activeFranchise;
    _nearestZones = [];
    for (int i = 0; i < activeFran.zones.length; i++) {
      final name = activeFran.zones[i];
      _nearestZones.add({
        "name": name,
        "distance": "${(1.2 + i * 1.1).toStringAsFixed(1)} km",
        "address": "$name, ${activeFran.city}",
        "hours": "Open 24x7",
        "isPopular": i == 0,
        "color": i == 0 ? const Color(0xFFF5F3FF) : Colors.white,
        "iconColor": i == 0 ? const Color(0xFF4313B8) : const Color(0xFF64748B),
      });
    }

    _getCurrentLocation();
    _fetchZones();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = "Location services disabled";
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = "Location permissions denied";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = "Permissions permanently denied";
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      String finalAddress = "${FranchiseService().activeFranchise.city}, India";
      try {
        final geocodeUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyC_Pn12n9hRH5jQdxU7hQUOPDy820ehjwo';
        final geoRes = await http.get(Uri.parse(geocodeUrl)).timeout(const Duration(seconds: 3));
        if (geoRes.statusCode == 200) {
          final geoData = json.decode(geoRes.body);
          if (geoData['status'] == 'OK' && geoData['results'] != null && geoData['results'].isNotEmpty) {
            finalAddress = geoData['results'][0]['formatted_address'] ?? finalAddress;
          }
        }
      } catch (ge) {
        debugPrint("Failed to reverse geocode: $ge");
      }

      setState(() {
        _currentPosition = position;
        _currentAddress = finalAddress;
        _isLoadingLocation = false;
      });

      _updateZoneDistances(position);
    } catch (e) {
      debugPrint("Error getting current location: $e");
      String fallbackCity = "${FranchiseService().activeFranchise.city}, India";
      setState(() {
        _currentAddress = fallbackCity;
        _isLoadingLocation = false;
      });
    }
  }

  void _updateZoneDistances(Position position) {
    if (_nearestZones.isEmpty) return;

    List<Map<String, dynamic>> updated = [];
    for (var zone in _nearestZones) {
      double zoneLat = 22.3072;
      double zoneLng = 73.1812;
      
      if (zone['center'] != null) {
        zoneLat = (zone['center']['lat'] as num).toDouble();
        zoneLng = (zone['center']['lng'] as num).toDouble();
      } else if (zone['points'] != null && (zone['points'] as List).isNotEmpty) {
        final firstPt = zone['points'][0];
        zoneLat = (firstPt['lat'] as num).toDouble();
        zoneLng = (firstPt['lng'] as num).toDouble();
      }

      double distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        zoneLat,
        zoneLng,
      );

      double distanceKm = distanceMeters / 1000.0;
      
      updated.add({
        ...zone,
        "distance": "${distanceKm.toStringAsFixed(1)} km",
        "distanceVal": distanceKm,
      });
    }

    // Sort by distance ascending
    updated.sort((a, b) => (a['distanceVal'] as double).compareTo(b['distanceVal'] as double));

    setState(() {
      _nearestZones = updated;
      _selectedZoneIndex = 0; // Auto-select nearest zone!
    });
  }

  Future<void> _fetchZones() async {
    final urls = [
      AppConstants.getLiveZones,
      'http://192.168.1.4:5000/api/v1/getzoneDetailWithBikeCountList',
      'http://localhost:5000/api/v1/getzoneDetailWithBikeCountList',
      'http://10.0.2.2:5000/api/v1/getzoneDetailWithBikeCountList',
      'http://192.168.1.4:5000/api/zones',
      'http://localhost:5000/api/zones',
    ];

    for (final url in urls) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success' && data['data'] != null) {
            final List dbList = data['data'];
            if (dbList.isNotEmpty) {
              final mapped = dbList.map((z) => {
                "id": z['id'],
                "name": z['name'] ?? '',
                "distance": "1.5 km",
                "address": z['address'] ?? z['locality'] ?? '',
                "hours": "Open 24x7",
                "isPopular": true,
                "color": const Color(0xFFF5F3FF),
                "iconColor": const Color(0xFF4313B8),
                "center": z['center'],
                "points": z['points'],
                "pricing": z['pricing'],
              }).toList();

              setState(() {
                _nearestZones = mapped;
              });

              if (_currentPosition != null) {
                _updateZoneDistances(_currentPosition!);
              }
              return;
            }
          }
        }
      } catch (e) {
        debugPrint("Failed to fetch zones from $url: $e");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFE),
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP SEARCH HEADER ---
            _buildTopSearchHeader(),

            // --- MAIN SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. CURRENT LOCATION CARD ---
                    _buildCurrentLocationCard(),
                    const SizedBox(height: 16),

                    // --- 3. NEAREST ZONES HEADER ---
                    _buildNearestZonesHeader(),
                    const SizedBox(height: 12),

                    // --- 4. ZONES LIST CARDS ---
                    ...List.generate(_nearestZones.length, (index) {
                      final zone = _nearestZones[index];
                      final bool isSelected = _selectedZoneIndex == index;
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(zone["name"]),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 80)),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 15 * (1.0 - value)),
                            child: Opacity(
                              opacity: value,
                              child: _buildZoneCard(zone, index, isSelected),
                            ),
                          );
                        },
                      );
                    }),

                    // MORE ZONES CARD
                    _buildMoreZonesCard(),
                    const SizedBox(height: 16),

                    // --- 5. GO GREEN WITH EVEGAH BANNER ---
                    _buildGoGreenBanner(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- BOTTOM CONTINUE ACTION BUTTON ---
            _buildBottomActionButton(),
          ],
        ),
      ),
    );
  }

  // Top Search Header with merged back button and search box
  Widget _buildTopSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Circular Back Arrow Button
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF200F54), size: 20),
            ),
          ),
          const SizedBox(width: 10),
          // Clean merged Search Field Box
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: "Search for a zone or location",
                        hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                    ),
                    const SizedBox(width: 14),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Current Location Card
  Widget _buildCurrentLocationCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDD6FE).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.my_location_rounded, color: Color(0xFF4313B8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Current Location",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (!_isLoadingLocation)
            InkWell(
              onTap: () {
                if (_nearestZones.isNotEmpty) {
                  final nearestZone = _nearestZones[0];
                  widget.onLocationSelected(nearestZone['name']);
                  Navigator.pop(context, nearestZone['name']);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.near_me_outlined, size: 12, color: Color(0xFF4313B8)),
                    SizedBox(width: 4),
                    Text(
                      "Use Current",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Nearest Zones Section Header
  Widget _buildNearestZonesHeader() {
    return Row(
      children: [
        const Icon(Icons.navigation_outlined, size: 14, color: Color(0xFF4313B8)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Nearest Zones",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              "Based on your current location",
              style: TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  // Zone Card Item
  Widget _buildZoneCard(Map<String, dynamic> zone, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedZoneIndex = index;
        });
        widget.onLocationSelected(zone["name"]);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF4313B8) : const Color(0xFFF1F5F9),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Circle Icon Box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: zone["color"],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.electric_scooter_rounded, color: zone["iconColor"], size: 22),
            ),
            const SizedBox(width: 12),

            // Center Zone Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        zone["name"],
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      if (zone["isPopular"]) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Most Popular",
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF64748B)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          zone["address"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 10, color: Color(0xFF64748B)),
                      const SizedBox(width: 2),
                      Text(
                        zone["hours"],
                        style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right Distance & Chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  zone["distance"],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // More Zones Card
  Widget _buildMoreZonesCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ZoneMapScreen()),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.grid_view_rounded, color: Color(0xFF4313B8), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "More Zones",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
                ),
                SizedBox(height: 2),
                Text(
                  "Explore all zones in Bengaluru",
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
        ],
      ),
    ),
  );
}

  // Go Green Banner
  Widget _buildGoGreenBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6F4D0)),
            ),
            child: const Icon(Icons.eco_outlined, color: Color(0xFF16A34A), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Go Green with Evegah!",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                ),
                SizedBox(height: 4),
                Text(
                  "Our EVs help you reduce carbon footprint and build a cleaner tomorrow.",
                  style: TextStyle(fontSize: 9, color: Color(0xFF64748B), height: 1.3),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 45,
            child: Image.asset("assets/city.png", fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.electric_scooter, color: Color(0xFF4313B8), size: 30)),
          ),
        ],
      ),
    );
  }

  // Bottom Continue Action Button
  Widget _buildBottomActionButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: InkWell(
          onTap: () {
            if (_nearestZones.isEmpty || _selectedZoneIndex >= _nearestZones.length) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No operational zones found in this area.")),
              );
              return;
            }
            final selectedZoneMap = _nearestZones[_selectedZoneIndex];
            widget.onLocationSelected(selectedZoneMap);
            Navigator.pop(context, selectedZoneMap);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF200F54), // Deep brand purple
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
