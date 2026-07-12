import 'package:flutter/material.dart';
import '../../../../core/services/franchise_service.dart';

class FranchiseSelectionModal extends StatefulWidget {
  final Function(FranchiseInfo) onFranchiseSelected;

  const FranchiseSelectionModal({super.key, required this.onFranchiseSelected});

  @override
  State<FranchiseSelectionModal> createState() => _FranchiseSelectionModalState();
}

class _FranchiseSelectionModalState extends State<FranchiseSelectionModal> {
  late String _selectedFranchiseId;

  @override
  void initState() {
    super.initState();
    FranchiseService().init();
    _selectedFranchiseId = FranchiseService().activeFranchise.id;
  }

  @override
  Widget build(BuildContext context) {
    final franchises = FranchiseService().availableFranchises;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Select Franchise / City",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Switch franchise to view operating zones & fleet",
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...List.generate(franchises.length, (index) {
            final f = franchises[index];
            final isSelected = f.id == _selectedFranchiseId;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFranchiseId = f.id;
                });
                FranchiseService().switchFranchise(f.id);
                widget.onFranchiseSelected(f);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4313B8) : const Color(0xFFE2E8F0),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF200F54) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_city_rounded,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                f.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: f.pricingType == 'Package' ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  f.pricingType == 'Package' ? 'Package Rates' : 'Hourly Rates',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: f.pricingType == 'Package' ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "📍 City: ${f.city}  •  ${f.zones.length} Zones Available",
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? const Color(0xFF4313B8) : const Color(0xFFCBD5E1),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
