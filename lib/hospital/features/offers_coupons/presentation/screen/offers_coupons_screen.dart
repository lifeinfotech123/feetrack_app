import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';

class OffersCouponsScreen extends StatelessWidget {
  const OffersCouponsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> offers = [
      {
        'code': 'HEALTH50',
        'discount': '50% OFF',
        'title': 'Full Body Health Checkup Discount',
        'desc': 'Get flat 50% discount on comprehensive executive checkups.',
        'validTill': 'Valid till 30 Sep 2026',
        'color': primaryColor,
      },
      {
        'code': 'MEDS20',
        'discount': '20% OFF',
        'title': 'Flat 20% on First Medicine Order',
        'desc': 'Valid on prescription and wellness products above \$30.',
        'validTill': 'Valid till 15 Oct 2026',
        'color': pharmacyTeal,
      },
      {
        'code': 'DOCFREE',
        'discount': '100% OFF',
        'title': 'Free 1st Online Tele-Consultation',
        'desc': 'Consult any general physician or pediatrician for free.',
        'validTill': 'New User Exclusive',
        'color': diagnosticViolet,
      },
      {
        'code': 'LABTEST15',
        'discount': '15% OFF',
        'title': 'Diagnostic Pathology Tests',
        'desc': 'Applicable on CBC, Lipid, Thyroid and Vitamin blood tests.',
        'validTill': 'Valid till 31 Dec 2026',
        'color': offerOrange,
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Exclusive Offers & Coupons', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          final Color color = offer['color'] as Color;

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
                      StatusBadgeWidget(label: offer['discount'], textColor: color, bgColor: color.withOpacity(0.12)),
                      Text(offer['validTill'], style: const TextStyle(fontSize: 11, color: textMuted)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(offer['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                  const SizedBox(height: 2),
                  Text(offer['desc'], style: const TextStyle(fontSize: 12, color: textMuted)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderGrey, style: BorderStyle.solid),
                        ),
                        child: Text(
                          offer['code'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2, color: color),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: offer['code']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: color,
                              content: Text('Coupon code ${offer['code']} copied to clipboard!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Copy Code', style: TextStyle(color: colorWhite, fontSize: 12, fontWeight: FontWeight.bold)),
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
