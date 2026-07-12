
class AuthService {
  static String get baseUrl => 'mock_url';

  // GENERATED OTP
  String generatedOtp = "1234";

  // ACCESS TOKEN
  String accessToken = "mock_access_token_123456789";

  // CHECK MOBILE NUMBER
  Future<bool> checkMobileNumber(String mobileNumber) async {
    // Fake a 500ms network latency
    await Future.delayed(const Duration(milliseconds: 500));
    accessToken = "mock_access_token_${mobileNumber}_${DateTime.now().millisecondsSinceEpoch}";
    return true;
  }

  // GENERATE OTP
  String generateOtp() {
    generatedOtp = "1234";
    return generatedOtp;
  }

  // SEND OTP USING 2FACTOR
  Future<bool> sendOtp(String mobileNumber) async {
    // Fake latency
    await Future.delayed(const Duration(milliseconds: 500));
    generateOtp();
    return true;
  }

  // VERIFY OTP
  bool verifyOtp(String otp) {
    return otp == "1234" || otp == generatedOtp;
  }
}
