import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class ClassTeacherProfileSection extends StatelessWidget {
  const ClassTeacherProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Class Teacher",
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 24,
                  color: blackText1,
                ),
          ),
          sizedBoxHeight(height: 16),
          Row(
            children: [
              const CustomImage(
                path: Assets.imagesTeacher,
                height: 76,
                width: 76,
                radius: 99,
              ),
              sizedBoxWidth(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mrs. Shanthi Kumar",
                    style: Helper(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          color: blackText1,
                        ),
                  ),
                  Text(
                    "SENIOR FACULTY",
                    style: Helper(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: greyText5,
                        ),
                  ),
                  sizedBoxHeight(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: whiteSmoke,
                        radius: 20,
                        child: SvgPicture.asset(
                          Assets.svgsCall,
                          height: 15,
                          width: 15,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            blueLight3,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      sizedBoxWidth(width: 12),
                      CircleAvatar(
                        backgroundColor: whiteSmoke,
                        radius: 20,
                        child: SvgPicture.asset(
                          Assets.svgsEmail,
                          height: 15,
                          width: 15,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            blueLight3,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      sizedBoxWidth(width: 12),
                      CircleAvatar(
                        backgroundColor: whiteSmoke,
                        radius: 20,
                        child: SvgPicture.asset(
                          Assets.svgsMessage,
                          height: 15,
                          width: 15,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            blueLight3,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
