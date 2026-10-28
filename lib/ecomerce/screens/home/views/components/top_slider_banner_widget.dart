import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/skleton/banner/banner_m_skelton.dart';
import '../../../../constants.dart';
import '../../../../controllers/top_slider_controller.dart';
import '../../../../models/top_slider_model.dart';
import '../../../../route/route_constants.dart';

class TopSliderBannerWidget extends StatefulWidget {
  const TopSliderBannerWidget({super.key});

  @override
  State<TopSliderBannerWidget> createState() => _TopSliderBannerWidgetState();
}

class _TopSliderBannerWidgetState extends State<TopSliderBannerWidget> {
  late final TopSliderController _controller;
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(TopSliderController());
    _pageController = PageController(initialPage: 0);

    // Automatic horizontal slide timer (every 4 seconds)
    _startAutoSlideTimer();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final count = _controller.sliders.length;
      if (count <= 1) return;

      int nextIndex = _currentIndex + 1;
      if (nextIndex >= count) {
        nextIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleBannerTap(TopSliderModel slider) {
    if (slider.linkedProduct != null) {
      final productModel = slider.linkedProduct!.toProductModel(
        storeName: slider.store?.name,
        storeDomain: slider.store?.domain,
      );
      Navigator.pushNamed(
        context,
        productDetailsScreenRoute,
        arguments: productModel,
      );
    } else {
      Navigator.pushNamed(context, onSaleScreenRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (_controller.isLoading.value && _controller.sliders.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultPadding),
          child: BannerMSkelton(),
        );
      }

      final sliders = _controller.sliders;
      if (sliders.isEmpty) {
        return const SizedBox.shrink();
      }

      return AspectRatio(
        aspectRatio: 2.05,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 1. Horizontal PageView Sliding Images
              PageView.builder(
                controller: _pageController,
                itemCount: sliders.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _controller.setActiveIndex(index);
                },
                itemBuilder: (context, index) {
                  final slider = sliders[index];
                  final hasTitle = slider.title.trim().isNotEmpty;
                  final hasSubTitle = slider.subTitle.trim().isNotEmpty;
                  final hasButton = slider.buttonText.trim().isNotEmpty;

                  return InkWell(
                    onTap: () => _handleBannerTap(slider),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(slider.parsedColorValue),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.35 : 0.08,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Banner Image
                            if (slider.photo.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: slider.photo,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: Color(slider.parsedColorValue),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Color(slider.parsedColorValue),
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    color: Colors.white54,
                                    size: 36,
                                  ),
                                ),
                              ),

                            // Gradient Overlay for text readability (only if title or subtitle present)
                            if (hasTitle || hasSubTitle || hasButton)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.65),
                                      Colors.black.withValues(alpha: 0.2),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),

                            // Store Tag at top-left
                            if (slider.store != null)
                              Positioned(
                                top: 10,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.storefront_rounded,
                                        color: Colors.white,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        slider.store!.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Content: Title, Subtitle, Action Button
                            if (hasTitle || hasSubTitle || hasButton)
                              Positioned(
                                left: 14,
                                bottom: 14,
                                right: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasTitle)
                                      Text(
                                        slider.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          height: 1.2,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (hasSubTitle) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        slider.subTitle,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (hasButton) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              slider.buttonText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 11,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 2. Dynamic Floating Dots Indicator (Bottom-Right)
              if (sliders.length > 1)
                Positioned(
                  bottom: 10,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        sliders.length,
                        (dotIndex) {
                          final isSelected = dotIndex == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            height: 5,
                            width: isSelected ? 16 : 5,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
