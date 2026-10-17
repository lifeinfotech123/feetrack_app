import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../payments/presentation/screen/payments_screen.dart';

class BillsInvoicesScreen extends StatelessWidget {
  const BillsInvoicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();

    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: const Text('Bills & Invoices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
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
                  'Please log in with your FeeTrack account to view and download your hospital bills & payment invoices.',
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
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> invoices = [
      {
        'id': 'INV-2026-4401',
        'title': 'Consultation & Neurology Exam',
        'doctor': 'Dr. Mohamed Saeed',
        'date': '14 Sep 2026',
        'amount': '\$45.00',
        'status': 'Paid',
        'method': 'UPI / Apple Pay',
      },
      {
        'id': 'INV-2026-3890',
        'title': 'Pathology Lab Tests (CBC + Lipid)',
        'doctor': 'Central Pathology Lab',
        'date': '12 Sep 2026',
        'amount': '\$60.00',
        'status': 'Paid',
        'method': 'Visa Card ending 4812',
      },
      {
        'id': 'INV-2026-5120',
        'title': 'Pharmacy Home Delivery',
        'doctor': 'City Meds Pharmacy',
        'date': '15 Sep 2026',
        'amount': '\$26.00',
        'status': 'Due',
        'method': 'Pending Payment',
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Bills & Invoices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final inv = invoices[index];
          final isPaid = inv['status'] == 'Paid';

          return FadeSlideTransitionWidget(
            index: index,
            child: ModernCard(
              margin: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(inv['id']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textMuted)),
                      StatusBadgeWidget(
                        label: inv['status']!,
                        textColor: isPaid ? wellnessGreen : emergencyRed,
                        bgColor: isPaid ? wellnessGreenBg : emergencyRedBg,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(inv['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                  const SizedBox(height: 2),
                  Text('${inv['doctor']} • ${inv['date']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Amount', style: TextStyle(fontSize: 10, color: textMuted)),
                          Text(inv['amount']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                        ],
                      ),
                      isPaid
                          ? OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryColor)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(backgroundColor: primaryColor, content: Text('Invoice ${inv['id']} downloaded!')),
                                );
                              },
                              icon: const Icon(Icons.download, size: 14, color: primaryColor),
                              label: const Text('Download Invoice', style: TextStyle(fontSize: 11, color: primaryColor)),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PaymentsScreen(amount: 26.0, billTitle: 'Pharmacy Order #INV-2026-5120'),
                                  ),
                                );
                              },
                              child: const Text('Pay Now', style: TextStyle(fontSize: 12, color: colorWhite, fontWeight: FontWeight.bold)),
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
}
