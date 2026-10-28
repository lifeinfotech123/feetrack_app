import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit/gym_my_visit_detail_screen.dart';

class GymMyVisitsScreen extends StatelessWidget {
  const GymMyVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const GymActivityScreen(showVisits: true);
}

class GymMembershipsScreen extends StatelessWidget {
  const GymMembershipsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const GymActivityScreen(showVisits: false);
}

class GymActivityScreen extends StatefulWidget {
  final bool showVisits;
  const GymActivityScreen({super.key, required this.showVisits});

  @override
  State<GymActivityScreen> createState() => _GymActivityScreenState();
}

class _GymActivityScreenState extends State<GymActivityScreen> {
  String get _title => widget.showVisits ? 'My Visits' : 'My Memberships';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<AuthController>() &&
          Get.find<AuthController>().isLoggedIn()) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn()) {
      final gymController = Get.find<GymController>();
      if (widget.showVisits) {
        await gymController.fetchMyGymVisits();
      } else {
        await gymController.fetchMyGymBookings();
      }
    } else {
      if (Get.isRegistered<GymController>()) {
        final gymController = Get.find<GymController>();
        gymController
          ..clearMyGymBookings()
          ..clearMyGymVisits();
      }
    }
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                Icons.lock_outline_rounded,
                size: 40,
                color: Color(0xFF002060),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "You are browsing as Guest",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please log in to view ${_title.toLowerCase()}.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: greyText3,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                if (mounted &&
                    Get.isRegistered<AuthController>() &&
                    Get.find<AuthController>().isLoggedIn()) {
                  _loadData();
                  setState(() {});
                }
              },
              icon: const Icon(Icons.login_rounded,
                  color: Colors.white, size: 18),
              label: const Text(
                "Log In Now",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002060),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final bool isLoggedIn = authController.isLoggedIn();

        if (!isLoggedIn) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              shadowColor: black.withValues(alpha: 0.05),
              centerTitle: false,
              title: Text(
                _title,
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: blackText1,
                    ),
              ),
            ),
            body: _buildGuestView(context),
          );
        }

        // If logged in, ensure data is loaded if empty
        final gymCtrl = Get.find<GymController>();
        final needsInitialLoad = widget.showVisits
            ? !gymCtrl.hasLoadedMyGymVisits && !gymCtrl.isMyGymVisitsLoading
            : !gymCtrl.hasLoadedMyGymBookings &&
                !gymCtrl.isMyGymBookingsLoading;
        if (needsInitialLoad) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadData();
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            shadowColor: black.withValues(alpha: 0.05),
            centerTitle: false,
            title: Text(
              _title,
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: blackText1,
                  ),
            ),
          ),
          body:
              widget.showVisits ? _buildVisitsList() : _buildMembershipsList(),
        );
      },
    );
  }

  Widget _buildMembershipsList() {
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
                    Text(
                      gymController.myGymBookingsError == null
                          ? "No Membership Bookings"
                          : "Could Not Load Memberships",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gymController.myGymBookingsError ??
                          "Book a gym membership plan to enjoy unrestricted workouts.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: greyText3,
                      ),
                    ),
                    if (gymController.myGymBookingsError != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("Retry"),
                      ),
                    ],
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
            final rawStatus = (item['activation_status'] ??
                    item['membership_status'] ??
                    item['status'] ??
                    "pending_activation")
                .toString()
                .toLowerCase()
                .replaceAll('-', '_');
            final status = switch (rawStatus) {
              "completed" || "pending" || "pending_otp" => "PENDING ACTIVATION",
              "active" => "ACTIVE",
              "inactive" => "INACTIVE",
              "expired" => "EXPIRED",
              _ => rawStatus.replaceAll("_", " ").toUpperCase(),
            };
            final otp = item['otp']?.toString();
            final membershipId = item['membership_id']?.toString() ??
                item['booking_id']?.toString() ??
                "";
            final createdAt = item['created_at']?.toString() ?? "";
            final membershipDetails = <MapEntry<String, String>>[
              MapEntry("Start Date", item['start_date']?.toString() ?? ""),
              MapEntry(
                "Expiry Date",
                (item['expiry_date'] ?? item['expires_at'])?.toString() ?? "",
              ),
              MapEntry(
                "Trainer",
                (item['trainer_name'] ??
                            (item['trainer'] is Map
                                ? item['trainer']['name']
                                : null))
                        ?.toString() ??
                    "",
              ),
              MapEntry(
                "Schedule",
                (item['trainer_schedule'] ?? item['schedule'])?.toString() ??
                    "",
              ),
            ].where((entry) => entry.value.isNotEmpty).toList();
            final benefits = item['benefits'] is List
                ? (item['benefits'] as List)
                    .map((benefit) => benefit.toString())
                    .toList()
                : <String>[];

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
                          color: status == "ACTIVE"
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: status == "ACTIVE"
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

                  if (membershipDetails.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...membershipDetails.map(
                      (detail) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                detail.key,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: greyText3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                detail.value,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (benefits.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Membership Benefits",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    ...benefits.map(
                      (benefit) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 14, color: Colors.green),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                benefit,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

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

                  if (membershipId.isNotEmpty || createdAt.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (membershipId.isNotEmpty)
                          Text(
                            "Membership ID: $membershipId",
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

  Widget _buildVisitsList() {
    return GetBuilder<GymController>(builder: (gymController) {
      if (gymController.isMyGymVisitsLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final gymVisits = gymController.myGymVisitsList;
      if (gymVisits.isEmpty) {
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

      return RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: gymVisits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final visit = gymVisits[index];
            final visitId = visit['id']?.toString() ??
                visit['booking_id']?.toString() ??
                visit['booking_number']?.toString() ??
                "";
            final gymName = visit['gym_name']?.toString() ?? "Gym Sanctuary";
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

            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Get.to(() => GymMyVisitDetailScreen(
                        visitId: visitId,
                        initialData: visit,
                      ));
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
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
                          const SizedBox(width: 8),
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
                      const SizedBox(height: 12),
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
                            )
                          else
                            const SizedBox.shrink(),
                          const Row(
                            children: [
                              Text(
                                "View Details",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: primaryColor,
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
          },
        ),
      );
    });
  }
}
