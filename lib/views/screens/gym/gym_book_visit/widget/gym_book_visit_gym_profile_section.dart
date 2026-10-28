import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';

class GYMBookingVisitGYMProfile extends StatelessWidget {
  const GYMBookingVisitGYMProfile({super.key});

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    try {
      final clean = timeStr.trim();
      if (clean.toUpperCase().contains('AM') ||
          clean.toUpperCase().contains('PM')) {
        return clean;
      }
      final parts = clean.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final formattedMinute = minute.toString().padLeft(2, '0');
        return '$formattedHour:$formattedMinute $ampm';
      }
    } catch (_) {}
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final listing = homeController.selectListingModel;
      final category = listing?.category;

      final String gymImage = (listing?.images?.isNotEmpty == true &&
              listing!.images![0].imagePath != null &&
              listing.images![0].imagePath!.isNotEmpty)
          ? listing.images![0].imagePath!
          : (listing?.image?.isNotEmpty == true ? listing!.image! : "");

      final opening = _formatTime(listing?.openingTime);
      final closing = _formatTime(listing?.closingTime);

      final timings = (opening.isNotEmpty && closing.isNotEmpty)
          ? "$opening – $closing"
          : (opening.isNotEmpty
              ? "Opens at $opening"
              : "Working hours available on visit");

      final double avgRating = double.tryParse(listing?.reviewsAvgRating ??
              listing?.rating?.average?.toString() ??
              "0") ??
          0.0;

      final int reviewsCount = int.tryParse(listing?.reviewsCount ??
              listing?.rating?.count?.toString() ??
              "0") ??
          0;

      final String titleText = listing?.title?.isNotEmpty == true
          ? listing!.title!
          : "Fitness Sanctuary";

      final String addressText = listing?.address?.isNotEmpty == true
          ? listing!.address!
          : (listing?.landmark?.isNotEmpty == true
              ? listing!.landmark!
              : "Location details available upon booking");

      final String genderText = listing?.genderType?.isNotEmpty == true
          ? listing!.genderType!
          : "Unisex";

      final String? phoneNumber = listing?.phone?.toString().trim();
      final String? whatsappNumber =
          listing?.links?['whatsapp']?.toString().trim() ?? phoneNumber;

      return Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Image and Basic Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CustomImage(
                      path: gymImage,
                      height: 85,
                      width: 85,
                      fit: BoxFit.cover,
                    ),
                  ),
                  sizedBoxWidth(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                category?.name ?? "Gym",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),

                        sizedBoxHeight(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            genderText,
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        if (listing?.isVerified == true) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.blue,
                            size: 14,
                          ),
                        ],
                        sizedBoxHeight(height: 6),
                        // Title
                        Text(
                          titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Helper(context).textTheme.titleLarge?.copyWith(
                                color: blackText1,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                        ),
                        sizedBoxHeight(height: 4),
                        // Rating & Reviews
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 16),
                            sizedBoxWidth(width: 3),
                            Text(
                              avgRating > 0
                                  ? avgRating.toStringAsFixed(1)
                                  : "4.5",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: blackText1,
                                fontSize: 13,
                              ),
                            ),
                            sizedBoxWidth(width: 6),
                            Text(
                              reviewsCount > 0
                                  ? "($reviewsCount Reviews)"
                                  : "(Verified Sanctuary)",
                              style: TextStyle(
                                color: greyText2,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF0F2F5)),

            // Details Section (Timings & Location)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    iconColor: primaryColor,
                    text: timings,
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  sizedBoxHeight(height: 8),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.grey.shade600,
                    text: addressText,
                    textStyle: TextStyle(
                      fontSize: 12,
                      color: greyText2,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: const Color(0xFFF0F2F5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onTap: () {
                        if (phoneNumber != null && phoneNumber.isNotEmpty) {
                          LaunchHelper.callUs(number: phoneNumber);
                        } else {
                          showToast(
                            message: "Gym contact number is not available",
                            toastType: ToastType.info,
                          );
                        }
                      },
                      height: 40,
                      radius: 10,
                      type: ButtonType.secondary,
                      borderColor: primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.call_rounded,
                              color: primaryColor, size: 16),
                          sizedBoxWidth(width: 4),
                          const Text(
                            "Call",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  sizedBoxWidth(width: 8),
                  Expanded(
                    child: CustomButton(
                      onTap: () {
                        final lat = listing?.lat;
                        final lng = listing?.lng;
                        if (lat != null &&
                            lng != null &&
                            lat.toString().isNotEmpty &&
                            lng.toString().isNotEmpty) {
                          LaunchHelper.openGoogleMap(
                            lat: lat.toString(),
                            lng: lng.toString(),
                          );
                        } else {
                          showToast(
                            message: "Gym location map is not available",
                            toastType: ToastType.info,
                          );
                        }
                      },
                      height: 40,
                      radius: 10,
                      type: ButtonType.secondary,
                      borderColor: Colors.blue.shade600,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined,
                              color: Colors.blue.shade600, size: 16),
                          sizedBoxWidth(width: 4),
                          Text(
                            "Map",
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  sizedBoxWidth(width: 8),
                  Expanded(
                    child: CustomButton(
                      onTap: () {
                        if (whatsappNumber != null &&
                            whatsappNumber.isNotEmpty) {
                          LaunchHelper.launchWhatsApp(phone: whatsappNumber);
                        } else {
                          showToast(
                            message: "WhatsApp contact is not available",
                            toastType: ToastType.info,
                          );
                        }
                      },
                      height: 40,
                      radius: 10,
                      color: greenDark,
                      borderColor: greenDark,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_rounded,
                              color: white, size: 16),
                          sizedBoxWidth(width: 4),
                          Text(
                            "Help",
                            style: TextStyle(
                              color: white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final TextStyle textStyle;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        sizedBoxWidth(width: 8),
        Expanded(
          child: Text(
            text,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
