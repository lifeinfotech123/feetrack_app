// ignore_for_file: unused_import

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/data/api/api_checker.dart';
import 'package:vlr/services/appsflyer_service.dart';
import 'package:vlr/services/app_router.dart';
import 'package:vlr/views/screens/dashboard/dashboard_screen.dart';

import '../../../services/constants.dart';
import '../../../services/theme.dart';
import '../../base/common_button.dart';
import '../../base/custom_image.dart';
import '../../base/custom_toast.dart' hide ToastType;
import 'dart:async';

class OTPVerification extends StatefulWidget {
  final String phone;
  final String gmail;
  final bool isPhone;
  final bool callLoginApi;
  final bool callRegisterApi;
  final bool isSMS;
  const OTPVerification({
    super.key,
    required this.phone,
    required this.gmail,
    this.isPhone = false,
    this.callLoginApi = false,
    this.callRegisterApi = false,
    this.isSMS = true,
  });

  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  Timer? _resendTimer;
  int _resendSeconds = 120; // 5 minutes

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendSeconds = 120;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {
          _resendSeconds--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _otpVerificationFun(
      AuthController authController,
      ) async {
    log(" mobileOtpCodeController :${authController.mobileOtpCodeController.text}, emailOtpCodeController :${authController.emailOtpCodeController.text}");
    log(" check --1 isPhone :  ${widget.isPhone}");
    log(" check --1 callLoginApi :  ${widget.callLoginApi}");
    log(" check --1 callRegisterApi :  ${widget.callRegisterApi}");

    if ((widget.isPhone
        ? authController.mobileOtpCodeController
        : authController.emailOtpCodeController)
        .text
        .length !=
        6) {
      return showToast(message: 'Invalid Otp', toastType: ToastType.warning);
    }
    if (widget.callRegisterApi) {
      final inputReferral = authController.referralCodeController.text.trim();
      final lastRef = authController.lastUsedReferralCode?.trim() ?? '';

      authController
          .verifyMobileAndEmail(
          mobileOtp: authController.mobileOtpCodeController.text,
          emailOtp: authController.emailOtpCodeController.text)
          .then((value) async {
        if (value.isSuccess) {
          showToast(message: value.message, typeCheck: value.isSuccess);
          authController.updateFcmToken();

          String referralCode = inputReferral;
          if (referralCode.isEmpty) {
            referralCode = lastRef;
          }
          if (referralCode.isEmpty) {
            referralCode = authController.lastUsedReferralCode?.trim() ?? '';
          }
          if (referralCode.isEmpty) {
            referralCode = (await AppsFlyerService.getSavedReferralCode()) ?? '';
          }

          final pendingJobId = AppsFlyerService.getPendingJobId();

          // Rule 1: ONLY navigate to Job Detail if referral code was used in registration
          if (referralCode.isNotEmpty) {
            AppsFlyerService.onRegisterWithReferral(referralCode);

            // Navigate to Dashboard as base, then open Job Details
            navigate(
                context: context,
                isRemoveUntil: true,
                page: const DashboardScreen());

            Future.delayed(const Duration(milliseconds: 350), () {
              if (pendingJobId != null && pendingJobId > 0) {
                AppRouter.goToJob(pendingJobId, referralCode: referralCode);
              } else {
                AppRouter.goToJobByReferral(referralCode);
              }
            });
          } else {
            // Rule 2: If NO referral code was used in registration -> go to normal Dashboard
            AppsFlyerService.onNormalAuth();
            navigate(
                context: context,
                isRemoveUntil: true,
                page: const DashboardScreen());
          }
        } else {
          showToast(message: value.message, typeCheck: value.isSuccess);
        }
      });
      return;
    }
    if (widget.callLoginApi) {
      authController.loginOtpVerify().then((value) {
        if (value.isSuccess) {
          showToast(message: value.message, typeCheck: value.isSuccess);
          authController.updateFcmToken();
          // Rule 3: Normal login via phone + OTP -> ALWAYS go to normal Dashboard
          AppsFlyerService.onNormalAuth();

          navigate(
              context: context,
              isRemoveUntil: true,
              page: const DashboardScreen());
        } else {
          showToast(message: value.message, typeCheck: value.isSuccess);
        }
      });
      return;
    }

    navigate(
      context: context,
      page: OTPVerification(
        phone: authController.mobileNoController.text,
        gmail: authController.emailController.text,
        isPhone: false,
        callRegisterApi: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Verify Your ${widget.isPhone ? "Mobile" : "Gmail"}",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: blackText1,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "We have sent the verification to ${widget.isPhone ? "+91 ${widget.phone}" : widget.gmail} ",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(),
            ),
            widget.isPhone
                ? Text(
              "Change Phone Number?",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: primaryColor),
            )
                : const SizedBox(),
            const SizedBox(
              height: 40,
            ),
            GetBuilder<AuthController>(builder: (authController) {
              return Center(
                child: Pinput(
                  controller: widget.isPhone
                      ? authController.mobileOtpCodeController
                      : authController.emailOtpCodeController,
                  length: 6,
                  autofocus: true,
                  onCompleted: (_) {
                    _otpVerificationFun(authController);
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  defaultPinTheme: PinTheme(
                    width: 45,
                    height: 55,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 45,
                    height: 55,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 45,
                    height: 55,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              );
            }),
            GetBuilder<AuthController>(builder: (authController) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const Text("Didn’t you received any code?"),
                    sizedBoxHeight(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Resend a new code."),
                        const SizedBox(width: 6),
                        _resendSeconds == 0
                            ? CustomButton(
                          isLoading: authController.isLoading,
                          height: 40,
                          radius: 999,
                          onTap: () {
                            if (widget.callLoginApi) {
                              authController
                                  .postLoginResendOtpVerify(
                                  isSMS: widget.isSMS)
                                  .then((value) {
                                if (value.isSuccess) {
                                  showToast(
                                      message: value.message,
                                      typeCheck: value.isSuccess);
                                  _startResendTimer();
                                } else {
                                  showToast(
                                      message: value.message,
                                      typeCheck: value.isSuccess);
                                }
                              });
                            } else {
                              authController
                                  .resendVerifyMobileAndEmail()
                                  .then((value) {
                                if (value.isSuccess) {
                                  showToast(
                                      message: value.message,
                                      typeCheck: value.isSuccess);
                                  _startResendTimer();
                                } else {
                                  showToast(
                                      message: value.message,
                                      typeCheck: value.isSuccess);
                                }
                              });
                            }
                          },
                          child: Text(
                            "Resend OTP",
                            style: Helper(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontSize: 12,
                              color: white,
                              letterSpacing: 1,
                            ),
                          ),
                        )
                            : Text(
                          "Available in ${_formatTime(_resendSeconds)}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            })
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding, vertical: 15),
          child: SizedBox(
            height: 50,
            child: GetBuilder<AuthController>(builder: (authController) {
              return CustomButton(
                radius: 6,
                elevation: 0,
                color: primaryText1,
                onTap: () {
                  _otpVerificationFun(authController);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verify & Proceed',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    sizedBoxWidth(width: 20),
                    Icon(
                      Icons.arrow_forward,
                      color: white,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}