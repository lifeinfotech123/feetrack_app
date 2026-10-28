import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/booking_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<SubscriptionController>().fetchBookingById(id: widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: black.withValues(alpha: 0.05),
        title: Text(
          "Booking Details",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryText1,
              ),
        ),
      ),
      body: GetBuilder<SubscriptionController>(builder: (subscriptionController) {
        if (subscriptionController.isBookingDetailLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final booking = subscriptionController.selectedBookingDetail;
        if (booking == null) {
          return const Center(child: Text("Booking details not found"));
        }

        return SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildListingSection(booking),
              const SizedBox(height: 24),
              _buildActionButtons(booking),
              const SizedBox(height: 24),
              _buildStatusSection(booking),
              const SizedBox(height: 24),
              _buildContactSection(booking),
              const SizedBox(height: 24),
              _buildPlanSection(booking),
              const SizedBox(height: 24),
              if (booking.shift != null || (booking.trainers != null && (booking.trainers as List).isNotEmpty)) ...[
                _buildGymSpecificSection(booking),
                const SizedBox(height: 24),
              ],
              if (booking.room != null) ...[
                _buildRoomSection(booking),
                const SizedBox(height: 24),
              ],
              _buildBillingSection(booking),
              if (booking.invoices != null && booking.invoices!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildInvoiceSection(booking),
              ],
              if (booking.payments != null && booking.payments!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildPaymentSection(booking),
              ],
              if (booking.bookingStatus?.toLowerCase() != 'cancelled' && booking.status?.toLowerCase() != 'cancelled') ...[
                const SizedBox(height: 24),
                _buildCancelButton(subscriptionController, booking.id),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons(BookingModel booking) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: "Call",
            icon: Icons.phone_outlined,
            color: Colors.green,
            onTap: () {
              if (booking.listing?.phone != null) {
                LaunchHelper.callUs(number: booking.listing!.phone!);
              } else {
                showToast(message: "Phone number not available");
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: "Map",
            icon: Icons.map_outlined,
            color: Colors.blue,
            onTap: () {
              if (booking.listing?.lat != null && booking.listing?.lng != null) {
                LaunchHelper.openGoogleMap(
                  lat: booking.listing!.lat!,
                  lng: booking.listing!.lng!,
                );
              } else {
                showToast(message: "Location coordinates not available");
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: "Help",
            icon: Icons.help_outline,
            color: Colors.orange,
            onTap: () {
              LaunchHelper.launchInBrowser(
                  Uri.parse("https://app.feetrack.in/contact-us"));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(SubscriptionController controller, String? bookingId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading
            ? null
            : () {
                _showCancelConfirmation(controller, bookingId);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.shade200),
          ),
          elevation: 0,
        ),
        child: controller.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
              )
            : const Text(
                "Cancel Booking",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  void _showCancelConfirmation(SubscriptionController controller, String? bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this booking? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NO", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (bookingId != null) {
                controller.cancelBooking(bookingId).then((response) {
                  showToast(
                    message: response.message,
                    toastType: response.isSuccess ? ToastType.success : ToastType.error,
                  );
                });
              }
            },
            child: const Text("YES, CANCEL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildListingSection(BookingModel booking) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: CustomImage(
                  path: booking.listing?.image ?? "",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: _buildStatusChip(booking.status ?? booking.bookingStatus ?? ""),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.listing?.title ?? "",
                            style: Helper(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: blackText1,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.listing?.category ?? "",
                            style: Helper(context).textTheme.bodyMedium?.copyWith(
                                  color: greyText3,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        String shareText = "Booking Details:\n\n"
                            "Listing: ${booking.listing?.title ?? ''}\n"
                            "Category: ${booking.listing?.category ?? ''}\n"
                            "Address: ${booking.listing?.address ?? ''}\n"
                            "Plan: ${booking.plan?.name ?? ''} (${booking.plan?.duration ?? ''})\n"
                            "Start Date: ${booking.startsAt != null ? DateFormat('dd MMM yyyy').format(booking.startsAt!) : '-'}\n"
                            "Expiry Date: ${booking.expiresAt != null ? DateFormat('dd MMM yyyy').format(booking.expiresAt!) : '-'}\n"
                            "Total Amount: ₹ ${booking.billing?.finalAmount ?? 0}\n\n"
                            "Shared via ${AppConstants.appName}";
                        Share.share(shareText);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: blueLight5.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.share_outlined, color: primaryColor, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.listing?.address ?? "",
                        style: Helper(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: greyText3,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                if (booking.listing?.landmark != null && booking.listing!.landmark!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.near_me_outlined, size: 16, color: greyText3),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Landmark: ${booking.listing?.landmark}",
                          style: Helper(context).textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: greyText3,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (booking.listing?.description != null && booking.listing!.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    booking.listing?.description ?? "",
                    style: Helper(context).textTheme.bodySmall?.copyWith(
                          color: greyText2,
                          fontSize: 13,
                          height: 1.5,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
      case 'pending_otp':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusSection(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // _buildDetailRow("Booking ID", booking.id ?? "-", icon: Icons.tag),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          if (booking.otp != null && (booking.status?.toLowerCase() == 'pending_otp' || booking.bookingStatus?.toLowerCase() == 'pending_otp')) ...[
            _buildDetailRow("Verification OTP", booking.otp!, icon: Icons.lock_person_outlined, textColor: primaryColor),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
          ],
          _buildDetailRow("Payment Method", booking.paymentMethod?.toString().toUpperCase() ?? "", icon: Icons.payment_rounded),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          if (booking.listing?.openingTime != null) ...[
             _buildDetailRow("Business Hours", "${booking.listing?.openingTime} - ${booking.listing?.closingTime}", icon: Icons.access_time_rounded),
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 12),
               child: Divider(height: 1),
             ),
          ],
          _buildDetailRow(
            "Booking Date",
            booking.createdAt != null ? DateFormat('dd MMM yyyy').format(booking.createdAt!) : "-",
            icon: Icons.calendar_month_outlined,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildDetailRow(
            "Start Date",
            booking.startsAt != null ? DateFormat('dd MMM yyyy').format(booking.startsAt!) : "-",
            icon: Icons.calendar_today_rounded,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildDetailRow(
            "Expiry Date",
            booking.expiresAt != null ? DateFormat('dd MMM yyyy').format(booking.expiresAt!) : "-",
            icon: Icons.event_busy_rounded,
          ),
          if (booking.daysRemaining != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _buildDetailRow("Days Remaining", "${booking.daysRemaining} Days", icon: Icons.timer_outlined, textColor: primaryColor),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(BookingModel booking) {
    final partner = booking.listing?.partner;
    final customer = booking.customer;
    
    if (partner == null && customer == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "CONTACT INFORMATION",
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: greyText3,
                  fontSize: 12,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              if (partner != null) ...[
                // _buildContactItem("Property Manager", partner.name ?? "", partner.mobile ?? "", partner.email ?? "", Icons.business_center_outlined),
                // if (customer != null) const Padding(
                //   padding: EdgeInsets.symmetric(vertical: 16),
                //   child: Divider(height: 1),
                // ),
              ],
              if (customer != null) ...[
                _buildContactItem("Customer Details", customer.name ?? "", customer.mobile ?? "", customer.email ?? "", Icons.person_pin_outlined),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(String label, String name, String mobile, String email, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDetailRow("Name", name),
        const SizedBox(height: 8),
        _buildDetailRow("Mobile", mobile, textColor: Colors.blue, icon: Icons.phone_android),
        const SizedBox(height: 8),
        _buildDetailRow("Email", email, textColor: Colors.blue, icon: Icons.email),
      ],
    );
  }

  Widget _buildPlanSection(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "PLAN DETAILS",
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: greyText3,
                  fontSize: 12,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow("Plan Name", booking.plan?.name ?? "", icon: Icons.layers_outlined),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _buildDetailRow("Duration", booking.plan?.duration ?? "", icon: Icons.update_rounded),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _buildDetailRow("Base Price", "₹ ${booking.plan?.price ?? 0}", icon: Icons.sell_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillingSection(BookingModel booking) {
    final billing = booking.billing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "BILLING SUMMARY",
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: greyText3,
                  fontSize: 12,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow("Subtotal", "₹ ${billing?.subtotal ?? 0}"),
              if ((billing?.securityDeposit ?? 0) > 0) ...[
                const SizedBox(height: 12),
                _buildDetailRow("Security Deposit", "₹ ${billing?.securityDeposit}"),
              ],
              if ((billing?.reserveAmount ?? 0) > 0) ...[
                const SizedBox(height: 12),
                _buildDetailRow("Reserve Amount", "₹ ${billing?.reserveAmount}"),
              ],
              if ((billing?.trainerFee ?? 0) > 0) ...[
                const SizedBox(height: 12),
                _buildDetailRow("Trainer Fee", "₹ ${billing?.trainerFee}"),
              ],
              if ((billing?.shiftFee ?? 0) > 0) ...[
                const SizedBox(height: 12),
                _buildDetailRow("Shift Fee", "₹ ${billing?.shiftFee}"),
              ],
              if ((billing?.bedsBooked ?? 0) > 1) ...[
                const SizedBox(height: 12),
                _buildDetailRow("Beds Booked", "${billing?.bedsBooked}"),
              ],
              if (billing?.discount != null && billing!.discount! > 0) ...[
                const SizedBox(height: 12),
                _buildDetailRow("Discount", "- ₹ ${billing.discount}", textColor: Colors.green),
              ],
              if (billing?.coupon != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow("Coupon Applied", "${billing?.coupon}", textColor: Colors.blue),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: Helper(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: blackText1,
                        ),
                  ),
                  Text(
                    "₹ ${billing?.finalAmount ?? 0}",
                    style: Helper(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: primaryColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSection(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "INVOICES",
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: greyText3,
                  fontSize: 12,
                ),
          ),
        ),
        ...booking.invoices!.map((invoice) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: blueLight5.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber ?? "",
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: blackText1,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Due: ${invoice.dueDate != null ? DateFormat('dd MMM yyyy').format(invoice.dueDate!) : "-"}",
                        style: Helper(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: greyText3,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹ ${invoice.total ?? 0}",
                      style: Helper(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: blackText1,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (invoice.status == 'paid' ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        invoice.status?.toUpperCase() ?? "",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: invoice.status == 'paid' ? Colors.green : Colors.orange,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPaymentSection(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "PAYMENTS",
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: greyText3,
                  fontSize: 12,
                ),
          ),
        ),
        ...booking.payments!.map((payment) {
          final isSuccess = payment.status?.toLowerCase() == 'success' || payment.status?.toLowerCase() == 'paid';
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isSuccess ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_circle_outline : Icons.pending_outlined,
                        color: isSuccess ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Receipt: ${payment.receiptNo ?? '-'}",
                            style: Helper(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: blackText1,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Gateway: ${payment.gateway?.toUpperCase() ?? '-'}",
                            style: Helper(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: greyText3,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹ ${payment.amount ?? 0}",
                          style: Helper(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isSuccess ? Colors.green : blackText1,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isSuccess ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            payment.status?.toUpperCase() ?? "",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isSuccess ? Colors.green : Colors.orange,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (payment.transactionId != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transaction ID",
                        style: TextStyle(fontSize: 10, color: greyText3, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        payment.transactionId!,
                        style: TextStyle(fontSize: 10, color: blackText1, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
                if (payment.paidAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Paid On",
                        style: TextStyle(fontSize: 10, color: greyText3, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(payment.paidAt!),
                        style: TextStyle(fontSize: 10, color: blackText1, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? textColor, IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: greyText3.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Helper(context).textTheme.bodySmall?.copyWith(
                    color: greyText3,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        Text(
          value,
          style: Helper(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor ?? blackText1,
              ),
        ),
      ],
    );
  }

  Widget _buildGymSpecificSection(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "GYM DETAILS",
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: greyText3,
                  fontSize: 12,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              if (booking.shift != null) ...[
                _buildDetailRow("Shift", booking.shift['shift_name'] ?? "-", icon: Icons.access_time_rounded),
                _buildDetailRow("Timing", "${booking.shift['start_time']} - ${booking.shift['end_time']}", icon: Icons.timer_outlined),
              ],
              if (booking.trainers != null && (booking.trainers as List).isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                ... (booking.trainers as List).map((trainer) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildDetailRow("Trainer", "${trainer['name']} (${trainer['specialization']})", icon: Icons.person_outline_rounded),
                )).toList(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSection(BookingModel booking) {
    final room = booking.room;
    if (room == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "ROOM INFORMATION",
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: greyText3,
                  fontSize: 12,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow("Room Number", room.roomNumber ?? "-", icon: Icons.door_front_door_outlined),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _buildDetailRow("Room Type", room.roomType ?? "-", icon: Icons.king_bed_outlined),
              if (room.floor != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildDetailRow("Floor", room.floor['name'] ?? "-", icon: Icons.layers_outlined),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
