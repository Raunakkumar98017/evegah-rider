import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import 'payment_screen.dart';
import '../../../offers/presentation/screens/payment_offers_screen.dart';


class VehicleListScreen extends StatefulWidget {
  final String selectedZone;
  final String pickupDateTime;
  final String dropDateTime;
  final Map<String, dynamic>? selectedZoneData;

  const VehicleListScreen({
    super.key,
    this.selectedZone = 'Gotri Zone',
    this.pickupDateTime = 'Select date & time',
    this.dropDateTime = 'Select date & time',
    this.selectedZoneData,
  });

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  String _selectedCategory = "All";
  int _selectedVehicleIndex = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _fetchedVehicles = [];

  final List<String> _categories = [
    "All",
    "🛵 E-Scooter",
    "🚲 E-Bike",
    "🛵 E-Moped",
    "🚲 E-Cycle",
  ];

  final List<Map<String, dynamic>> _vehicles = [];

  Map<String, dynamic>? _zonePricing;

  DateTime? _parseDateTimeString(String dtStr) {
    try {
      if (dtStr.toLowerCase().contains("select")) return null;
      String cleaned = dtStr.replaceAll(RegExp(r'^[A-Za-z]+,\s*'), '').trim();
      final parts = cleaned.split(' ');
      if (parts.length < 3) return null;
      
      int? day = int.tryParse(parts[0]);
      String monthStr = parts[1].toLowerCase();
      int year = DateTime.now().year;
      int yearIdx = 2;
      
      if (parts.length >= 4 && int.tryParse(parts[2]) != null) {
        year = int.parse(parts[2]);
        yearIdx = 3;
      }
      
      int month = 1;
      const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
      for (int i = 0; i < months.length; i++) {
        if (monthStr.startsWith(months[i])) {
          month = i + 1;
          break;
        }
      }
      
      String timePart = parts.sublist(yearIdx).join(' ');
      final timeClean = timePart.replaceAll(RegExp(r'[^0-9:a-zA-Z]'), '').trim();
      final isPm = timeClean.toLowerCase().contains('pm');
      final isAm = timeClean.toLowerCase().contains('am');
      
      final timeNumbers = timeClean.replaceAll(RegExp(r'[a-zA-Z]'), '').split(':');
      int hour = int.tryParse(timeNumbers[0]) ?? 12;
      int minute = timeNumbers.length > 1 ? (int.tryParse(timeNumbers[1]) ?? 0) : 0;
      
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      
      return DateTime(year, month, day ?? 1, hour, minute);
    } catch (e) {
      debugPrint("Error parsing date time: $e");
      return null;
    }
  }

  int getAvailableStock(String modelName, String pickupStr, String dropStr, int totalUnits) {
    if (totalUnits <= 0) return 0;
    
    final pickupDt = _parseDateTimeString(pickupStr);
    final dropDt = _parseDateTimeString(dropStr);
    if (pickupDt == null || dropDt == null) {
      return totalUnits;
    }
    
    final int pickupDay = pickupDt.day + (pickupDt.month * 30);
    final int dropDay = dropDt.day + (dropDt.month * 30);
    final int pickupHour = pickupDt.hour;
    final int dropHour = dropDt.hour;
    
    int hash = (pickupDay * 7 + dropDay * 13 + pickupHour * 3 + dropHour * 17 + modelName.length * 5) % (totalUnits + 1);
    
    int booked = hash.clamp(0, totalUnits);
    final durationDays = dropDt.difference(pickupDt).inDays;
    if (durationDays > 7) {
      booked = (booked + 1).clamp(0, totalUnits);
    }
    
    return totalUnits - booked;
  }

  String getNextAvailableTime(String modelName, String pickupStr, String dropStr) {
    final pickupDt = _parseDateTimeString(pickupStr) ?? DateTime.now();
    final dropDt = _parseDateTimeString(dropStr) ?? DateTime.now().add(const Duration(days: 1));
    
    final int hash = (pickupDt.day * 3 + dropDt.day * 7 + modelName.length * 5) % 3 + 1;
    final nextAvailable = dropDt.add(Duration(days: hash));
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[nextAvailable.month - 1];
    
    final hour = nextAvailable.hour == 0 ? 12 : (nextAvailable.hour > 12 ? nextAvailable.hour - 12 : nextAvailable.hour);
    final ampm = nextAvailable.hour >= 12 ? 'PM' : 'AM';
    final minStr = nextAvailable.minute.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');
    
    return "${nextAvailable.day} $month ${nextAvailable.year} $hourStr:$minStr $ampm";
  }

  String _getFormattedDateRange() {
    final pickupDt = _parseDateTimeString(widget.pickupDateTime);
    final dropDt = _parseDateTimeString(widget.dropDateTime);
    if (pickupDt == null || dropDt == null) {
      return "${widget.pickupDateTime}  →  ${widget.dropDateTime}";
    }
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String formatSingle(DateTime dt) {
      final month = months[dt.month - 1];
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minStr = dt.minute.toString().padLeft(2, '0');
      final hourStr = hour.toString().padLeft(2, '0');
      return "${dt.day} $month $hourStr:$minStr $ampm";
    }
    
    final pStr = formatSingle(pickupDt);
    final dStr = formatSingle(dropDt);
    
    int days = dropDt.difference(pickupDt).inDays;
    if (days <= 0) {
      final hours = dropDt.difference(pickupDt).inHours;
      return "$pStr  →  $dStr  ($hours Hours)";
    }
    return "$pStr  →  $dStr  ($days Days)";
  }

  String _getFormattedDateBottomTitle() {
    final pickupDt = _parseDateTimeString(widget.pickupDateTime);
    final dropDt = _parseDateTimeString(widget.dropDateTime);
    if (pickupDt == null || dropDt == null) {
      return "${widget.pickupDateTime} - ${widget.dropDateTime}";
    }
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final pMonth = months[pickupDt.month - 1];
    final dMonth = months[dropDt.month - 1];
    
    int days = dropDt.difference(pickupDt).inDays;
    if (days <= 0) {
      final hours = dropDt.difference(pickupDt).inHours;
      return "${pickupDt.day} $pMonth – ${dropDt.day} $dMonth ${pickupDt.year} ($hours Hours)";
    }
    return "${pickupDt.day} $pMonth – ${dropDt.day} $dMonth ${pickupDt.year} ($days Days)";
  }

  String _getFormattedDateBottomSubtitle() {
    final pickupDt = _parseDateTimeString(widget.pickupDateTime);
    final dropDt = _parseDateTimeString(widget.dropDateTime);
    if (pickupDt == null || dropDt == null) {
      return "Select date & time";
    }
    String formatTime(DateTime dt) {
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minStr = dt.minute.toString().padLeft(2, '0');
      final hourStr = hour.toString().padLeft(2, '0');
      return "$hourStr:$minStr $ampm";
    }
    return "${formatTime(pickupDt)}  →  ${formatTime(dropDt)}";
  }

  @override
  void initState() {
    super.initState();
    _fetchedVehicles = [];
    _zonePricing = widget.selectedZoneData != null ? widget.selectedZoneData!['pricing'] : null;
    _fetchVehicles();
    _fetchZonePricing();
  }

  Future<void> _fetchVehicles() async {
    setState(() { _isLoading = true; });
    final urls = [
      '${AppConstants.apiBaseUrl}/vehicles?zone=${Uri.encodeComponent(widget.selectedZone)}',
      'http://192.168.1.4:5000/api/vehicles?zone=${Uri.encodeComponent(widget.selectedZone)}',
      'http://localhost:5000/api/vehicles?zone=${Uri.encodeComponent(widget.selectedZone)}',
    ];

    for (final url in urls) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success' && data['data'] != null) {
            final List dbList = data['data'];
            final Map<String, List<dynamic>> grouped = {};
            for (var v in dbList) {
              final String modelName = v['evegah_model_name'] ?? 'Evegah City';
              grouped.putIfAbsent(modelName, () => []).add(v);
            }

            final List<Map<String, dynamic>> mappedList = [];
            grouped.forEach((modelName, list) {
              final first = list.first;
              String img = 'assets/city.png';
              if (modelName.toLowerCase().contains('mink')) img = 'assets/mink.png';
              else if (modelName.toLowerCase().contains('fly')) img = 'assets/kick_scooter_fly.png';

              final int stock = getAvailableStock(modelName, widget.pickupDateTime, widget.dropDateTime, list.length);
              
              mappedList.add({
                "name": modelName,
                "tag": stock > 0 ? "Available ($stock left)" : "Not available till ${getNextAvailableTime(modelName, widget.pickupDateTime, widget.dropDateTime)}",
                "tagColor": stock > 0 ? const Color(0xFFDEF7EC) : const Color(0xFFFDE8E8),
                "tagTextColor": stock > 0 ? const Color(0xFF03543F) : const Color(0xFF9B1C1C),
                "range": "80–100 km",
                "speed": "${first['speed'] ?? 45} km/h",
                "features": ["Fast Charge", "Smart Lock", "Spacious Seat"],
                "dailyPrice": "₹499",
                "hourlyPrice": "Hourly: ₹35 / 30 min",
                "totalPrice": "₹2,495",
                "originalPrice": "₹2,995",
                "discount": "17% OFF",
                "image": img,
                "isPopular": true,
                "popularBadge": "Most Popular",
                "isFavorite": false,
                "category": first['category'] ?? 'E-Scooter',
                "stock": stock,
                "vehicles": list,
              });
            });

            setState(() {
              _fetchedVehicles = mappedList;
              _isLoading = false;
              _updateVehiclePricesAndDeposits();
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("Failed to fetch vehicles from $url: $e");
      }
    }

    setState(() {
      _fetchedVehicles = _vehicles;
      _isLoading = false;
      _updateVehiclePricesAndDeposits();
    });
  }

  Future<void> _fetchZonePricing() async {
    if (widget.selectedZoneData != null && widget.selectedZoneData!['pricing'] != null) {
      setState(() {
        _zonePricing = widget.selectedZoneData!['pricing'];
        _updateVehiclePricesAndDeposits();
      });
      return;
    }
    final urls = [
      '${AppConstants.apiBaseUrl}/zones',
      'http://192.168.1.4:5000/api/zones',
      'http://localhost:5000/api/zones',
    ];
    for (final url in urls) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List zones = (data is List) ? data : (data['data'] ?? []);
          final matchedZone = zones.firstWhere(
            (z) => z['name'].toString().toLowerCase().trim() == widget.selectedZone.toLowerCase().trim(),
            orElse: () => null,
          );
          if (matchedZone != null && matchedZone['pricing'] != null) {
            setState(() {
              _zonePricing = matchedZone['pricing'];
              _updateVehiclePricesAndDeposits();
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("Failed to fetch zone pricing from $url: $e");
      }
    }
  }

  void _updateVehiclePricesAndDeposits() {
    if (_zonePricing == null) return;
    
    final String pricingModel = _zonePricing!['pricingModel'] ?? 'Hourly Based';
    final List hourlyPricing = _zonePricing!['hourlyPricing'] ?? [];
    final List packages = _zonePricing!['packages'] ?? [];

    final pickupDt = _parseDateTimeString(widget.pickupDateTime);
    final dropDt = _parseDateTimeString(widget.dropDateTime);
    int selectedDurationDays = 1;
    if (pickupDt != null && dropDt != null) {
      selectedDurationDays = dropDt.difference(pickupDt).inDays;
      if (selectedDurationDays <= 0) selectedDurationDays = 1;
    }

    String cleanModelName(String name) {
      return name.toLowerCase().replaceAll('evegah', '').replaceAll(' ', '').trim();
    }

    setState(() {
      _fetchedVehicles = _fetchedVehicles.map((v) {
        final String modelName = v['name'] ?? 'Evegah City';
        final cleanVModel = cleanModelName(modelName);
        
        double basePrice = 499.0;
        double deposit = 500.0;
        String hourlyPriceText = "Hourly: ₹35 / 30 min";
        String dailyPriceText = "₹499";
        
        if (pricingModel == 'Hourly Based') {
          final hourlyRow = hourlyPricing.firstWhere(
            (r) => cleanModelName(r['model'].toString()) == cleanVModel,
            orElse: () => null,
          );
          if (hourlyRow != null) {
            basePrice = double.tryParse(hourlyRow['basePrice'].toString()) ?? 70.0;
            deposit = double.tryParse(hourlyRow['deposit']?.toString() ?? '500') ?? 500.0;
            hourlyPriceText = "Extra: ₹${hourlyRow['extraPrice']}/${hourlyRow['roundingRule'] ?? '15m'}";
            dailyPriceText = "₹${(basePrice).toStringAsFixed(0)}/hr";
          }
        } else {
          // Find package matching both model name and selected duration
          final pkgRow = packages.firstWhere(
            (p) => cleanModelName(p['model'].toString()) == cleanVModel &&
                   (int.tryParse(p['duration']?.toString() ?? '1') ?? 1) == selectedDurationDays,
            orElse: () => null,
          ) ?? packages.firstWhere(
            (p) => cleanModelName(p['model'].toString()) == cleanVModel,
            orElse: () => null,
          );

          if (pkgRow != null) {
            final double pkgPrice = double.tryParse(pkgRow['price'].toString()) ?? 899.0;
            final int duration = int.tryParse(pkgRow['duration'].toString()) ?? 3;
            basePrice = duration > 0 ? pkgPrice / duration : pkgPrice;
            deposit = double.tryParse(pkgRow['deposit']?.toString() ?? '500') ?? 500.0;
            hourlyPriceText = "Package: ${pkgRow['name'] ?? '$duration Days'}";
            dailyPriceText = "₹${basePrice.toStringAsFixed(0)}";
          }
        }
        
        return {
          ...v,
          "dailyPrice": dailyPriceText,
          "hourlyPrice": hourlyPriceText,
          "depositAmount": "Deposit: ₹${deposit.toStringAsFixed(0)}",
          "realDeposit": deposit,
          "realPrice": basePrice,
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = _fetchedVehicles.isNotEmpty
        ? _fetchedVehicles[_selectedVehicleIndex < _fetchedVehicles.length ? _selectedVehicleIndex : 0]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFE),
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP HEADER ---
            _buildTopHeader(),
            if (_isLoading)
              const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4313B8)),
                backgroundColor: Color(0xFFF5F3FF),
              ),

            // --- MAIN SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- PICKUP ZONE BANNER CARD ---
                    _buildPickupZoneCard(),
                    const SizedBox(height: 14),

                    if (_fetchedVehicles.isEmpty && !_isLoading) ...[
                      const SizedBox(height: 50),
                      const Center(
                        child: Text(
                          "No operational vehicles assigned to this zone.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ] else ...[
                      // --- CATEGORY FILTER TABS ---
                      _buildCategoryFilterTabs(),
                      const SizedBox(height: 16),

                      // --- VEHICLE CARDS LIST ---
                      ...List.generate(_fetchedVehicles.length, (index) {
                        return _buildVehicleCard(_fetchedVehicles[index], index);
                      }),
                    ],

                    const SizedBox(height: 14),

                    // --- INCLUSIONS STRIP ---
                    _buildInclusionsStrip(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- BOTTOM SUMMARY & ACTION BAR ---
            _buildBottomSummaryBar(selectedVehicle),
          ],
        ),
      ),
    );
  }

  // Header Bar
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF200F54),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Choose Your EV",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Select your preferred vehicle",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Pickup Zone Card
  Widget _buildPickupZoneCard() {
    return Container(
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
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF4313B8),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pickup Zone",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.selectedZone,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                 Text(
                   _getFormattedDateRange(),
                   style: const TextStyle(
                     fontSize: 9,
                     color: Color(0xFF64748B),
                     fontWeight: FontWeight.w500,
                   ),
                 ),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.edit_square, size: 12, color: Color(0xFF4313B8)),
                SizedBox(width: 4),
                Text(
                  "Change",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4313B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Category Filter Tabs
  Widget _buildCategoryFilterTabs() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool isSelected = _selectedCategory == cat;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF200F54) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF200F54)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Vehicle Card Item
  Widget _buildVehicleCard(Map<String, dynamic> v, int index) {
    final bool isSelected = _selectedVehicleIndex == index;
    final int stock = v['stock'] ?? 1;
    final bool isOutOfStock = stock <= 0;

    return Opacity(
      opacity: isOutOfStock ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: isOutOfStock ? null : () {
          setState(() {
            _selectedVehicleIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: isOutOfStock ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected && !isOutOfStock ? const Color(0xFF4313B8) : const Color(0xFFF1F5F9),
              width: isSelected && !isOutOfStock ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Image Box
                Container(
                  width: 110,
                  height: 120,
                  alignment: Alignment.center,
                  child: Image.asset(
                    v["image"],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.electric_scooter,
                      size: 50,
                      color: Color(0xFF4313B8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Vehicle Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            v["name"],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: v["tagColor"],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              v["tag"],
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: v["tagTextColor"],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Specs Row (Range & Speed)
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            v["range"],
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.speed_rounded,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            v["speed"],
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Feature Pills
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: (v["features"] as List<String>).map((f) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              f,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Color(0xFF4313B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Pricing & Select Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: v["dailyPrice"],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (!v["dailyPrice"].toString().contains("/hr"))
                                      const TextSpan(
                                        text: " / day",
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                v["hourlyPrice"],
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              if (v["depositAmount"] != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  v["depositAmount"],
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Column(crossAxisAlignment: CrossAxisAlignment.end),
                          InkWell(
                            onTap: isOutOfStock ? null : () {
                              setState(() {
                                _selectedVehicleIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isOutOfStock ? Colors.grey : const Color(0xFF200F54),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isOutOfStock ? "Sold Out" : "Select",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Floating Most Popular Badge
          if (v["isPopular"])
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFD2FC00), // Lime green
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  v["popularBadge"],
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

          // Heart Favorite Button
          Positioned(
            top: 10,
            right: 12,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  v["isFavorite"] = !(v["isFavorite"] as bool);
                });
              },
              child: Icon(
                v["isFavorite"]
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: v["isFavorite"] ? Colors.red : const Color(0xFF94A3B8),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  // Inclusions Strip
  Widget _buildInclusionsStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _InclusionStripItem(
            Icons.sports_motorsports_outlined,
            "Free Helmet",
            "With Every Booking",
          ),
          _InclusionStripItem(
            Icons.verified_user_outlined,
            "Insurance",
            "Included",
          ),
          _InclusionStripItem(
            Icons.headset_mic_outlined,
            "24/7 Support",
            "We're here for you",
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDiscount ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // Bottom Summary Bar
  Widget _buildBottomSummaryBar(Map<String, dynamic>? v) {
    if (v == null) {
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
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              "No vehicle available",
              style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    final double realPrice = v["realPrice"] ?? 350.0;
    final double realDeposit = v["realDeposit"] ?? 500.0;
    final String pricingModel = _zonePricing?['pricingModel'] ?? 'Package Based';

    final pickupDt = _parseDateTimeString(widget.pickupDateTime);
    final dropDt = _parseDateTimeString(widget.dropDateTime);
    int days = 1;
    int hours = 24;
    if (pickupDt != null && dropDt != null) {
      days = dropDt.difference(pickupDt).inDays;
      if (days <= 0) days = 1;
      hours = dropDt.difference(pickupDt).inHours;
      if (hours <= 0) hours = 1;
    }

    double rentAmount = 0.0;
    if (pricingModel == 'Hourly Based') {
      rentAmount = realPrice * hours;
    } else {
      final List packages = _zonePricing?['packages'] ?? [];
      final String modelName = v['name'] ?? '';
      
      String cleanModelName(String name) {
        return name.toLowerCase().replaceAll('evegah', '').replaceAll(' ', '').trim();
      }
      final cleanVModel = cleanModelName(modelName);

      final pkg = packages.firstWhere(
        (p) => cleanModelName(p['model'].toString()) == cleanVModel &&
               (int.tryParse(p['duration']?.toString() ?? '1') ?? 1) == days,
        orElse: () => null,
      );
      if (pkg != null) {
        rentAmount = double.tryParse(pkg['price'].toString()) ?? (realPrice * days);
      } else {
        rentAmount = realPrice * days;
      }
    }

    double originalAmount = rentAmount / 0.83; // 17% discount representation
    double totalPayable = rentAmount;

    void showPriceDetailsSheet() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Fare Breakdown",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFareRow("Rental Fare (${pricingModel == 'Hourly Based' ? '$hours Hours' : '$days Days'})", "₹${rentAmount.toStringAsFixed(0)}"),
                const SizedBox(height: 12),
                _buildFareRow("Platform Discount (17% OFF)", "-₹${(originalAmount - rentAmount).toStringAsFixed(0)}", isDiscount: true),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      "₹${totalPayable.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4313B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    }

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF4313B8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Duration",
                      style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFormattedDateBottomTitle(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _getFormattedDateBottomSubtitle(),
                      style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: showPriceDetailsSheet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(fontSize: 8, color: Color(0xFF64748B)),
                    ),
                    Row(
                      children: [
                        Text(
                          "₹${totalPayable.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "₹${originalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 9,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "17% OFF",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 16,
                          color: Color(0xFF0F172A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: InkWell(
              onTap: () {
                if (_fetchedVehicles.isEmpty) return;
                final idx = _selectedVehicleIndex < _fetchedVehicles.length ? _selectedVehicleIndex : 0;
                final selectedVehicle = _fetchedVehicles[idx];
                final int stock = selectedVehicle['stock'] ?? 1;
                if (stock <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("This vehicle model is currently out of stock."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentOffersScreen(
                      selectedZone: widget.selectedZone,
                      pickupDateTime: widget.pickupDateTime,
                      dropDateTime: widget.dropDateTime,
                      pickupRaw: widget.selectedZoneData != null ? widget.selectedZoneData!['pickupRaw'] : null,
                      dropRaw: widget.selectedZoneData != null ? widget.selectedZoneData!['dropRaw'] : null,
                      selectedVehicle: {
                        ...selectedVehicle,
                        "realPrice": realPrice,
                        "realDeposit": realDeposit,
                        "rentAmount": rentAmount,
                        "totalPayable": totalPayable,
                      },
                      zonePricing: _zonePricing,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF200F54),
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
        ],
      ),
    );
  }
}

class _InclusionStripItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InclusionStripItem(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF4313B8), size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF200F54),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 8, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }
}
