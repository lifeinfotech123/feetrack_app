import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'order_model.dart';

/// Location coordinates with label
class TrackingLocation {
  final double latitude;
  final double longitude;
  final String? title;
  final String? snippet;

  const TrackingLocation({
    required this.latitude,
    required this.longitude,
    this.title,
    this.snippet,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  bool get isValid => latitude != 0.0 && longitude != 0.0;
}

/// Delivery rider / partner info
class DeliveryPartnerInfo {
  final String name;
  final String? phone;
  final String? avatar;
  final String rating;
  final bool isAssigned;

  const DeliveryPartnerInfo({
    required this.name,
    this.phone,
    this.avatar,
    this.rating = '4.8',
    this.isAssigned = false,
  });
}

/// Address details for tracking
class TrackingAddressInfo {
  final String contactName;
  final String? phone;
  final String fullAddress;
  final String? city;
  final String? zip;
  final String? note;

  const TrackingAddressInfo({
    required this.contactName,
    this.phone,
    required this.fullAddress,
    this.city,
    this.zip,
    this.note,
  });

  String get displayAddress {
    final buffer = StringBuffer(fullAddress);
    if (city != null && city!.isNotEmpty) buffer.write(', $city');
    if (zip != null && zip!.isNotEmpty) buffer.write(' - $zip');
    return buffer.toString();
  }
}

/// Order item in tracking summary
class TrackingOrderItem {
  final String name;
  final int quantity;
  final double lineTotal;

  const TrackingOrderItem({
    required this.name,
    required this.quantity,
    required this.lineTotal,
  });
}

/// Single step in the timeline
class TrackingStepItem {
  final String title;
  final String description;
  final bool isCompleted;
  final bool isActive;
  final String? timestamp;

  const TrackingStepItem({
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isActive,
    this.timestamp,
  });
}

/// Comprehensive Tracking Model for all order types
class OrderTrackingModel {
  final int orderId;
  final String orderStatus;
  final bool isFood;
  final String vendorName;
  final String? deliveryCode;
  final String? eta;
  final TrackingLocation? customerLocation;
  final TrackingLocation? vendorLocation;
  final TrackingLocation? driverLocation;
  final DeliveryPartnerInfo? deliveryPartner;
  final TrackingAddressInfo? shippingAddress;
  final List<TrackingStepItem> timelineSteps;
  final List<TrackingOrderItem> items;
  final double totalAmount;
  final int itemsCount;
  final String? orderNote;

  const OrderTrackingModel({
    required this.orderId,
    required this.orderStatus,
    required this.isFood,
    required this.vendorName,
    this.deliveryCode,
    this.eta,
    this.customerLocation,
    this.vendorLocation,
    this.driverLocation,
    this.deliveryPartner,
    this.shippingAddress,
    required this.timelineSteps,
    required this.items,
    required this.totalAmount,
    required this.itemsCount,
    this.orderNote,
  });

  bool get isDelivered => orderStatus.toLowerCase() == 'delivered';
  bool get isCancelled =>
      orderStatus.toLowerCase() == 'canceled' ||
      orderStatus.toLowerCase() == 'cancelled';
  bool get isOutForDelivery =>
      orderStatus.toLowerCase() == 'out_for_delivery' ||
      orderStatus.toLowerCase() == 'shipped' ||
      orderStatus.toLowerCase() == 'delivering';
  bool get isProcessing =>
      orderStatus.toLowerCase() == 'processing' ||
      orderStatus.toLowerCase() == 'confirmed';

  bool get hasDriverCoordinates =>
      driverLocation != null && driverLocation!.isValid;
  bool get hasCustomerCoordinates =>
      customerLocation != null && customerLocation!.isValid;
  bool get hasVendorCoordinates =>
      vendorLocation != null && vendorLocation!.isValid;

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.trim());
    return null;
  }

  // Haversine distance in km between driver and customer
  double? get distanceToCustomerKm {
    if (!hasDriverCoordinates || !hasCustomerCoordinates) return null;
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        cos((customerLocation!.latitude - driverLocation!.latitude) * p) / 2 +
        cos(driverLocation!.latitude * p) *
            cos(customerLocation!.latitude * p) *
            (1 -
                cos((customerLocation!.longitude -
                        driverLocation!.longitude) *
                    p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  /// Factory to construct from OrderDetailsDataModel
  factory OrderTrackingModel.fromOrderDetail({
    required OrderDetailsDataModel detail,
    OrderListItemModel? initialOrder,
  }) {
    final status = detail.orderStatus.toLowerCase();
    final bool isFood = detail.isFood || (initialOrder?.isFood ?? false);

    // Locations
    TrackingLocation? customerLoc;
    if (detail.customerLat != null && detail.customerLng != null) {
      customerLoc = TrackingLocation(
        latitude: detail.customerLat!,
        longitude: detail.customerLng!,
        title: "Delivery Destination",
        snippet: detail.shippingAddress?['address']?.toString() ?? "Your Address",
      );
    }

    TrackingLocation? vendorLoc;
    if (detail.vendorLat != null && detail.vendorLng != null) {
      vendorLoc = TrackingLocation(
        latitude: detail.vendorLat!,
        longitude: detail.vendorLng!,
        title: detail.vendor,
        snippet: detail.vendorDetails?['address']?.toString() ?? "Pickup Location",
      );
    }

    TrackingLocation? driverLoc;
    if (detail.deliveryPartnerLat != null && detail.deliveryPartnerLng != null) {
      driverLoc = TrackingLocation(
        latitude: detail.deliveryPartnerLat!,
        longitude: detail.deliveryPartnerLng!,
        title: detail.deliveryPartnerName ?? "Delivery Partner",
        snippet: "Current Location",
      );
    }

    // Delivery Partner
    DeliveryPartnerInfo? partnerInfo;
    if (detail.deliveryPartnerName != null &&
        detail.deliveryPartnerName!.isNotEmpty) {
      partnerInfo = DeliveryPartnerInfo(
        name: detail.deliveryPartnerName!,
        phone: detail.deliveryPartnerPhone,
        avatar: detail.deliveryPartnerImage,
        rating: detail.deliveryPartnerRating ?? '4.8',
        isAssigned: true,
      );
    } else {
      partnerInfo = const DeliveryPartnerInfo(
        name: "Delivery Partner",
        isAssigned: false,
      );
    }

    // Address
    TrackingAddressInfo? addressInfo;
    if (detail.shippingAddress != null) {
      final addr = detail.shippingAddress!;
      addressInfo = TrackingAddressInfo(
        contactName: addr['contact_person_name']?.toString() ??
            addr['name']?.toString() ??
            'Recipient',
        phone: addr['phone']?.toString(),
        fullAddress: addr['address']?.toString() ??
            addr['address_line_1']?.toString() ??
            'Delivery Address',
        city: addr['city']?.toString(),
        zip: addr['zip']?.toString() ?? addr['pincode']?.toString(),
        note: detail.orderNote,
      );
    }

    // Items
    final List<TrackingOrderItem> items = detail.items
        .map((it) => TrackingOrderItem(
              name: it.name,
              quantity: it.quantity,
              lineTotal: it.lineTotal,
            ))
        .toList();

    // Timeline Steps
    final steps = _buildTimelineSteps(status: status, isFood: isFood);

    return OrderTrackingModel(
      orderId: detail.orderId,
      orderStatus: status,
      isFood: isFood,
      vendorName: detail.vendor.isNotEmpty ? detail.vendor : 'Store',
      deliveryCode: detail.verificationCode,
      eta: detail.eta,
      customerLocation: customerLoc,
      vendorLocation: vendorLoc,
      driverLocation: driverLoc,
      deliveryPartner: partnerInfo,
      shippingAddress: addressInfo,
      timelineSteps: steps,
      items: items,
      totalAmount: detail.orderAmount,
      itemsCount: items.isNotEmpty ? items.length : 1,
      orderNote: detail.orderNote,
    );
  }

  /// Factory from raw map / initial args
  factory OrderTrackingModel.fromRawData({
    required int orderId,
    required Map<String, dynamic> rawData,
    OrderListItemModel? initialOrder,
  }) {
    final status = (rawData['order_status'] ??
            rawData['status'] ??
            initialOrder?.orderStatus ??
            'pending')
        .toString()
        .toLowerCase();

    final domain = (rawData['domain'] ?? initialOrder?.domain ?? '').toString();
    final bool isFood = domain.toLowerCase().contains('food') ||
        (initialOrder?.isFood ?? false);

    final vendor = rawData['vendor']?.toString() ??
        rawData['vendor_details']?['shop_name']?.toString() ??
        initialOrder?.vendor ??
        'Store';

    final deliveryCode = rawData['verification_code']?.toString();
    final eta = rawData['eta']?.toString() ??
        rawData['estimated_delivery_time']?.toString();

    // Address
    TrackingAddressInfo? addressInfo;
    final addrMap = rawData['shipping_address'] is Map<String, dynamic>
        ? rawData['shipping_address'] as Map<String, dynamic>
        : null;

    if (addrMap != null) {
      addressInfo = TrackingAddressInfo(
        contactName: addrMap['contact_person_name']?.toString() ??
            addrMap['name']?.toString() ??
            'Recipient',
        phone: addrMap['phone']?.toString(),
        fullAddress: addrMap['address']?.toString() ?? 'Delivery Address',
        city: addrMap['city']?.toString(),
        zip: addrMap['zip']?.toString(),
        note: rawData['order_note']?.toString(),
      );
    }

    // Items
    final List<TrackingOrderItem> items = [];
    if (rawData['items'] is List) {
      for (final it in rawData['items']) {
        if (it is Map<String, dynamic>) {
          items.add(TrackingOrderItem(
            name: it['name']?.toString() ?? 'Item',
            quantity: (it['quantity'] as num?)?.toInt() ?? 1,
            lineTotal: (it['line_total'] as num?)?.toDouble() ??
                (it['price'] as num?)?.toDouble() ??
                0.0,
          ));
        }
      }
    }

    // Coordinates extraction from raw data
    TrackingLocation? customerLoc;
    final cLat = _parseDouble(addrMap?['latitude'] ?? addrMap?['lat']);
    final cLng = _parseDouble(addrMap?['longitude'] ?? addrMap?['lng']);
    if (cLat != null && cLng != null && cLat != 0.0) {
      customerLoc = TrackingLocation(
        latitude: cLat,
        longitude: cLng,
        title: "Delivery Destination",
        snippet: addrMap?['address']?.toString() ?? "Your Address",
      );
    }

    TrackingLocation? vendorLoc;
    final vMap = rawData['vendor_details'] is Map<String, dynamic>
        ? rawData['vendor_details'] as Map<String, dynamic>
        : null;
    final vLat = _parseDouble(vMap?['latitude'] ?? vMap?['lat']);
    final vLng = _parseDouble(vMap?['longitude'] ?? vMap?['lng']);
    if (vLat != null && vLng != null && vLat != 0.0) {
      vendorLoc = TrackingLocation(
        latitude: vLat,
        longitude: vLng,
        title: vendor,
        snippet: vMap?['address']?.toString() ?? "Pickup Location",
      );
    }

    TrackingLocation? driverLoc;
    final dynamic dmRaw = rawData['delivery_man'] ??
        rawData['delivery_person'] ??
        rawData['delivery_partner'] ??
        rawData['delivery_boy'] ??
        rawData['driver'];
    final dMap = dmRaw is Map<String, dynamic> ? dmRaw : null;
    final dLat = _parseDouble(
        dMap?['latitude'] ?? dMap?['lat'] ?? rawData['delivery_man_lat']);
    final dLng = _parseDouble(
        dMap?['longitude'] ?? dMap?['lng'] ?? rawData['delivery_man_lng']);
    if (dLat != null && dLng != null && dLat != 0.0) {
      driverLoc = TrackingLocation(
        latitude: dLat,
        longitude: dLng,
        title: dMap?['name']?.toString() ?? "Delivery Partner",
        snippet: "Current Location",
      );
    }

    final bool isPartnerAssigned = driverLoc != null ||
        (dMap != null &&
            dMap['name'] != null &&
            dMap['name'].toString().isNotEmpty);

    final DeliveryPartnerInfo partnerInfo = DeliveryPartnerInfo(
      name: dMap?['name']?.toString() ?? "Delivery Partner",
      phone: dMap?['phone']?.toString() ?? dMap?['mobile']?.toString(),
      avatar: dMap?['avatar']?.toString() ?? dMap?['image']?.toString(),
      rating: dMap?['rating']?.toString() ?? "4.8",
      isAssigned: isPartnerAssigned,
    );

    final double totalAmount = (rawData['bill_summary']?['total_payable_amount']
            as num?)
        ?.toDouble() ??
        (rawData['order_amount'] as num?)?.toDouble() ??
        initialOrder?.orderAmount ??
        0.0;

    final steps = _buildTimelineSteps(status: status, isFood: isFood);

    return OrderTrackingModel(
      orderId: orderId,
      orderStatus: status,
      isFood: isFood,
      vendorName: vendor,
      deliveryCode: deliveryCode,
      eta: eta,
      customerLocation: customerLoc,
      vendorLocation: vendorLoc,
      driverLocation: driverLoc,
      deliveryPartner: partnerInfo,
      shippingAddress: addressInfo,
      timelineSteps: steps,
      items: items,
      totalAmount: totalAmount,
      itemsCount: items.isNotEmpty ? items.length : (initialOrder?.itemsCount ?? 1),
      orderNote: rawData['order_note']?.toString(),
    );
  }

  static List<TrackingStepItem> _buildTimelineSteps({
    required String status,
    required bool isFood,
  }) {
    final bool isDelivered = status == 'delivered';
    final bool isOutForDelivery = status == 'out_for_delivery' ||
        status == 'shipped' ||
        status == 'delivering';
    final bool isProcessing = status == 'processing' || status == 'confirmed';

    if (isFood) {
      return [
        const TrackingStepItem(
          title: "Order Placed",
          description: "Order has been submitted and verified",
          isCompleted: true,
          isActive: false,
        ),
        TrackingStepItem(
          title: "Order Confirmed",
          description: "Restaurant accepted your order",
          isCompleted: isProcessing || isOutForDelivery || isDelivered,
          isActive: status == 'pending',
        ),
        TrackingStepItem(
          title: "Preparing in Kitchen",
          description: "Chef is cooking your fresh meal",
          isCompleted: isOutForDelivery || isDelivered,
          isActive: isProcessing,
        ),
        TrackingStepItem(
          title: "Out for Delivery",
          description: "Delivery partner picked up and is en route",
          isCompleted: isDelivered,
          isActive: isOutForDelivery,
        ),
        TrackingStepItem(
          title: "Delivered",
          description: "Order delivered to your doorstep",
          isCompleted: isDelivered,
          isActive: false,
        ),
      ];
    } else {
      return [
        const TrackingStepItem(
          title: "Order Placed",
          description: "Order has been received successfully",
          isCompleted: true,
          isActive: false,
        ),
        TrackingStepItem(
          title: "Order Confirmed",
          description: "Seller confirmed your order items",
          isCompleted: isProcessing || isOutForDelivery || isDelivered,
          isActive: status == 'pending',
        ),
        TrackingStepItem(
          title: "Packed & Ready",
          description: "Items inspected and packed securely",
          isCompleted: isOutForDelivery || isDelivered,
          isActive: isProcessing,
        ),
        TrackingStepItem(
          title: "Out for Delivery",
          description: "Courier partner has dispatched package",
          isCompleted: isDelivered,
          isActive: isOutForDelivery,
        ),
        TrackingStepItem(
          title: "Delivered",
          description: "Package delivered safely",
          isCompleted: isDelivered,
          isActive: false,
        ),
      ];
    }
  }
}

