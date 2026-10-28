import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class GymHomeScreenGymWight extends StatelessWidget {
  final ListingModel listingModel;
  const GymHomeScreenGymWight({
    super.key,
    required this.listingModel,
  });

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
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
    final hasLandmark = listingModel.landmark != null && listingModel.landmark!.isNotEmpty;
    final hasOpeningTime = listingModel.openingTime != null && listingModel.openingTime!.isNotEmpty;
    final hasClosingTime = listingModel.closingTime != null && listingModel.closingTime!.isNotEmpty;
    final hasStartingPrice = listingModel.startingPrice != null && listingModel.startingPrice! > 0;
    final hasSecurityDeposit = listingModel.securityDeposit != null &&
        double.tryParse(listingModel.securityDeposit!) != null &&
        double.parse(listingModel.securityDeposit!) > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Section with overlay starting price
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomImage(
                  path: (listingModel.images?.isNotEmpty ?? false)
                      ? listingModel.images!.first.imagePath ??
                          listingModel.image ??
                          Assets.imagesGymBanner
                      : listingModel.image ?? Assets.imagesGymBanner,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Text(
                    listingModel.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (hasSecurityDeposit)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Deposit: ₹${listingModel.securityDeposit}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Title and Action Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listingModel.address ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Helper(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  color: greyText3,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 20,
                color: primaryColor,
              ),
            ],
          ),
          
          // Divider if we have landmark or timings
          if (hasLandmark || hasOpeningTime || hasClosingTime) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: Colors.grey.withValues(alpha: 0.1),
                height: 1,
              ),
            ),
          ],
          
          // Landmark and Timing Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLandmark)
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB400).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assistant_navigation,
                          size: 14,
                          color: Color(0xFFFFB400),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Landmark',
                              style: Helper(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: greyText3,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              listingModel.landmark!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Helper(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: blackText1,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (hasLandmark && (hasOpeningTime || hasClosingTime))
                const SizedBox(width: 16),
              if (hasOpeningTime || hasClosingTime)
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Timings',
                              style: Helper(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: greyText3,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${_formatTime(listingModel.openingTime)} - ${_formatTime(listingModel.closingTime)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Helper(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: blackText1,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
