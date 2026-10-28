import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class SelectTrainerTopSection extends StatelessWidget {
  const SelectTrainerTopSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final hasRooms = homeController.selectListingModel?.category?.hasRooms ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Select Your ",
              style: Helper(context).textTheme.titleSmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: blackText1,
                  ),
            ),
            GradientText(
              hasRooms ? 'Dream' : 'Elite',
              style: Helper(context).textTheme.titleSmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
              colors: [
                primaryText1,
                Color(0xFF60A5FA),
              ],
            ),
          ],
        ),
        GradientText(
          hasRooms ? 'Living' : 'Performance',
          style: Helper(context).textTheme.titleSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
          colors: [
            primaryText1,
            Color(0xFF60A5FA),
          ],
        ),
        Text(
          "Partner.",
          style: Helper(context).textTheme.titleSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: blackText1,
              ),
        ),
        sizedBoxHeight(height: 16),
        Text(
          hasRooms 
            ? "Discover your ideal living space. Choose from our premium rooms designed for comfort, convenience, and a vibrant community."
            : "Our world-class trainers specialize in bio- hacking, strength conditioning, and precision wellness. Choose the expert who matches your ambition.",
          style: Helper(context).textTheme.titleSmall?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: greyText2,
              ),
        ),
      ],
    );
  }
}
