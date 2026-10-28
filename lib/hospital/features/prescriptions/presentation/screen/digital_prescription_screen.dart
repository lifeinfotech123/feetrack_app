import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';
import '../../../pharmacy/presentation/screens/pharmacy_screen.dart';

class DigitalPrescriptionScreen extends StatelessWidget {
  final String rxId;
  final String doctorName;
  final String specialty;
  final String date;
  final String? patientName;

  const DigitalPrescriptionScreen({
    Key? key,
    this.rxId = 'RX-2026-8941',
    this.doctorName = 'Dr. Mohamed Saeed',
    this.specialty = 'Neurology Specialist',
    this.date = '14 Sep 2026',
    this.patientName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> medicines = [
      {
        'name': 'Amoxicillin 500mg',
        'dosage': '1 Capsule',
        'timing': '3 times daily (After food)',
        'duration': '5 Days',
        'notes': 'Take with full glass of water',
      },
      {
        'name': 'Paracetamol 650mg',
        'dosage': '1 Tablet',
        'timing': 'When needed for fever/pain',
        'duration': '3 Days',
        'notes': 'Minimum 6 hours gap',
      },
      {
        'name': 'Vitamin B-Complex + Zinc',
        'dosage': '1 Capsule',
        'timing': 'Once daily (Morning after breakfast)',
        'duration': '15 Days',
        'notes': 'Nutritional support',
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Digital Prescription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: colorWhite),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prescription link copied to clipboard!'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: colorWhite),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: primaryColor, content: Text('Prescription PDF downloaded successfully!'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Prescription Card (Doctor & Patient Header)
            ModernCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                          Text(specialty, style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w500)),
                          const Text('City Care Hospital • Reg #482910', style: TextStyle(fontSize: 11, color: textMuted)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.qr_code_2, size: 38, color: primaryColor),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Builder(
                    builder: (context) {
                      final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
                      final bool isAuth = authCtrl?.isLoggedIn() ?? false;
                      final String resolvedName = patientName ?? (isAuth ? (authCtrl?.userModel?.name ?? 'Guest') : 'Guest');
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem('Patient', resolvedName),
                          _buildInfoItem('Date', date),
                          _buildInfoItem('Prescription ID', rxId),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: pharmacyTealBg, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: pharmacyTeal, size: 14),
                        SizedBox(width: 6),
                        Text('Digitally Verified & Doctor Signed', style: TextStyle(color: pharmacyTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Medicines Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Prescribed Medications (3)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyScreen()));
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: primaryColor),
                  label: const Text('Order All Online', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                ),
              ],
            ),

            // Medicine List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                return FadeSlideTransitionWidget(
                  index: index,
                  child: ModernCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              med['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark),
                            ),
                            StatusBadgeWidget(
                              label: med['duration']!,
                              textColor: primaryColor,
                              bgColor: fillColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.medication_outlined, size: 16, color: textMuted),
                            const SizedBox(width: 6),
                            Text('Dosage: ${med['dosage']}', style: const TextStyle(fontSize: 12, color: textDark)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: pharmacyTeal),
                            const SizedBox(width: 6),
                            Text(med['timing']!, style: const TextStyle(fontSize: 12, color: pharmacyTeal, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        if (med['notes']!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(6)),
                            child: Text('Note: ${med['notes']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            // Doctor Advice & Follow-up Notice
            ModernCard(
              color: const Color(0xFFFFFDE7),
              border: Border.all(color: const Color(0xFFFFF59D)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Doctor Remarks & General Advice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF57F17))),
                  SizedBox(height: 6),
                  Text('• Drink at least 2.5L water daily.\n• Avoid excessive screen time before bed.\n• Follow-up review scheduled after 7 days.', style: TextStyle(fontSize: 12, color: textDark, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Order Medicine CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pharmacyTeal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyScreen()));
                },
                icon: const Icon(Icons.local_shipping_outlined, color: colorWhite),
                label: const Text('Deliver Medicines to Home', style: TextStyle(color: colorWhite, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark)),
      ],
    );
  }
}
