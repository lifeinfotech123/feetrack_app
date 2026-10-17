import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/auth_screens/login/widget/auth_top_section.dart';
import 'package:vlr/views/screens/auth_screens/login/widget/login_bottom_section.dart';
import 'package:vlr/views/screens/auth_screens/register/widget/register_med_section.dart';

class RegisterScreen extends StatefulWidget {
  final String? mobileNumber;
  final String? referralCode;
  const RegisterScreen({super.key, this.mobileNumber, this.referralCode});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AuthController auth = Get.find<AuthController>();
      auth.firstNameController.clear();
      auth.lastNameController.clear();
      auth.fullNameController.clear();
      auth.emailController.clear();
      auth.passwordController.clear();
      auth.confirmPasswordController.clear();
      if (widget.mobileNumber != null) {
        auth.mobileNoController.text = widget.mobileNumber!;
      } else {
        auth.mobileNoController.clear();
      }
      if (widget.referralCode != null && widget.referralCode!.isNotEmpty) {
        auth.referralCodeController.text = widget.referralCode!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 40.h,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            children: [
              const AuthTopSection(),
              RegisterMedSection(referralCode: widget.referralCode),
              sizedBoxHeight(height: 36),
              const LoginBottomSection()
            ],
          ),
        ),
      ),
    );
  }
}
