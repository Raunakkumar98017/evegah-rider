import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evegah_rider_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:evegah_rider_app/features/wallet/presentation/screens/wallet_screen.dart';

void main() {
  testWidgets('DashboardScreen renders without crashing', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print("DASHBOARD CRASH: ${details.exception}");
      print(details.stack);
    };
    
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('WalletScreen renders without crashing', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print("WALLET CRASH: ${details.exception}");
      print(details.stack);
    };
    
    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );
    await tester.pumpAndSettle();
  });
}
