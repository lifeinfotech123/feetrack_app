import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';

import '../../../services/constants.dart';
import '../../../services/theme.dart';
import 'package:vlr/services/appsflyer_service.dart';
import 'package:vlr/services/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      checkAuth();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkAuth() async {
    final authController = Get.find<AuthController>();

    String token = authController.getUserToken();

    if (token.isNotEmpty) {
      final response = await authController.fetchProfile();

      if (response.isSuccess) {
        // Mark app ready BEFORE navigation — user IS logged in
        AppsFlyerService.markAppReady(isLoggedIn: true);
        if (mounted) {
          AppRouter.goToDashboard();
        }
      } else {
        // Token invalid/expired — user is NOT logged in
        AppsFlyerService.markAppReady(isLoggedIn: false);
        if (mounted) {
          AppRouter.goToLogin();
        }
      }
    } else {
      // No token — user is NOT logged in
      AppsFlyerService.markAppReady(isLoggedIn: false);
      if (mounted) {
        AppRouter.goToLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              white,
              primaryColor.withValues(alpha: 0.02),
              primaryColor.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ScaleTransition(
                //   scale: _scaleAnimation,
                //   child: FadeTransition(
                //     opacity: _opacityAnimation,
                //     child: CustomImage(
                //       path: Assets.feetrackLogo,
                //       height: size.height * 0.25,
                //       width: size.height * 0.25,
                //       fit: BoxFit.contain,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName.toUpperCase(),
                        style:
                            Helper(context).textTheme.displayMedium?.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  color: primaryText1,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 2,
                        width: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "ELEVATING YOUR FITNESS EXPERIENCE",
                        style: Helper(context).textTheme.bodySmall?.copyWith(
                              color: greyText3,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Loading and Footer
            Positioned(
              bottom: size.height * 0.08,
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Gym and Room Rent Payment App",
                    style: Helper(context).textTheme.bodySmall?.copyWith(
                          color: greyText3.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
