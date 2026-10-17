import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/firebase/get_fcm_token.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/app_router.dart';
import 'package:vlr/views/screens/auth_screens/login/widget/auth_mid_section.dart';
import 'package:vlr/views/screens/auth_screens/login/widget/auth_top_section.dart';
import 'package:vlr/views/screens/auth_screens/login/widget/login_bottom_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Get.find<PermissionController>()
          .requestLocationPermissionAndFetch(context);
      AuthController auth = Get.find<AuthController>();

      auth.mobileNoController.clear();
      auth.emailOtpCodeController.clear();
      auth.mobileOtpCodeController.clear();
      auth.loginEmailController.clear();
      auth.loginPasswordController.clear();

      // Print FCM Token
      String token = await NotificationServices().getDeviceToken();
      debugPrint("FCM TOKEN: $token");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFF),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                Get.find<AuthController>().continueAsGuest();
                AppRouter.goToDashboard();
              },
              child: Text(
                "Skip",
                style: Helper(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: AppConstants.screenPadding,
            child: Column(
              children: [
                const AuthTopSection(),
                const AuthMidSection(),
                sizedBoxHeight(height: 16),
                const LoginBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
