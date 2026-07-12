import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:evegah_rider_app/core/services/session_service.dart';

void main() {
  group('SessionService isLoggedIn tests', () {
    test('Returns true for valid token (created just now)', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'valid_token',
        'login_time': DateTime.now().millisecondsSinceEpoch,
      });
      final service = SessionService();
      expect(await service.isLoggedIn(), true);
    });

    test('Returns false for expired token (>7 days old)', () async {
      final oldDate = DateTime.now().subtract(const Duration(days: 8));
      SharedPreferences.setMockInitialValues({
        'access_token': 'expired_token',
        'login_time': oldDate.millisecondsSinceEpoch,
      });
      final service = SessionService();
      expect(await service.isLoggedIn(), false);
    });

    test('Returns false for missing token', () async {
      SharedPreferences.setMockInitialValues({});
      final service = SessionService();
      expect(await service.isLoggedIn(), false);
    });
  });
}
