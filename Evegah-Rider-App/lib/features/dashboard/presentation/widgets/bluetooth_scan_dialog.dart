import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/services/ble_battery_service.dart';

class BluetoothScanDialog extends StatefulWidget {
  const BluetoothScanDialog({super.key});

  @override
  State<BluetoothScanDialog> createState() => _BluetoothScanDialogState();
}

class _BluetoothScanDialogState extends State<BluetoothScanDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  final BleBatteryService _bleService = BleBatteryService.instance;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start scanning on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bleService.startScan();
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _bleService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: ValueListenableBuilder<BleBatteryState>(
          valueListenable: _bleService.connectionState,
          builder: (context, connState, _) {
            final isScanning = connState == BleBatteryState.scanning;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Scan Batteries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4313B8),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),

                // Error Message banner
                ValueListenableBuilder<String?>(
                  valueListenable: _bleService.errorMessage,
                  builder: (context, errorMsg, _) {
                    if (errorMsg == null) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        errorMsg,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    );
                  },
                ),

                // Radar scanning status
                if (isScanning) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: AnimatedBuilder(
                        animation: _radarController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: RadarRipplePainter(_radarController.value),
                            child: Center(
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4313B8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bluetooth_searching,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Searching for nearby DL batteries...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ] else if (connState == BleBatteryState.connecting) ...[
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator(color: Color(0xFF4313B8))),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Connecting & authenticating...',
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ] else ...[
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _bleService.startScan(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Start Scan', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4313B8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Discovered Devices list
                const Text(
                  'Discovered Devices',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: ValueListenableBuilder<List>(
                    valueListenable: _bleService.scannedDevices,
                    builder: (context, devices, _) {
                      if (devices.isEmpty) {
                        return Center(
                          child: Text(
                            isScanning ? 'No DL batteries found yet.' : 'Scan stopped.',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final result = devices[index];
                          final device = result.device;
                          final name = device.platformName.isNotEmpty ? device.platformName : 'Unknown Device';
                          final id = device.remoteId.str;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              title: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              subtitle: Text(
                                id,
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Colors.grey),
                              ),
                              trailing: Icon(Icons.bluetooth_connected, color: Colors.grey.shade400, size: 16),
                              onTap: () async {
                                await _bleService.stopScan();
                                if (context.mounted) {
                                  // Connect to tapped device
                                  await _bleService.connectToDevice(device);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Action Buttons (Simulation option for testing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showSimulatedDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF65A30D),
                          side: const BorderSide(color: Color(0xFF65A30D)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Simulate Battery', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    if (connState == BleBatteryState.connected) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _bleService.disconnect();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Disconnect', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSimulatedDialog(BuildContext context) {
    int soc = 85;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Simulate Battery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setStateSlider) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Battery SOC: $soc%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Slider(
                    value: soc.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: const Color(0xFF4313B8),
                    onChanged: (val) {
                      setStateSlider(() {
                        soc = val.toInt();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                _bleService.startSimulation(soc.toDouble());
                Navigator.pop(context); // Close slider dialog
                Navigator.pop(context); // Close scanning dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4313B8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Simulated', style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );
  }
}

class RadarRipplePainter extends CustomPainter {
  final double animationValue;
  RadarRipplePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    for (int i = 3; i >= 0; i--) {
      final progress = (animationValue + i / 4.0) % 1.0;
      final radius = maxRadius * progress;
      final opacity = (1.0 - progress) * 0.35;
      final paint = Paint()
        ..color = const Color(0xFF4313B8).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
