import 'package:flutter/material.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final bool initialIsPackageBased;
  final Map<String, dynamic>? pricing;
  final String? zoneName;
  const SelectDateTimeScreen({
    super.key,
    this.initialIsPackageBased = true,
    this.pricing,
    this.zoneName,
  });

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  late bool isPackageBased;
  bool _isSelectingEnd = false;

  // Real Date Selections
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 4));

  // Package Mode Selections
  String selectedDurationChip = "3 Days";
  int selectedPackageIndex = 0; // 0: 3 Days, 1: 5 Days, 2: 7 Days, 3: 10 Days

  // Time Spinners State
  String pickupHour = "10";
  String pickupMinute = "00";
  String pickupPeriod = "AM";

  String dropHour = "06";
  String dropMinute = "00";
  String dropPeriod = "PM";

  // Hourly Mode Quick Select
  String quickPickupTime = "10:00 AM";
  String quickDropTime = "6:00 PM";

  List<Map<String, dynamic>> packageList = [
    {
      "title": "3 Days",
      "subtitle": "Most Popular",
      "price": "₹899",
      "originalPrice": "₹1,197",
      "perDay": "₹299 / day",
      "savings": "Save ₹298",
      "isPopular": true,
      "isBestValue": false,
      "duration": 3,
    },
    {
      "title": "5 Days",
      "subtitle": "",
      "price": "₹1,399",
      "originalPrice": "₹1,995",
      "perDay": "₹280 / day",
      "savings": "Save ₹596",
      "isPopular": false,
      "isBestValue": false,
      "duration": 5,
    },
    {
      "title": "7 Days",
      "subtitle": "Best Value",
      "price": "₹1,899",
      "originalPrice": "₹2,793",
      "perDay": "₹271 / day",
      "savings": "Save ₹894",
      "isPopular": false,
      "isBestValue": true,
      "duration": 7,
    },
    {
      "title": "10 Days",
      "subtitle": "",
      "price": "₹2,499",
      "originalPrice": "₹3,990",
      "perDay": "₹249 / day",
      "savings": "Save ₹1,491",
      "isPopular": false,
      "isBestValue": false,
      "duration": 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    isPackageBased = widget.initialIsPackageBased;
    if (widget.pricing != null && widget.pricing!['pricingModel'] != null) {
      isPackageBased = widget.pricing!['pricingModel'] == 'Package Based';
    }
    _initializeDynamicPackages();
  }

  void _initializeDynamicPackages() {
    if (widget.pricing != null && widget.pricing!['packages'] != null) {
      final List rawPkgs = widget.pricing!['packages'];
      if (rawPkgs.isNotEmpty) {
        packageList = [];
        final Set<String> seenNames = {};
        for (var pkg in rawPkgs) {
          final name = pkg['name'] ?? '${pkg['duration']} Days';
          final titleKey = name.toString().toLowerCase().trim();
          if (seenNames.contains(titleKey)) {
            continue; // Skip duplicate packages
          }
          seenNames.add(titleKey);

          final durationDays = pkg['duration'] != null ? pkg['duration'].toString() : '3';
          final price = pkg['price'] != null ? pkg['price'].toString() : '0';
          final double priceVal = double.tryParse(price) ?? 0.0;
          final double dailyRate = double.parse(durationDays) > 0 ? priceVal / double.parse(durationDays) : priceVal;
          final double originalVal = priceVal * 1.3;
          
          packageList.add({
            "title": name,
            "subtitle": pkg['model'] ?? "",
            "price": "₹${priceVal.toStringAsFixed(0)}",
            "originalPrice": "₹${originalVal.toStringAsFixed(0)}",
            "perDay": "₹${dailyRate.toStringAsFixed(0)} / day",
            "savings": "Save ₹${(originalVal - priceVal).toStringAsFixed(0)}",
            "isPopular": false,
            "isBestValue": false,
            "duration": int.tryParse(durationDays) ?? 3,
          });
        }
        if (packageList.isNotEmpty) {
          selectedDurationChip = packageList[0]['title'];
          selectedPackageIndex = 0;
          final int duration = packageList[0]['duration'] ?? 3;
          _endDate = _startDate.add(Duration(days: duration));
        }
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
            // --- TOP HEADER ---
            _buildHeader(),

            // --- MAIN SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- PICKUP ZONE BANNER CARD ---
                    _buildPickupZoneCard(),
                    const SizedBox(height: 14),

                    // RENDER MODE SPECIFIC UI
                    if (isPackageBased) ...[
                      // --- PACKAGE MODE PROMO BAR ---
                      _buildPackagePromoBar(),
                      const SizedBox(height: 16),

                      // --- 1. SELECT PACKAGE DURATION CHIPS ---
                      _buildSectionTitle("1. Select Package Duration"),
                      const SizedBox(height: 10),
                      _buildDurationChips(),
                      const SizedBox(height: 16),

                      // --- CALENDAR VIEW ---
                      _buildCalendarCard(),
                      const SizedBox(height: 16),

                      // --- INCLUSIONS BAR ---
                      _buildInclusionsBar(),
                      const SizedBox(height: 16),

                      // --- 2. SELECT PICKUP & DROP TIMES ---
                      _buildSectionTitle("2. Select Pickup & Drop Times"),
                      const SizedBox(height: 10),
                      _buildPickupDropTimePickers(),
                      const SizedBox(height: 16),

                      // --- SELECTION SUMMARY CARD ---
                      _buildPackageSelectionSummary(),
                    ] else ...[
                      // --- HOURLY MODE: 1. SELECT RENTAL DATES ---
                      _buildSectionTitle("1. Select Rental Dates"),
                      const SizedBox(height: 10),
                      _buildCalendarCard(),
                      const SizedBox(height: 16),

                      // --- HOURLY MODE: 2. SELECT PICKUP & DROP TIMES ---
                      _buildSectionTitle("2. Select Pickup & Drop Times"),
                      const SizedBox(height: 10),
                      _buildPickupDropTimePickersWithQuickSelect(),
                      const SizedBox(height: 14),

                      // --- HOURLY MODE: MODIFY DURATION BANNER ---
                      _buildModifyDurationBanner(),
                      const SizedBox(height: 16),

                      // --- HOURLY MODE: YOUR SELECTION BREAKDOWN ---
                      _buildHourlySelectionBreakdown(),
                    ],

                    const SizedBox(height: 24),
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

  // Header Bar
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back Button
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
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPackageBased ? "Select Package & Dates" : "Select Dates & Times",
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPackageBased
                      ? "This zone offers package based rentals"
                      : "Choose your pickup & drop details",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // Pickup Zone Banner Card
  Widget _buildPickupZoneCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Purple Pin Icon Circle
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF4313B8),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isPackageBased ? "Pickup Zone " : "Pickup Zone",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isPackageBased)
                      const Text(
                        "(Package Based)",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF16A34A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.zoneName ?? "Nani Daman, Daman",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isPackageBased) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Package Available",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text("|", style: TextStyle(color: Colors.black26, fontSize: 10)),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        "Nearest to you: Gotri, Vadodara",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4313B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Change Button
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
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
          ),
        ],
      ),
    );
  }

  // Package Mode Promo Bar
  Widget _buildPackagePromoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBEF), // Light lime tint
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6F4D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Color(0xFF8CE600),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Save more with our package plans!",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  "Enjoy better prices for longer rides.",
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
            Icons.info_outline_rounded,
            color: Color(0xFF94A3B8),
            size: 16,
          ),
        ],
      ),
    );
  }

  // Section Header Helper
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
    );
  }

  // Package Duration Chips Selector
  Widget _buildDurationChips() {
    final List<String> chips = packageList.map((p) => p['title'] as String).toList();
    if (!chips.contains("Custom")) {
      chips.add("Custom");
    }
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        itemBuilder: (context, index) {
          final chip = chips[index];
          final bool isSelected = selectedDurationChip == chip;
          final bool isMostPopular = index == 0;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDurationChip = chip;
                if (chip == "Custom") {
                  _isSelectingEnd = true;
                } else {
                  final pkgIdx = packageList.indexWhere((p) => p['title'] == chip);
                  if (pkgIdx != -1) {
                    selectedPackageIndex = pkgIdx;
                    final duration = packageList[pkgIdx]['duration'] ?? 3;
                    _endDate = _startDate.add(Duration(days: duration));
                  }
                }
              });
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4313B8) : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chip,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? const Color(0xFF4313B8) : const Color(0xFF475569),
                        ),
                      ),
                      if (chip == "Custom") ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.calendar_month_outlined, size: 14, color: Color(0xFF4313B8)),
                      ],
                    ],
                  ),
                ),
                // Floating Most Popular Badge
                if (isMostPopular)
                  Positioned(
                    top: 0,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Most Popular",
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(DateTime date) {
    final months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  String _formatDateShort(DateTime date) {
    final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day} ${months[date.month - 1]} ${date.year} (${weekdays[date.weekday - 1]})";
  }

  // Calendar View & Selected Range Box
  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          // Month Selector Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: (() {
                    final today = DateTime.now();
                    final firstDayOfCurrentMonth = DateTime(today.year, today.month, 1);
                    final firstDayOfPrevMonth = DateTime(_startDate.year, _startDate.month - 1, 1);
                    return firstDayOfPrevMonth.isBefore(firstDayOfCurrentMonth) ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
                  })(),
                ),
                onPressed: () {
                  final today = DateTime.now();
                  final firstDayOfCurrentMonth = DateTime(today.year, today.month, 1);
                  final firstDayOfPrevMonth = DateTime(_startDate.year, _startDate.month - 1, 1);
                  if (firstDayOfPrevMonth.isBefore(firstDayOfCurrentMonth)) {
                    return;
                  }
                  setState(() {
                    _startDate = DateTime(_startDate.year, _startDate.month - 1, _startDate.day);
                    if (isPackageBased) {
                      _endDate = _startDate.add(const Duration(days: 3));
                    }
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getMonthName(_startDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                onPressed: () {
                  setState(() {
                    _startDate = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
                    if (isPackageBased) {
                      _endDate = _startDate.add(const Duration(days: 3));
                    }
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Days of Week Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _CalendarHeaderDay("Sun"),
              _CalendarHeaderDay("Mon"),
              _CalendarHeaderDay("Tue"),
              _CalendarHeaderDay("Wed"),
              _CalendarHeaderDay("Thu"),
              _CalendarHeaderDay("Fri"),
              _CalendarHeaderDay("Sat"),
            ],
          ),
          const SizedBox(height: 8),

          // Calendar Grid (Dynamically calculated)
          _buildCalendarGrid(),
          const SizedBox(height: 14),

          // Selected Duration Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_calendar_rounded,
                    color: Color(0xFF4313B8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPackageBased ? "Selected Duration" : "Selected Range",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDateShort(_startDate),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF4313B8)),
                          ),
                          Expanded(
                            child: Text(
                              _formatDateShort(_endDate),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: Text(
                    "${_endDate.difference(_startDate).inDays} Days",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4313B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_startDate.year, _startDate.month, 1);
    final lastDayOfMonth = DateTime(_startDate.year, _startDate.month + 1, 0);
    
    int firstWeekday = firstDayOfMonth.weekday % 7;
    final List<DateTime> calendarDays = [];
    
    final prevMonthLastDay = DateTime(_startDate.year, _startDate.month, 0);
    for (int i = firstWeekday - 1; i >= 0; i--) {
      calendarDays.add(DateTime(prevMonthLastDay.year, prevMonthLastDay.month, prevMonthLastDay.day - i));
    }
    
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      calendarDays.add(DateTime(_startDate.year, _startDate.month, i));
    }
    
    int remainingCells = 35 - calendarDays.length;
    if (remainingCells < 0) {
      remainingCells = 42 - calendarDays.length;
    }
    for (int i = 1; i <= remainingCells; i++) {
      calendarDays.add(DateTime(_startDate.year, _startDate.month + 1, i));
    }
    
    final List<List<DateTime>> weeks = [];
    for (int i = 0; i < calendarDays.length; i += 7) {
      weeks.add(calendarDays.sublist(i, i + 7));
    }
    
    return Column(
      children: weeks.map((week) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.map((date) {
              final bool isCurrentMonth = date.month == _startDate.month;
              final bool isStart = DateUtils.isSameDay(date, _startDate);
              final bool isEnd = DateUtils.isSameDay(date, _endDate);
              final bool inRange = date.isAfter(_startDate) && date.isBefore(_endDate);

              final today = DateTime.now();
              final todayDateOnly = DateTime(today.year, today.month, today.day);
              final bool isPast = date.isBefore(todayDateOnly);

              Color txtColor = const Color(0xFF0F172A);
              if (!isCurrentMonth) txtColor = const Color(0xFFCBD5E1);
              if (isPast) {
                txtColor = const Color(0xFFE2E8F0);
              } else if (isStart || isEnd) {
                txtColor = Colors.white;
              } else if (inRange) {
                txtColor = const Color(0xFF4313B8);
              }

              BoxDecoration? dec;
              if (!isPast) {
                if (isStart || isEnd) {
                  dec = const BoxDecoration(
                    color: Color(0xFF4313B8),
                    shape: BoxShape.circle,
                  );
                } else if (inRange) {
                  dec = const BoxDecoration(
                    color: Color(0xFFF5F3FF),
                    shape: BoxShape.rectangle,
                  );
                }
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isPast) return; // Block past dates
                    if (isCurrentMonth) {
                      setState(() {
                        if (isPackageBased && selectedDurationChip != "Custom") {
                          _startDate = date;
                          int duration = 3;
                          final index = packageList.indexWhere((p) => p['title'] == selectedDurationChip);
                          if (index != -1) {
                            duration = packageList[index]['duration'] ?? 3;
                          }
                          _endDate = _startDate.add(Duration(days: duration));
                        } else {
                          // Hourly based allocation OR Custom duration: support custom start/end selection
                          if (!_isSelectingEnd) {
                            // Start of a brand new selection: set start date, clear/set end date to start
                            _startDate = date;
                            _endDate = date;
                            _isSelectingEnd = true;
                          } else {
                            // We already have a start date and are selecting the end date
                            if (date.isBefore(_startDate)) {
                              // Clicked date is before start date: make it the new start date
                              _startDate = date;
                              _endDate = date;
                              _isSelectingEnd = true;
                            } else if (DateUtils.isSameDay(date, _startDate)) {
                              // Clicked the same date again: set end date to start date (1-day selection)
                              _endDate = _startDate;
                              _isSelectingEnd = false;
                            } else {
                              // Clicked date is after start date: set it as the end date
                              _endDate = date;
                              _isSelectingEnd = false;
                            }
                          }
                        }
                      });
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: dec,
                        alignment: Alignment.center,
                        child: Text(
                          "${date.day}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: (isStart || isEnd || inRange) ? FontWeight.bold : FontWeight.w500,
                            color: txtColor,
                          ),
                        ),
                      ),
                      if (isStart)
                        const Text("Start", style: TextStyle(fontSize: 8, color: Color(0xFF4313B8), fontWeight: FontWeight.bold))
                      else if (isEnd)
                        const Text("End", style: TextStyle(fontSize: 8, color: Color(0xFF4313B8), fontWeight: FontWeight.bold))
                      else
                        const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // Package Cards Horizontal View


  // Inclusions Bar
  Widget _buildInclusionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF4313B8), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "All packages include",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4313B8),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _InclusionItem(Icons.bolt_rounded, "Unlimited KM"),
                    _InclusionItem(Icons.security_rounded, "Insurance"),
                    _InclusionItem(Icons.access_time_rounded, "24/7 Support"),
                    _InclusionItem(Icons.car_repair_rounded, "Roadside Assistance"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pickup & Drop Time Pickers
  Widget _buildPickupDropTimePickers() {
    return Row(
      children: [
        // Pickup Box
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF8CE600)),
                    SizedBox(width: 6),
                    Text(
                      "Pickup Date & Time",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(_formatDateShort(_startDate), style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                const SizedBox(height: 10),

                // Time Spinner
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeColumn(pickupHour, List.generate(12, (i) => (i + 1).toString().padLeft(2, '0')), (val) => setState(() => pickupHour = val)),
                      const Text(" : ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      _buildTimeColumn(pickupMinute, List.generate(12, (i) => (i * 5).toString().padLeft(2, '0')), (val) => setState(() => pickupMinute = val)),
                      const SizedBox(width: 4),
                      _buildPeriodDropdown(pickupPeriod, (val) => setState(() => pickupPeriod = val!)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Drop Box
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF8CE600)),
                    SizedBox(width: 6),
                    Text(
                      "Drop Date & Time",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(_formatDateShort(_endDate), style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                const SizedBox(height: 10),

                // Time Spinner
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeColumn(dropHour, List.generate(12, (i) => (i + 1).toString().padLeft(2, '0')), (val) => setState(() => dropHour = val)),
                      const Text(" : ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      _buildTimeColumn(dropMinute, List.generate(12, (i) => (i * 5).toString().padLeft(2, '0')), (val) => setState(() => dropMinute = val)),
                      const SizedBox(width: 4),
                      _buildPeriodDropdown(dropPeriod, (val) => setState(() => dropPeriod = val!)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Hourly Mode Time Pickers with Quick Select Chips
  Widget _buildPickupDropTimePickersWithQuickSelect() {
    return Column(
      children: [
        _buildPickupDropTimePickers(),
        const SizedBox(height: 8),

        // Quick Select Row
        Row(
          children: [
            // Pickup Quick Select
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 10, color: Color(0xFF4313B8)),
                    const SizedBox(width: 2),
                    const Text("Quick Select ", style: TextStyle(fontSize: 8, color: Color(0xFF64748B))),
                    _buildQuickChip("9:00 AM", quickPickupTime == "9:00 AM", () => setState(() => quickPickupTime = "9:00 AM")),
                    _buildQuickChip("10:00 AM", quickPickupTime == "10:00 AM", () => setState(() => quickPickupTime = "10:00 AM")),
                    _buildQuickChip("11:00 AM", quickPickupTime == "11:00 AM", () => setState(() => quickPickupTime = "11:00 AM")),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Drop Quick Select
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 10, color: Color(0xFF4313B8)),
                    const SizedBox(width: 2),
                    const Text("Quick Select ", style: TextStyle(fontSize: 8, color: Color(0xFF64748B))),
                    _buildQuickChip("5:00 PM", quickDropTime == "5:00 PM", () => setState(() => quickDropTime = "5:00 PM")),
                    _buildQuickChip("6:00 PM", quickDropTime == "6:00 PM", () => setState(() => quickDropTime = "6:00 PM")),
                    _buildQuickChip("7:00 PM", quickDropTime == "7:00 PM", () => setState(() => quickDropTime = "7:00 PM")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF200F54) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // Time Spinner Helper Column
  Widget _buildTimeColumn(String value, List<String> items, Function(String) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF200F54)),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF200F54)),
          onChanged: (val) {
            if (val != null) onChange(val);
          },
          items: items.map((e) {
            return DropdownMenuItem(value: e, child: Text(e));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown(String value, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF4313B8)),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
          onChanged: onChange,
          items: ["AM", "PM"].map((e) {
            return DropdownMenuItem(value: e, child: Text(e));
          }).toList(),
        ),
      ),
    );
  }

  // Package Mode Selection Summary
  Widget _buildPackageSelectionSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBEF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6F4D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_calendar_rounded, color: Color(0xFF8CE600), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Your Selection",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                SizedBox(height: 2),
                Text(
                  "3 Days Package",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(
                  "21 May 10:00 AM → 25 May 06:00 PM",
                  style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF200F54)),
        ],
      ),
    );
  }

  // Hourly Mode Modify Duration Banner
  Widget _buildModifyDurationBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit_calendar_rounded, color: Color(0xFF4313B8), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Need it for a different duration?",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(
                  "You can modify the time while booking.",
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "View Pricing",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
              ),
              Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF4313B8)),
            ],
          ),
        ],
      ),
    );
  }

  // Hourly Mode Selection Breakdown Card
  Widget _buildHourlySelectionBreakdown() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Selection",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          _buildSelectionRow(
            icon: Icons.calendar_today_rounded,
            label: "Rental Duration",
            value: "${_formatDateShort(_startDate)}  →  ${_formatDateShort(_endDate)}",
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          _buildSelectionRow(
            icon: Icons.access_time_rounded,
            label: "Pickup Time",
            value: "$pickupHour:$pickupMinute $pickupPeriod, ${_formatDateShort(_startDate)}",
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          _buildSelectionRow(
            icon: Icons.access_time_rounded,
            label: "Drop Time",
            value: "$dropHour:$dropMinute $dropPeriod, ${_formatDateShort(_endDate)}",
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF4313B8), size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.edit_square, size: 10, color: Color(0xFF4313B8)),
              SizedBox(width: 2),
              Text(
                "Change",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4313B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bottom Continue Button
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
            final monthName = _getMonthName(_startDate).split(' ')[0].substring(0, 3);
            final endMonthName = _getMonthName(_endDate).split(' ')[0].substring(0, 3);
            final pickupStr = "${_startDate.day} $monthName ${_startDate.year} $pickupHour:$pickupMinute $pickupPeriod";
            final dropStr = "${_endDate.day} $endMonthName ${_endDate.year} $dropHour:$dropMinute $dropPeriod";
            Navigator.pop(context, {
              "pickup": pickupStr,
              "drop": dropStr,
              "pickupRaw": _startDate.toIso8601String(),
              "dropRaw": _endDate.toIso8601String(),
            });
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

class _CalendarHeaderDay extends StatelessWidget {
  final String label;
  const _CalendarHeaderDay(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _InclusionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InclusionItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: const Color(0xFF4313B8)),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFF4313B8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
