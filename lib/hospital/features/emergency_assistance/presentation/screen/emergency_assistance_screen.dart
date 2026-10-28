import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../ambulance_booking/presentation/screen/ambulance_booking_screen.dart';
import '../../../blood_bank/presentation/screen/blood_bank_screen.dart';


class EmergencyAssistanceScreen extends StatelessWidget {
  const EmergencyAssistanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> emergencyContacts = [
      {'title': 'National Emergency', 'number': '112 / 108', 'icon': Icons.emergency, 'color': emergencyRed},
      {'title': 'Hospital ICU & Trauma', 'number': '+1 (800) 555-0199', 'icon': Icons.local_hospital, 'color': primaryColor},
      {'title': 'Emergency Blood Bank', 'number': '+1 (800) 555-0144', 'icon': Icons.bloodtype, 'color': emergencyRed},
      {'title': 'Poison Control Center', 'number': '+1 (800) 222-1222', 'icon': Icons.warning_amber_rounded, 'color': ambulanceAmber},
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: emergencyRed,
        elevation: 0,
        title: const Text('Emergency Assistance (SOS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Big SOS Pulse Trigger
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [emergencyRed, Color(0xFFC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: emergencyRed.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  PulseEffectWidget(
                    pulseColor: colorWhite,
                    maxRadius: 1.3,
                    child: AnimatedPressable(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: emergencyRed,
                            content: Text('EMERGENCY SOS SENT! GPS location and alerts broadcasted to emergency team and family.'),
                            duration: Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: colorWhite,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'SOS',
                            style: TextStyle(
                              color: emergencyRed,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TAP SOS TO DISPATCH IMMEDIATE HELP',
                    style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Shares live GPS coordinates with nearest ambulance, ICU team and emergency contacts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions Grid
            Row(
              children: [
                Expanded(
                  child: ModernCard(
                    color: emergencyRedBg,
                    border: Border.all(color: emergencyRed.withOpacity(0.3)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AmbulanceBookingScreen())),
                    child: Column(
                      children: const [
                        Icon(Icons.airport_shuttle, color: emergencyRed, size: 30),
                        SizedBox(height: 6),
                        Text('Book Ambulance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: emergencyRed)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernCard(
                    color: emergencyRedBg,
                    border: Border.all(color: emergencyRed.withOpacity(0.3)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodBankScreen())),
                    child: Column(
                      children: const [
                        Icon(Icons.bloodtype, color: emergencyRed, size: 30),
                        SizedBox(height: 6),
                        Text('Find Blood Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: emergencyRed)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: '24/7 Emergency Helplines'),
            ...emergencyContacts.map((contact) {
              return ModernCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: (contact['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(contact['icon'], color: contact['color'], size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                          const SizedBox(height: 2),
                          Text(contact['number'], style: const TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: wellnessGreen),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${contact['title']} at ${contact['number']}...')),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
