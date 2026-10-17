import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:vlr/controllers/common_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/search/search_all_screen.dart';

class NearByRowSection extends StatelessWidget {
  const NearByRowSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommonController>(builder: (commonController) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Nearby ${capitalize(commonController.currentSelectService.name)}",
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  color: blackText1,
                ),
          ),
          CustomButton(
            type: ButtonType.tertiary,
            onTap: () {
              navigate(
                context: context,
                page: const SearchAllScreen(),
              );
            },
            child: Text(
              "View All",
              style: Helper(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryText1,
                  ),
            ),
          ),
        ],
      );
    });
  }
}
