import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/kyc_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/auth_screens/kyc/kyc_details_screen.dart';
import 'package:vlr/views/screens/auth_screens/kyc/widget/document_kyc_section.dart';
import 'package:vlr/views/screens/dashboard/dashboard_screen.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/all_category_home_screen.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "KYC Screen",
          style: Helper(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: GetBuilder<KycController>(
        initState: (state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.find<KycController>().getKycProfile();
          });
        },
        builder: (kycController) {
          bool isApproved =
              kycController.kycProfile?.status?.toLowerCase() == 'approved';

          if (kycController.isLoading && kycController.kycProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: AppConstants.screenPadding,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    navigate(context: context, page: const KycDetailsScreen());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: greyLight,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: greyLight2.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryText1.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_pin_outlined,
                              color: primaryText1),
                        ),
                        sizedBoxWidth(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Identity & Address Details",
                                style: Helper(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: blackText1,
                                    ),
                              ),
                              Text(
                                "Provide your personal and address information",
                                style: Helper(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: greyText2,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: greyText2),
                      ],
                    ),
                  ),
                ),
                sizedBoxHeight(height: 20.h),
                if (isApproved)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 12),
                              Text(
                                "KYC Approved",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (kycController.isLoading) {
                              return;
                            }

                            navigate(
                                context: context,
                                page: const AllCategoryHomeScreen());
                          },
                          child: Container(
                              height: 64.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  colors: [
                                    primaryText1,
                                    const Color(0xFF00338F),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: kycController.isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                      color: white,
                                    ))
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Explore All Category",
                                          style: Helper(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: white,
                                              ),
                                        ),
                                        sizedBoxWidth(width: 12.h),
                                        // SvgPicture.asset(Assets.sv`gsArrowForward)
                                      ],
                                    )),
                        ),
                        const Spacer(),
                      ],
                    ),
                  )
                else
                  const DocumentUpdateKycSection(),
                if (!isApproved) ...[
                  sizedBoxHeight(height: 40.h),
                  GestureDetector(
                    onTap: () {
                      kycController.submitKyc().then((value) {
                        if (value.isSuccess) {
                          showToast(message: value.message, typeCheck: true);
                          navigate(
                              context: context, page: const DashboardScreen());
                        } else {
                          showToast(message: value.message, typeCheck: false);
                        }
                      });
                    },
                    child: Container(
                        height: 64.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              primaryText1,
                              const Color(0xFF00338F),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: kycController.isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                color: white,
                              ))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Submit Verification",
                                    style: Helper(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: white,
                                        ),
                                  ),
                                  sizedBoxWidth(width: 12.h),
                                  // SvgPicture.asset(Assets.sv`gsArrowForward)
                                ],
                              )),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
