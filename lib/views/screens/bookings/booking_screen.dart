import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/booking_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/base/web_view.dart';
import 'package:vlr/views/screens/bookings/booking_detail_screen.dart';

import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/app_router.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<SubscriptionController>().fetchBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        shadowColor: black.withValues(alpha: 0.05),
        title: Text(
          "My Bookings",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryText1,
              ),
        ),
      ),
      body: GetBuilder<SubscriptionController>(builder: (subscriptionController) {
        if (!Get.find<AuthController>().isLoggedIn()) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "You are browsing as Guest",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please log in to view and manage your bookings.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => AppRouter.goToLogin(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Log In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            _buildFilterRow(subscriptionController),
            Expanded(
              child: subscriptionController.isBookingLoading
                  ? const Center(child: CircularProgressIndicator())
                  : subscriptionController.filteredBookingList.isEmpty
                      ? Center(
                          child: Text(
                            "No Bookings Found",
                            style: Helper(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.separated(
                          padding: AppConstants.screenPadding,
                          itemCount: subscriptionController.filteredBookingList.length + 1,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            if (index == subscriptionController.filteredBookingList.length) {
                              return const SizedBox(height: 100);
                            }
                            final booking = subscriptionController.filteredBookingList[index];
                            return BookingListItem(booking: booking);
                          },
                        ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterRow(SubscriptionController controller) {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Pending OTP', 'value': 'pending_otp'},
      {'label': 'Pending Payment', 'value': 'pending_payment'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Cancelled', 'value': 'cancelled'},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = controller.selectedBookingFilter == filter['value'];

          return GestureDetector(
            onTap: () => controller.setBookingFilter(filter['value']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
                border: Border.all(
                  color: isSelected ? primaryColor : greyLight2.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  filter['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? white : greyText3,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BookingListItem extends StatelessWidget {
  final BookingModel booking;
  const BookingListItem({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigate(
          context: context,
          page: BookingDetailScreen(
            bookingId: booking.id ?? booking.subscriptionId ?? "",
          ),
        );
      },
      child: Container(
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomImage(
                        path: booking.listing?.image ?? "",
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.listing?.title ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Helper(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: blackText1,
                                    ),
                              ),
                            ),
                            _buildStatusChip(booking.bookingStatus ?? ""),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.listing?.category ?? "",
                          style: Helper(context).textTheme.bodySmall?.copyWith(
                                color: greyText3,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (booking.listing?.address != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 10, color: greyText3),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  booking.listing?.address ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Helper(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: greyText3,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (booking.listing?.partner != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 10, color: greyText3),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "${booking.listing?.partner?.name} (${booking.listing?.partner?.mobile})",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Helper(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: greyText3,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (booking.createdAt != null) ...[
                          Text(
                            "Booked on: ${DateFormat('dd MMM yyyy').format(booking.createdAt!)}",
                            style:
                                Helper(context).textTheme.bodySmall?.copyWith(
                                      color: greyText3,
                                      fontSize: 10,
                                    ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 12, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              booking.startsAt != null
                                  ? DateFormat('dd MMM')
                                      .format(booking.startsAt!)
                                  : "-",
                              style:
                                  Helper(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                            Text(
                              " to ",
                              style:
                                  Helper(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        color: greyText3,
                                      ),
                            ),
                            Text(
                              booking.expiresAt != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(booking.expiresAt!)
                                  : "-",
                              style:
                                  Helper(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                          ],
                        ),
                        if (booking.otp != null &&
                            (booking.status?.toLowerCase() == 'pending_otp' ||
                                booking.bookingStatus?.toLowerCase() ==
                                    'pending_otp')) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_clock_outlined,
                                    size: 12, color: primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  "OTP: ${booking.otp}",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (booking.status?.toLowerCase() == 'pending_payment' ||
                      booking.bookingStatus?.toLowerCase() == 'pending_payment') ...[
                    Expanded(
                      child: GetBuilder<SubscriptionController>(
                          builder: (subController) {
                        return _buildActionButton(
                          label: "Pay Now",
                          icon: Icons.payment_outlined,
                          color: primaryColor,
                          isLoading: subController.isLoading,
                          onTap: () {
                            subController
                                .payBooking(booking.id ?? "")
                                .then((value) {
                              if (value.isSuccess) {
                                String? paymentLink = value.data['payment_link'];
                                if (paymentLink != null) {
                                  navigate(
                                    context: context,
                                    page: CustomWebView(
                                      url: paymentLink,
                                      title: "Booking Payment",
                                    ),
                                  );
                                }
                              } else {
                                showToast(message: value.message);
                              }
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                  ],
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      label: "Map",
                      icon: Icons.location_on_outlined,
                      color: Colors.blue,
                      onTap: () {
                        if (booking.listing?.lat != null &&
                            booking.listing?.lng != null) {
                          LaunchHelper.openGoogleMap(
                            lat: booking.listing!.lat!,
                            lng: booking.listing!.lng!,
                          );
                        } else {
                          showToast(
                              message: "Location coordinates not available");
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
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
              ),
            ),
            if ((booking.billing?.securityDeposit ?? 0) > 0 || (booking.billing?.reserveAmount ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    if ((booking.billing?.securityDeposit ?? 0) > 0)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Security Deposit",
                              style: Helper(context).textTheme.bodySmall?.copyWith(fontSize: 9, color: greyText3),
                            ),
                            Text(
                              "₹${booking.billing?.securityDeposit}",
                              style: Helper(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: blackText1),
                            ),
                          ],
                        ),
                      ),
                    if ((booking.billing?.reserveAmount ?? 0) > 0)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Reserve Amount",
                              style: Helper(context).textTheme.bodySmall?.copyWith(fontSize: 9, color: greyText3),
                            ),
                            Text(
                              "₹${booking.billing?.reserveAmount}",
                              style: Helper(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: blackText1),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: blueLight5.withValues(alpha: 0.2),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.layers_outlined, size: 16, color: greyText3),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${booking.plan?.name ?? ""} (${booking.plan?.duration ?? ""})",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Helper(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: blackText1,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "₹${booking.billing?.finalAmount ?? 0}",
                    style: Helper(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
      case 'pending_otp':
      case 'pending_payment':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
