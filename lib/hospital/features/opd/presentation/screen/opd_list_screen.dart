import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import '../../../../core/constants/colors.dart';

class OpdListScreen extends StatelessWidget {
  const OpdListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();

    if (!isLoggedIn) {
      return Container(
        color: backgroundColor,
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: Colors.amber.shade800,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Browsing as Guest',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please log in with your FeeTrack account to view your past OPD visits and doctor prescriptions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const LoginScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.login_rounded,
                  color: colorWhite, size: 18),
              label: const Text(
                'Log In to FeeTrack',
                style: TextStyle(
                  color: colorWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Sample data structured with your requested fields
    final List<Map<String, String>> opdData = [
      {
        'date': '15 Sep 2026',
        'case': 'Dental',
        'symptoms': 'Bladder leakage & Toothache',
        'amount': '₹250.00',
        'payment': 'Cash',
        'status': 'COMPLETED'
      },
      {
        'date': '12 Sep 2026',
        'case': 'General Medicine',
        'symptoms': 'Fever and severe cough',
        'amount': '₹150.00',
        'payment': 'Online',
        'status': 'COMPLETED'
      },
      {
        'date': '10 Sep 2026',
        'case': 'Orthopedic',
        'symptoms': 'Joint and lower back pain',
        'amount': '₹400.00',
        'payment': 'Card',
        'status': 'COMPLETED'
      },
    ];

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: opdData.length,
        itemBuilder: (context, index) {
          final item = opdData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, color: primaryColor, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            item['case']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          item['status']!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(Icons.calendar_today_outlined, 'Date', item['date']!),
                      ),
                      Expanded(
                        child: _buildInfoColumn(Icons.payments_outlined, 'Payment', item['payment']!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInfoColumn(Icons.healing_outlined, 'Symptoms', item['symptoms']!),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Total Amount: ',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          children: [
                            TextSpan(
                              text: item['amount']!,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility, size: 14, color: Colors.white),
                        label: const Text('Receipt', style: TextStyle(color: Colors.white, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          elevation: 0,
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
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
