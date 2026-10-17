import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/room_home/room_home_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_booking_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_visit_list_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_visit_detail_screen.dart';
import 'package:vlr/views/screens/room_section/attendance/attendance_checkin_checkout_screen.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';
import 'package:vlr/services/app_router.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_invoice_detail_pdf_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_invoice_list_screen.dart';

class RoomProfileDashboardScreen extends StatefulWidget {
  const RoomProfileDashboardScreen({super.key});

  @override
  State<RoomProfileDashboardScreen> createState() =>
      _RoomProfileDashboardScreenState();
}

class _RoomProfileDashboardScreenState
    extends State<RoomProfileDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (Get.isRegistered<RoomController>()) {
      final ctrl = Get.find<RoomController>();
      ctrl.fetchPgCustomerDashboard();
      ctrl.fetchPgCustomerWallet();
      ctrl.fetchPgCustomerProfile();
      ctrl.fetchPgCustomerInvoices();
      ctrl.fetchPgCustomerSubscriptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Customer Dashboard",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF002060),
            ),
            tooltip: "Refresh",
            onPressed: _loadData,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: GetBuilder<RoomController>(
        builder: (controller) {
          if (controller.isCustomerDashboardLoading &&
              controller.customerDashboardData == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF002060),
              ),
            );
          }

          final dashboardData = controller.customerDashboardData;
          final customer = dashboardData?.customer;
          final header = dashboardData?.header;
          final metrics = dashboardData?.metrics;
          final sections = dashboardData?.sections;

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: () async {
              await controller.fetchPgCustomerDashboard();
              await controller.fetchPgCustomerWallet();
              await controller.fetchPgCustomerProfile();
              await controller.fetchPgCustomerInvoices();
              await controller.fetchPgCustomerSubscriptions();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Customer Profile Card
                  _buildCustomerProfileCard(
                      context, customer, header, controller),

                  const SizedBox(height: 16),

                  // 2. PG Wallet Card
                  _buildWalletCard(context, header, controller),

                  const SizedBox(height: 16),

                  // 3. Key Metrics Cards Grid
                  _buildMetricsGrid(context, metrics, controller),

                  const SizedBox(height: 20),

                  // 6. Account & Services Options Card
                  _buildAccountOptionsCard(context, controller),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 1. CUSTOMER PROFILE CARD
  // ══════════════════════════════════════════════════════════════════
  Widget _buildCustomerProfileCard(
    BuildContext context,
    PgCustomerInfo? customer,
    PgDashboardHeader? header,
    RoomController controller,
  ) {
    final initials = customer?.initials ?? header?.initials ?? "CU";
    final name = customer?.name ??
        "${customer?.firstName ?? 'Customer'} ${customer?.lastName ?? ''}"
            .trim();
    final email = customer?.email ?? "Email not provided";
    final phone = customer?.phone ?? "Phone not provided";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Initials / Avatar Circle
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF002060), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002060).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: customer?.avatar != null && customer!.avatar!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(29),
                    child: Image.network(
                      customer.avatar!,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        initials.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                : Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // Name, Email, Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.isNotEmpty ? name : "Customer",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 12, color: Color(0xFF16A34A)),
                          SizedBox(width: 3),
                          Text(
                            "Active",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (phone.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 2),
                if (email.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Quick arrow to profile details
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
            onPressed: () => _showProfileSheet(context, controller),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 2. PG WALLET CARD
  // ══════════════════════════════════════════════════════════════════
  Widget _buildWalletCard(
    BuildContext context,
    PgDashboardHeader? header,
    RoomController controller,
  ) {
    final balanceStr = controller.customerWalletData?.formattedBalance ??
        header?.formattedWalletBalance ??
        "₹0.00";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF002060),
            Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002060).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Brand & Wallet Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "PG SMART WALLET",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showWalletSheet(context, controller),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "Passbook",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Balance Display
          Text(
            balanceStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 4),
          const Text(
            "Available balance for rent, deposits & visits",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: Passbook & Recharge
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showWalletSheet(context, controller),
                  icon: const Icon(Icons.receipt_long_rounded, size: 16),
                  label: const Text(
                    "Transactions",
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF002060),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.snackbar(
                      "Wallet Recharge",
                      "Wallet recharge option will open UPI / Razorpay gateway.",
                      backgroundColor: const Color(0xFF002060),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  label: const Text(
                    "Recharge",
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 3. KEY METRICS GRID (4 CARDS)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildMetricsGrid(
    BuildContext context,
    PgDashboardMetrics? metrics,
    RoomController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stay & Booking Metrics",
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: "Scheduled Visits",
                value: "${metrics?.scheduledVisits ?? 0}",
                icon: Icons.calendar_month_rounded,
                bgColor: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFEA580C),
                onTap: () {
                  navigate(
                    context: context,
                    page: const MyRoomVisitListScreen(),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: "Total Bookings",
                value: "${metrics?.totalBookings ?? 0}",
                icon: Icons.hotel_rounded,
                bgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                onTap: () {
                  navigate(
                    context: context,
                    page: const MyRoomBookingScreen(),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: "Active Stays",
                value: "${metrics?.activeSubscriptions ?? 0}",
                icon: Icons.home_work_rounded,
                bgColor: const Color(0xFFF0FDF4),
                iconColor: const Color(0xFF16A34A),
                onTap: () => _showSubscriptionsSheet(context, controller),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: "Total Spent",
                value: "₹${metrics?.totalSpent ?? 0}",
                icon: Icons.payments_rounded,
                bgColor: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF7C3AED),
                onTap: () => _showInvoicesSheet(context, controller),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
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

  // ══════════════════════════════════════════════════════════════════
  // 4. SCHEDULED VISITS CARD SECTION
  // ══════════════════════════════════════════════════════════════════
  Widget _buildRecentVisitsSection(
    BuildContext context,
    List<PgCustomerVisitItem> visits,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Recent Scheduled Visits",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (visits.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002060).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${visits.length}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002060),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            TextButton(
              onPressed: () {
                navigate(
                  context: context,
                  page: const MyRoomVisitListScreen(),
                );
              },
              child: const Text(
                "View All",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF002060),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (visits.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(Icons.calendar_month_outlined,
                    size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                const Text(
                  "No scheduled visits right now",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Book a free visit to experience your next stay in person.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visits.length > 3 ? 3 : visits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final visit = visits[index];
              return _buildVisitCard(context, visit);
            },
          ),
      ],
    );
  }

  Widget _buildVisitCard(BuildContext context, PgCustomerVisitItem visit) {
    final property = visit.property;
    final status = (visit.status ?? "pending").toUpperCase();
    final isPending = (visit.status ?? "").toLowerCase() == 'pending';

    final statusBgColor =
        isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7);
    final statusTextColor =
        isPending ? const Color(0xFFD97706) : const Color(0xFF16A34A);

    final dateStr = visit.formattedDate ?? visit.visitDate ?? "";
    final timeStr = visit.visitTime ?? "";

    return InkWell(
      onTap: () {
        if (visit.id != null) {
          navigate(
            context: context,
            page: RoomVisitDetailScreen(visitId: visit.id!),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
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
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Exterior Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: property?.image != null && property!.image!.isNotEmpty
                      ? Image.network(
                          property.image!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.apartment_rounded,
                                color: Color(0xFF94A3B8)),
                          ),
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.apartment_rounded,
                              color: Color(0xFF94A3B8)),
                        ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              property?.title ?? "PG Accommodation",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: statusTextColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              "${property?.address ?? ''}${property?.city != null ? ', ${property!.city}' : ''}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 12, color: Color(0xFF002060)),
                            const SizedBox(width: 4),
                            Text(
                              "$dateStr • $timeStr",
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF002060),
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
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // Call / Details action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (property?.phone != null && property!.phone!.isNotEmpty)
                  InkWell(
                    onTap: () {
                      LaunchHelper.callUs(number: property.phone!);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.call_rounded,
                              size: 15, color: Color(0xFF16A34A)),
                          const SizedBox(width: 4),
                          Text(
                            "Call: ${property.phone}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                Row(
                  children: [
                    Text(
                      "Visit Details",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: Colors.blue.shade700),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 5. RECENT BOOKINGS CARD SECTION
  // ══════════════════════════════════════════════════════════════════
  Widget _buildRecentBookingsSection(
    BuildContext context,
    List<PgCustomerBookingItem> bookings,
    RoomController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Recent Bookings",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (bookings.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002060).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${bookings.length}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002060),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            TextButton(
              onPressed: () {
                navigate(
                  context: context,
                  page: const MyRoomBookingScreen(),
                );
              },
              child: const Text(
                "View All",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF002060),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (bookings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(Icons.hotel_outlined,
                    size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                const Text(
                  "No active room bookings",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Looking for comfortable, verified PG rooms near you?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002060),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    navigate(
                      context: context,
                      page: const RoomHomeScreen(),
                    );
                  },
                  icon: const Icon(Icons.search_rounded, size: 16),
                  label: const Text(
                    "Explore Rooms & PGs",
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.length > 2 ? 2 : bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(context, booking, controller);
            },
          ),
      ],
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    PgCustomerBookingItem booking,
    RoomController controller,
  ) {
    final property = booking.property;
    final isConfirmed = (booking.status ?? "").toLowerCase() == 'confirmed';
    final statusBgColor =
        isConfirmed ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final statusTextColor =
        isConfirmed ? const Color(0xFF16A34A) : const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: property?.image != null && property!.image!.isNotEmpty
                    ? Image.network(
                        property.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.hotel_rounded,
                              color: Color(0xFF94A3B8)),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.hotel_rounded,
                            color: Color(0xFF94A3B8)),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property?.title ?? "PG Room Stay",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            booking.statusLabel ??
                                (booking.status ?? "").toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.shortId ?? booking.bookingNumber ?? "",
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.formattedAmount ?? "₹${booking.finalAmount ?? 0}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002060),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  booking.formattedDate ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  if (booking.actions?['can_pay'] == true) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        navigate(
                          context: context,
                          page: const MyRoomBookingScreen(),
                        );
                      },
                      child: const Text(
                        "Pay with Razorpay",
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF002060),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _showBookingDetailSheet(context, booking, controller);
                    },
                    child: const Text(
                      "Details",
                      style: TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 6. ACCOUNT & SERVICES OPTIONS CARD
  // ══════════════════════════════════════════════════════════════════
  Widget _buildAccountOptionsCard(
    BuildContext context,
    RoomController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.receipt_long_rounded,
            title: "My Room Bookings & Stays",
            subtitle: "View booking history, receipts & invoice",
            onTap: () {
              navigate(
                context: context,
                page: const MyRoomBookingScreen(),
              );
            },
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.fingerprint_rounded,
            title: "PG Attendance & Daily Check-in",
            subtitle: "Mark daily entry/exit & view attendance logs",
            onTap: () {
              navigate(
                context: context,
                page: const PgAttendanceCheckinCheckoutScreen(),
              );
            },
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.calendar_month_rounded,
            title: "My Scheduled Visits",
            subtitle: "Property tour appointments & status",
            onTap: () {
              navigate(
                context: context,
                page: const MyRoomVisitListScreen(),
              );
            },
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.description_outlined,
            title: "Invoices & Tax Receipts",
            subtitle: "View billing history & download PDF invoices",
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const PgInvoiceListScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.card_membership_rounded,
            title: "My PG Subscriptions & Plans",
            subtitle: "Active stay plans, validity & renewals",
            onTap: () => _showSubscriptionsSheet(context, controller),
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.account_balance_wallet_rounded,
            title: "PG Wallet & Transactions",
            subtitle: "Recharges, cashback & deposit history",
            onTap: () => _showWalletSheet(context, controller),
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.badge_outlined,
            title: "Personal Profile & Details",
            subtitle: "Name, email, phone & KYC details",
            onTap: () => _showProfileSheet(context, controller),
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.headset_mic_rounded,
            title: "Help & Customer Support",
            subtitle: "24/7 dedicated support for tenants",
            onTap: () {
              LaunchHelper.callUs(number: "9876543210");
            },
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.logout_rounded,
            title: "Log Out",
            subtitle: "Sign out of your account",
            iconColor: const Color(0xFFDC2626),
            textColor: const Color(0xFFDC2626),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF002060)).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? const Color(0xFF002060),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor ?? const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11.5,
          color: Color(0xFF64748B),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 7. DEDICATED WALLET BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showWalletSheet(BuildContext context, RoomController controller) {
    controller.fetchPgCustomerWallet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "PG Smart Wallet",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: GetBuilder<RoomController>(
                  builder: (ctrl) {
                    final wallet = ctrl.customerWalletData;
                    if (ctrl.isCustomerWalletLoading && wallet == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final transactions = wallet?.transactions ?? [];

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Wallet Balance Banner
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF002060), Color(0xFF1E3A8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Available Balance",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                wallet?.formattedBalance ?? "₹0.00",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Total Transactions: ${wallet?.totalTransactions ?? 0}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Transaction History",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (transactions.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 36),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                const Text(
                                  "No wallet transactions recorded yet",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              final isCredit =
                                  (tx.type ?? "").toLowerCase() == 'credit';

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isCredit
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626))
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCredit
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: isCredit
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  tx.description ?? "Wallet Transaction",
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  "${tx.referenceId ?? ''}\n${tx.formattedDate ?? ''}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                trailing: Text(
                                  tx.formattedAmount ??
                                      "${isCredit ? '+' : '-'}₹${tx.amount ?? 0}",
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: isCredit
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 8. DEDICATED PROFILE DETAILS SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showProfileSheet(BuildContext context, RoomController controller) {
    controller.fetchPgCustomerProfile();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Personal Profile Details",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GetBuilder<RoomController>(
                  builder: (ctrl) {
                    final profile = ctrl.customerProfileData;
                    final customer = ctrl.customerDashboardData?.customer;

                    final name = profile?.name ?? customer?.name ?? "Customer";
                    final email = profile?.email ?? customer?.email ?? "N/A";
                    final phone = profile?.phone ?? customer?.phone ?? "N/A";
                    final gender =
                        profile?.gender ?? customer?.gender ?? "Not Specified";
                    final dob = profile?.dateOfBirth ?? "Not Specified";
                    final bloodGroup = profile?.bloodGroup ?? "Not Specified";
                    final address =
                        profile?.address ?? customer?.address ?? "Not Provided";
                    final city =
                        profile?.city ?? customer?.city ?? "Not Provided";
                    final state = profile?.state ?? "Not Provided";
                    final country = profile?.country ?? "India";
                    final status = profile?.status ?? "active";

                    return ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF002060),
                                      Color(0xFF1E3A8A)
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  (profile?.initials ??
                                          customer?.initials ??
                                          "CU")
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A34A)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildProfileInfoRow(
                            "Mobile Phone", phone, Icons.phone_rounded),
                        _buildProfileInfoRow(
                            "Email Address", email, Icons.email_outlined),
                        _buildProfileInfoRow(
                            "Gender", gender, Icons.person_outline_rounded),
                        _buildProfileInfoRow(
                            "Date of Birth", dob, Icons.cake_outlined),
                        _buildProfileInfoRow("Blood Group", bloodGroup,
                            Icons.bloodtype_outlined),
                        _buildProfileInfoRow(
                            "Address", address, Icons.home_outlined),
                        _buildProfileInfoRow("City / State", "$city, $state",
                            Icons.location_city_rounded),
                        _buildProfileInfoRow(
                            "Country", country, Icons.public_rounded),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF002060).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF002060)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 9. DEDICATED BOOKING DETAIL SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showBookingDetailSheet(
    BuildContext context,
    PgCustomerBookingItem booking,
    RoomController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Booking ${booking.shortId ?? ''}",
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    // Property Name
                    Text(
                      booking.property?.title ?? "PG Room",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${booking.property?.address ?? ''}, ${booking.property?.city ?? ''}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Key Specs
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                              "Status",
                              booking.statusLabel ??
                                  booking.status?.toUpperCase() ??
                                  ""),
                          const Divider(height: 16),
                          _buildDetailRow(
                              "Payment Status",
                              booking.paymentStatusBadge?.isNotEmpty == true
                                  ? booking.paymentStatusBadge!
                                  : (booking.paymentStatus ?? "")
                                      .toUpperCase()),
                          const Divider(height: 16),
                          _buildDetailRow("Occupancy",
                              booking.occupancyTypeDisplay ?? "Per Bed"),
                          const Divider(height: 16),
                          _buildDetailRow(
                              "Beds Booked", booking.bedsDisplay ?? "1 Bed"),
                          const Divider(height: 16),
                          _buildDetailRow(
                              "Total Rent",
                              booking.formattedAmount ??
                                  "₹${booking.finalAmount ?? 0}"),
                          if (booking.invoice?['invoice_number'] != null) ...[
                            const Divider(height: 16),
                            _buildDetailRow("Invoice Number",
                                booking.invoice!['invoice_number'].toString()),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (booking.actions?['can_pay'] == true) ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          navigate(
                            context: context,
                            page: const MyRoomBookingScreen(),
                          );
                        },
                        child: const Text(
                          "Pay with Razorpay",
                          style: TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    if (booking.invoice != null) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002060),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: controller.isInvoiceDownloading
                            ? null
                            : () {
                                final invId =
                                    booking.invoice!['id']?.toString() ??
                                        booking.id ??
                                        "";
                                final invNum = booking
                                    .invoice!['invoice_number']
                                    ?.toString();
                                controller.downloadOrOpenInvoicePdf(
                                  invoiceId: invId,
                                  invoiceNumber: invNum,
                                );
                              },
                        icon: controller.isInvoiceDownloading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf_rounded,
                                size: 18),
                        label: Text(
                          controller.isInvoiceDownloading
                              ? "Opening Invoice..."
                              : "Download Invoice PDF",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF002060),
                        side: const BorderSide(color: Color(0xFF002060)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 10. ACTIVE SUBSCRIPTIONS DASHBOARD SECTION
  // ══════════════════════════════════════════════════════════════════
  Widget _buildActiveSubscriptionsSection(
    BuildContext context,
    List<PgCustomerSubscriptionItem> subscriptions,
    RoomController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Active Subscriptions & Plans",
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showSubscriptionsSheet(context, controller),
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
          itemCount: subscriptions.length > 2 ? 2 : subscriptions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final sub = subscriptions[index];
            return _buildActiveSubscriptionCard(context, sub, controller);
          },
        ),
      ],
    );
  }

  Widget _buildActiveSubscriptionCard(
    BuildContext context,
    PgCustomerSubscriptionItem sub,
    RoomController controller,
  ) {
    final property = sub.property;
    final isActive = (sub.status ?? "").toLowerCase() == 'active';
    final packageName = sub.package?['name']?.toString() ?? "Stay Plan";
    final packagePrice = sub.package?['price']?.toString() ?? "0";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Header: Sub number and status badge
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
                      Icons.card_membership_rounded,
                      size: 16,
                      color: Color(0xFF002060),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sub.subscriptionNumber ?? "Subscription",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF002060),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sub.statusLabel ?? (isActive ? "Active" : "Inactive"),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Property title and address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (property?.image != null && property!.image!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    property.image!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF002060).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.home_work_outlined,
                          size: 22, color: Color(0xFF002060)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property?.title ?? "PG Accommodation",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      property?.address ?? property?.city ?? "India",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Plan details summary banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packageName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002060),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub.occupancyType == 'per_bed'
                          ? "Per Bed (${sub.bedsBooked ?? 1} Bed)"
                          : (sub.occupancyType ?? "Standard"),
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹$packagePrice",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub.daysRemaining != null
                          ? "${sub.daysRemaining} days left"
                          : (sub.formattedExpiresAt ?? "Valid"),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Bottom Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Valid: ${sub.formattedStartsAt ?? sub.startsAt ?? ''} - ${sub.formattedExpiresAt ?? sub.expiresAt ?? ''}",
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () =>
                    _showSubscriptionDetailSheet(context, sub, controller),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: Text(
                    "View Plan",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF002060),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 11. RECENT INVOICES DASHBOARD SECTION
  // ══════════════════════════════════════════════════════════════════
  Widget _buildRecentInvoicesSection(
    BuildContext context,
    List<PgCustomerInvoiceItem> invoices,
    RoomController controller,
  ) {
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
            return _buildInvoiceCard(context, inv, controller);
          },
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    PgCustomerInvoiceItem invoice,
    RoomController controller,
  ) {
    final isPaid = (invoice.status ?? "").toLowerCase() == 'paid';
    final isDownloading = controller.isInvoiceDownloading &&
        controller.downloadingInvoiceId == invoice.id;

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
              // Header: Invoice No and Status Pill
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

              // Property title
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

              // Booking number & Date
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
                ],
              ),

              const Divider(height: 18, color: Color(0xFFF1F5F9)),

              // Amount and Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        invoice.formattedTotal ??
                            "₹${invoice.total ?? invoice.amount ?? 0}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF002060),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                        ),
                        onPressed: openInvoicePdfDetail,
                        icon: const Icon(Icons.remove_red_eye_outlined,
                            size: 15),
                        label: const Text(
                          "View PDF",
                          style: TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002060),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isDownloading
                            ? null
                            : () {
                                controller.downloadOrOpenInvoicePdf(
                                  invoiceId: invoice.id ?? "",
                                  invoiceNumber: invoice.invoiceNumber,
                                );
                              },
                        icon: isDownloading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf_rounded,
                                size: 15),
                        label: Text(
                          isDownloading ? "Opening..." : "Download",
                          style: const TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 12. DEDICATED INVOICES BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showInvoicesSheet(BuildContext context, RoomController controller) {
    controller.fetchPgCustomerInvoices();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.82,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "PG Invoices & Receipts",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GetBuilder<RoomController>(
                          builder: (ctrl) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF002060)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "${ctrl.customerInvoicesList.length}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF002060),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: GetBuilder<RoomController>(
                  builder: (ctrl) {
                    if (ctrl.isCustomerInvoicesLoading &&
                        ctrl.customerInvoicesList.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF002060),
                        ),
                      );
                    }

                    final invoices = ctrl.customerInvoicesList;

                    if (invoices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF002060)
                                    .withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                size: 40,
                                color: Color(0xFF002060),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "No Invoices Found",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Invoices for room bookings will show here.",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: invoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildInvoiceCard(
                            context, invoices[index], ctrl);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 13. DEDICATED SUBSCRIPTIONS BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showSubscriptionsSheet(
      BuildContext context, RoomController controller) {
    controller.fetchPgCustomerSubscriptions();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "My PG Subscriptions",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GetBuilder<RoomController>(
                          builder: (ctrl) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF002060)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "${ctrl.customerSubscriptionsList.length}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF002060),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: GetBuilder<RoomController>(
                  builder: (ctrl) {
                    if (ctrl.isCustomerSubscriptionsLoading &&
                        ctrl.customerSubscriptionsList.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF002060),
                        ),
                      );
                    }

                    final subscriptions = ctrl.customerSubscriptionsList;

                    if (subscriptions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF002060)
                                    .withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.card_membership_rounded,
                                size: 40,
                                color: Color(0xFF002060),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "No Active Subscriptions",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Active PG subscriptions and stay plans will show here.",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: subscriptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildActiveSubscriptionCard(
                            context, subscriptions[index], ctrl);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 14. DEDICATED SUBSCRIPTION DETAIL BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showSubscriptionDetailSheet(
    BuildContext context,
    PgCustomerSubscriptionItem subscription,
    RoomController controller,
  ) {
    if (subscription.id != null) {
      controller.fetchPgCustomerSubscriptionDetail(subscription.id!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.82,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Subscription Details",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: GetBuilder<RoomController>(
                  builder: (ctrl) {
                    if (ctrl.isCustomerSubscriptionDetailLoading &&
                        ctrl.selectedCustomerSubscription == null) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF002060),
                        ),
                      );
                    }

                    final item =
                        ctrl.selectedCustomerSubscription ?? subscription;
                    final property = item.property;
                    final pkg = item.package;

                    return ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        // Property Header Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF002060).withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFF002060)
                                    .withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF002060),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.home_work_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      property?.title ?? "PG Accommodation",
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      property?.address ??
                                          property?.city ??
                                          "India",
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Subscription breakdown container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("Subscription ID",
                                  item.subscriptionNumber ?? "N/A"),
                              const Divider(height: 16),
                              _buildDetailRow(
                                  "Status",
                                  (item.statusLabel ?? item.status ?? "Active")
                                      .toUpperCase()),
                              const Divider(height: 16),
                              _buildDetailRow(
                                  "Plan Name",
                                  pkg?['name']?.toString().toUpperCase() ??
                                      "Stay Plan"),
                              const Divider(height: 16),
                              _buildDetailRow(
                                  "Monthly Rent", "₹${pkg?['price'] ?? 0}"),
                              const Divider(height: 16),
                              _buildDetailRow(
                                  "Occupancy",
                                  item.occupancyType == 'per_bed'
                                      ? "Per Bed (${item.bedsBooked ?? 1} Bed)"
                                      : (item.occupancyType ?? "Standard")),
                              const Divider(height: 16),
                              _buildDetailRow(
                                  "Start Date",
                                  item.formattedStartsAt ??
                                      item.startsAt ??
                                      "N/A"),
                              const Divider(height: 16),
                              _buildDetailRow(
                                  "Expiry Date",
                                  item.formattedExpiresAt ??
                                      item.expiresAt ??
                                      "N/A"),
                              if (item.daysRemaining != null) ...[
                                const Divider(height: 16),
                                _buildDetailRow("Days Remaining",
                                    "${item.daysRemaining} days"),
                              ],
                              const Divider(height: 16),
                              _buildDetailRow(
                                  "Auto Renew",
                                  item.autoRenew == true
                                      ? "Enabled"
                                      : "Disabled"),
                              if (item.website?['name'] != null) ...[
                                const Divider(height: 16),
                                _buildDetailRow("Host / Portal",
                                    item.website!['name'].toString()),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF002060),
                            side: const BorderSide(color: Color(0xFF002060)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text(
                            "Close",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // LOGOUT CONFIRMATION DIALOG
  // ══════════════════════════════════════════════════════════════════
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Confirm Log Out",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: const Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (Get.isRegistered<AuthController>()) {
                await Get.find<AuthController>().logout();
              }
              if (context.mounted) {
                navigate(
                    context: context,
                    isRemoveUntil: true,
                    page: const LoginScreen());
              }
              AppRouter.goToLogin();
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }
}
