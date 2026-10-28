import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/room_section/pg_subscription/my_pg_subscription_screen.dart';
import 'package:vlr/views/screens/room_section/pg_wallet/my_pg_wallet_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_booking_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_visit_list_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_invoice_list_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_payment_history_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_saved_listings_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/widgets/pg_profile_header_card.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/widgets/pg_profile_metrics_grid.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/widgets/pg_profile_options_card.dart';
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

  Future<void> _loadData() async {
    if (Get.isRegistered<RoomController>()) {
      final ctrl = Get.find<RoomController>();
      await Future.wait([
        ctrl.fetchPgCustomerDashboard(),
        ctrl.fetchPgCustomerWallet(),
        ctrl.fetchPgCustomerProfile(),
        ctrl.fetchPgCustomerInvoices(),
        ctrl.fetchPgCustomerSubscriptions(),
        ctrl.fetchPgSavedListings(),
        ctrl.fetchPgCustomerPayments(),
      ]);
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
          final balanceStr = controller.customerWalletData?.formattedBalance ??
              (controller.isCustomerWalletLoading
                  ? "Loading..."
                  : controller.customerWalletError != null
                      ? "Unavailable"
                      : "—");

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Customer Profile Card
                  PgProfileHeaderCard(
                    customer: customer,
                    profile: controller.customerProfileData,
                    header: header,
                    onProfileTap: () =>
                        PgProfileSheets.showProfileSheet(context, controller),
                  ),

                  const SizedBox(height: 16),

                  // 2. PG Wallet Card
                  PgProfileWalletCard(
                    balance: balanceStr,
                    onTransactionsTap: () => navigate(
                      context: context,
                      page: const MyPgWalletScreen(),
                    ),
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
                    onSubscriptionsTap: () => navigate(
                      context: context,
                      page: const MyPgSubscriptionScreen(),
                    ),
                    onPaymentsTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const PgPaymentHistoryScreen(),
                        ),
                      );
                    },
                    onWalletTap: () => navigate(
                      context: context,
                      page: const MyPgWalletScreen(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 8. Account & Services Options Card
                  PgProfileOptionsCard(
                    onBookingsTap: () {
                      navigate(
                        context: context,
                        page: const MyRoomBookingScreen(),
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
                    onSubscriptionsTap: () => navigate(
                      context: context,
                      page: const MyPgSubscriptionScreen(),
                    ),
                    onWalletTap: () => navigate(
                      context: context,
                      page: const MyPgWalletScreen(),
                    ),
                    onProfileTap: () =>
                        PgProfileSheets.showProfileSheet(context, controller),
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
