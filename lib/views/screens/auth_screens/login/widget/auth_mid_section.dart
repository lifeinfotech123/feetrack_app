import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:flutter/material.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/auth_screens/opt_verification_screen.dart';
import 'package:vlr/views/screens/auth_screens/register/register_screen.dart';

import 'package:vlr/services/app_router.dart';
import '../../../dashboard/dashboard_screen.dart';

class AuthMidSection extends StatefulWidget {
  const AuthMidSection({super.key});

  @override
  State<AuthMidSection> createState() => _AuthMidSectionState();
}

class _AuthMidSectionState extends State<AuthMidSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final FocusNode _phoneFocusNode = FocusNode();

  bool isSms = true;
  bool isEmailLogin = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _phoneFocusNode.requestFocus();
          SystemChannels.textInput.invokeMethod('TextInput.show');
        }
      });
    });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail(AuthController authController) async {
    if (authController.isLoading) {
      return;
    }

    if (_emailFormKey.currentState?.validate() ?? false) {
      final value = await authController.loginWithEmailPassword();
      if (value.isSuccess) {
        showToast(
          message: value.message.isNotEmpty
              ? value.message
              : "Login successful!",
          typeCheck: true,
        );

        if (!mounted) return;
        AppRouter.goToDashboard();
      } else {
        showToast(
          message: value.message,
          toastType: ToastType.warning,
        );
      }
    }
  }

  Future<void> _signIn(AuthController authController) async {
    if (authController.isLoading) {
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final value = await authController.loginUser(isSMS: isSms);
      if (value.isSuccess) {
        showToast(message: value.message, typeCheck: value.isSuccess);
        if (!mounted) return;
        navigate(
          context: context,
          page: OTPVerification(
            phone: authController.mobileNoController.text,
            gmail: authController.emailController.text,
            isPhone: true,
            callLoginApi: true,
            isSMS: isSms,
          ),
        );
      } else {
        // Check if the error message indicates the user is not registered
        if (value.message.toLowerCase().contains("not found") ||
            value.message.toLowerCase().contains("not register") ||
            value.message.toLowerCase().contains("user doesn't exist")) {
          if (!mounted) return;
          _showNotRegisteredDialog(authController.mobileNoController.text);
        } else {
          showToast(message: value.message, typeCheck: value.isSuccess);
        }
      }
    }
  }

  void _showNotRegisteredDialog(String mobileNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Account Not Found",
            style: Helper(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Text(
            "This mobile number ($mobileNumber) is not registered with us. Please register first to continue.",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: greyDart2,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: greyText2, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                navigate(
                  context: context,
                  page: RegisterScreen(mobileNumber: mobileNumber),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Register",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmailLoginForm(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 70.h,
                color: primaryColor,
              ),
              sizedBoxHeight(height: 14.h),
              Text(
                "Login with Email",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 24.sp,
                    ),
              ),
              sizedBoxHeight(height: 8.h),
              Text(
                "Enter your registered email and password to login.",
                textAlign: TextAlign.center,
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.sp,
                      color: greyDart,
                    ),
              ),
            ],
          ),
        ),
        sizedBoxHeight(height: 28.h),
        Form(
          key: _emailFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: "Email ID ",
                  style: Helper(context).textTheme.titleSmall?.copyWith(
                        fontSize: 14.sp,
                        color: greyDart2,
                      ),
                  children: const [
                    TextSpan(
                      text: "*",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                constraints: BoxConstraints(minHeight: 56.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: TextFormField(
                  controller: authController.loginEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter your email address",
                    hintStyle: Helper(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16.sp,
                          color: const Color(0xFF98A2B3),
                        ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF2563EB),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your email";
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value.trim())) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
              ),
              sizedBoxHeight(height: 20.h),
              RichText(
                text: TextSpan(
                  text: "Password ",
                  style: Helper(context).textTheme.titleSmall?.copyWith(
                        fontSize: 14.sp,
                        color: greyDart2,
                      ),
                  children: const [
                    TextSpan(
                      text: "*",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                constraints: BoxConstraints(minHeight: 56.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: TextFormField(
                  controller: authController.loginPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    hintStyle: Helper(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16.sp,
                          color: const Color(0xFF98A2B3),
                        ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF2563EB),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF98A2B3),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        sizedBoxHeight(height: 28.h),
        CustomButton(
          isLoading: authController.isLoading,
          onTap: () {
            _signInWithEmail(authController);
          },
          height: 50.h,
          color: textBlue,
          radius: 999,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, color: white, size: 20.h),
              sizedBoxWidth(width: 12.w),
              Text(
                "Login",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      color: white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        sizedBoxHeight(height: 14.h),
        CustomButton(
          borderColor: primaryColor,
          type: ButtonType.secondary,
          height: 50.h,
          radius: 999,
          onTap: () {
            setState(() {
              isEmailLogin = false;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_android_rounded,
                  color: primaryColor, size: 20.sp),
              sizedBoxWidth(width: 10.w),
              Text(
                "Login with Mobile Number (OTP)",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.sp,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        sizedBoxHeight(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                "Do not have an account?",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16.sp,
                      color: greyText2,
                    ),
              ),
            ),
            CustomButton(
              type: ButtonType.tertiary,
              onTap: () {
                navigate(context: context, page: const RegisterScreen());
              },
              child: Text(
                "Register",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      color: primaryText1,
                    ),
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: white,
        border: Border.all(width: 1, color: white.withValues(alpha: 0.60)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 10),
            color: black.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: GetBuilder<AuthController>(builder: (authController) {
        if (isEmailLogin) {
          return _buildEmailLoginForm(authController);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Column(
            children: [
              isSms
                  ? Icon(Icons.message_rounded, size: 80.h, color: primaryColor)
                  : CustomImage(
                      path: Assets.imagesWhatsappLogo,
                      height: 80.h,
                      width: 80.w,
                      fit: BoxFit.cover,
                    ),
              sizedBoxHeight(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                    child: Text(
                      isSms ? "Login with SMS" : "Login with WhatsApp",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 24.sp,
                          ),
                    ),
                  ),
                ),
              ),
              sizedBoxHeight(height: 8.h),
              Text(
                isSms
                    ? "We'll send a 6-digit OTP to your mobile number to login to your account."
                    : "We'll send a 6-digit OTP to your WhatsApp to login to your account.",
                textAlign: TextAlign.center,
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.sp,
                      color: greyDart,
                    ),
              ),
              sizedBoxHeight(height: 32.h),
              Row(
                children: [
                  Text(
                    "Mobile Number.",
                    textAlign: TextAlign.center,
                    style: Helper(context).textTheme.titleSmall?.copyWith(
                          fontSize: 14.sp,
                          color: greyDart2,
                        ),
                  ),
                ],
              ),
              sizedBoxHeight(height: 8.h),
              GetBuilder<AuthController>(builder: (authController) {
                return Form(
                    key: _formKey,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "+91",
                                  style: Helper(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 16.sp,
                                        color: greyDart2,
                                      ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: const Color(0xFF2563EB),
                                  size: 16.r,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              focusNode: _phoneFocusNode,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              autofocus: true,
                              onTap: () {
                                debugPrint("PHONE FIELD TAPPED");
                                _phoneFocusNode.requestFocus();
                                SystemChannels.textInput.invokeMethod(
                                    'TextInput.show');
                              },
                              decoration: InputDecoration(
                                hintText: "Enter your mobile number",
                                hintStyle: Helper(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        fontSize: 16.sp,
                                        color: const Color(0xFF98A2B3)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                ),
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {
                                if (value.length == 10) {
                                  _signIn(authController);
                                }
                              },
                              controller: authController.mobileNoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter your mobile number";
                                }
                                if (value.length != 10) {
                                  return "Enter a valid mobile number";
                                }
                                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                                  return "Enter a valid mobile number";
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ));
              }),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    CustomImage(
                      path: Assets.imagesProtection,
                      height: 10.h,
                      width: 10.w,
                    ),
                    sizedBoxWidth(width: 16.w),
                    Expanded(
                      child: Text(
                        isSms
                            ? "We will send OTP to your mobile number"
                            : "We will send OTP to your WhatsApp number",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Helper(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 12.sp,
                              color: greyDart2,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              sizedBoxHeight(height: 24),
              Text(
                "RECEIVE OTP ON",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: primaryText80.withValues(alpha: 0.80),
                    ),
              ),
              sizedBoxHeight(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      borderColor: isSms ? primaryColor : greyLight6,
                      radius: 12,
                      onTap: () {
                        setState(() {
                          isSms = true;
                        });
                      },
                      type: isSms ? ButtonType.primary : ButtonType.secondary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message_outlined,
                              size: 14, color: isSms ? white : black),
                          sizedBoxWidth(width: 10),
                          Text(
                            "SMS",
                            style:
                                Helper(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14,
                                      color: isSms ? white : greyDart2,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  sizedBoxWidth(width: 8),
                  Expanded(
                    child: CustomButton(
                      borderColor: isSms ? greyLight6 : primaryColor,
                      radius: 12,
                      type: isSms ? ButtonType.secondary : ButtonType.primary,
                      onTap: () {
                        setState(() {
                          isSms = false;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            Assets.svgsWhatsapp,
                            height: 16,
                            width: 16,
                            colorFilter: isSms
                                ? null
                                : ColorFilter.mode(white, BlendMode.srcIn),
                          ),
                          sizedBoxWidth(width: 10),
                          Text(
                            "Whatsapp",
                            style:
                                Helper(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 12,
                                      color: isSms ? greyDart2 : white,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          sizedBoxHeight(height: 24.h),
          Column(
            children: [
              GetBuilder<AuthController>(builder: (authController) {
                return CustomButton(
                  onTap: () {
                    _signIn(authController);
                  },
                  height: 50.h,
                  color: textBlue,
                  radius: 999,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isSms
                          ? Icon(Icons.message, color: white, size: 20.h)
                          : SvgPicture.asset(
                              Assets.svgsWhatsapp,
                              height: 20.h,
                              width: 20.w,
                              fit: BoxFit.contain,
                              colorFilter:
                                  ColorFilter.mode(white, BlendMode.srcIn),
                            ),
                      sizedBoxWidth(width: 12.w),
                      Text(
                        isSms ? "Send OTP on SMS" : "Send OTP on WhatsApp",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: Helper(context).textTheme.titleMedium?.copyWith(
                              fontSize: 14.sp,
                              color: white,
                            ),
                      ),
                    ],
                  ),
                );
              }),
              sizedBoxHeight(height: 14.h),
              CustomButton(
                borderColor: primaryColor,
                type: ButtonType.secondary,
                height: 50.h,
                radius: 999,
                onTap: () {
                  setState(() {
                    isEmailLogin = true;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline_rounded,
                        color: primaryColor, size: 20.sp),
                    sizedBoxWidth(width: 10.w),
                    Text(
                      "Login with email & password",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14.sp,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              sizedBoxHeight(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Do not have an account?",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16.sp,
                            color: greyText2,
                          ),
                    ),
                  ),
                  CustomButton(
                    type: ButtonType.tertiary,
                    onTap: () {
                      navigate(context: context, page: const RegisterScreen());
                    },
                    child: Text(
                      "Register",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16.sp,
                            color: primaryText1,
                          ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      );
    }),
  );
}
}
