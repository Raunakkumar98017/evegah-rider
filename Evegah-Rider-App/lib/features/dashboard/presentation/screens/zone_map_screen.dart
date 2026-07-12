import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';

class ZoneMapScreen extends StatefulWidget {
  const ZoneMapScreen({super.key});

  @override
  State<ZoneMapScreen> createState() => _ZoneMapScreenState();
}

class _ZoneMapScreenState extends State<ZoneMapScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = false;
  List<dynamic> _zones = [];
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  int _selectedZoneIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(AppConstants.getLiveZones));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final List<dynamic> zonesList = decoded['data'];
          final Set<Polygon> loadedPolygons = {};
          final Set<Marker> loadedMarkers = {};

          for (int i = 0; i < zonesList.length; i++) {
            final zone = zonesList[i];
            final List<dynamic> pts = zone['points'] ?? [];
            if (pts.isNotEmpty) {
              final List<LatLng> pointsList = pts.map<LatLng>((p) {
                return LatLng(
                  (p['lat'] as num).toDouble(),
                  (p['lng'] as num).toDouble(),
                );
              }).toList();

              // Calculate center of polygon
              double latSum = 0;
              double lngSum = 0;
              for (var p in pointsList) {
                latSum += p.latitude;
                lngSum += p.longitude;
              }
              final LatLng center = LatLng(latSum / pointsList.length, lngSum / pointsList.length);
              zone['center'] = {
                'lat': center.latitude,
                'lng': center.longitude
              };

              loadedPolygons.add(
                Polygon(
                  polygonId: PolygonId("ZONE_${zone['id']}"),
                  points: pointsList,
                  strokeColor: const Color(0xFF4313B8),
                  strokeWidth: 2,
                  fillColor: const Color(0xFF4313B8).withOpacity(0.12),
                ),
              );

              loadedMarkers.add(
                Marker(
                  markerId: MarkerId("MARKER_${zone['id']}"),
                  position: center,
                  infoWindow: InfoWindow(
                    title: zone['name'] ?? 'Zone',
                    snippet: 'Code: ${zone['code'] ?? ''}',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                ),
              );
            }
          }

          setState(() {
            _zones = zonesList;
            _polygons = loadedPolygons;
            _markers = loadedMarkers;
            _isLoading = false;
          });

          // Move camera to first zone center if available
          if (_zones.isNotEmpty && _zones[0]['center'] != null && _mapController != null) {
            final center = _zones[0]['center'];
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(center['lat'], center['lng']),
                14.0,
              ),
            );
          }
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching zones for map: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onZoneSelected(int index) {
    setState(() {
      _selectedZoneIndex = index;
    });

    final zone = _zones[index];
    if (zone['center'] != null && _mapController != null) {
      final center = zone['center'];
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(center['lat'], center['lng']),
          14.5,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map View
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(28.6304, 77.2177),
              zoom: 12.0,
            ),
            polygons: _polygons,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_zones.isNotEmpty && _zones[0]['center'] != null) {
                final center = _zones[0]['center'];
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(center['lat'], center['lng']),
                    14.0,
                  ),
                );
              }
            },
          ),

          // 2. Circular Back Button & Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF200F54), size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Text(
                      "Operating Zones",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4313B8)),
              ),
            ),

          // 3. Horizontal list of zones at the bottom
          if (_zones.isNotEmpty)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _zones.length,
                  itemBuilder: (context, index) {
                    final zone = _zones[index];
                    final bool isSelected = _selectedZoneIndex == index;

                    return GestureDetector(
                      onTap: () => _onZoneSelected(index),
                      child: Container(
                        width: 240,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4313B8) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F3FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: Color(0xFF4313B8),
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    zone['name'] ?? 'Zone',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              zone['code'] ?? 'Zone Code',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Open 24/7",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF16A34A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "Active",
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
