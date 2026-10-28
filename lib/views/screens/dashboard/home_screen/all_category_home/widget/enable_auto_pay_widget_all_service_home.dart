import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

class EnableAutoPayWidgetAllServiceHome extends StatelessWidget {
  const EnableAutoPayWidgetAllServiceHome({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric( horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt_sharp,
                color: blueLight6,
              ),
              sizedBoxWidth(width: 8),
              Expanded(
                child: Text(
                  "Enable AutoPay",
                  overflow: TextOverflow.clip,
                  style: Helper(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        color: blueLight6,
                      ),
                ),
              ),
            ],
          ),
          sizedBoxHeight(height: 7),
          Text(
            "Automate future school fees and never worry about late penalties again. Secure and hassle free.",
            overflow: TextOverflow.clip,
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: blueLight6.withValues(alpha: 0.90),
                ),
          ),
          sizedBoxHeight(height: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: CustomButton(
              onTap: () {},
              color: white,
              borderColor: white,
              radius: 999,
              child: Text(
                "Setup Auto-Pay",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      color: blueLight3,
                    ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
