import 'package:flutter/material.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';
import '../../../home_sample_collection/presentation/screen/home_sample_collection_screen.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';
// import 'package:hospital_management_system/features/home_sample_collection/presentation/screen/home_sample_collection_screen.dart';

class HealthPackagesScreen extends StatelessWidget {
  const HealthPackagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> packages = [
      {
        'title': 'Comprehensive Full Body Health Check',
        'testsCount': '85 Tests included',
        'price': 99,
        'originalPrice': 199,
        'tag': 'BEST VALUE (50% OFF)',
        'color': primaryColor,
        'includes': ['Complete Hemogram (CBC)', 'Full Lipid Profile', 'Liver & Kidney Profile', 'Thyroid (T3/T4/TSH)', 'HbA1c & Fasting Sugar', 'Vitamin D3 & B12', 'ECG & Urine Analysis'],
      },
      {
        'title': 'Advanced Cardiac Health Package',
        'testsCount': '42 Tests + Cardiologist Consult',
        'price': 120,
        'originalPrice': 220,
        'tag': 'HEART CARE',
        'color': emergencyRed,
        'includes': ['Lipid Profile', 'Cardiac Troponin & CRP', '2D Echo / ECG Screening', 'Blood Pressure & Vitals', 'Doctor Video Consultation'],
      },
      {
        'title': 'Senior Citizen Vital Care Package',
        'testsCount': '68 Tests included',
        'price': 89,
        'originalPrice': 160,
        'tag': 'AGE 60+',
        'color': careIndigo,
        'includes': ['Bone Mineral Density / Calcium', 'Full Renal Function (KFT)', 'Prostate / Mammogram screening', 'HbA1c & Fasting Glucose', 'Free Home Sample Pickup'],
      },
      {
        'title': 'Women’s Wellness & Hormone Check',
        'testsCount': '52 Tests included',
        'price': 79,
        'originalPrice': 140,
        'tag': 'FOR WOMEN',
        'color': diagnosticViolet,
        'includes': ['Thyroid Panel', 'Iron Deficiency & Ferritin', 'Pap Smear / Gynec consult voucher', 'Vitamin B12 & D3', 'CBC & ESR'],
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Preventive Health Packages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final pkg = packages[index];
          final Color pkgColor = pkg['color'] as Color;

          return FadeSlideTransitionWidget(
            index: index,
            child: ModernCard(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadgeWidget(label: pkg['tag'], textColor: pkgColor, bgColor: pkgColor.withOpacity(0.12)),
                      Row(
                        children: [
                          Text('\$${pkg['originalPrice']}', style: const TextStyle(fontSize: 13, decoration: TextDecoration.lineThrough, color: textMuted)),
                          const SizedBox(width: 6),
                          Text('\$${pkg['price']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pkgColor)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(pkg['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                  const SizedBox(height: 2),
                  Text(pkg['testsCount'], style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Divider(height: 20),
                  const Text('Key Diagnostic Tests:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark)),
                  const SizedBox(height: 6),
                  ...(pkg['includes'] as List<String>).map((t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: wellnessGreen, size: 14),
                            const SizedBox(width: 6),
                            Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: textDark))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pkgColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeSampleCollectionScreen(
                              selectedTestNames: [pkg['title']],
                              totalPrice: pkg['price'] as int,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bookmark_add_outlined, color: colorWhite, size: 18),
                      label: const Text('Book Package at Home', style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
