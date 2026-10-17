import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/data/models/category_model/category_model.dart';
import 'package:vlr/services/constants.dart';

import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/slider_card/slider_card_widget/pg/pg_feature_card.dart';

import '../../../../../../../base/custom_image.dart';

class PgHostelCategoryCard extends StatefulWidget {
  final bool isActive;

  const PgHostelCategoryCard({
    super.key,
    required this.isActive,
  });

  @override
  State<PgHostelCategoryCard> createState() => _PgHostelCategoryCardState();
}

class _PgHostelCategoryCardState extends State<PgHostelCategoryCard>
    with TickerProviderStateMixin {
  // ==========================================================
  // POPUP + FLIP
  // ==========================================================

  late final AnimationController _mainController;

  // ==========================================================
  // CONTINUOUS FLOAT
  // ==========================================================

  late final AnimationController _floatController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateXAnimation;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // ========================================================
    // POPUP + FLIP CONTROLLER
    // ========================================================

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1400,
      ),
    );

    // ========================================================
    // SMALL -> BIG -> SETTLE
    // ========================================================

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

    // ========================================================
    // DOWN -> UP 3D FLIP
    // ========================================================

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
    // FLOAT CONTROLLER
    // ========================================================

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2400,
      ),
    );

    // ========================================================
    // UP -> DOWN
    // ========================================================

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
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (mounted) {
            _playAnimation();
          }
        },
      );
    }
  }

  // ==========================================================
  // START ANIMATION
  // ==========================================================

  Future<void> _playAnimation() async {
    if (!mounted || !widget.isActive) {
      return;
    }

    // Reset popup.
    _mainController.reset();

    // Reset floating.
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
    // CONTINUOUS FLOAT
    // --------------------------------------------------------

    _floatController.repeat(
      reverse: true,
    );
  }

  // ==========================================================
  // STOP ANIMATION
  // ==========================================================

  void _stopAnimation() {
    _mainController
      ..stop()
      ..reset();

    _floatController
      ..stop()
      ..reset();
  }

  // ==========================================================
  // ACTIVE STATE CHANGED
  // ==========================================================

  @override
  void didUpdateWidget(
    covariant PgHostelCategoryCard oldWidget,
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

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();

    super.dispose();
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
    navigate(context: context, page: const RoomBottomNavBarScreen());
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
            Color(0xFFFFF0DC),
            Color(0xFFFFE4BF),
            Color(0xFFFFF2DF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7900).withValues(
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
          // PG / HOSTELS IMAGE ANIMATION
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
                    // FLOAT AFTER POPUP
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
                    // ROTATION
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
                  // PG IMAGE / GIF
                  // ------------------------------------------------

                  child: CustomImage(
                    path: Assets.imagesPGSlider,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 12.h,
          ),

          // ====================================================
          // FEATURES
          // ====================================================

          Expanded(
            flex: 5,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 7.w,
              mainAxisSpacing: 7.h,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                PgFeatureCard(
                  icon: Icons.bed_rounded,
                  title: "Furnished",
                  subtitle: "Move in Easily",
                  iconColor: Color(0xFFE91E63),
                  backgroundColor: Color(0xFFFFE7F0),
                ),
                PgFeatureCard(
                  icon: Icons.location_on_rounded,
                  title: "Locations",
                  subtitle: "Near You",
                  iconColor: Color(0xFF00A878),
                  backgroundColor: Color(0xFFE3FFF4),
                ),
                PgFeatureCard(
                  icon: Icons.wifi_rounded,
                  title: "High-Speed",
                  subtitle: "Stay Connected",
                  iconColor: Color(0xFF1976D2),
                  backgroundColor: Color(0xFFE7F0FF),
                ),
                PgFeatureCard(
                  icon: Icons.verified_user_rounded,
                  title: "Safe",
                  subtitle: "Peace of Mind",
                  iconColor: Color(0xFFFFA000),
                  backgroundColor: Color(0xFFFFF2D8),
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

          GetBuilder<HomeController>(builder: (homeController) {
            return SizedBox(
              width: double.infinity,
              height: 38.h,
              child: ElevatedButton(
                onPressed: () {
                  if (homeController.isLoading) return;
                  _onCategorySelected("3");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
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
                      "Find PGs / Hostels",
                      style: TextStyle(
                        fontSize: 12.sp,
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
          }),
        ],
      ),
    );
  }
}
