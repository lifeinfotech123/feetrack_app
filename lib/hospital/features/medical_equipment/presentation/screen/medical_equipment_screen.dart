import 'package:flutter/material.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';

class MedicalEquipmentScreen extends StatefulWidget {
  const MedicalEquipmentScreen({Key? key}) : super(key: key);

  @override
  State<MedicalEquipmentScreen> createState() => _MedicalEquipmentScreenState();
}

class _MedicalEquipmentScreenState extends State<MedicalEquipmentScreen> {
  String _mode = 'Rent Monthly';

  final List<Map<String, dynamic>> _equipments = [
    {
      'name': 'Oxygen Concentrator (5L / 10L)',
      'rent': '\$45 / month',
      'buy': '\$450 to buy',
      'features': '93% purity, continuous flow, with backup battery',
      'icon': Icons.air,
      'color': primaryColor,
    },
    {
      'name': 'Motorized ICU Hospital Bed (3-Function)',
      'rent': '\$60 / month',
      'buy': '\$650 to buy',
      'features': 'Remote control backrest & height, side rails, anti-bedsore mattress',
      'icon': Icons.single_bed,
      'color': careIndigo,
    },
    {
      'name': 'Foldable Wheelchair (Lightweight)',
      'rent': '\$20 / month',
      'buy': '\$120 to buy',
      'features': 'Comfort cushion, attendant brakes, quick fold',
      'icon': Icons.accessible,
      'color': pharmacyTeal,
    },
    {
      'name': 'Auto BiPAP / CPAP Machine',
      'rent': '\$55 / month',
      'buy': '\$580 to buy',
      'features': 'Heated humidifier, mask included, sleep apnea management',
      'icon': Icons.healing,
      'color': diagnosticViolet,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Home Medical Equipment Rental', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: Row(
              children: ['Rent Monthly', 'Buy Equipment'].map((m) {
                final isSelected = _mode == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mode = m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colorWhite : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        m,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isSelected ? primaryColor : colorWhite,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _equipments.length,
              itemBuilder: (context, index) {
                final eq = _equipments[index];
                final Color color = eq['color'] as Color;

                return FadeSlideTransitionWidget(
                  index: index,
                  child: ModernCard(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                              child: Icon(eq['icon'], color: color, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(eq['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _mode == 'Rent Monthly' ? eq['rent'] : eq['buy'],
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(eq['features'], style: const TextStyle(fontSize: 11, color: textMuted)),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Free Home Delivery & Installation', style: TextStyle(fontSize: 11, color: wellnessGreen, fontWeight: FontWeight.w600)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: color,
                                    content: Text('Request booked for ${eq['name']}! Technician will deliver within 24 hrs.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Text(_mode == 'Rent Monthly' ? 'Rent Now' : 'Buy Now', style: const TextStyle(color: colorWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
