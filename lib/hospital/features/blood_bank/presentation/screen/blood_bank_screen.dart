import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';


class BloodBankScreen extends StatefulWidget {
  const BloodBankScreen({Key? key}) : super(key: key);

  @override
  State<BloodBankScreen> createState() => _BloodBankScreenState();
}

class _BloodBankScreenState extends State<BloodBankScreen> {
  String _selectedGroup = 'O+ve';

  final List<Map<String, dynamic>> _bloodStock = [
    {'group': 'A+ve', 'units': 18, 'status': 'Available'},
    {'group': 'A-ve', 'units': 4, 'status': 'Low Stock'},
    {'group': 'B+ve', 'units': 24, 'status': 'Available'},
    {'group': 'B-ve', 'units': 6, 'status': 'Low Stock'},
    {'group': 'O+ve', 'units': 32, 'status': 'Available (Universal)'},
    {'group': 'O-ve', 'units': 2, 'status': 'Critical Stock'},
    {'group': 'AB+ve', 'units': 12, 'status': 'Available'},
    {'group': 'AB-ve', 'units': 3, 'status': 'Low Stock'},
  ];

  final List<Map<String, dynamic>> _bloodBanks = [
    {
      'name': 'Red Cross Central Blood Bank',
      'location': 'Downtown Sector 3',
      'distance': '1.8 km',
      'contact': '+1 (800) 222-0199',
      'timing': 'Open 24/7',
    },
    {
      'name': 'City Care Hospital Blood Bank',
      'location': 'Ring Road Medical Hub',
      'distance': '2.4 km',
      'contact': '+1 (800) 555-4920',
      'timing': 'Open 24/7',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: emergencyRed,
        elevation: 0,
        title: const Text('Blood Bank & Donor Finder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
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
            // Urgent Request Blood Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: emergencyRedBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: emergencyRed.withOpacity(0.3))),
              child: Row(
                children: [
                  const Icon(Icons.bloodtype, color: emergencyRed, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Need Urgent Blood / Platelets?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: emergencyRed)),
                        SizedBox(height: 2),
                        Text('Direct live link to verified regional blood banks and voluntary donors.', style: TextStyle(fontSize: 11, color: textDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Live Blood Group Availability'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.95,
              ),
              itemCount: _bloodStock.length,
              itemBuilder: (context, index) {
                final item = _bloodStock[index];
                final isSelected = _selectedGroup == item['group'];

                return GestureDetector(
                  onTap: () => setState(() => _selectedGroup = item['group']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? emergencyRed : colorWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? emergencyRed : borderGrey),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['group'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isSelected ? colorWhite : emergencyRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['units']} units',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white70 : textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Partner Blood Centers Near You'),
            ..._bloodBanks.map((bank) {
              return ModernCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: emergencyRedBg, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.local_hospital, color: emergencyRed, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bank['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                          Text('${bank['location']} • ${bank['distance']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                          const SizedBox(height: 2),
                          Text(bank['timing'], style: const TextStyle(fontSize: 11, color: wellnessGreen, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call, color: emergencyRed),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${bank['name']} at ${bank['contact']}...')),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: emergencyRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: emergencyRed,
                      content: Text('Blood unit request for $_selectedGroup broadcasted to donor network!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.send, color: colorWhite),
                label: Text('Request $_selectedGroup Blood Units', style: const TextStyle(color: colorWhite, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
