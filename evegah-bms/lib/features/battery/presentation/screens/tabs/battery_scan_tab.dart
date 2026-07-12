import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../data/models/battery_model.dart';
import '../../providers/battery_provider.dart';
import '../../widgets/battery_details_dialog.dart';

class BatteryScanTab extends ConsumerStatefulWidget {
  final bool isVisible;
  const BatteryScanTab({super.key, required this.isVisible});

  @override
  ConsumerState<BatteryScanTab> createState() => _BatteryScanTabState();
}

class _BatteryScanTabState extends ConsumerState<BatteryScanTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  
  // Tracks connection attempts to prevent spamming and track failures
  final Set<String> _autoConnectingIds = {};

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // Slow sweep (10s)
    );

    if (widget.isVisible) {
      _radarController.repeat();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Clear memory on initial load and start scanning
        _autoConnectingIds.clear();
        ref.read(batteryProvider.notifier).startScan();
      });
    }
  }

  @override
  void didUpdateWidget(covariant BatteryScanTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _radarController.repeat();
        _autoConnectingIds.clear(); // Clear memory when returning to tab
        ref.read(batteryProvider.notifier).startScan();
      } else {
        _radarController.stop();
        ref.read(batteryProvider.notifier).stopScan();
      }
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _showRenameDialog(BuildContext context, BatteryModel battery) {
    final controller = TextEditingController(text: battery.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Rename Battery',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF151833),
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Display Name',
              hintText: 'e.g. BGS001',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8C93A8)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  ref
                      .read(batteryProvider.notifier)
                      .renameBattery(battery.id, newName);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E1C9F),
                minimumSize: const Size(100, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final batteryState = ref.watch(batteryProvider);
    final notifier = ref.read(batteryProvider.notifier);

    // =====================================================================
    // The Auto-Connect Engine
    // =====================================================================
    ref.listen(batteryProvider, (previous, next) {
      if (next.isScanning) {
        for (var scanResult in next.scannedDevices) {
          final device = scanResult.device;
          final id = device.remoteId.str;
          
          final isAlreadyConnected = next.connectedBatteries.any((b) => b.id == id);
          
          if (!isAlreadyConnected && !_autoConnectingIds.contains(id)) {
            // Add to memory so we don't spam requests
            _autoConnectingIds.add(id); 
            
            // Instantly fire connection
            notifier.connectToDevice(device);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Auto-connecting to ${device.platformName.isNotEmpty ? device.platformName : id}...'),
                duration: const Duration(milliseconds: 600),
                backgroundColor: const Color(0xFF2E1C9F),
              ),
            );
          }
        }
      }
    });
    // =====================================================================
    
    // Build display list from scanned devices
    final displayList = batteryState.scannedDevices.map((scanResult) {
      final device = scanResult.device;
      final id = device.remoteId.str;

      final existingIndex = batteryState.connectedBatteries.indexWhere(
        (b) => b.id == id,
      );
      if (existingIndex != -1) {
        return batteryState.connectedBatteries[existingIndex];
      }

      final displayName = device.platformName.isNotEmpty
          ? device.platformName
          : 'Smart Battery (${id.length >= 5 ? id.substring(0, 5) : id})';

      return BatteryModel(
        id: id,
        name: displayName,
        soc: 85, 
        temperature: 25.0,
        voltage: 52.0,
        current: 0.0,
        rssi: scanResult.rssi,
        status: BatteryStatus.disconnected,
        device: device,
      );
    }).toList();

    /*// 1. Dummy Connected Battery (Healthy Green)
    displayList.insert(0, BatteryModel(
      id: 'dummy_1_connected',
      name: 'BGS-TEST-CONN',
      soc: 92, // High battery
      temperature: 24.0,
      voltage: 53.2,
      current: 0.0,
      rssi: -45, // Strong signal
      status: BatteryStatus.connected, // Forces the green badge
      device: null,
    ));

    // 2. Dummy Connecting Battery (Yellow warning SoC, Grey Button)
    // We add its ID to the tracking set so the UI thinks we are actively trying to connect
    _autoConnectingIds.add('dummy_2_connecting'); 
    displayList.insert(1, BatteryModel(
      id: 'dummy_2_connecting',
      name: 'BGS-TEST-SYNC',
      soc: 45, // Medium battery
      temperature: 27.0,
      voltage: 48.1,
      current: 0.0,
      rssi: -72,
      status: BatteryStatus.disconnected,
      device: null,
    ));

    // 3. Dummy Failed/Retry Battery (Red critical SoC, Purple Button)
    displayList.insert(2, BatteryModel(
      id: 'dummy_3_retry',
      name: 'BGS-TEST-FAIL',
      soc: 12, // Critical battery
      temperature: 34.0,
      voltage: 42.5,
      current: 0.0,
      rssi: -90, // Weak signal
      status: BatteryStatus.disconnected,
      device: null,
    ));*/

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            //-HEADER PANEL (Static matching Monitor & Analytics)
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Title Area
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFF00).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bluetooth_searching_rounded, color: Color(0xFF15803D), size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'BMS Scan',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF151833),
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'AUTO CONNECT & FETCH',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8C93A8),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),

                  // 2. Right Area: Dynamic Auto Scan Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: batteryState.isScanning ? const Color(0xFFE2FDF2) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: batteryState.isScanning ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0), 
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Auto Scan',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: batteryState.isScanning ? const Color(0xFF8C93A8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: batteryState.isScanning ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          batteryState.isScanning ? 'Active' : 'Idle',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: batteryState.isScanning ? const Color(0xFF15803D) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── SCROLLABLE BODY ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Radar & Scanner Stats Card
                    _buildScannerCard(
                      displayList.length,
                      screenWidth,
                      notifier,
                      batteryState.isScanning,
                    ),
                    const SizedBox(height: 20),

                    // List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby BMS Devices (${displayList.length})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF151833),
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Last updated: Just now',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF8C93A8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E), shape: BoxShape.circle),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Batteries ListView
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final battery = displayList[index];
                        return _buildBatteryRow(battery);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Actions Footer
            _buildFooterActions(batteryState.isScanning, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerCard(
    int devicesCount,
    double screenWidth,
    BatteryNotifier notifier,
    bool isScanning,
  ) {
    final bool isNarrow = screenWidth < 460;

    final scannerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scanning for batteries...',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF151833),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Auto connecting to nearby devices and fetching live data',
          style: TextStyle(fontSize: 10.5, color: Color(0xFF8C93A8), height: 1.3),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatIndicator(Icons.bluetooth_rounded, 'Bluetooth', 'On', const Color(0xFF3B82F6)),
            _buildStatIndicator(Icons.sensors_rounded, 'Scanning', isScanning ? 'Active' : 'Idle', isScanning ? const Color(0xFF8CE300) : Colors.grey),
            _buildStatIndicator(Icons.sync_rounded, 'Found', '$devicesCount', const Color(0xFF2E1C9F)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Scan Progress',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF151833),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF2E1C9F)),
              onPressed: () {
                // Wipe memory and restart scan
                setState(() {
                  _autoConnectingIds.clear();
                });
                notifier.startScan();
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              tooltip: 'Scan Again',
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _radarController,
          builder: (context, child) {
            final progress = isScanning ? _radarController.value : 0.0;
            return Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2E1C9F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF151833),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );

    final radarWidget = SizedBox(
      width: isNarrow ? 105 : 120,
      height: isNarrow ? 105 : 120,
      child: AnimatedBuilder(
        animation: _radarController,
        builder: (context, child) {
          return CustomPaint(
            painter: RadarSweepPainter(
              _radarController.value * 2 * pi,
              devicesCount,
            ),
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E1C9F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          );
        },
      ),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: isNarrow
          ? Column(
              children: [
                scannerContent,
                const SizedBox(height: 18),
                Center(child: radarWidget),
              ],
            )
          : Row(
              children: [
                Expanded(child: scannerContent),
                const SizedBox(width: 14),
                radarWidget,
              ],
            ),
    );
  }

  Widget _buildStatIndicator(IconData icon, String title, String val, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF8C93A8)),
        ),
        Text(
          val,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF151833)),
        ),
      ],
    );
  }

  Widget _buildBatteryRow(BatteryModel battery) {
    Color fillStatusColor = const Color(0xFF22C55E);
    if (battery.soc < 30) {
      fillStatusColor = const Color(0xFFEF4444);
    } else if (battery.soc < 75) {
      fillStatusColor = const Color(0xFFF59E0B);
    }

    final bool isConnected = battery.status == BatteryStatus.connected;
    final bool isConnecting = _autoConnectingIds.contains(battery.id) && !isConnected;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isConnected
            ? () {
                showDialog(
                  context: context,
                  builder: (context) => BatteryDetailsDialog(battery: battery),
                );
              }
            : null,
        child: Row(
          children: [
            // Battery Graphic (vertical)
            Container(
              width: 28,
              height: 42,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FD),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Positioned(
                    top: 1,
                    child: Container(
                      width: 8,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF94A3B8),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(1), topRight: Radius.circular(1)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    child: Container(
                      width: 14,
                      height: 22 * (battery.soc / 100),
                      decoration: BoxDecoration(
                        color: fillStatusColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Center device info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        battery.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151833)),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _showRenameDialog(context, battery),
                        child: const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF8C93A8)),
                      ),
                      const SizedBox(width: 8),
                      if (isConnected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2FDF2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFDCFCE7), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Connected',
                                style: TextStyle(fontSize: 9, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${battery.voltage.toStringAsFixed(1)}v  •  ${battery.temperature.toInt()}°C  •  RSSI: ${battery.rssi}dBm',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF8C93A8), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            // Right status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${battery.soc.toInt()}%',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151833)),
                ),
                const SizedBox(height: 4),
                if (isConnected)
                  const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF8C93A8))
                else
                  // Smart Retry/Connecting button
                  OutlinedButton(
                    onPressed: isConnecting 
                        ? null // Disabled while trying
                        : () {
                            setState(() {
                              _autoConnectingIds.add(battery.id);
                            });
                            if (battery.device != null) {
                              ref.read(batteryProvider.notifier).connectToDevice(battery.device!);
                            } else {
                              // Fallback simulated connection
                              ref.read(batteryProvider.notifier).addSimulatedBattery(
                                battery.name.replaceAll('BGS', 'BOS'),
                                battery.soc,
                                battery.temperature,
                              );
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      minimumSize: const Size(54, 22),
                      side: BorderSide(color: isConnecting ? const Color(0xFFCBD5E1) : const Color(0xFF2E1C9F)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      isConnecting ? 'Connecting...' : 'Retry',
                      style: TextStyle(
                        fontSize: 9, 
                        fontWeight: FontWeight.bold, 
                        color: isConnecting ? const Color(0xFF94A3B8) : const Color(0xFF2E1C9F),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions(bool isScanning, BatteryNotifier notifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
      ),
      child: isScanning
          ? OutlinedButton.icon(
              onPressed: () => notifier.stopScan(),
              icon: const Icon(Icons.stop_rounded, size: 20, color: Color(0xFFEF4444)),
              label: const Text('Stop Auto-Scan', style: TextStyle(fontSize: 15, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: () {
                // Wipe memory before restarting
                setState(() {
                  _autoConnectingIds.clear();
                });
                notifier.startScan();
              },
              icon: const Icon(Icons.sensors_rounded, size: 20, color: Colors.white),
              label: const Text('Start Auto-Scan', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E1C9F), 
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
    );
  }
}

class RadarSweepPainter extends CustomPainter {
  final double angle;
  final int detectedCount;

  RadarSweepPainter(this.angle, this.detectedCount);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    final Paint paintCircle = Paint()
      ..color = const Color(0xFFCCFF00).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, maxRadius, paintCircle);
    canvas.drawCircle(center, maxRadius * 0.75, paintCircle);
    canvas.drawCircle(center, maxRadius * 0.50, paintCircle);
    canvas.drawCircle(center, maxRadius * 0.25, paintCircle);

    final Paint sweepPaint = Paint()
      ..color = const Color(0xFFCCFF00).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    const sweepAngle = pi / 5;
    final start = angle - sweepAngle / 2;
    final rect = Rect.fromCircle(center: center, radius: maxRadius);
    canvas.drawArc(rect, start, sweepAngle, true, sweepPaint);

    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFCCFF00).withOpacity(0.08),
          const Color(0xFFCCFF00).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.5, glowPaint);

    final pulseValue = 0.5 + 0.5 * sin(angle);
    final dotOpacity = 0.5 + 0.5 * pulseValue;
    final ringOpacity = (0.5 - 0.3 * pulseValue).clamp(0.0, 0.5);
    final ringRadius = 3.0 + 5.0 * pulseValue;

    final Paint paintGreenDot = Paint()..color = const Color(0xFF22C55E).withOpacity(dotOpacity);
    final Paint paintGreenRing = Paint()
      ..color = const Color(0xFF22C55E).withOpacity(ringOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final int dotsToDraw = detectedCount.clamp(0, 12);
    for (int i = 0; i < dotsToDraw; i++) {
      final ringIndex = (i ~/ 4) + 1;
      const itemsOnRing = 4;
      const angleStep = 2 * pi / itemsOnRing;
      final dotAngle = start + (i % itemsOnRing) * angleStep + (ringIndex * 0.25);
      final distanceRatio = 0.22 * ringIndex + 0.12;

      final Offset dotPos = Offset(
        center.dx + maxRadius * distanceRatio * cos(dotAngle),
        center.dy + maxRadius * distanceRatio * sin(dotAngle),
      );

      canvas.drawCircle(dotPos, 3.5, paintGreenDot);
      canvas.drawCircle(dotPos, ringRadius, paintGreenRing);
    }
  }

  @override
  bool shouldRepaint(covariant RadarSweepPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.detectedCount != detectedCount;
  }
}