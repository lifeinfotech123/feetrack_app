import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class WhyChooseFeetrackWidget extends StatelessWidget {
  final WhyChooseFeetrackModel whyChooseFeetrackModel;

  const WhyChooseFeetrackWidget({
    super.key,
    required this.whyChooseFeetrackModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                whyChooseFeetrackModel.color.withValues(alpha: 0.12),
            child: Icon(
              whyChooseFeetrackModel.icon,
              color: whyChooseFeetrackModel.color,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            whyChooseFeetrackModel.title,
            textAlign: TextAlign.center,
            style: Helper(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: blackText1,
                ),
          ),
        ],
      ),
    );
  }
}

class WhyChooseFeetrackModel {
  final IconData icon;
  final String title;
  final Color color;

  WhyChooseFeetrackModel(
      {required this.icon, required this.title, required this.color});
}

List<WhyChooseFeetrackModel> whyChooseFeetrackModelList = [
  WhyChooseFeetrackModel(
    icon: Icons.security,
    title: "Secure Payments",
    color: primaryText1,
  ),
  WhyChooseFeetrackModel(
    icon: Icons.swap_horiz,
    title: "AutoPay Every Month",
    color: greenDark,
  ),
  WhyChooseFeetrackModel(
      icon: Icons.receipt_long_outlined,
      title: "Digital Receipts",
      color: purpleText1),
  WhyChooseFeetrackModel(
      icon: Icons.notifications_active_outlined,
      title: "Payment Reminders",
      color: redDark),
];
