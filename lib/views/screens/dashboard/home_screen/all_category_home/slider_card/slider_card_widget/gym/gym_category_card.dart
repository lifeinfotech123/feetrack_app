import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/data/models/category_model/category_model.dart';
import 'package:vlr/services/constants.dart';

import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/gym_home_screen.dart';
import 'package:vlr/views/screens/gym/gym_bottom_nav_bar/gym_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/slider_card/slider_card_widget/gym/gym_feature_card.dart';

class GymCategoryCard extends StatefulWidget {
  const GymCategoryCard({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  State<GymCategoryCard> createState() => _GymCategoryCardState();
}

class _GymCategoryCardState extends State<GymCategoryCard>
    with TickerProviderStateMixin {
  // ==========================================================
  // POPUP + FLIP
  // ==========================================================

  late final AnimationController _mainController;

  // ==========================================================
  // CONTINUOUS UP/DOWN FLOAT
  // ==========================================================

  late final AnimationController _floatController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateXAnimation;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // ========================================================
    // POPUP + DOWN -> UP FLIP
    // ========================================================

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1400,
      ),
    );

    // --------------------------------------------------------
    // SMALL -> BIG -> SETTLE
    // --------------------------------------------------------

    _scaleAnimation = TweenSequence<double>(
      [
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 0.15,
            end: 1.15,
          ).chain(
            CurveTween(
              curve: Curves.easeOutBack,
            ),
          ),
          weight: 78,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 1.15,
            end: 1.0,
          ).chain(
            CurveTween(
              curve: Curves.easeOutCubic,
            ),
          ),
          weight: 22,
        ),
      ],
    ).animate(_mainController);

    // --------------------------------------------------------
    // DOWN -> UP 3D FLIP
    // --------------------------------------------------------

    _rotateXAnimation = Tween<double>(
      begin: math.pi / 2,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutCubic,
      ),
    );

    // ========================================================
    // CONTINUOUS FLOAT
    // ========================================================

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2400,
      ),
    );

    _floatAnimation = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );

    // ========================================================
    // INITIAL ANIMATION
    // ========================================================

    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _playAnimation();
        }
      });
    }
  }

  // ==========================================================
  // START ANIMATION
  // ==========================================================

  Future<void> _playAnimation() async {
    if (!mounted || !widget.isActive) {
      return;
    }

    // Reset previous state.
    _mainController.reset();

    _floatController
      ..stop()
      ..reset();

    // --------------------------------------------------------
    // POPUP + FLIP
    // --------------------------------------------------------

    await _mainController.forward();

    if (!mounted || !widget.isActive) {
      return;
    }

    // --------------------------------------------------------
    // START CONTINUOUS UP/DOWN
    // --------------------------------------------------------

    _floatController.repeat(
      reverse: true,
    );
  }

  // ==========================================================
  // STOP ANIMATION
  // ==========================================================

  void _stopAnimation() {
    _mainController.stop();
    _mainController.reset();

    _floatController
      ..stop()
      ..reset();
  }

  // ==========================================================
  // ACTIVE STATE CHANGED
  // ==========================================================

  @override
  void didUpdateWidget(
    covariant GymCategoryCard oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    // Card became active.
    if (!oldWidget.isActive && widget.isActive) {
      _playAnimation();
    }

    // Card became inactive.
    if (oldWidget.isActive && !widget.isActive) {
      _stopAnimation();
    }
  }

  void _onCategorySelected(String categoryId) async {
    final homeController = Get.find<HomeController>();
    final permissionController = Get.find<PermissionController>();

    final category = homeController.categoryModelList.firstWhere(
      (element) => element.id.toString() == categoryId,
      orElse: () => CategoryModel(
        id: int.tryParse(categoryId),
        name: categoryId == "1"
            ? "Gym"
            : (categoryId == "3"
                ? "PG / Hostel"
                : (categoryId == "2" ? "Dance Center" : "Services")),
      ),
    );

    homeController.updateSelectCategoryModel(category);
    await fetchLocation(permissionController);

    if (!mounted) return;
    navigate(context: context, page: const GymBottomNavBarScreen());
  }

  Future<void> fetchLocation(PermissionController permissionController) async {
    bool success =
        await permissionController.requestLocationPermissionAndFetch(context);

    if (success && permissionController.locationFetched) {
      final homeController = Get.find<HomeController>();

      // Refresh listings with the new location coordinates
      homeController.fetchGymListing(
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );
      homeController.fetchDanceListing(
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );
      homeController.fetchPgHostelListing(
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 4.w,
      ),
      padding: EdgeInsets.all(
        10.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          24.r,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEBDFFF),
            Color(0xFFDCC9FF),
            Color(0xFFE9DCFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2FD6).withValues(
              alpha: 0.12,
            ),
            blurRadius: 16.r,
            offset: Offset(
              0,
              6.h,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          // ====================================================
          // GYM IMAGE ANIMATION
          // ====================================================

          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                20.r,
              ),
              child: SizedBox(
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _mainController,
                    _floatController,
                  ]),

                  builder: (
                    BuildContext context,
                    Widget? child,
                  ) {
                    // ------------------------------------------
                    // FLOAT ONLY AFTER POPUP IS COMPLETE
                    // ------------------------------------------

                    final double floatY =
                        widget.isActive && _mainController.isCompleted
                            ? _floatAnimation.value
                            : 0.0;

                    // ------------------------------------------
                    // SCALE
                    // ------------------------------------------

                    final double scale =
                        widget.isActive ? _scaleAnimation.value : 1.0;

                    // ------------------------------------------
                    // FLIP
                    // ------------------------------------------

                    final double rotateX =
                        widget.isActive ? _rotateXAnimation.value : 0.0;

                    return Transform.translate(
                      offset: Offset(
                        0,
                        floatY,
                      ),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          // Perspective
                          ..setEntry(
                            3,
                            2,
                            0.0025,
                          )

                          // DOWN -> UP
                          ..rotateX(
                            rotateX,
                          ),
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      ),
                    );
                  },

                  // ------------------------------------------------
                  // YOUR IMAGE
                  // ------------------------------------------------

                  child: CustomImage(
                    path: Assets.imagesGymSlider,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 8.h,
          ),

          // ====================================================
          // FEATURES
          // ====================================================

          Expanded(
            flex: 4,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 7.w,
              mainAxisSpacing: 7.h,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                GymFeatureCard(
                  icon: Icons.fitness_center_rounded,
                  title: "Strength",
                  subtitle: "Build Muscle",
                  iconColor: Color(0xFF1565E8),
                  backgroundColor: Color(0xFFEAF2FF),
                ),
                GymFeatureCard(
                  icon: Icons.directions_run_rounded,
                  title: "Cardio",
                  subtitle: "Stay Active",
                  iconColor: Color(0xFF13B874),
                  backgroundColor: Color(0xFFE7FFF5),
                ),
                GymFeatureCard(
                  icon: Icons.person_rounded,
                  title: "Personal",
                  subtitle: "Expert Trainers",
                  iconColor: Color(0xFFFF8B00),
                  backgroundColor: Color(0xFFFFF2DF),
                ),
                GymFeatureCard(
                  icon: Icons.favorite_rounded,
                  title: "Nutrition",
                  subtitle: "Eat Better",
                  iconColor: Color(0xFFFF2E7A),
                  backgroundColor: Color(0xFFFFE8F1),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 8.h,
          ),

          // ====================================================
          // BUTTON
          // ====================================================

          GetBuilder<HomeController>(
            builder: (homeController) {
              return SizedBox(
                width: double.infinity,
                height: 38.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (homeController.isLoading) return;
                    _onCategorySelected("1");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E1BC7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        14.r,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Book Workout",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        width: 7.w,
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 17.sp,
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}
