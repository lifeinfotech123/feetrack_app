import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class SubscriptionStatusWidget extends StatelessWidget {
  final bool isActive;
  const SubscriptionStatusWidget({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      decoration: BoxDecoration(
          color: isActive ? blueLight1.withValues(alpha: 0.30) : redLight,
          borderRadius: BorderRadius.circular(999)),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: isActive ? greenDark : red1,
          ),
          sizedBoxWidth(width: 12),
          Text(
            isActive ? "ACTIVE" : "INACTIVE",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? greenDark : red1,
                ),
          ),
        ],
      ),
    );
  }
}
