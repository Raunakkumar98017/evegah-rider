import 'package:flutter/material.dart';

class FranchiseInfo {
  final String id;
  final String name;
  final String city;
  final String logoUrl;
  final String supportPhone;
  final List<String> zones;
  final String pricingType; // 'Package' (Vadodara) or 'Hourly' (Daman)

  const FranchiseInfo({
    required this.id,
    required this.name,
    required this.city,
    required this.logoUrl,
    required this.supportPhone,
    required this.zones,
    required this.pricingType,
  });
}

class FranchiseService {
  static final FranchiseService _instance = FranchiseService._internal();
  factory FranchiseService() => _instance;
  FranchiseService._internal();

  // Pre-configured Available Franchises
  final List<FranchiseInfo> availableFranchises = const [
    FranchiseInfo(
      id: 'FRAN_VADODARA',
      name: 'Evegah Vadodara Mobility',
      city: 'Vadodara',
      logoUrl: 'assets/Evegah_login_page_logo.png',
      supportPhone: '+91 98765 43210',
      zones: ['Gotri Zone', 'Alkapuri Zone', 'Fatehgunj Zone', 'Manjalpur Zone'],
      pricingType: 'Package', // Package-based pricing
    ),
    FranchiseInfo(
      id: 'FRAN_DAMAN',
      name: 'Evegah Daman Tourist Rides',
      city: 'Daman',
      logoUrl: 'assets/Evegah_login_page_logo.png',
      supportPhone: '+91 91234 56789',
      zones: ['Nani Daman Zone', 'Moti Daman Zone', 'Devka Beach Zone', 'Jampore Beach Zone'],
      pricingType: 'Hourly', // Hourly-based tourist pricing
    ),
    FranchiseInfo(
      id: 'FRAN_SURAT',
      name: 'Evegah Surat Smart Transit',
      city: 'Surat',
      logoUrl: 'assets/Evegah_login_page_logo.png',
      supportPhone: '+91 99887 76655',
      zones: ['Vesu Zone', 'Adajan Zone', 'Piplod Zone', 'VR Mall Zone'],
      pricingType: 'Package',
    ),
  ];

  // Current Active Franchise (Defaults to Vadodara)
  late FranchiseInfo _activeFranchise;

  FranchiseInfo get activeFranchise => _activeFranchise;

  void init() {
    _activeFranchise = availableFranchises[0];
  }

  void switchFranchise(String franchiseId) {
    final found = availableFranchises.firstWhere(
      (f) => f.id == franchiseId,
      orElse: () => availableFranchises[0],
    );
    _activeFranchise = found;
  }
}
