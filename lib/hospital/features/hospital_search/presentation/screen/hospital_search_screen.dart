import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';

class HospitalSearchScreen extends StatefulWidget {
  const HospitalSearchScreen({Key? key}) : super(key: key);

  @override
  State<HospitalSearchScreen> createState() => _HospitalSearchScreenState();
}

class _HospitalSearchScreenState extends State<HospitalSearchScreen> {
  String _search = '';

  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'City Care Multi-Specialty Hospital',
      'location': 'Downtown Medical Enclave, Sector 4',
      'distance': '2.1 km away',
      'beds': '350 Beds • 24/7 ICU',
      'emergency': true,
      'rating': 4.9,
      'nabh': true,
      'specialties': 'Cardiology, Neurology, Orthopedics, Trauma',
    },
    {
      'name': 'Apollo Health Super-Specialty',
      'location': 'Health City Blvd, Ring Road',
      'distance': '4.8 km away',
      'beds': '500 Beds • Organ Transplant Center',
      'emergency': true,
      'rating': 4.8,
      'nabh': true,
      'specialties': 'Oncology, Nephrology, Cardiac Surgery',
    },
    {
      'name': 'St. Jude Memorial Community Clinic',
      'location': 'Parkview Avenue, East Zone',
      'distance': '1.5 km away',
      'beds': '80 Beds • Day Care Surgery',
      'emergency': false,
      'rating': 4.6,
      'nabh': false,
      'specialties': 'Pediatrics, Maternity, General Surgery',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _hospitals.where((h) {
      return h['name'].toString().toLowerCase().contains(_search.toLowerCase()) ||
          h['location'].toString().toLowerCase().contains(_search.toLowerCase()) ||
          h['specialties'].toString().toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text('Find Hospitals & Clinics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
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
            child: TextField(
              onChanged: (val) => setState(() => _search = val),
              decoration: InputDecoration(
                hintText: 'Search hospital name, area, department...',
                hintStyle: const TextStyle(fontSize: 13, color: textMuted),
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: colorWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final h = filtered[index];
                return FadeSlideTransitionWidget(
                  index: index,
                  child: ModernCard(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.local_hospital, color: primaryColor, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                                  const SizedBox(height: 2),
                                  Text(h['location'], style: const TextStyle(fontSize: 11, color: textMuted)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 12, color: primaryColor),
                                      Text(' ${h['distance']}', style: const TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.star, size: 12, color: Colors.amber),
                                      Text(' ${h['rating']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            if (h['emergency'])
                              StatusBadgeWidget(label: '24/7 Emergency', textColor: emergencyRed, bgColor: emergencyRedBg, icon: Icons.bolt),
                            if (h['emergency']) const SizedBox(width: 8),
                            if (h['nabh'])
                              StatusBadgeWidget(label: 'NABH Accredited', textColor: wellnessGreen, bgColor: wellnessGreenBg, icon: Icons.verified),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Depts: ${h['specialties']}', style: const TextStyle(fontSize: 11, color: textDark)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryColor)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Directions to ${h['name']} opened on Maps!')),
                                  );
                                },
                                icon: const Icon(Icons.directions, size: 16, color: primaryColor),
                                label: const Text('Directions', style: TextStyle(color: primaryColor, fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(backgroundColor: primaryColor, content: Text('Connected to ${h['name']} reception!')),
                                  );
                                },
                                icon: const Icon(Icons.call, size: 16, color: colorWhite),
                                label: const Text('Call Hospital', style: TextStyle(color: colorWhite, fontSize: 12)),
                              ),
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
