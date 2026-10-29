import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/order_tracking_controller.dart';

class OrderTrackingMapView extends StatelessWidget {
  final OrderTrackingController controller;
  final bool isDark;
  final Color cardBg;

  const OrderTrackingMapView({
    super.key,
    required this.controller,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final model = controller.trackingData.value;
      final markers = controller.markers;
      final polylines = controller.polylines;

      final bool hasDriverCoord = model?.hasDriverCoordinates ?? false;
      final bool hasAnyCoordinates = (model?.hasDriverCoordinates ?? false) ||
          (model?.hasCustomerCoordinates ?? false) ||
          (model?.hasVendorCoordinates ?? false);

      final String status = model?.orderStatus ?? 'pending';

      final LatLng initialTarget = (hasDriverCoord
              ? model!.driverLocation!.toLatLng()
              : (model?.hasCustomerCoordinates ?? false)
                  ? model!.customerLocation!.toLatLng()
                  : (model?.hasVendorCoordinates ?? false)
                      ? model!.vendorLocation!.toLatLng()
                      : const LatLng(26.8467, 80.9462));

      return Container(
        height: 290,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE4E4ED),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 1. Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 14.5,
                ),
                markers: markers,
                polylines: polylines,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                onMapCreated: controller.onMapCreated,
              ),

              // 2. Top Status Overlay Badges
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Live tracking pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xCC1A1A24)
                            : const Color(0xE6FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C853),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasDriverCoord
                                ? "LIVE PARTNER LOCATION"
                                : (status == 'delivered'
                                    ? "ORDER DELIVERED"
                                    : "LIVE STATUS"),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Re-center Camera Button
                    Material(
                      color: isDark
                          ? const Color(0xCC1A1A24)
                          : const Color(0xE6FFFFFF),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: controller.fitMapToMarkers,
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Icon(
                            Icons.my_location_rounded,
                            size: 18,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Bottom Notice (when live driver location not yet active)
              if (!hasDriverCoord && status != 'delivered' && status != 'canceled')
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xEA242432)
                          : const Color(0xFAFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasAnyCoordinates
                                ? "Live partner location will update once out for delivery."
                                : "Live location is not available yet. Tracking will begin once partner is assigned.",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
