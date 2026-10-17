import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/visit_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/gym/gym_book_visit/gym_my_visit_detail_screen.dart';

class GymMyVisitListScreen extends StatefulWidget {
  final int initialIndex;
  const GymMyVisitListScreen({super.key, this.initialIndex = 0});

  @override
  State<GymMyVisitListScreen> createState() => _GymMyVisitListScreenState();
}

class _GymMyVisitListScreenState extends State<GymMyVisitListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    Get.find<GymController>().fetchMyGymBookings();
    Get.find<VisitController>().fetchVisits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: black.withValues(alpha: 0.05),
        centerTitle: false,
        title: Text(
          "My Gym",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: blackText1,
              ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF002060),
              unselectedLabelColor: greyText3,
              indicatorColor: const Color(0xFF002060),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                GetBuilder<GymController>(
                  builder: (gymCtrl) {
                    final count = gymCtrl.myGymMembershipsList.length;
                    return Tab(
                      child: Text(
                        "Memberships ${count > 0 ? '($count)' : ''}",
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  },
                ),
                GetBuilder<GymController>(
                  builder: (gymCtrl) {
                    final count = gymCtrl.myGymVisitsList.isNotEmpty
                        ? gymCtrl.myGymVisitsList.length
                        : Get.find<VisitController>().visitList.length;
                    return Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.tour_rounded, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "Visits ${count > 0 ? '($count)' : ''}",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembershipsTab(),
          _buildVisitsTab(),
        ],
      ),
    );
  }

  Widget _buildMembershipsTab() {
    return GetBuilder<GymController>(builder: (gymController) {
      if (gymController.isMyGymBookingsLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final memberships = gymController.myGymMembershipsList;
      if (memberships.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.card_membership_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No Active Memberships",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Book a gym membership plan to enjoy unrestricted workouts.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: greyText3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: memberships.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = memberships[index];
            final gymName = item['gym_name']?.toString() ?? "Gym Sanctuary";
            final gymAddress = item['gym_address']?.toString() ?? "";
            final packageName =
                item['package_name']?.toString() ?? "Membership";
            final finalAmount = item['final_amount'] ?? item['package_price'];
            final paymentMethod =
                item['payment_method']?.toString().toUpperCase() ?? "CASH";
            final status =
                item['status']?.toString().replaceAll("_", " ").toUpperCase() ??
                    "PENDING";
            final otp = item['otp']?.toString();
            final bookingNumber = item['booking_number']?.toString() ?? "";
            final createdAt = item['created_at']?.toString() ?? "";

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gym Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF002060).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFF002060),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gymName,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            if (gymAddress.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                gymAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: greyText3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status.contains("COMPLETED") ||
                                  status.contains("ACTIVE")
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: status.contains("COMPLETED") ||
                                    status.contains("ACTIVE")
                                ? Colors.green
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Package & Amount Strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              packageName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF002060),
                              ),
                            ),
                            Text(
                              "Method: $paymentMethod",
                              style: TextStyle(
                                fontSize: 10.5,
                                color: greyText3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (finalAmount != null)
                          Text(
                            "₹$finalAmount",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Prominent OTP section if pending
                  if (otp != null && otp.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF002060), Color(0xFF0D47A1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.vpn_key_rounded,
                                  color: Color(0xFFFFD54F), size: 16),
                              const SizedBox(width: 8),
                              const Text(
                                "OTP: ",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
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
                                message: "OTP copied: $otp",
                                toastType: ToastType.success,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.copy_rounded,
                                      size: 13, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    "COPY",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (bookingNumber.isNotEmpty || createdAt.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (bookingNumber.isNotEmpty)
                          Text(
                            "No: $bookingNumber",
                            style: TextStyle(
                              fontSize: 10.5,
                              color: greyText3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (createdAt.isNotEmpty)
                          Text(
                            createdAt.split(" ").first,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: greyText3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildVisitsTab() {
    return GetBuilder<GymController>(builder: (gymController) {
      return GetBuilder<VisitController>(builder: (visitController) {
        if (gymController.isMyGymBookingsLoading || visitController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final gymVisits = gymController.myGymVisitsList;
        final directVisits = visitController.visitList;

        final hasItems = gymVisits.isNotEmpty || directVisits.isNotEmpty;
        if (!hasItems) {
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.tour_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No Scheduled Visits",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Schedule a free gym tour or trial workout anytime.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: greyText3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Render visits from gym endpoint if present, else fallback to VisitController list
        final int itemCount =
            gymVisits.isNotEmpty ? gymVisits.length : directVisits.length;

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: itemCount,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (gymVisits.isNotEmpty) {
                final visit = gymVisits[index];
                final gymName =
                    visit['gym_name']?.toString() ?? "Gym Sanctuary";
                final gymAddress = visit['gym_address']?.toString() ?? "";
                final visitDate = visit['visit_date']?.toString() ?? "";
                final visitTime = visit['visit_time']?.toString() ?? "";
                final note = visit['note']?.toString() ?? "";
                final status = visit['status']
                        ?.toString()
                        .replaceAll("_", " ")
                        .toUpperCase() ??
                    "PENDING";
                final bookingNumber = visit['booking_number']?.toString() ?? "";

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.explore_rounded,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gymName,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                if (gymAddress.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    gymAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: greyText3,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 14, color: primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              visitDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF222222),
                              ),
                            ),
                            if (visitTime.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time_rounded,
                                  size: 14, color: primaryColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  visitTime,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: greyText3,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          note,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: greyText3,
                          ),
                        ),
                      ],
                      if (bookingNumber.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          "No: $bookingNumber",
                          style: TextStyle(
                            fontSize: 10.5,
                            color: greyText3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              } else {
                final visit = directVisits[index];
                return GestureDetector(
                  onTap: () {
                    navigate(
                      context: context,
                      page: GymMyVisitDetailScreen(visitId: visit.id ?? ""),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: greyLight2.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    visit.listing?.title ?? "Unknown Gym",
                                    style: Helper(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                  ),
                                  sizedBoxHeight(height: 8),
                                  Text(
                                    "Date: ${visit.visitDate} | Time: ${visit.visitTime}",
                                    style: Helper(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: greyText2,
                                          fontSize: 14,
                                        ),
                                  ),
                                  sizedBoxHeight(height: 8),
                                  Text(
                                    "Status: ${capitalize(visit.status)}",
                                    style: Helper(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: visit.status == 'pending'
                                              ? Colors.orange
                                              : Colors.green,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        sizedBoxHeight(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                context: context,
                                label: "Call",
                                icon: Icons.phone_outlined,
                                color: Colors.green,
                                onTap: () {
                                  if (visit.listing?.phone != null) {
                                    LaunchHelper.callUs(
                                        number:
                                            visit.listing!.phone!.toString());
                                  } else {
                                    showToast(
                                        message: "Phone number not available");
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionButton(
                                context: context,
                                label: "Map",
                                icon: Icons.map_outlined,
                                color: Colors.blue,
                                onTap: () {
                                  if (visit.listing?.lat != null &&
                                      visit.listing?.lng != null) {
                                    LaunchHelper.openGoogleMap(
                                      lat: visit.listing!.lat!.toString(),
                                      lng: visit.listing!.lng!.toString(),
                                    );
                                  } else {
                                    showToast(
                                        message: "Location not available");
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionButton(
                                context: context,
                                label: "Help",
                                icon: Icons.help_outline,
                                color: Colors.orange,
                                onTap: () {
                                  LaunchHelper.launchInBrowser(Uri.parse(
                                      "https://app.feetrack.in/about-us"));
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        );
      });
    });
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
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
