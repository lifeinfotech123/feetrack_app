import 'package:flutter/material.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';

class HealthMembershipScreen extends StatelessWidget {
  const HealthMembershipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> plans = [
      {
        'tier': 'Silver Health Care',
        'price': '\$19 / month',
        'badge': 'ESSENTIAL',
        'color': primaryColor,
        'features': [
          '2 Free Online Doctor Consultations / mo',
          '15% Discount on all Lab Diagnostic tests',
          '10% Flat OFF on Medicine Orders',
          'Free Home Sample Pickup',
        ],
      },
      {
        'tier': 'Gold Family Wellness',
        'price': '\$39 / month',
        'badge': 'MOST POPULAR',
        'color': ambulanceAmber,
        'features': [
          'Unlimited Tele-Consultations for 4 Family Members',
          '1 Free Comprehensive Full-Body Health Checkup / year',
          '25% Discount on Lab Tests & Scans',
          '15% Discount on Medicine Delivery + Free Fast Shipping',
          'Priority Doctor Appointments & Dedicated Care Manager',
        ],
      },
      {
        'tier': 'Platinum Executive VIP',
        'price': '\$79 / month',
        'badge': 'PREMIUM VIP',
        'color': diagnosticViolet,
        'features': [
          'Unlimited 24/7 Super-Specialist Tele & Video Consults',
          '2 Free Executive Health Packages / year',
          'Emergency Ambulance Priority Dispatch with Zero Surcharge',
          'Free Home Nursing & Physiotherapy First Sessions',
          'Dedicated Personal Health Concierge & Dietitian',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Healthcare Membership Plans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          final Color color = plan['color'] as Color;

          return FadeSlideTransitionWidget(
            index: index,
            child: ModernCard(
              margin: const EdgeInsets.only(bottom: 16),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadgeWidget(label: plan['badge'], textColor: color, bgColor: color.withOpacity(0.12)),
                      Text(plan['price'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(plan['tier'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                  const Divider(height: 20),
                  ...(plan['features'] as List<String>).map((f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: color, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(f, style: const TextStyle(fontSize: 12, color: textDark))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: color,
                            content: Text('Subscribed to ${plan['tier']} plan! Membership benefits unlocked.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text('Subscribe to ${plan['tier']}', style: const TextStyle(color: colorWhite, fontWeight: FontWeight.bold, fontSize: 13)),
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
