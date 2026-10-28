
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';

class GymVisitSuccessGymProfile extends StatelessWidget {
  const GymVisitSuccessGymProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            width: 1,
            color: greyText2.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 25),
              blurRadius: 50,
              spreadRadius: -12,
              color: primaryText1.withValues(alpha: 0.08),
            )
          ]),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              const CustomImage(
                path: Assets.imagesGymBanner,
                width: double.infinity,
                height: 256,
                fit: BoxFit.cover,
              ),
              const Positioned(
                child: CustomImage(
                  path: Assets.imagesGymImageLinear,
                  width: double.infinity,
                  height: 256,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                child: Text(
                  "Iron Haven Elite",
                  style:
                      Helper(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: white,
                          ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 13),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: primaryText1.withValues(alpha: 0.10),
                        ),
                        shape: BoxShape.circle,
                        color: primaryText1.withValues(alpha: 0.05),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: primaryText1,
                      ),
                    ),
                    sizedBoxWidth(width: 12),
                    Expanded(
                      child: Text(
                        "Level 14, The Obsidian Tower Level 14, The Obsidian TowerLevel 14, The Obsidian TowerLevel 14, The Obsidian Tower",
                        style: Helper(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: greyText2,
                            ),
                      ),
                    ),
                  ],
                ),
                sizedBoxHeight(height: 24),
                CustomButton(
                  onTap: () {
                    LaunchHelper.launchWhatsApp(phone: "797239849");
                  },
                  height: 44,
                  radius: 999,
                  color: primaryText1,
                  borderColor: primaryText1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.svgsCall,
                        colorFilter: ColorFilter.mode(
                          white,
                          BlendMode.srcIn,
                        ),
                      ),
                      sizedBoxWidth(width: 12),
                      Text(
                        "Call",
                        style: Helper(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: white,
                            ),
                      ),
                    ],
                  ),
                ),
                sizedBoxHeight(height: 12),
                CustomButton(
                  onTap: () {
                    LaunchHelper.launchWhatsApp(phone: "797239849");
                  },
                  type: ButtonType.secondary,
                  height: 44,
                  radius: 999,
                  borderColor: greenDark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.message,
                        color: greenDark,
                      ),
                      sizedBoxWidth(width: 12),
                      Text(
                        "WhatsApp",
                        style: Helper(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: greenDark,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
