import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  bool _showAvailableOffers = true;
  String _selectedCategory = "All";
  bool _isLoading = false;

  List<Map<String, dynamic>> _availableOffers = [];
  List<Map<String, dynamic>> _myOffers = [];

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    setState(() {
      _isLoading = true;
    });

    final urls = [
      '${AppConstants.apiBaseUrl}/coupons',
      'http://192.168.1.4:5000/api/coupons',
      'http://localhost:5000/api/coupons',
    ];

    for (final url in urls) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success' && data['data'] != null) {
            final List dbList = data['data'];
            final List<Map<String, dynamic>> mappedList = [];
            for (var c in dbList) {
              if (c['status'] != 'Active') continue;
              final expiryStr = c['end_date'] != null 
                  ? "Valid till ${DateTime.parse(c['end_date'].toString()).toLocal().toString().split(' ')[0]}" 
                  : "No expiry";
              mappedList.add({
                "code": c['code'],
                "title": c['title'] ?? 'Discount Coupon',
                "subtitle": c['description'] ?? 'Save on your next ride',
                "expiry": expiryStr,
                "isBest": c['code'] == 'GET100' || c['code'] == 'WELCOME100',
                "category": "All",
                "type": c['discount_type']?.toString().toLowerCase() == 'percentage' ? 'percent' : 'flat',
                "discount_value": double.tryParse(c['discount_value']?.toString() ?? '0') ?? 0.0,
                "min_order": double.tryParse(c['min_order']?.toString() ?? '0') ?? 0.0,
              });
            }

            setState(() {
              _availableOffers = mappedList;
              _myOffers = mappedList;
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("Error fetching coupons from $url: $e");
      }
    }

    setState(() {
      _isLoading = false;
      // Fallback
      _availableOffers = [
        {
          "code": "GET100",
          "title": "Flat ₹100 OFF on All Rentals",
          "subtitle": "Flat ₹100 off on your booking",
          "expiry": "Valid till 31 Dec 2026",
          "isBest": true,
          "category": "All",
          "type": "flat",
          "discount_value": 100.0,
          "min_order": 300.0,
        },
        {
          "code": "WELCOME50",
          "title": "Flat ₹50 OFF for New Users",
          "subtitle": "Get ₹50 off on your first ride",
          "expiry": "Valid till 31 Dec 2026",
          "isBest": false,
          "category": "All",
          "type": "flat",
          "discount_value": 50.0,
          "min_order": 0.0,
        },
        {
          "code": "RIDER50",
          "title": "Save ₹50 on Next 3 Rides",
          "subtitle": "Save ₹50 off on next rides",
          "expiry": "Valid till 31 Dec 2026",
          "isBest": false,
          "category": "All",
          "type": "flat",
          "discount_value": 50.0,
          "min_order": 150.0,
        }
      ];
      _myOffers = List.from(_availableOffers);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> displayedOffers = _showAvailableOffers ? _availableOffers : _myOffers;

    // Filter by category if selected
    final List<Map<String, dynamic>> filteredOffers = displayedOffers.where((offer) {
      if (_selectedCategory == "All") return true;
      return offer["category"] == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TOP HEADER (Back Button, Logo, Bell, Profile) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 20),
                    ),
                  ),
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
                    "Promotions & Offers",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Save more on every ride",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- 3. CUSTOM SEGMENTED TABS (Available / My Offers) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    // Available Offers Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showAvailableOffers = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _showAvailableOffers ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _showAvailableOffers ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ] : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Available Offers",
                                style: TextStyle(
                                  color: _showAvailableOffers ? const Color(0xFF4313B8) : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _showAvailableOffers ? const Color(0xFF4313B8) : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "${_availableOffers.length}",
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // My Offers Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showAvailableOffers = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_showAvailableOffers ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_showAvailableOffers ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ] : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "My Offers",
                                style: TextStyle(
                                  color: !_showAvailableOffers ? const Color(0xFF4313B8) : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: !_showAvailableOffers ? const Color(0xFF4313B8) : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "${_myOffers.length}",
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- 4. HERO PROMO BANNER ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF5F3FF), Color(0xFFEEF2FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Ride more, save more!",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Unlock exciting offers and exclusive benefits.",
                                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4313B8),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text("View All Deals", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_rounded, size: 10, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Image.asset(
                                "assets/gift_box_refer.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- 5. CATEGORY FILTERSROW ---
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          _buildCategoryChip("All", Icons.grid_view_rounded),
                          _buildCategoryChip("Scooter", Icons.electric_scooter_rounded),
                          _buildCategoryChip("Bike", Icons.electric_bike_rounded),
                          _buildCategoryChip("Car", Icons.directions_car_rounded),
                          _buildCategoryChip("Wallet", Icons.account_balance_wallet_rounded),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- 6. OFFERS LIST ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF4313B8),
                                ),
                              ),
                            )
                          : filteredOffers.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Text("No offers available for this category", style: TextStyle(color: Colors.grey)),
                                )
                              : Column(
                                  children: filteredOffers.map((offer) => _buildOfferCard(offer)).toList(),
                                ),
                    ),

                    // --- 7. HOW TO USE OFFERS HELP ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Color(0xFF4313B8), shape: BoxShape.circle),
                              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "How to use offers?",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Copy the code and apply it while booking your ride.",
                                    style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                "Learn More →",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final bool isSelected = _selectedCategory == label;
    final Color color = isSelected ? const Color(0xFF4313B8) : Colors.grey.shade600;
    final Color borderClr = isSelected ? const Color(0xFF4313B8) : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderClr),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (offer["type"]) {
      case "scooter":
        icon = Icons.electric_scooter_rounded;
        iconColor = const Color(0xFF4313B8);
        iconBg = const Color(0xFFF5F3FF);
        break;
      case "bike":
        icon = Icons.electric_bike_rounded;
        iconColor = const Color(0xFF65A30D);
        iconBg = const Color(0xFFF7FEE7);
        break;
      case "wallet":
        icon = Icons.account_balance_wallet_rounded;
        iconColor = const Color(0xFF1D4ED8);
        iconBg = const Color(0xFFEFF6FF);
        break;
      case "car":
        icon = Icons.directions_car_rounded;
        iconColor = const Color(0xFF854D0E);
        iconBg = const Color(0xFFFEF9C3);
        break;
      default:
        icon = Icons.percent_rounded;
        iconColor = const Color(0xFF16A34A);
        iconBg = const Color(0xFFECFDF5);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer["isBest"] == true) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "BEST OFFER",
                style: TextStyle(color: Color(0xFF4313B8), fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              // Offer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer["title"],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      offer["subtitle"],
                      style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Colors.grey, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          offer["expiry"],
                          style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right Coupon Box & Copy Link
              Column(
                children: [
                  _buildDashedCodeBox(offer["code"]),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, offer);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4313B8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashedCodeBox(String code) {
    return CustomPaint(
      painter: DashedRectPainter(
        color: const Color(0xFFD9F99D), // Yellow-green dashed border
        strokeWidth: 1.5,
        gap: 3.0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FEE7), // Very light yellow-green bg
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          code,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = const Color(0xFFDDD6FE),
    this.strokeWidth = 1.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(6),
      ));

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double length = gap;
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + length),
          paint,
        );
        distance += length * 2;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) => false;
}