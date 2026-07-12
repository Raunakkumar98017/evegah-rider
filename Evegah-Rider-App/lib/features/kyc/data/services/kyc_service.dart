class KycService {
  // --- SINGLETON SETUP ---
  static final KycService _instance = KycService._internal();
  factory KycService() {
    return _instance;
  }
  KycService._internal();

  // --- KYC STATE DATA ---
  // Statuses: "Pending", "Captured", "Verified"
  String livePhotoStatus = "Pending";
  String aadhaarFrontStatus = "Pending";
  String aadhaarBackStatus = "Pending";

  // Overall KYC Status: "Pending", "Under Review", "Verified"
  String get kycStatus {
    if (livePhotoStatus == "Verified" && 
        aadhaarFrontStatus == "Verified" && 
        aadhaarBackStatus == "Verified") {
      return "Verified";
    }
    if (livePhotoStatus == "Captured" && 
        aadhaarFrontStatus == "Captured" && 
        aadhaarBackStatus == "Captured") {
      return "Under Review";
    }
    return "Pending";
  }

  // Captured File Paths
  String? livePhotoFile;
  String? aadhaarFrontFile;
  String? aadhaarBackFile;

  // Extracted OCR Details
  String ocrName = "";
  String ocrAadhaarNumber = "";
  String ocrDob = "";
  String ocrGender = "";
  String ocrAddress = "";
  String ocrPinCode = "";

  // Check if a specific step is completed
  bool isStepCompleted(String step) {
    if (step == "Selfie" || step == "Live Photo") {
      return livePhotoStatus == "Captured" || livePhotoStatus == "Verified";
    }
    if (step == "Aadhaar Front") {
      return aadhaarFrontStatus == "Captured" || aadhaarFrontStatus == "Verified";
    }
    if (step == "Aadhaar Back") {
      return aadhaarBackStatus == "Captured" || aadhaarBackStatus == "Verified";
    }
    return false;
  }

  // Reset KYC data for retakes
  void resetKyc() {
    livePhotoStatus = "Pending";
    aadhaarFrontStatus = "Pending";
    aadhaarBackStatus = "Pending";

    livePhotoFile = null;
    aadhaarFrontFile = null;
    aadhaarBackFile = null;

    ocrName = "";
    ocrAadhaarNumber = "";
    ocrDob = "";
    ocrGender = "";
    ocrAddress = "";
    ocrPinCode = "";
  }

  // Update specific step status
  void updateStepStatus(String step, String status, {String? filePath}) {
    if (step == "Selfie" || step == "Live Photo") {
      livePhotoStatus = status;
      if (filePath != null) livePhotoFile = filePath;
    } else if (step == "Aadhaar Front") {
      aadhaarFrontStatus = status;
      if (filePath != null) aadhaarFrontFile = filePath;
    } else if (step == "Aadhaar Back") {
      aadhaarBackStatus = status;
      if (filePath != null) aadhaarBackFile = filePath;
    }
  }

  // Simulates verification (e.g., when approved)
  void simulateVerificationApproval() {
    livePhotoStatus = "Verified";
    aadhaarFrontStatus = "Verified";
    aadhaarBackStatus = "Verified";
  }
}