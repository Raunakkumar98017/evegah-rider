import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'booking_confirmed_screen.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- PDF GENERATION LOGIC ---
  Future<void> _generateAndDownloadInvoice(String vehicle, String rideId, String date, String cost, String distance, String time) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("EVegah Mobility", style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                pw.SizedBox(height: 8),
                pw.Text("Official Ride Invoice", style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
                pw.SizedBox(height: 40),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text("Ride ID:"), pw.Text(rideId, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text("Vehicle:"), pw.Text(vehicle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text("Date:"), pw.Text(date, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text("Distance Covered:"), pw.Text(distance, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text("Total Time:"), pw.Text(time, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))],
                ),
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Total Amount Paid:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text(cost, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Text("Thank you for riding smart and riding green!", style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'EVegah_Invoice_$rideId.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "My Bookings",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4313B8),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4313B8),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Ongoing"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTab(),
          _buildOngoingTab(),
          _buildCompletedTab(),
          _buildCancelledTab(),
        ],
      ),
    );
  }

  // --- UPCOMING TAB ---
  Widget _buildUpcomingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBookingCard(
            status: "UPCOMING",
            statusColor: const Color(0xFFEEF2FF),
            textColor: const Color(0xFF4313B8),
            price: "₹65.50",
            vehicleName: "EVegah Mink",
            bookingId: "EVG12345678",
            dateTime: "15 May 2024, 09:00 AM - 11:00 AM",
            location: "Koramangala Parking 2\nBasavanagudi Main Rd, Bengaluru",
            duration: "2 Hours",
            buttons: [
              _buildOutlinedCardButton("View Details", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingConfirmedScreen(isDepositPaid: false)),
                );
              }),
              const SizedBox(width: 12),
              _buildSolidCardButton("Start Ride", () {}),
            ],
          ),
          const SizedBox(height: 20),
          _buildSupportCard(),
        ],
      ),
    );
  }

  // --- ONGOING TAB ---
  Widget _buildOngoingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBookingCard(
            status: "ONGOING",
            statusColor: const Color(0xFFDCFCE7),
            textColor: const Color(0xFF16A34A),
            price: "₹116.00",
            vehicleName: "EVegah City",
            bookingId: "EVG87654321",
            dateTime: "15 May 2024, 08:00 AM - 02:00 PM",
            location: "Indiranagar 100ft Road\nNear BDA Complex, Bengaluru",
            duration: "6 Hours",
            extraWidget: Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFF4313B8), size: 16),
                  const SizedBox(width: 8),
                  const Text("Time Left ", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const Text("02h 35m", style: TextStyle(color: Color(0xFF4313B8), fontSize: 12, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  const Text("Return Before ", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  const Text("02:00 PM, 15 May 2024", style: TextStyle(color: Color(0xFF1E293B), fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            buttons: [
              _buildOutlinedCardButton("Extend Ride", () {}),
              const SizedBox(width: 12),
              _buildOutlinedCardButton("View Details", () {}),
              const SizedBox(width: 12),
              _buildSolidCardButton("End Ride", () {}),
            ],
          ),
          const SizedBox(height: 20),
          _buildSupportCard(),
        ],
      ),
    );
  }

  // --- COMPLETED TAB ---
  Widget _buildCompletedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBookingCard(
            status: "COMPLETED",
            statusColor: const Color(0xFFF1F5F9),
            textColor: Colors.blueGrey,
            price: "₹87.00",
            vehicleName: "EVegah Fly",
            bookingId: "EVG56473829",
            dateTime: "12 May 2024, 10:00 AM - 12:00 PM",
            location: "HSR Layout Sector 2\n27th Main Rd, Bengaluru",
            duration: "2 Hours",
            buttons: [
              _buildOutlinedCardButton("View Invoice", () {
                _generateAndDownloadInvoice(
                  "EVegah Fly",
                  "EVG56473829",
                  "12 May 2024",
                  "₹87.00",
                  "12.4 km",
                  "2 Hours",
                );
              }, hasIcon: true),
            ],
          ),
          const SizedBox(height: 20),
          _buildSupportCard(),
        ],
      ),
    );
  }

  // --- CANCELLED TAB ---
  Widget _buildCancelledTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBookingCard(
            status: "CANCELLED",
            statusColor: const Color(0xFFFEE2E2),
            textColor: const Color(0xFFEF4444),
            price: "₹58.00",
            vehicleName: "EVegah Pro",
            bookingId: "EVG11223344",
            dateTime: "10 May 2024, 09:00 AM - 10:00 AM",
            location: "Jayanagar 4th Block\n4th T Block, Jayanagar, Bengaluru",
            duration: "2 Hours",
            extraWidget: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 14),
                  SizedBox(width: 8),
                  Text(
                    "Cancelled on 10 May 2024, 08:20 AM",
                    style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            buttons: [
              _buildOutlinedCardButton("View Details", () {}, hasIcon: true),
            ],
          ),
          const SizedBox(height: 20),
          _buildSupportCard(),
        ],
      ),
    );
  }

  // --- RIDE CARD BUILDER ---
  Widget _buildBookingCard({
    required String status,
    required Color statusColor,
    required Color textColor,
    required String price,
    required String vehicleName,
    required String bookingId,
    required String dateTime,
    required String location,
    required String duration,
    Widget? extraWidget,
    required List<Widget> buttons,
  }) {
    return Container(
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
          // Header: Status Badge & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                price,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scooter details row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset("assets/mink.png", fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vehicleName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Self-Drive",
                            style: TextStyle(color: Color(0xFF16A34A), fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: $bookingId",
                      style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    _buildSpecLabel(Icons.calendar_month_outlined, dateTime),
                    const SizedBox(height: 4),
                    _buildSpecLabel(Icons.location_on_outlined, location),
                    const SizedBox(height: 4),
                    _buildSpecLabel(Icons.timer_outlined, "Duration: $duration"),
                  ],
                ),
              ),
            ],
          ),
          ?extraWidget,
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 14),

          // Bottom button row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: buttons,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecLabel(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF4313B8), size: 12),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 10, height: 1.3, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedCardButton(String label, VoidCallback onTap, {bool hasIcon = false}) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4313B8),
          side: const BorderSide(color: Color(0xFFDDD6FE), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 10),
          minimumSize: Size.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            if (hasIcon) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 14, color: Color(0xFF4313B8)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSolidCardButton(String label, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B0B78), // Deep purple
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 10),
          minimumSize: Size.zero,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 12, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // --- MOCK SUPPORT CARD ---
  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic_outlined, color: Color(0xFF16A34A), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Need help with your booking?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF16A34A)),
                ),
                SizedBox(height: 2),
                Text(
                  "We're here 24/7 to assist you.",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF16A34A),
              side: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text("Contact Support", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}