import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/package_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

class GymPackageWidget extends StatelessWidget {
  final PackageModel? packageModel;
  final Function()? onTap;
  const GymPackageWidget({
    super.key,
    this.packageModel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            width: 1,
            color: greyLight6.withValues(alpha: 0.30),
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              spreadRadius: 0,
              color: black.withValues(alpha: 0.05),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packageModel?.name ?? "",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            color: blackText3,
                          ),
                    ),
                    Text(
                      packageModel?.occupancyType ?? "",
                      style: Helper(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: greyText2,
                          ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                    text: packageModel?.priceFormat,
                    style: Helper(context).textTheme.titleSmall?.copyWith(
                          fontSize: 16,
                          color: blackText3,
                        ),
                    children: [
                      TextSpan(
                        text: " /${packageModel?.type}",
                        style: Helper(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: blackText3,
                            ),
                      )
                    ]),
              ),
            ],
          ),
          sizedBoxHeight(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              packageModel?.features?.length ?? 0,
              (index) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9999),
                    color: greyLight9,
                  ),
                  child: Text(
                    packageModel!.features![index],
                    style: Helper(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 10,
                          color: greyText3,
                        ),
                  ),
                );
              },
            ),
          ),
          sizedBoxHeight(height: 16),
          CustomButton(
            onTap: onTap,
            color: primaryText1,
            borderColor: primaryText1,
            radius: 999,
            child: Text(
              "Select Plan",
              style: Helper(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: white,
                  ),
            ),
          )
        ],
      ),
    );
  }
}
