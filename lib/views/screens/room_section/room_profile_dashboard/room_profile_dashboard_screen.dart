import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/views/screens/room_section/attendance/attendance_checkin_checkout_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_booking_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_visit_list_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_invoice_list_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_payment_history_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_saved_listings_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/widgets/pg_profile_header_card.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/widgets/pg_profile_metrics_grid.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/widgets/pg_profile_options_card.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/widgets/pg_profile_recent_sections.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/widgets/pg_profile_sheets.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/widgets/pg_profile_wallet_card.dart';

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
      ctrl.fetchPgSavedListings();
      ctrl.fetchPgCustomerPayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Customer Profile",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.headset_mic_outlined,
              color: Color(0xFF002060),
            ),
            tooltip: "Contact Support",
            onPressed: () {
              LaunchHelper.callUs(number: "9876543210");
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF002060),
            ),
            tooltip: "Notifications",
            onPressed: () {
              Get.snackbar(
                "Notifications",
                "You have 4 unread booking & stay notifications.",
                backgroundColor: const Color(0xFF002060),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(width: 4),
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
          final balanceStr = controller.customerWalletData?.formattedBalance ??
              header?.formattedWalletBalance ??
              "₹0.00";

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: () async {
              _loadData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Customer Profile Card
                  PgProfileHeaderCard(
                    customer: customer,
                    header: header,
                    onProfileTap: () =>
                        PgProfileSheets.showProfileSheet(context, controller),
                  ),

                  const SizedBox(height: 16),

                  // 2. PG Wallet Card
                  PgProfileWalletCard(
                    balance: balanceStr,
                    onTransactionsTap: () =>
                        PgProfileSheets.showWalletSheet(context, controller),
                    onRechargeTap: () =>
                        PgProfileSheets.showWalletRechargeDialog(
                            context, controller),
                  ),

                  const SizedBox(height: 16),

                  // 3. Key Metrics Cards Grid
                  PgProfileMetricsGrid(
                    metrics: metrics,
                    onVisitsTap: () {
                      navigate(
                        context: context,
                        page: const MyRoomVisitListScreen(),
                      );
                    },
                    onBookingsTap: () {
                      navigate(
                        context: context,
                        page: const MyRoomBookingScreen(),
                      );
                    },
                    onSubscriptionsTap: () =>
                        PgProfileSheets.showSubscriptionsSheet(
                            context, controller),
                    onInvoicesTap: () =>
                        PgProfileSheets.showInvoicesSheet(context, controller),
                  ),

                  // 4. Recent Bookings (if available)
                  if (sections != null &&
                      sections.recentBookings.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    PgRecentBookingsSection(
                      bookings: sections.recentBookings,
                      controller: controller,
                      onBookingTap: (booking) =>
                          PgProfileSheets.showBookingDetailSheet(
                              context, booking, controller),
                    ),
                  ],

                  // 5. Active Subscriptions (if available)
                  if (sections != null &&
                      sections.activeSubscriptions.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    PgActiveSubscriptionsSection(
                      subscriptions: sections.activeSubscriptions,
                      controller: controller,
                      onSubscriptionTap: (sub) =>
                          PgProfileSheets.showSubscriptionDetailSheet(
                              context, sub),
                    ),
                  ],

                  // 6. Recent Visits (if available)
                  if (sections != null &&
                      sections.recentVisits.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    PgRecentVisitsSection(
                      visits: sections.recentVisits,
                    ),
                  ],

                  // 7. Recent Invoices (if available)
                  if (sections != null &&
                      sections.pendingInvoices.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    PgRecentInvoicesSection(
                      invoices: sections.pendingInvoices,
                      controller: controller,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 8. Account & Services Options Card
                  PgProfileOptionsCard(
                    onBookingsTap: () {
                      navigate(
                        context: context,
                        page: const MyRoomBookingScreen(),
                      );
                    },
                    onAttendanceTap: () {
                      navigate(
                        context: context,
                        page: const PgAttendanceCheckinCheckoutScreen(),
                      );
                    },
                    onVisitsTap: () {
                      navigate(
                        context: context,
                        page: const MyRoomVisitListScreen(),
                      );
                    },
                    onSavedListingsTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const PgSavedListingsScreen(),
                        ),
                      );
                    },
                    onPaymentHistoryTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const PgPaymentHistoryScreen(),
                        ),
                      );
                    },
                    onInvoicesTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const PgInvoiceListScreen(),
                        ),
                      );
                    },
                    onSubscriptionsTap: () =>
                        PgProfileSheets.showSubscriptionsSheet(
                            context, controller),
                    onWalletTap: () =>
                        PgProfileSheets.showWalletSheet(context, controller),
                    onProfileTap: () =>
                        PgProfileSheets.showProfileSheet(context, controller),
                    onSupportTap: () {
                      LaunchHelper.callUs(number: "9876543210");
                    },
                    onLogoutTap: () =>
                        PgProfileSheets.showLogoutDialog(context),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
