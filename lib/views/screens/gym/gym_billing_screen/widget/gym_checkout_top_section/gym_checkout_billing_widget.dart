import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class GYMCheckoutBillingWidget extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? price;
  final bool isNegative;

  const GYMCheckoutBillingWidget({
    super.key,
    this.title,
    this.subTitle,
    this.price,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? "",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: blackText1,
                    ),
              ),
              if (subTitle != null && subTitle!.isNotEmpty) ...[
                sizedBoxHeight(height: 2),
                Text(
                  subTitle ?? "",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: greyText2,
                      ),
                ),
              ],
            ],
          ),
        ),
        Text(
          price ?? "",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isNegative ? Colors.green : blackText1,
              ),
        ),
      ],
    );
  }
}
