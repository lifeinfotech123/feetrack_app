import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_banner_section/row_gym_info_widget.dart';

class RowGYMInfo extends StatelessWidget {
  const RowGYMInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final _rowGYMInforWidgeList =
          rowGYMInforWidgetModelList(homeController: homeController);
      return Container(
          color: greyLight,
          height: 85,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final _rowGYMInforWidget = _rowGYMInforWidgeList[index];
              return SizedBox(
                width: MediaQuery.sizeOf(context).width / 3.2,
                child: CustomShimmer(
                  isLoading: homeController.isLoading,
                  child: RowGYMInfoWidget(
                    rowGYMInforWidgetModel: _rowGYMInforWidget,
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => Container(
              margin: const EdgeInsets.symmetric(vertical: 26),
              width: 2,
              decoration: BoxDecoration(
                  color: greyDart.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(99)),
            ),
            itemCount: _rowGYMInforWidgeList.length,
          ));
    });
  }
}
