import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class ProfilePendingWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final Color color;
  final bool isActive;
  final bool isAutoPay;
  const ProfilePendingWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.color,
    this.isActive = false,
    this.isAutoPay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
          ),
          sizedBoxHeight(height: 8),
          Text(
            title,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: greyText2,
                ),
          ),
          sizedBoxHeight(height: 10),
          Row(
            children: [
              Text(
                subTitle,
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: isAutoPay ? 18 : 24,
                      color: color,
                    ),
              ),
              sizedBoxWidth(width: 8),
              isAutoPay
                  ? Icon(
                      Icons.circle,
                      size: 10,
                      color: color,
                    )
                  : SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
