import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/services/theme.dart';

class GymHomeSearchBar extends StatefulWidget {
  const GymHomeSearchBar({super.key});

  @override
  State<GymHomeSearchBar> createState() => _GymHomeSearchBarState();
}

class _GymHomeSearchBarState extends State<GymHomeSearchBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final homeController = Get.find<HomeController>();
    _controller = TextEditingController(text: homeController.gymSearchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        // Keep controller text in sync if search query was cleared externally
        if (homeController.gymSearchQuery.isEmpty &&
            _controller.text.isNotEmpty) {
          _controller.clear();
        }

        final bool hasText = homeController.gymSearchQuery.isNotEmpty ||
            _controller.text.isNotEmpty;

        return Container(
          margin: EdgeInsets.only(top: 10.h, bottom: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: hasText
                  ? primaryColor.withValues(alpha: 0.6)
                  : const Color(0xFFE5E7EB),
              width: hasText ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: hasText
                    ? primaryColor.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onChanged: (val) {
              homeController.setGymSearchQuery(val);
            },
            onSubmitted: (val) {
              homeController.setGymSearchQuery(val);
            },
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: blackText1,
            ),
            decoration: InputDecoration(
              hintText: "Search gym by name, area, location...",
              hintStyle: TextStyle(
                fontSize: 13.sp,
                color: greyText3,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: hasText ? primaryColor : greyText3,
                size: 22.sp,
              ),
              suffixIcon: hasText
                  ? IconButton(
                      icon: Icon(
                        Icons.cancel_rounded,
                        color: Colors.grey.shade400,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        _controller.clear();
                        homeController.clearGymSearch();
                        _focusNode.unfocus();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        );
      },
    );
  }
}

