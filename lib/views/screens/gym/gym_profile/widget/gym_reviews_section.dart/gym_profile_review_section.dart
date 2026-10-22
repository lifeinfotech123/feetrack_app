import 'package:easy_stars/easy_stars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/basic_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_reviews_section.dart/gym_profile_reviews_list.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_reviews_section.dart/row_reviews_progress_bar_widget.dart';
import 'package:vlr/views/screens/gym/gym_reviews/gym_reviews_screen.dart';
import 'package:vlr/views/widget/text_box/app_text_box.dart';

class GYMProfileReviewSection extends StatefulWidget {
  const GYMProfileReviewSection({
    super.key,
  });

  @override
  State<GYMProfileReviewSection> createState() =>
      _GYMProfileReviewSectionState();
}

class _GYMProfileReviewSectionState extends State<GYMProfileReviewSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final basicController = Get.find<BasicController>();

      basicController.resetReview();
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasicController>(builder: (basicController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedBoxHeight(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Customer Reviews",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: blackText1,
                    ),
              ),
              GetBuilder<HomeController>(builder: (homeController) {
                return TextButton(
                  onPressed: () {
                    final gymId = homeController.selectListingModel?.id;
                    final gymTitle = homeController.selectListingModel?.title;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GymReviewsScreen(
                          gymId: gymId,
                          gymTitle: gymTitle,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF002060),
                    ),
                  ),
                );
              }),
            ],
          ),
          sizedBoxHeight(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              color: white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "OVERALL PERFORMANCE",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: greyText3,
                        letterSpacing: 2.4,
                      ),
                ),
                sizedBoxHeight(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: basicController.averageRating.toString(),
                          style: Helper(context).textTheme.titleSmall?.copyWith(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: primaryText1,
                              ),
                          children: [
                            TextSpan(
                              text: " /5",
                              style: Helper(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: greyText3,
                                  ),
                            ),
                          ]),
                    ),
                  ],
                ),
                sizedBoxHeight(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EasyStarsRating(
                      initialRating: basicController.averageRating,
                      allowHalfRating: true,
                      filledColor: greenDark,
                    ),
                  ],
                ),
                sizedBoxHeight(height: 16),
                Text(
                  "Based on ${basicController.totalReviews.toString()} reviews",
                  style: Helper(context).textTheme.titleSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: greyText2,
                      ),
                ),
                sizedBoxHeight(height: 38),
                ...rowReviewProgressBarModelList.map((model) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: RowReviewProgressBar(
                          rowReviewProgressBarModel: model),
                    )),
                sizedBoxHeight(height: 20), // Adjusted space after the list items
                sizedBoxHeight(height: 32),
                Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                      spreadRadius: -4,
                      color: black.withValues(alpha: 0.010),
                    ),
                    BoxShadow(
                      offset: const Offset(0, 10),
                      blurRadius: 15,
                      spreadRadius: -3,
                      color: black.withValues(alpha: 0.010),
                    ),
                  ]),
                  child: CustomButton(
                    onTap: () {
                      GYMReviewPopUpWidget(context, _formKey);
                    },
                    color: const Color(0xFF022C7F),
                    borderColor: const Color(0xFF022C7F),
                    height: 56,
                    radius: 999,
                    child: Text(
                      "Leave a Review",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: white,
                          ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const GYMProfileReviewsList()
        ],
      );
    });
  }

  Future<dynamic> GYMReviewPopUpWidget(
      BuildContext context, GlobalKey<FormState> formKey) {
    return showDialog(
      context: context,
      builder: (context) {
        return GetBuilder<BasicController>(builder: (basicController) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: white,
                  border: Border.all(
                    width: 1,
                    color: greyLight2.withValues(alpha: 0.20),
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Rate Your Experience",
                      style: Helper(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: blackText1,
                          ),
                    ),
                    sizedBoxHeight(height: 8),
                    Text(
                      "How was your session at Apex Performance Lab today?",
                      textAlign: TextAlign.center,
                      style: Helper(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: greyText2,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: RatingBar.builder(
                        initialRating: basicController.selectRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 30,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: greenDark,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {});
                          basicController.selectRating = rating;
                          basicController.update();
                        },
                      ),
                    ),
                    Form(
                      key: formKey,
                      child: AppTextFieldWithHeading(
                        controller: basicController.reviewController,
                        hindText:
                            "Tell us what you liked about your workout...",
                        maxLines: 6,
                        bgColor: greyLight3,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Write a review";
                          }
                          return null;
                        },
                      ),
                    ),
                    sizedBoxHeight(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                            spreadRadius: -4,
                            color: primaryText1.withValues(alpha: 0.20),
                          ),
                          BoxShadow(
                            offset: const Offset(0, 10),
                            blurRadius: 15,
                            spreadRadius: -3,
                            color: primaryText1.withValues(alpha: 0.20),
                          )
                        ],
                      ),
                      child:
                          GetBuilder<HomeController>(builder: (homeController) {
                        return CustomButton(
                          isLoading: basicController.isLoading,
                          onTap: () {
                            if (formKey.currentState?.validate() ?? false) {
                              basicController
                                  .submitReviewsById(
                                      id: homeController.selectListingModel?.id ?? "")
                                  .then((value) {
                                if (value.isSuccess) {
                                  showToast(
                                      message: value.message,
                                      typeCheck: value.isSuccess);

                                  pop(context);
                                  basicController.resetReview();
                                  basicController
                                      .fetchListingReviewsByIdPagination(
                                          id: homeController
                                                  .selectListingModel?.id ??
                                              "");
                                } else {
                                  showToast(
                                      message: value.message,
                                      typeCheck: value.isSuccess);
                                  pop(context);
                                }
                              });
                            }
                          },
                          height: 56,
                          radius: 999,
                          color: primaryText1,
                          borderColor: primaryText1,
                          child: Text(
                            "Submit Review",
                            style:
                                Helper(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: white,
                                    ),
                          ),
                        );
                      }),
                    ),
                    sizedBoxHeight(height: 12),
                    CustomButton(
                      type: ButtonType.tertiary,
                      onTap: () {
                        pop(context);
                        basicController.resetReview();
                      },
                      child: Text(
                        "Maybe Later",
                        style: Helper(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: primaryText1,
                            ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
