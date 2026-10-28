import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vlr/controllers/basic_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class RowGYMInfoWidget extends StatelessWidget {
  final RowGYMInforWidgetModel rowGYMInforWidgetModel;

  const RowGYMInfoWidget({
    super.key,
    required this.rowGYMInforWidgetModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      color: greyLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            rowGYMInforWidgetModel.icon,
            height: 15,
            width: 15,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 4),
          Text(
            rowGYMInforWidgetModel.head,
            textAlign: TextAlign.center,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: blackText1,
                ),
          ),
        ],
      ),
    );
  }
}

class RowGYMInforWidgetModel {
  final String icon;
  final String head;

  RowGYMInforWidgetModel({required this.icon, required this.head});
}

String _formatRowTime(String? timeStr) {
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

List<RowGYMInforWidgetModel> rowGYMInforWidgetModelList(
        {required HomeController homeController}) {
  final listing = homeController.selectListingModel;
  final opening = _formatRowTime(listing?.openingTime);
  final closing = _formatRowTime(listing?.closingTime);
  final timings = (opening.isNotEmpty && closing.isNotEmpty)
      ? "$opening - $closing"
      : "Not Available";

  final address = (listing?.landmark != null && listing!.landmark!.isNotEmpty)
      ? listing.landmark!
      : (listing?.address != null && listing!.address!.isNotEmpty)
          ? listing.address!
          : "Not Available";

  final distanceStr = listing?.effectiveDistanceKm != null
      ? "${listing?.effectiveDistanceKm!.toStringAsFixed(1)} KM"
      : "0.0 KM";

  return [
    RowGYMInforWidgetModel(
      icon: Assets.svgsWatch,
      head: timings,
    ),
    RowGYMInforWidgetModel(
      icon: Assets.svgsLocation,
      head: address,
    ),
    RowGYMInforWidgetModel(
      icon: Assets.svgsDiection,
      head: distanceStr,
    ),
  ];
}
