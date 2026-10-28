import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/dashboard_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class HomeTopSection extends StatelessWidget {
  const HomeTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    final sectionList = [
      (HomeServiceType.gym, 'GYM'),
      (HomeServiceType.room, 'Room'),
    ];

    return GetBuilder<DashBoardController>(
      id: 'home_switch',
      builder: (controller) {
        final selectedIndex = sectionList.indexWhere(
          (section) => section.$1 == controller.homeServiceType,
        );
        final safeSelectedIndex = selectedIndex < 0 ? 0 : selectedIndex;
        final alignmentX =
            -1.0 + (2.0 * safeSelectedIndex / (sectionList.length - 1));

        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: greyLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      alignment: Alignment(alignmentX, 0),
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 40,
                        width: constraints.maxWidth / sectionList.length,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9999),
                          color: white,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              spreadRadius: 0,
                              color: black.withValues(alpha: 0.05),
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: sectionList.map((section) {
                        final isSelected =
                            controller.homeServiceType == section.$1;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                controller.selectHomeService(section.$1),
                            child: SizedBox(
                              height: 40,
                              child: Center(
                                child: Text(
                                  section.$2,
                                  style: Helper(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? primaryText1
                                            : greyText2,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
