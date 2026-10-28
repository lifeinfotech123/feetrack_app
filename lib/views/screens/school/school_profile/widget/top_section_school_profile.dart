import 'package:flutter/material.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class TopSectionSchoolProfile extends StatelessWidget {
  const TopSectionSchoolProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width / 1.5,
      child: Stack(
        children: [
          CustomImage(
            path: Assets.imagesSchoolProfile,
            height: MediaQuery.of(context).size.width / 1.9,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 4, color: white),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                      spreadRadius: -6,
                      color: black.withValues(alpha: 0.10),
                    ),
                    BoxShadow(
                      offset: const Offset(0, 10),
                      blurRadius: 15,
                      spreadRadius: -3,
                      color: black.withValues(alpha: 0.10),
                    ),
                  ],
                ),
                child: const CustomImage(
                  path: Assets.imagesSchoolLogo,
                  height: 128,
                  width: 128,
                  radius: 999,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
