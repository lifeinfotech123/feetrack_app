import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vlr/hospital/core/constants/colors.dart';

import '../../data/model/order_model.dart';
import 'pharmacy_bookings_screen.dart';
import 'pharmacy_invoice_detail_screen.dart';
import 'pharmacy_screen.dart';

class PaymentVerifedScreen extends StatelessWidget {
  final VerifyPaymentResponse? verificationData;
  final PlaceOrderResponse? placeOrderResponse;
  final dynamic billId;
  final String? groupOrderNo;
  final String? paymentMode;
  final num? grandTotal;
  final String? hospitalName;
  final bool isCashOnDelivery;
  final List<CartItem>? cartItems;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final String? paymentId;

  const PaymentVerifedScreen({
    super.key,
    this.verificationData,
    this.placeOrderResponse,
    this.billId,
    this.groupOrderNo,
    this.paymentMode,
    this.grandTotal,
    this.hospitalName,
    this.isCashOnDelivery = false,
    this.cartItems,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.paymentId,
  });

  Map<String, dynamic>? get _hospitalDetails {
    final verifiedHospital = verificationData?.hospital?.toJson();
    if (verifiedHospital != null && verifiedHospital.isNotEmpty) {
      return verifiedHospital;
    }
    return placeOrderResponse?.hospital?.toJson();
  }

  String get _hospitalAddress {
    final hospital = _hospitalDetails;
    if (hospital == null) return '';
    final direct = hospital['full_address'] ??
        hospital['address'] ??
        hospital['location_address'];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString().trim();
    }
    return [
      hospital['landmark'],
      hospital['city'],
      hospital['state'],
      hospital['pincode'] ?? hospital['postal_code'],
    ]
        .where((value) => value != null && value.toString().trim().isNotEmpty)
        .map((value) => value.toString().trim())
        .join(', ');
  }

  Future<void> _openHospitalLocation(BuildContext context) async {
    final hospital = _hospitalDetails;
    if (hospital == null) return;
    final location = hospital['location'];
    final latitude = hospital['latitude'] ??
        hospital['lat'] ??
        (location is Map ? location['lat'] ?? location['latitude'] : null);
    final longitude = hospital['longitude'] ??
        hospital['lng'] ??
        (location is Map ? location['lng'] ?? location['longitude'] : null);
    final destination = latitude != null && longitude != null
        ? '${latitude.toString().trim()},${longitude.toString().trim()}'
        : _hospitalAddress.isNotEmpty
            ? _hospitalAddress
            : hospital['name']?.toString() ?? hospitalName ?? '';
    if (destination.trim().isEmpty) return;

    final url = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': destination,
    });
    if (!await launchUrl(url, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open hospital location.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCod = isCashOnDelivery ||
        (paymentMode?.toLowerCase().contains('cash') == true) ||
        (paymentMode?.toLowerCase().contains('cod') == true) ||
        (placeOrderResponse?.paymentMode?.toLowerCase().contains('cash') ==
            true) ||
        (placeOrderResponse?.paymentMode?.toLowerCase().contains('cod') ==
            true);

    final effectiveBillId = verificationData?.bills.isNotEmpty == true
        ? verificationData!.bills.first.billId
        : (billId ??
            placeOrderResponse?.billId ??
            (placeOrderResponse?.bills.isNotEmpty == true
                ? placeOrderResponse!.bills.first.billId
                : null));

    final effectiveOrderNo = verificationData?.bills.isNotEmpty == true
        ? verificationData!.bills.first.groupOrderNo
        : (groupOrderNo ??
            placeOrderResponse?.groupOrderNo ??
            (placeOrderResponse?.bills.isNotEmpty == true
                ? placeOrderResponse!.bills.first.groupOrderNo
                : null));

    final effectiveBillNo = verificationData?.bills.isNotEmpty == true
        ? verificationData!.bills.first.billNo
        : (placeOrderResponse?.billNo ??
            (placeOrderResponse?.bills.isNotEmpty == true
                ? placeOrderResponse!.bills.first.billNo
                : null));

    final amount = verificationData?.bills.isNotEmpty == true
        ? verificationData!.bills.first.netAmount
        : (grandTotal ??
            placeOrderResponse?.grandTotal ??
            (placeOrderResponse?.bills.isNotEmpty == true
                ? placeOrderResponse!.bills.first.netAmount
                : null));

    final effectiveHospitalName = _hospitalDetails?['name']?.toString() ??
        hospitalName ??
        placeOrderResponse?.labName ??
        placeOrderResponse?.storeName;

    final String generatedOrderNo =
        (effectiveOrderNo != null && effectiveOrderNo.isNotEmpty)
            ? effectiveOrderNo
            : ((effectiveBillNo != null && effectiveBillNo.isNotEmpty)
                ? effectiveBillNo
                : (effectiveBillId != null
                    ? 'ORD-$effectiveBillId'
                    : 'ORD-${DateTime.now().millisecondsSinceEpoch}'));

    final effectivePaymentMode = isCod
        ? (paymentMode ??
            placeOrderResponse?.paymentMode ??
            'Cash on Delivery (COD)')
        : (verificationData?.paymentMode ?? paymentMode ?? 'Razorpay Online');

    final effectiveOrderStatus = verificationData?.orderStatus?.toUpperCase() ??
        placeOrderResponse?.orderStatus?.toUpperCase() ??
        'CONFIRMED';

    final effectivePaymentStatus = isCod
        ? 'PENDING (PAY ON DELIVERY)'
        : (verificationData?.paymentStatus?.toUpperCase() ?? 'PAID');

    final effectivePaymentId = paymentId ??
        verificationData?.razorpayPaymentId ??
        verificationData?.razorpayOrderId ??
        placeOrderResponse?.razorpay?.orderId;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pharmacyTeal,
        title: const Text(
          'Order Confirmation',
          style: TextStyle(
            color: colorWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Animated Success Icon Badge
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: pharmacyTealBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: pharmacyTeal,
                size: 68,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              isCod
                  ? 'Order Placed Successfully!'
                  : 'Payment Verified & Confirmed!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),

            // Generated Order Number Tag with Copy button
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Clipboard.setData(ClipboardData(text: generatedOrderNo));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order Number copied: $generatedOrderNo'),
                    backgroundColor: pharmacyTeal,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: pharmacyTealBg,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: pharmacyTeal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tag_rounded,
                        size: 16, color: pharmacyTeal),
                    const SizedBox(width: 4),
                    Text(
                      'Order No: $generatedOrderNo',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: pharmacyTeal,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.copy_rounded,
                        size: 14, color: pharmacyTeal),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              isCod
                  ? 'Your medicine order has been placed with Cash on Delivery. Please pay ${amount != null ? "₹$amount " : ""}upon receiving your delivery.'
                  : 'Your payment via Razorpay was successful and medicine order is confirmed with the hospital pharmacy.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: textMuted,
              ),
            ),

            const SizedBox(height: 20),

            // Order & Payment Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderGrey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          color: pharmacyTeal, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Order & Payment Summary',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: borderGrey),
                  _buildDetailRow('Order Number', generatedOrderNo,
                      isBold: true, color: pharmacyTeal),
                  if (effectiveBillNo != null &&
                      effectiveBillNo != generatedOrderNo)
                    _buildDetailRow('Bill No', effectiveBillNo),
                  if (effectiveBillId != null)
                    _buildDetailRow('Bill ID', '#$effectiveBillId'),
                  if (amount != null)
                    _buildDetailRow(
                      isCod ? 'Total Order Amount' : 'Net Amount Paid',
                      '₹$amount',
                      isBold: true,
                      color: pharmacyTeal,
                    ),
                  _buildDetailRow('Payment Mode', effectivePaymentMode),
                  if (effectivePaymentId != null && !isCod)
                    _buildDetailRow('Payment ID', effectivePaymentId),
                  _buildDetailRow(
                    'Order Status',
                    effectiveOrderStatus,
                    color: Colors.green,
                  ),
                  _buildDetailRow(
                    'Payment Status',
                    effectivePaymentStatus,
                    color: isCod ? Colors.orange.shade800 : Colors.green,
                  ),
                  if (effectiveHospitalName != null)
                    _buildDetailRow(
                        'Hospital / Pharmacy', effectiveHospitalName),
                ],
              ),
            ),

            if (effectiveHospitalName != null ||
                _hospitalAddress.isNotEmpty) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _openHospitalLocation(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderGrey),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.local_hospital_rounded,
                          color: pharmacyTeal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hospital Information',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                            if (effectiveHospitalName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                effectiveHospitalName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                            ],
                            if (_hospitalAddress.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _hospitalAddress,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: textMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(Icons.map_outlined,
                                    size: 15, color: pharmacyTeal),
                                SizedBox(width: 4),
                                Text(
                                  'Open Location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: pharmacyTeal,
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
              ),
            ],

            // Ordered Medicines / Items Card ("jo maine order kiya h")
            if (cartItems != null && cartItems!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderGrey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.medication_rounded,
                                color: pharmacyTeal, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Ordered Medicines',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: pharmacyTealBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${cartItems!.length} ${cartItems!.length == 1 ? "Item" : "Items"}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: pharmacyTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: borderGrey),
                    ...cartItems!.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: pharmacyTealBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.medical_services_outlined,
                                color: pharmacyTeal,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.medicine.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textDark,
                                    ),
                                  ),
                                  if (item.medicine.categoryName != null ||
                                      item.medicine.medicineCompany !=
                                          null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        if (item.medicine.categoryName != null)
                                          item.medicine.categoryName!,
                                        if (item.medicine.medicineCompany !=
                                            null)
                                          item.medicine.medicineCompany!,
                                      ].join(' • '),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 3),
                                  Text(
                                    '₹${item.itemPrice} × ${item.qty}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${item.totalItemPrice}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 16, color: borderGrey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          '₹${amount ?? cartItems!.fold<num>(0, (sum, i) => sum + i.totalItemPrice)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: pharmacyTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Customer and Delivery Address Card
            if ((customerName != null && customerName!.isNotEmpty) ||
                (deliveryAddress != null && deliveryAddress!.isNotEmpty)) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderGrey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_shipping_outlined,
                            color: pharmacyTeal, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Delivery Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: borderGrey),
                    if (customerName != null && customerName!.isNotEmpty)
                      _buildDetailRow('Recipient', customerName!),
                    if (customerPhone != null && customerPhone!.isNotEmpty)
                      _buildDetailRow('Contact Phone', customerPhone!),
                    if (deliveryAddress != null && deliveryAddress!.isNotEmpty)
                      _buildDetailRow('Shipping Address', deliveryAddress!),
                  ],
                ),
              ),
            ],

            // API Response Message Note if available
            if ((placeOrderResponse?.message != null &&
                    placeOrderResponse!.message!.isNotEmpty) ||
                (verificationData?.message != null &&
                    verificationData!.message!.isNotEmpty)) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        placeOrderResponse?.message ??
                            verificationData?.message ??
                            '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 26),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (effectiveBillId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PharmacyInvoiceDetailScreen(
                            billId: effectiveBillId),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Invoice ID is processing. Please view orders in My Bookings.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: pharmacyTeal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.receipt_long_rounded, color: colorWhite),
                label: const Text(
                  'VIEW INVOICE DETAILS',
                  style: TextStyle(
                      color: colorWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PharmacyBookingsScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: pharmacyTeal, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.history_rounded, color: pharmacyTeal),
                label: const Text(
                  'VIEW MY ORDERS',
                  style: TextStyle(
                      color: pharmacyTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const PharmacyScreen()),
                    (route) => route.isFirst,
                  );
                },
                icon: const Icon(Icons.storefront_rounded, color: textMuted),
                label: const Text(
                  'Return to Pharmacy',
                  style: TextStyle(
                      color: textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: textMuted),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isBold ? 14 : 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: color ?? textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
