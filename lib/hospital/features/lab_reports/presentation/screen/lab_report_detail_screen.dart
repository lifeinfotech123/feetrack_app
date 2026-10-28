import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/core/constants/colors.dart';

import 'package:vlr/controllers/auth_controller.dart';
import '../../controller/lab_controller.dart';
import '../../data/model/lab_model.dart';

class LabReportDetailScreen extends StatelessWidget {
  final PatientLabBookingModel? booking;
  final String? testName;
  final String? date;
  final String? labName;
  final String? bookingNo;
  final dynamic bookingId;

  const LabReportDetailScreen({
    super.key,
    this.booking,
    this.testName,
    this.date,
    this.labName,
    this.bookingNo,
    this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    final LabController controller = Get.isRegistered<LabController>()
        ? Get.find<LabController>()
        : Get.put(LabController());
    final AuthController? authController =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

    final lastBooking = controller.lastBooking.value;
    final verified = controller.verifiedPayment.value;

    final defaultLab = controller.diagnosticLabs.isNotEmpty
        ? controller.diagnosticLabs.first.labName
        : 'Hospital Diagnostic Lab';

    final matchedBooking = booking ??
        controller.patientLabBookings.firstWhereOrNull(
          (b) =>
              (bookingNo != null && b.bookingNo == bookingNo) ||
              (bookingId != null && b.bookingId == bookingId) ||
              (testName != null &&
                  (b.primaryTestName.toLowerCase() == testName!.toLowerCase())),
        );

    final effectiveBookingNo = booking?.bookingNo ??
        bookingNo ??
        matchedBooking?.bookingNo ??
        lastBooking?.bookingNo ??
        'LAB-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final effectiveBookingId = booking?.bookingId ??
        bookingId ??
        matchedBooking?.bookingId ??
        lastBooking?.bookingId ??
        1;
    final effectiveTestName = booking?.primaryTestName ??
        testName ??
        matchedBooking?.primaryTestName ??
        lastBooking?.testName ??
        'Diagnostic Pathology Examination';
    final effectiveLabName = booking?.labName ??
        booking?.hospital?.name ??
        labName ??
        matchedBooking?.labName ??
        lastBooking?.labName ??
        defaultLab;
    final effectivePatientName = booking?.patientName ??
        matchedBooking?.patientName ??
        lastBooking?.patientName ??
        (authController?.fullNameController.text.isNotEmpty == true
            ? authController!.fullNameController.text
            : 'Patient');
    final effectiveAmount = booking?.netAmount ??
        matchedBooking?.netAmount ??
        lastBooking?.netAmount ??
        250;
    final effectiveStatus =
        booking?.bookingStatus ?? verified?.bookingStatus ?? 'Confirmed';
    final effectiveDate = booking?.bookingDate ?? date ?? '';
    final effectiveTimeSlot = booking?.timeSlot;
    final effectivePaymentMode = booking?.paymentMode ?? 'Online';
    final effectivePaymentStatus = booking?.paymentStatus ?? 'Paid';
    final effectiveCollectionType = booking?.collectionType ?? 'Lab Visit';
    final reportPdf = booking?.reportPdf;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lab Report Details',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Booking & Test Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderGrey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          effectiveTestName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: wellnessGreenBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified,
                                size: 14, color: wellnessGreen),
                            const SizedBox(width: 4),
                            Text(
                              effectiveStatus.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: wellnessGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$effectiveLabName • ${effectiveDate.isNotEmpty ? effectiveDate : "Scheduled"}',
                    style: const TextStyle(fontSize: 12, color: textMuted),
                  ),
                  const Divider(height: 20),
                  _buildDetailRow('Booking No:', effectiveBookingNo),
                  _buildDetailRow('Booking ID:', '#$effectiveBookingId'),
                  _buildDetailRow('Patient Name:', effectivePatientName),
                  if (matchedBooking?.patientPhone != null &&
                      matchedBooking!.patientPhone!.isNotEmpty)
                    _buildDetailRow(
                        'Contact Phone:', matchedBooking.patientPhone!),
                  _buildDetailRow('Collection Type:', effectiveCollectionType),
                  if (effectiveTimeSlot != null && effectiveTimeSlot.isNotEmpty)
                    _buildDetailRow('Time Slot:', effectiveTimeSlot),
                  _buildDetailRow('Payment Mode:', effectivePaymentMode),
                  _buildDetailRow('Payment Status:', effectivePaymentStatus),
                  _buildDetailRow('Total Amount:', '₹$effectiveAmount',
                      isBold: true, color: primaryColor),
                ],
              ),
            ),

            if (matchedBooking != null && matchedBooking.items.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booked Test Items',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textDark,
                      ),
                    ),
                    const Divider(height: 18),
                    ...matchedBooking.items.map((it) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      it.testName ?? 'Diagnostic Test',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (it.price != null)
                              Text(
                                '₹${it.price}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Pathologist Remarks Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: diagnosticVioletBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pathologist Summary',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: diagnosticViolet)),
                  SizedBox(height: 6),
                  Text(
                    'All cellular counts are in physiological normal range. Report electronically signed & certified by Chief Clinical Pathologist.',
                    style:
                        TextStyle(fontSize: 12, color: textDark, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Return Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('BACK TO LAB REPORTS',
                    style: TextStyle(
                        color: colorWhite, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? textDark,
            ),
          ),
        ],
      ),
    );
  }
}
