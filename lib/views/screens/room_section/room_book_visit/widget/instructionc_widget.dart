import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class InstructionWidget extends StatelessWidget {
  const InstructionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: primaryColor.withValues(alpha: 0.20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info,
            color: primaryColor,
          ),
          sizedBoxWidth(width: 16),
          Expanded(
            child: Text(
              "Visiting allows you to verify amenities and room conditions. Please arrive 5 minutes before your scheduled slot.",
              style: Helper(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: primaryText1,
                  ),
            ),
          ),
          sizedBoxHeight(height: 16),
        ],
      ),
    );
  }
}
