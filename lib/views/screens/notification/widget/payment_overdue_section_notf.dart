import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

class PaymentOverdueSectionNotif extends StatelessWidget {
  const PaymentOverdueSectionNotif({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: redLight2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error,
                color: redDark,
                size: 56,
              ),
              sizedBoxWidth(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Overdue",
                    style: Helper(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          color: redText,
                        ),
                  ),
                  Text(
                    "Your PG Rent was due 2 days ago.",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: redText.withValues(alpha: 0.90),
                        ),
                  ),
                ],
              )
            ],
          ),
          sizedBoxHeight(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹12,500",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 24,
                      color: redDark,
                    ),
              ),
              CustomButton(
                onTap: () {},
                radius: 999,
                borderColor: redDark,
                color: redDark,
                child: Text(
                  "  Pay Now  ",
                  style: Helper(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        color: white,
                      ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
