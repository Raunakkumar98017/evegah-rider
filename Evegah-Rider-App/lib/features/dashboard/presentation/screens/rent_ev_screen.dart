import 'package:flutter/material.dart';
import '../../../../core/widgets/app_sidebar_drawer.dart';
import 'select_location_screen.dart';
import 'select_date_time_screen.dart';
import 'vehicle_list_screen.dart';

class RentEvScreen extends StatefulWidget {
  const RentEvScreen({super.key});

  @override
  State<RentEvScreen> createState() => _RentEvScreenState();
}

class _RentEvScreenState extends State<RentEvScreen> {
  String selectedLocation = "Select pickup zone";
  Map<String, dynamic>? selectedZoneData;
  String pickupDateTime = "Select date & time";
  String dropDateTime = "Select date & time";
  String? pickupRaw;
  String? dropRaw;
  bool returnToSameZone = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebarDrawer(),
      backgroundColor: const Color(0xFFFAFBFE),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- TOP HEADER ---
            _buildTopHeader(),

            // --- MAIN SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- FLEET BANNER IMAGE LINEUP ---
                    _buildFleetLineupBanner(),
                    const SizedBox(height: 16),

                    // --- MAIN BOOKING SEARCH CARD ---
                    _buildBookingSearchCard(),
                    const SizedBox(height: 16),

                    // --- ZONE BASED PRICING BANNER ---
                    _buildZonePricingBanner(),
                    const SizedBox(height: 12),

                    // --- FLEXI PICKUP & DROP BANNER ---
                    _buildFlexiPickupBanner(),
                    const SizedBox(height: 20),

                    // --- WHY CHOOSE EVEGAH SECTION ---
                    _buildWhyChooseEvegahSection(),
                    const SizedBox(height: 20),

                    // --- GO ELECTRIC BOTTOM BANNER ---
                    _buildGoElectricBottomBanner(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header with Menu, Green Slogan & Bell Badge
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Rent Your EV",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF200F54),
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Ride Green, Ride Smart",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF200F54),
              ),
            ),
            SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "⇒  ",
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "Anywhere",
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: " • ",
                    style: TextStyle(
                      color: Color(0xFF200F54),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "Anytime",
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: "  ⇐",
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Horizontal Fleet Lineup Banner Image
  Widget _buildFleetLineupBanner() {
    return Container(
      width: double.infinity,
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Image.asset(
              "assets/city.png",
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.electric_scooter, color: Colors.purple),
            ),
          ),
          Expanded(
            child: Image.asset(
              "assets/mink.png",
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.two_wheeler, color: Colors.teal),
            ),
          ),
          Expanded(
            child: Image.asset(
              "assets/v1.webp",
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.directions_bike, color: Colors.purple),
            ),
          ),
          Expanded(
            child: Image.asset(
              "assets/kick_scooter_fly.png",
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.electric_scooter_outlined,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Search Card (Pickup location, Dates, Checkbox & Search Button)
  Widget _buildBookingSearchCard() {
    final isSearchDisabled = selectedLocation == "Select pickup zone" ||
        pickupDateTime == "Select date & time" ||
        dropDateTime == "Select date & time";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Enter pickup zone or location
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectLocationScreen(
                    currentCity: "Vadodara",
                    onLocationSelected: (zone) {
                      setState(() {
                        if (zone is Map<String, dynamic>) {
                          selectedZoneData = zone;
                          selectedLocation = "${zone['name']}, Vadodara";
                        } else {
                          selectedLocation = "$zone Zone, Vadodara";
                        }
                      });
                    },
                  ),
                ),
              );
              if (result != null) {
                setState(() {
                  if (result is Map<String, dynamic>) {
                    selectedZoneData = result;
                    selectedLocation = "${result['name']}, Vadodara";
                  } else if (result is String) {
                    selectedLocation = result;
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF4313B8),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Enter pickup zone or location",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedLocation,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Color(0xFF4313B8),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Pickup & Drop Date & Time (2 Columns)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final isPackage = selectedZoneData != null
                        ? (selectedZoneData!['pricing'] != null &&
                            selectedZoneData!['pricing']['pricingModel'] == 'Package Based')
                        : (!selectedLocation.toLowerCase().contains("daman") &&
                            !selectedLocation.toLowerCase().contains("aatapi"));
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectDateTimeScreen(
                          initialIsPackageBased: isPackage,
                          pricing: selectedZoneData != null ? selectedZoneData!['pricing'] : null,
                          zoneName: selectedZoneData != null ? selectedZoneData!['name'] : selectedLocation.split(',').first,
                        ),
                      ),
                    );
                    if (result != null && result is Map<String, String>) {
                      setState(() {
                        pickupDateTime =
                            result['pickup'] ?? "Select date & time";
                        dropDateTime = result['drop'] ?? "Select date & time";
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF4313B8),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Pickup Date & Time",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pickupDateTime,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final isPackage = selectedZoneData != null
                        ? (selectedZoneData!['pricing'] != null &&
                            selectedZoneData!['pricing']['pricingModel'] == 'Package Based')
                        : (!selectedLocation.toLowerCase().contains("daman") &&
                            !selectedLocation.toLowerCase().contains("aatapi"));
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectDateTimeScreen(
                          initialIsPackageBased: isPackage,
                          pricing: selectedZoneData != null ? selectedZoneData!['pricing'] : null,
                          zoneName: selectedZoneData != null ? selectedZoneData!['name'] : selectedLocation.split(',').first,
                        ),
                      ),
                    );
                    if (result != null && result is Map) {
                      setState(() {
                        pickupDateTime = result['pickup'] ?? "Select date & time";
                        dropDateTime = result['drop'] ?? "Select date & time";
                        pickupRaw = result['pickupRaw'];
                        dropRaw = result['dropRaw'];
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF4313B8),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Drop Date & Time",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dropDateTime,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. Return to same zone Checkbox
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: returnToSameZone,
                  activeColor: const Color(0xFF4313B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (val) =>
                      setState(() => returnToSameZone = val ?? true),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Return to same zone",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4. Full Width Search Vehicle Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: InkWell(
              onTap: isSearchDisabled
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleListScreen(
                            selectedZone: selectedLocation.split(',').first.trim(),
                            pickupDateTime: pickupDateTime,
                            dropDateTime: dropDateTime,
                            selectedZoneData: {
                              ...?selectedZoneData,
                              'pickupRaw': pickupRaw,
                              'dropRaw': dropRaw,
                            },
                          ),
                        ),
                      );
                    },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: isSearchDisabled ? Colors.grey : const Color(0xFF200F54), // Deep brand purple
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.search_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "SEARCH VEHICLE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Zone Based Pricing Banner
  Widget _buildZonePricingBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBEF), // Light green tint
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delivery_dining_rounded,
              color: Color(0xFF16A34A),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Zone based pricing",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Prices & packages may vary based on vehicle and zone.",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Learn More",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Color(0xFF475569),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Flexi Pickup & Drop Banner
  Widget _buildFlexiPickupBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF), // Light purple tint
        borderRadius: BorderRadius.circular(16),
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
            child: const Icon(
              Icons.wrong_location_rounded,
              color: Color(0xFF4313B8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Flexi Pickup & Drop",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF200F54),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Now pick up and drop off the vehicle from any zone you prefer.",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF475569),
            size: 18,
          ),
        ],
      ),
    );
  }

  // Why Choose Evegah Section (4 Cards Grid)
  Widget _buildWhyChooseEvegahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Why Choose Evegah?",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _FeatureCardItem(
                Icons.eco_outlined,
                "Eco Friendly",
                "Zero Emission\nRide",
                Color(0xFFDCFCE7),
                Color(0xFF16A34A),
              ),
              _FeatureCardItem(
                Icons.security_outlined,
                "Safe & Secure",
                "Smart Lock &\nInsurance",
                Color(0xFFF5F3FF),
                Color(0xFF4313B8),
              ),
              _FeatureCardItem(
                Icons.sell_outlined,
                "Best Prices",
                "Zone Based\nPricing",
                Color(0xFFFFF7ED),
                Color(0xFFEA580C),
              ),
              _FeatureCardItem(
                Icons.headset_mic_outlined,
                "24/7 Support",
                "We're here\nfor you",
                Color(0xFFE0F2FE),
                Color(0xFF0284C7),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bottom Banner
  Widget _buildGoElectricBottomBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Go Electric, Go Smart",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF200F54),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Join the green revolution today!",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            height: 50,
            child: Image.asset(
              "assets/city.png",
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.electric_scooter,
                color: Color(0xFF4313B8),
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;

  const _FeatureCardItem(
    this.icon,
    this.title,
    this.subtitle,
    this.bgColor,
    this.iconColor,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
