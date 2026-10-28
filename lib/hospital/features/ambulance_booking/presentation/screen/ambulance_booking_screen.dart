import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';


class AmbulanceBookingScreen extends StatefulWidget {
  const AmbulanceBookingScreen({Key? key}) : super(key: key);

  @override
  State<AmbulanceBookingScreen> createState() => _AmbulanceBookingScreenState();
}

class _AmbulanceBookingScreenState extends State<AmbulanceBookingScreen> {
  String _ambulanceType = 'Basic Life Support (BLS)';
  bool _isRequested = false;

  final List<Map<String, dynamic>> _types = [
    {
      'title': 'Basic Life Support (BLS)',
      'desc': 'Oxygen cylinder, stretcher, BP monitor & EMT attendant',
      'price': '\$45',
      'icon': Icons.airport_shuttle,
    },
    {
      'title': 'Advanced Cardiac Life Support (ACLS / ICU)',
      'desc': 'Ventilator, Defibrillator, Paramedic Doctor on board',
      'price': '\$95',
      'icon': Icons.emergency,
    },
    {
      'title': 'Patient Transport Vehicle (PTV)',
      'desc': 'Non-emergency transfers, wheelchair equipped',
      'price': '\$30',
      'icon': Icons.accessible_forward,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: emergencyRed,
        elevation: 0,
        title: const Text('Emergency Ambulance Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorWhite)),
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
            // Active SOS Emergency Dispatch status or Dispatcher Card
            if (_isRequested)
              FadeSlideTransitionWidget(
                child: ModernCard(
                  color: emergencyRedBg,
                  border: Border.all(color: emergencyRed),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          PulseEffectWidget(
                            pulseColor: emergencyRed,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: emergencyRed, shape: BoxShape.circle),
                              child: const Icon(Icons.emergency_share, color: colorWhite, size: 26),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Ambulance Dispatched! (Live Tracking)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: emergencyRed)),
                                Text('Driver: David Miller (Vehicle #AMB-708)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                Text('ETA: 6 mins (1.8 km away)', style: TextStyle(fontSize: 11, color: textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: emergencyRed),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Calling Ambulance Driver David (+1 800 200 4455)...')),
                                );
                              },
                              icon: const Icon(Icons.call, color: colorWhite, size: 16),
                              label: const Text('Call Driver', style: TextStyle(color: colorWhite, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: emergencyRed)),
                              onPressed: () => setState(() => _isRequested = false),
                              icon: const Icon(Icons.cancel_outlined, color: emergencyRed, size: 16),
                              label: const Text('Cancel Dispatch', style: TextStyle(color: emergencyRed, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Live Location Card
            ModernCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: emergencyRedBg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.my_location, color: emergencyRed, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Pickup Location (GPS Detected)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark)),
                        Text('Flat 402, Sunshine Heights, Block B (Accurate to 5m)', style: TextStyle(fontSize: 11, color: textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Select Ambulance Fleet Type'),
            ...List.generate(_types.length, (index) {
              final type = _types[index];
              final isSelected = _ambulanceType == type['title'];
              return FadeSlideTransitionWidget(
                index: index,
                child: ModernCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  border: Border.all(color: isSelected ? emergencyRed : borderGrey, width: isSelected ? 2 : 1),
                  onTap: () => setState(() => _ambulanceType = type['title']),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? emergencyRedBg : backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(type['icon'], color: isSelected ? emergencyRed : textMuted, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                            const SizedBox(height: 2),
                            Text(type['desc'], style: const TextStyle(fontSize: 11, color: textMuted)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(type['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Emergency Helpline Quick Strip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: ambulanceAmberBg, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: const [
                  Icon(Icons.phone_in_talk, color: ambulanceAmber),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('24/7 Central Emergency Command: 108 / 112 (Toll-Free)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dispatch Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: emergencyRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () {
                  setState(() => _isRequested = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: emergencyRed,
                      content: Text('Emergency ambulance requested! ETA is 6 minutes.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.bolt, color: colorWhite),
                label: const Text('REQUEST AMBULANCE NOW', style: TextStyle(color: colorWhite, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
