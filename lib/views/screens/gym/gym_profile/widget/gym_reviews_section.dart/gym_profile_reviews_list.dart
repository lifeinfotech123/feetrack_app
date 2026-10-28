import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_stars/easy_stars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/basic_controller.dart';
import 'package:vlr/data/models/reviews_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class GYMProfileReviewsList extends StatelessWidget {
  const GYMProfileReviewsList({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasicController>(builder: (basicController) {

      if (basicController.reviewsList.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No Reviews Found"),
          ),
        );
      }
      return CarouselSlider(
        items: basicController.reviewsList.map((review) {
          return ReviewThinCard(reviewsModel: review);
        }).toList(),
        options: CarouselOptions(
          height: 150,
          viewportFraction: 0.9,
          autoPlay: true,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
          autoPlayInterval: const Duration(seconds: 4),
        ),
      );
    });
  }
}

class ReviewThinCard extends StatelessWidget {
  final ReviewsModel reviewsModel;
  const ReviewThinCard({super.key, required this.reviewsModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: greyLight2.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CustomImage(
                path: reviewsModel.avatar ?? "",
                height: 44,
                width: 44,
                isProfile: true,
                radius: 999,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewsModel.customerName ?? "Anonymous",
                      style: Helper(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: blackText1,
                            letterSpacing: 0.1,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reviewsModel.createdAt ?? "",
                      style: Helper(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: greyText3,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: greenDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      "${reviewsModel.rating ?? 0}",
                      style: Helper(context).textTheme.bodySmall?.copyWith(
                            color: greenDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.star_rounded, color: greenDark, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reviewsModel.comment ?? "",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: greyText2,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}

