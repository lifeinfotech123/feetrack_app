import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/slider_card/slider_card_widget/gym/gym_category_card.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/slider_card/slider_card_widget/image_slider_card.dart/image_slider_card.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/slider_card/slider_card_widget/pg/pg_hostel_category_card.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/slider_card/slider_card_widget/plan_image_card/plan_image_card.dart';

class GymPgSlider extends StatefulWidget {
  const GymPgSlider({
    super.key,
  });

  @override
  State<GymPgSlider> createState() => _GymPgSliderState();
}

class _GymPgSliderState extends State<GymPgSlider> {
  // ----------------------------------------------------------
  // CONTROLLER
  // ----------------------------------------------------------

  late final ScrollController _scrollController;

  // ----------------------------------------------------------
  // TIMER
  // ----------------------------------------------------------

  Timer? _timer;

  // ----------------------------------------------------------
  // ACTIVE CARD
  // ----------------------------------------------------------

  int activeIndex = 0;

  // ----------------------------------------------------------
  // CARD LIST
  // ----------------------------------------------------------

  final List<Widget Function(bool isActive)> categoryCards = [
    (isActive) => GymCategoryCard(
          key: const ValueKey('gym-card'),
          isActive: isActive,
        ),
    (isActive) => const PlanImageCard(
          key: ValueKey('plan-image-card'),
        ),
    (isActive) => PgHostelCategoryCard(
          key: const ValueKey('pg-card'),
          isActive: isActive,
        ),
    (isActive) => const ImageSliderCard(
          key: ValueKey('image-slider-card'),
        ),
  ];

  // ----------------------------------------------------------
  // CARD GAP
  // ----------------------------------------------------------

  static const double cardGap = 8.0;

  // ----------------------------------------------------------
  // CARD WIDTH
  // ----------------------------------------------------------

  static const double cardWidthFraction = 0.60;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(
      _handleScroll,
    );

    // Start timer after first frame.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _startAutoChange();
      },
    );
  }

  // ==========================================================
  // CARD WIDTH
  // ==========================================================

  double _getCardWidth() {
    final double screenWidth = MediaQuery.of(context).size.width;

    return screenWidth * cardWidthFraction;
  }

  // ==========================================================
  // TARGET SCROLL POSITION
  // ==========================================================

  double _getTargetOffset(int index) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final double cardWidth = screenWidth * cardWidthFraction;

    final double itemWidth = cardWidth + cardGap;

    // Space needed to center the card.
    final double centerSpace = (screenWidth - cardWidth) / 2;

    double target = (index * itemWidth) - centerSpace;

    // First card must stay at the left.
    if (index == 0) {
      target = 0;
    }

    // Make sure we never scroll beyond limits.
    if (_scrollController.hasClients) {
      target = target.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
    }

    return target;
  }

  // ==========================================================
  // AUTO CHANGE EVERY 2 SECONDS
  // ==========================================================

  void _startAutoChange() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!mounted) return;

        int nextIndex = activeIndex + 1;

        // Loop back to first card.
        if (nextIndex >= categoryCards.length) {
          nextIndex = 0;
        }

        _scrollToCard(nextIndex);
      },
    );
  }

  // ==========================================================
  // SCROLL TO CARD
  // ==========================================================

  Future<void> _scrollToCard(
    int index,
  ) async {
    if (!mounted) return;

    if (!_scrollController.hasClients) {
      return;
    }

    final double targetOffset = _getTargetOffset(index);

    // Activate the card immediately.
    setState(() {
      activeIndex = index;
    });

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(
        milliseconds: 900,
      ),
      curve: Curves.easeInOutCubic,
    );
  }

  // ==========================================================
  // UPDATE ACTIVE CARD WHEN USER SWIPES
  // ==========================================================

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double currentOffset = _scrollController.offset;

    int closestIndex = 0;

    double smallestDistance = double.infinity;

    for (int i = 0; i < categoryCards.length; i++) {
      final double target = _getTargetOffset(i);

      final double distance = (currentOffset - target).abs();

      if (distance < smallestDistance) {
        smallestDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != activeIndex && mounted) {
      setState(() {
        activeIndex = closestIndex;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    _scrollController.removeListener(
      _handleScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double cardWidth = _getCardWidth();

    final double cardHeight = screenHeight * 0.46;

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: ListView.separated(
        controller: _scrollController,

        scrollDirection: Axis.horizontal,

        physics: const BouncingScrollPhysics(),

        itemCount: categoryCards.length,

        // Start from the left.
        padding: EdgeInsets.zero,

        separatorBuilder: (
          BuildContext context,
          int index,
        ) {
          return SizedBox(
            width: cardGap.w,
          );
        },

        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          final bool isActive = activeIndex == index;

          return SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: categoryCards[index](
              isActive,
            ),
          );
        },
      ),
    );
  }
}
