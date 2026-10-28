import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/views/base/custom_image.dart';

class ImageSliderCard extends StatefulWidget {
  const ImageSliderCard({
    super.key,
  });

  @override
  State<ImageSliderCard> createState() => _ImageSliderCardState();
}

class _ImageSliderCardState extends State<ImageSliderCard> {
  int currentIndex = 0;

  Timer? _timer;

  // ----------------------------------------------------------
  // IMAGE LIST
  // ----------------------------------------------------------

  final List<String> sliderImages = [
    Assets.imagesBanner1,
    Assets.imagesGymBanner2,
    Assets.imagesGymBanner3,
  ];

  @override
  void initState() {
    super.initState();

    _startImageChange();
  }

  // ----------------------------------------------------------
  // CHANGE IMAGE
  // ----------------------------------------------------------

  void _startImageChange() {
    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!mounted) return;

        setState(() {
          currentIndex =
              (currentIndex + 1) % sliderImages.length;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,

      margin: EdgeInsets.symmetric(
        horizontal: 4.w,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          24.r,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 16.r,
            offset: Offset(
              0,
              6.h,
            ),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          24.r,
        ),

        child: AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 1000,
          ),

          reverseDuration: const Duration(
            milliseconds: 700,
          ),

          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,

          transitionBuilder: (
            Widget child,
            Animation<double> animation,
          ) {
            return FadeTransition(
              opacity: animation,

              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 1.04,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),

                child: child,
              ),
            );
          },

          child: CustomImage(
            key: ValueKey(
              sliderImages[currentIndex],
            ),

            path: sliderImages[currentIndex],

            width: double.infinity,
            height: double.infinity,

            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}