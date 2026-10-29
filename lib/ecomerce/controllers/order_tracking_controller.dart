import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../models/order_model.dart';
import '../models/order_tracking_model.dart';
import 'orders_controller.dart';

class OrderTrackingController extends GetxController {
  final int orderId;
  final String? storeDomain;
  final OrderListItemModel? initialOrder;
  final Map<String, dynamic>? initialData;

  OrderTrackingController({
    required this.orderId,
    this.storeDomain,
    this.initialOrder,
    this.initialData,
  });

  late final OrdersController _ordersController;
  GoogleMapController? mapController;
  Timer? _pollingTimer;

  final Rx<OrderTrackingModel?> trackingData = Rx<OrderTrackingModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxString etaDisplayText = ''.obs;

  bool _hasInitialFitted = false;

  String? get effectiveStore =>
      storeDomain ??
      initialOrder?.domain ??
      initialData?['domain']?.toString();

  @override
  void onInit() {
    super.onInit();
    _ordersController = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    // 1. If initialData or initialOrder exists, initialize immediately to avoid blank screen
    if (initialData != null) {
      trackingData.value = OrderTrackingModel.fromRawData(
        orderId: orderId,
        rawData: initialData!,
        initialOrder: initialOrder,
      );
    }

    // 2. Fetch fresh order tracking details from backend
    loadTrackingDetails();

    // 3. Periodic polling every 15 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      refreshSilently();
    });
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  /// Initial / Manual Refresh
  Future<void> loadTrackingDetails() async {
    if (trackingData.value == null) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final detail = await _ordersController.fetchOrderDetails(
        orderId,
        storeDomain: effectiveStore,
      );

      if (detail != null) {
        final model = OrderTrackingModel.fromOrderDetail(
          detail: detail,
          initialOrder: initialOrder,
        );
        trackingData.value = model;
        _updateMapData(model);
      } else if (trackingData.value == null && initialData != null) {
        final model = OrderTrackingModel.fromRawData(
          orderId: orderId,
          rawData: initialData!,
          initialOrder: initialOrder,
        );
        trackingData.value = model;
        _updateMapData(model);
      }
    } catch (e) {
      debugPrint("OrderTrackingController loadTrackingDetails error: $e");
      errorMessage.value = "Failed to load tracking: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// Silent background polling without showing progress indicator
  Future<void> refreshSilently() async {
    try {
      final detail = await _ordersController.fetchOrderDetails(
        orderId,
        storeDomain: effectiveStore,
      );

      if (detail != null) {
        final model = OrderTrackingModel.fromOrderDetail(
          detail: detail,
          initialOrder: initialOrder,
        );
        trackingData.value = model;
        _updateMapData(model);
      }
    } catch (e) {
      debugPrint("OrderTrackingController silent refresh error: $e");
    }
  }

  /// Map created callback
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (!_hasInitialFitted) {
      _hasInitialFitted = true;
      Future.delayed(const Duration(milliseconds: 350), () {
        fitMapToMarkers();
      });
    }
  }

  /// Update Markers, Polylines, and ETA from updated model
  void _updateMapData(OrderTrackingModel model) {
    final Set<Marker> newMarkers = {};
    final Set<Polyline> newPolylines = {};

    // 1. Destination Marker
    if (model.hasCustomerCoordinates) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: model.customerLocation!.toLatLng(),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          infoWindow: InfoWindow(
            title: model.customerLocation!.title ?? "Delivery Destination",
            snippet: model.customerLocation!.snippet ?? "Your Address",
          ),
        ),
      );
    }

    // 2. Vendor Marker
    if (model.hasVendorCoordinates) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('vendor'),
          position: model.vendorLocation!.toLatLng(),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: model.vendorLocation!.title ?? model.vendorName,
            snippet: model.vendorLocation!.snippet ?? "Pickup Location",
          ),
        ),
      );
    }

    // 3. Driver / Delivery Partner Marker
    if (model.hasDriverCoordinates) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('delivery_partner'),
          position: model.driverLocation!.toLatLng(),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: model.deliveryPartner?.name ?? "Delivery Partner",
            snippet: "Current Location",
          ),
        ),
      );
    }

    // 4. Polylines
    if (model.hasDriverCoordinates && model.hasCustomerCoordinates) {
      newPolylines.add(
        Polyline(
          polylineId: const PolylineId('driver_to_customer'),
          points: [
            model.driverLocation!.toLatLng(),
            model.customerLocation!.toLatLng(),
          ],
          color: primaryColor,
          width: 4,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    } else if (model.hasVendorCoordinates && model.hasCustomerCoordinates) {
      newPolylines.add(
        Polyline(
          polylineId: const PolylineId('vendor_to_customer'),
          points: [
            model.vendorLocation!.toLatLng(),
            model.customerLocation!.toLatLng(),
          ],
          color: primaryColor.withValues(alpha: 0.8),
          width: 3,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    markers.assignAll(newMarkers);
    polylines.assignAll(newPolylines);

    // 5. ETA Calculation
    if (model.eta != null && model.eta!.isNotEmpty) {
      etaDisplayText.value = model.eta!;
    } else if (model.distanceToCustomerKm != null) {
      final double dist = model.distanceToCustomerKm!;
      final int minutes = (dist / 25 * 60).round().clamp(5, 120);
      etaDisplayText.value = "$minutes mins (${dist.toStringAsFixed(1)} km away)";
    } else {
      etaDisplayText.value = "25 - 35 mins";
    }

    fitMapToMarkers();
  }

  /// Automatically fit map camera to display all markers
  void fitMapToMarkers() {
    if (mapController == null) return;
    final model = trackingData.value;
    if (model == null) return;

    final List<LatLng> points = [];
    if (model.hasDriverCoordinates) points.add(model.driverLocation!.toLatLng());
    if (model.hasCustomerCoordinates) {
      points.add(model.customerLocation!.toLatLng());
    }
    if (model.hasVendorCoordinates) points.add(model.vendorLocation!.toLatLng());

    if (points.isEmpty) return;

    if (points.length == 1) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: points.first, zoom: 15.5),
        ),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50.0),
    );
  }

  /// Launch phone call
  Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri callUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cannot dial phone: $cleanPhone"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not launch call: $e"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Copy delivery code to clipboard
  void copyDeliveryCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Delivery code copied to clipboard"),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
