import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class PgVisitBookWidget extends StatelessWidget {
  final bool isSelect;
  const PgVisitBookWidget({
    super.key,
    required this.isSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 28, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isSelect ? primaryColor.withValues(alpha: 0.05) : white,
            border: isSelect
                ? Border.all(
                    width: 2,
                    color: blueLight3,
                  )
                : Border.all(
                    width: 1,
                    color: greyLight6,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Double",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      color: blackText3,
                    ),
              ),
              sizedBoxHeight(height: 2),
              Text(
                "10,500/mo",
                style: isSelect
                    ? Helper(context).textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: blueLight3,
                        )
                    : Helper(context).textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: blackText3,
                        ),
              ),
            ],
          ),
        ),
        isSelect
            ? Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: blueLight3,
                  size: 18,
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
