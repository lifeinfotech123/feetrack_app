import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/hospital/features/appointments/presentation/screen/booking_succsess_screen.dart';
import 'package:vlr/services/constants.dart';

class MyGymBookScreen extends StatefulWidget {
  const MyGymBookScreen({super.key});

  @override
  State<MyGymBookScreen> createState() => _MyGymBookScreenState();
}

class _MyGymBookScreenState extends State<MyGymBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<GymController>()) {
        Get.find<GymController>().fetchMyGymBookings();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshBookings() async {
    if (Get.isRegistered<GymController>()) {
      await Get.find<GymController>().fetchMyGymBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "My Gym Bookings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF002060),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: "Memberships"),
                  Tab(text: "Visits"),
                  Tab(text: "All"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<GymController>(
        builder: (gymCtrl) {
          if (gymCtrl.isMyGymBookingsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF002060)),
            );
          }

          final memberships = gymCtrl.myGymMembershipsList;
          final visits = gymCtrl.myGymVisitsList;
          final allBookings = gymCtrl.myGymBookingsList.isNotEmpty
              ? gymCtrl.myGymBookingsList
              : [...memberships, ...visits];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(
                items: memberships,
                emptyTitle: "No Memberships Found",
                emptySubtitle:
                    "You haven't purchased any gym memberships yet.",
              ),
              _buildBookingList(
                items: visits,
                emptyTitle: "No Gym Visits Scheduled",
                emptySubtitle: "Your scheduled gym visits will appear here.",
              ),
              _buildBookingList(
                items: allBookings,
                emptyTitle: "No Gym Bookings Yet",
                emptySubtitle:
                    "Explore gyms near you and book visits or memberships.",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList({
    required List<dynamic> items,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshBookings,
        color: const Color(0xFF002060),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF002060).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 40,
                  color: Color(0xFF002060),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBookings,
      color: const Color(0xFF002060),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final rawItem = items[index];
          final Map<String, dynamic> item =
              rawItem is Map ? Map<String, dynamic>.from(rawItem) : {};

          final bookingId = item['booking_number']?.toString() ??
              item['booking_id']?.toString() ??
              item['visit_id']?.toString() ??
              "BKG-${index + 100}";
          final gymName = item['gym_name']?.toString() ??
              item['gym_title']?.toString() ??
              item['gym']?.toString() ??
              "Gym Partner";
          final packageName = item['package_name']?.toString() ??
              item['package']?.toString() ??
              item['plan_name']?.toString() ??
              "Gym Membership Plan";
          final rawAmount = item['final_amount'] ??
              item['amount'] ??
              item['price'] ??
              item['total_amount'];
          final paymentMethod =
              item['payment_method']?.toString() ?? item['payment_mode']?.toString() ?? "online";
          final status = item['status']?.toString() ?? "confirmed";
          final otp = item['otp']?.toString();
          final createdAt = item['created_at']?.toString() ??
              item['visit_date']?.toString() ??
              "";

          return _buildBookingCard(
            context: context,
            item: item,
            bookingId: bookingId,
            gymName: gymName,
            packageName: packageName,
            amount: rawAmount != null ? "₹$rawAmount" : "₹0",
            paymentMethod: paymentMethod,
            status: status,
            otp: otp,
            dateStr: createdAt,
          );
        },
      ),
    );
  }

  Widget _buildBookingCard({
    required BuildContext context,
    required Map<String, dynamic> item,
    required String bookingId,
    required String gymName,
    required String packageName,
    required String amount,
    required String paymentMethod,
    required String status,
    required String? otp,
    required String dateStr,
  }) {
    final bool isCash = paymentMethod.toLowerCase().contains("cash") ||
        paymentMethod.toLowerCase().contains("offline");

    return InkWell(
      onTap: () {
        Get.to(() => BookingSuccsessScreen(
              bookingType: 'gym',
              bookingId: bookingId,
              gymTitle: gymName,
              packageName: packageName,
              amount: amount,
              otp: otp,
              paymentMethod: paymentMethod,
              status: status,
              date: dateStr,
              bookingData: item,
            ));
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Ref & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002060).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 18,
                          color: Color(0xFF002060),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gymName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bookingId,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(status, isCash),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),

            // Plan & Amount Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Package / Plan",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      packageName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isCash ? "Payable" : "Paid Amount",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF002060),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // OTP Box (if available)
            if (otp != null && otp.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF002060), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.vpn_key_rounded,
                          color: Color(0xFFFFD54F),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "ACTIVATION OTP:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          otp,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: otp));
                        showToast(
                          message: "Activation OTP copied: $otp",
                          toastType: ToastType.success,
                        );
                      },
                      child: const Icon(
                        Icons.copy_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (dateStr.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isCash) {
    Color bg;
    Color fg;
    String label;

    final s = status.toLowerCase();

    if (s.contains("pending_otp") || s.contains("pending")) {
      bg = const Color(0xFFFFF7ED);
      fg = const Color(0xFFC2410C);
      label = isCash ? "Pay Cash at Gym" : "Pending OTP";
    } else if (s.contains("completed") || s.contains("active") || s.contains("confirmed")) {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF15803D);
      label = "Confirmed";
    } else if (s.contains("cancelled") || s.contains("failed")) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFB91C1C);
      label = "Cancelled";
    } else {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF1D4ED8);
      label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
