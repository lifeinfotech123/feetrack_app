import 'package:flutter/material.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_booking_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_visit_list_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_visit_detail_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_invoice_detail_pdf_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_invoice_list_screen.dart';

// ══════════════════════════════════════════════════════════════════
// 1. RECENT BOOKINGS SECTION & CARD
// ══════════════════════════════════════════════════════════════════
class PgRecentBookingsSection extends StatelessWidget {
  final List<PgCustomerBookingItem> bookings;
  final RoomController controller;
  final Function(PgCustomerBookingItem booking) onBookingTap;

  const PgRecentBookingsSection({
    super.key,
    required this.bookings,
    required this.controller,
    required this.onBookingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Bookings",
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                navigate(
                  context: context,
                  page: const MyRoomBookingScreen(),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF002060),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF002060),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length > 2 ? 2 : bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return PgBookingCard(
              booking: booking,
              controller: controller,
              onTap: () => onBookingTap(booking),
            );
          },
        ),
      ],
    );
  }
}

class PgBookingCard extends StatelessWidget {
  final PgCustomerBookingItem booking;
  final RoomController controller;
  final VoidCallback onTap;

  const PgBookingCard({
    super.key,
    required this.booking,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed =
        (booking.status ?? "").toLowerCase() == 'confirmed';
    final isCancelled =
        (booking.status ?? "").toLowerCase() == 'cancelled';
    final statusColor = isConfirmed
        ? const Color(0xFF16A34A)
        : isCancelled
            ? const Color(0xFFDC2626)
            : const Color(0xFFD97706);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002060).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.hotel_rounded,
                          size: 16,
                          color: Color(0xFF002060),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        booking.shortId ?? booking.bookingNumber ?? "Booking",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF002060),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booking.statusLabel ??
                              (isConfirmed ? "Confirmed" : "Pending"),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (booking.property?.title != null) ...[
                Text(
                  booking.property!.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  if (booking.bedsDisplay != null) ...[
                    Text(
                      booking.bedsDisplay!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(" • ",
                        style: TextStyle(color: Color(0xFFCBD5E1))),
                  ],
                  Text(
                    booking.formattedAmount ?? "₹${booking.finalAmount ?? 0}",
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF002060),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    booking.formattedDate ?? "",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 2. SCHEDULED VISITS SECTION & CARD
// ══════════════════════════════════════════════════════════════════
class PgRecentVisitsSection extends StatelessWidget {
  final List<PgCustomerVisitItem> visits;

  const PgRecentVisitsSection({
    super.key,
    required this.visits,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Scheduled Property Visits",
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                navigate(
                  context: context,
                  page: const MyRoomVisitListScreen(),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF002060),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF002060),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visits.length > 2 ? 2 : visits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final visit = visits[index];
            return PgVisitCard(visit: visit);
          },
        ),
      ],
    );
  }
}

class PgVisitCard extends StatelessWidget {
  final PgCustomerVisitItem visit;

  const PgVisitCard({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final isConfirmed =
        (visit.status ?? "").toLowerCase() == 'confirmed' ||
        (visit.status ?? "").toLowerCase() == 'accepted';
    final isCancelled =
        (visit.status ?? "").toLowerCase() == 'cancelled' ||
        (visit.status ?? "").toLowerCase() == 'rejected';

    final statusBgColor = isConfirmed
        ? const Color(0xFFDCFCE7)
        : isCancelled
            ? const Color(0xFFFEE2E2)
            : const Color(0xFFFEF3C7);

    final statusTextColor = isConfirmed
        ? const Color(0xFF16A34A)
        : isCancelled
            ? const Color(0xFFDC2626)
            : const Color(0xFFD97706);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          navigate(
            context: context,
            page: RoomVisitDetailScreen(
              visitId: visit.id ?? "",
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${visit.formattedDate ?? visit.visitDate ?? ''} • ${visit.visitTime ?? ''}",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      visit.status != null
                          ? visit.status![0].toUpperCase() +
                              visit.status!.substring(1)
                          : "Pending",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (visit.property?.title != null) ...[
                Text(
                  visit.property!.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (visit.property?.address != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        visit.property!.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 3. ACTIVE SUBSCRIPTIONS SECTION & CARD
// ══════════════════════════════════════════════════════════════════
class PgActiveSubscriptionsSection extends StatelessWidget {
  final List<PgCustomerSubscriptionItem> subscriptions;
  final RoomController controller;
  final Function(PgCustomerSubscriptionItem sub) onSubscriptionTap;

  const PgActiveSubscriptionsSection({
    super.key,
    required this.subscriptions,
    required this.controller,
    required this.onSubscriptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Active PG Stays & Plans",
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subscriptions.length > 2 ? 2 : subscriptions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final sub = subscriptions[index];
            return PgActiveSubscriptionCard(
              subscription: sub,
              onTap: () => onSubscriptionTap(sub),
            );
          },
        ),
      ],
    );
  }
}

class PgActiveSubscriptionCard extends StatelessWidget {
  final PgCustomerSubscriptionItem subscription;
  final VoidCallback onTap;

  const PgActiveSubscriptionCard({
    super.key,
    required this.subscription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysRemaining = subscription.daysRemaining ?? 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.home_work_rounded,
                          size: 16,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subscription.subscriptionNumber ?? "Subscription",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF002060),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "$daysRemaining Days Left",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (subscription.property?.title != null) ...[
                Text(
                  subscription.property!.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  Text(
                    subscription.package?['name']?.toString() ?? "Stay Plan",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Expires: ${subscription.formattedExpiresAt ?? ''}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 4. RECENT INVOICES SECTION & CARD
// ══════════════════════════════════════════════════════════════════
class PgRecentInvoicesSection extends StatelessWidget {
  final List<PgCustomerInvoiceItem> invoices;
  final RoomController controller;

  const PgRecentInvoicesSection({
    super.key,
    required this.invoices,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Invoices & Receipts",
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const PgInvoiceListScreen(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF002060),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF002060),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoices.length > 2 ? 2 : invoices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final inv = invoices[index];
            return PgInvoiceCard(
              invoice: inv,
              controller: controller,
            );
          },
        ),
      ],
    );
  }
}

class PgInvoiceCard extends StatelessWidget {
  final PgCustomerInvoiceItem invoice;
  final RoomController controller;

  const PgInvoiceCard({
    super.key,
    required this.invoice,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = (invoice.status ?? "").toLowerCase() == 'paid';

    void openInvoicePdfDetail() {
      final invId = (invoice.id != null && invoice.id!.isNotEmpty)
          ? invoice.id!
          : (invoice.invoiceNumber ?? "");

      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => PgInvoiceDetailPdfScreen(
            invoiceId: invId,
            initialInvoice: invoice,
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: openInvoicePdfDetail,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002060).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 16,
                          color: Color(0xFF002060),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        invoice.invoiceNumber ?? "Invoice",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF002060),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          invoice.statusLabel ?? (isPaid ? "Paid" : "Pending"),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isPaid
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (invoice.property?.title != null) ...[
                Text(
                  invoice.property!.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  if (invoice.bookingNumber != null) ...[
                    Text(
                      "Ref: ${invoice.bookingNumber}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(" • ",
                        style: TextStyle(color: Color(0xFFCBD5E1))),
                  ],
                  Text(
                    invoice.formattedDate ?? invoice.dueDate ?? "",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    invoice.formattedTotal ?? "₹${invoice.total ?? 0}",
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF002060),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
