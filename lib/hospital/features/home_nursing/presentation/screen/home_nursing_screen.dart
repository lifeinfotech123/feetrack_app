import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';

class HomeNursingScreen extends StatefulWidget {
  const HomeNursingScreen({Key? key}) : super(key: key);

  @override
  State<HomeNursingScreen> createState() => _HomeNursingScreenState();
}

class _HomeNursingScreenState extends State<HomeNursingScreen> {
  String _selectedService = 'Post-Operative Care';
  String _duration = '12 Hours Day Shift';

  final List<Map<String, dynamic>> _nursingServices = [
    {
      'title': 'Post-Operative Care',
      'desc': 'Surgical wound care, vital monitoring, medication & mobility support',
      'rate': '\$50 / shift',
      'icon': Icons.medical_services_outlined,
    },
    {
      'title': 'Elderly & Critical Attendant',
      'desc': 'Feeding assistance, hygiene, companion care & daily activity management',
      'rate': '\$40 / shift',
      'icon': Icons.elderly,
    },
    {
      'title': 'ICU At Home (Trained Nurse)',
      'desc': 'Tracheostomy care, catheter, IV infusion & ventilator monitoring',
      'rate': '\$80 / shift',
      'icon': Icons.healing,
    },
    {
      'title': 'Wound & Dressing Visit',
      'desc': 'Sterile dressing for bedsores, diabetic wounds & suture removal',
      'rate': '\$25 / visit',
      'icon': Icons.clean_hands_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: careIndigo,
        elevation: 0,
        title: const Text('Home Nursing & Attendant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trust Guarantee
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: careIndigoBg, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: careIndigo, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Background-verified, licensed GNM/B.Sc nurses with clinical hospital experience.', style: TextStyle(color: careIndigo, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Choose Nursing Service'),
            ...List.generate(_nursingServices.length, (index) {
              final service = _nursingServices[index];
              final isSelected = _selectedService == service['title'];
              return FadeSlideTransitionWidget(
                index: index,
                child: ModernCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  border: Border.all(color: isSelected ? careIndigo : borderGrey, width: isSelected ? 2 : 1),
                  onTap: () => setState(() => _selectedService = service['title']),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: isSelected ? careIndigoBg : backgroundColor, borderRadius: BorderRadius.circular(12)),
                        child: Icon(service['icon'], color: isSelected ? careIndigo : textMuted, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                            const SizedBox(height: 2),
                            Text(service['desc'], style: const TextStyle(fontSize: 11, color: textMuted)),
                            const SizedBox(height: 4),
                            Text(service['rate'], style: const TextStyle(color: careIndigo, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            const SectionHeader(title: 'Select Shift / Duration'),
            ModernCard(
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: '12 Hours Day Shift',
                    groupValue: _duration,
                    activeColor: careIndigo,
                    title: const Text('12 Hours Day Shift (08:00 AM - 08:00 PM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    onChanged: (val) => setState(() => _duration = val!),
                  ),
                  RadioListTile<String>(
                    value: '12 Hours Night Shift',
                    groupValue: _duration,
                    activeColor: careIndigo,
                    title: const Text('12 Hours Night Shift (08:00 PM - 08:00 AM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    onChanged: (val) => setState(() => _duration = val!),
                  ),
                  RadioListTile<String>(
                    value: '24 Hours Full-Time Resident Nurse',
                    groupValue: _duration,
                    activeColor: careIndigo,
                    title: const Text('24 Hours Full-Time Resident Nurse', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    onChanged: (val) => setState(() => _duration = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: careIndigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: careIndigo,
                      content: Text('Nurse booking request submitted. Care manager will call you within 15 mins.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Confirm Nursing Service', style: TextStyle(color: colorWhite, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
