import 'package:flutter/material.dart';
import 'package:vlr/data/models/bill_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

class WalletBillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback onTapPayNow;

  const WalletBillCard({
    super.key,
    required this.bill,
    required this.onTapPayNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.category.toUpperCase(),
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: greyText3,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        bill.billName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: blackText1,
                            ),
                      ),
                    ),
                    Text(
                      bill.dueText,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: red1,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                "₹${bill.amount.toStringAsFixed(0)}",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
              ),
            ],
          ),
          sizedBoxHeight(height: 12),
          CustomButton(
            onTap: onTapPayNow,
            height: 40,
            radius: 12,
            color: primaryColor,
            borderColor: primaryColor,
            child: Center(
              child: Text(
                "Pay Now",
                style: Helper(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
