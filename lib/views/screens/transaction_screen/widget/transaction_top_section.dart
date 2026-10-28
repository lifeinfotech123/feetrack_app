
import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class TransactionTopRow extends StatelessWidget {
  final int count;
  const TransactionTopRow({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Activity",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: blackText1,
              ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: primaryText1.withValues(alpha: 0.10)),
          child: Text(
            "$count results",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryText1,
                ),
          ),
        ),
      ],
    );
  }
}
