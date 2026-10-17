import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/basic_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/screens/gym/new_gym_sceen/gym_profile_screen/widget/new_gym_banner.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_med_section/gym_profile_about_facilities_section.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_other_batch_section/gym_other_batch_section.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_profile_trainer_section/gym_profile_trainer_section.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_reviews_section.dart/gym_profile_review_section.dart';
import '../../../../../../../controllers/subscription_controller.dart';
import '../../../../../../../services/lanch_helper.dart';
import '../../../../../gym/gym_book_visit/gym_book_visit_screen.dart';
import '../../../../../gym/gym_select_plan_screen.dart/gym_select_plan_screen.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_shift_section/gym_profile_shift_section.dart';

class GymHomeDetailsScreen extends StatefulWidget {
  final String? listingId;
  const GymHomeDetailsScreen({super.key, this.listingId});

  @override
  State<GymHomeDetailsScreen> createState() => _GymHomeDetailsScreenState();
}

class _GymHomeDetailsScreenState extends State<GymHomeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeController = Get.find<HomeController>();
      final basicController = Get.find<BasicController>();
      final subscriptionController = Get.find<SubscriptionController>();

      final targetId =
          widget.listingId ?? homeController.selectListingModel?.id ?? "";
      log("GymHomeDetailsScreen: Fetching listing details for ID: $targetId...");

      if (targetId.isNotEmpty) {
        await homeController.fetchGymDetails(id: targetId);
      } else {
        await homeController.fetchCategoriesListingById();
      }

      final listing = homeController.selectListingModel;
      final listingId = listing?.id ?? targetId;

      log("GymHomeDetailsScreen: Listing ID: $listingId");

      homeController.fetchFacilitiesListingById();
      homeController.fetchStaffListingById();
      Get.find<GymController>().fetchGymTrainers(listingId: listingId);
      Get.find<GymController>().fetchGymShifts(gymId: listingId);

      subscriptionController.fetchPlanListingById(id: listingId);
      basicController.fetchListingReviewsByIdPagination(id: listingId);
    });
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final formattedMinute = minute.toString().padLeft(2, '0');
        return '$formattedHour:$formattedMinute $ampm';
      }
    } catch (_) {}
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar:
          GetBuilder<HomeController>(builder: (homeController) {
        return _PractoBottomBar(homeController: homeController);
      }),
      body: GetBuilder<HomeController>(builder: (homeController) {
        final listing = homeController.selectListingModel;
        final category = listing?.category;
        final hasTrainers =
            (listing?.trainers != null && listing!.trainers!.isNotEmpty) ||
                (category?.hasTrainers ?? true);

        final opening = _formatTime(listing?.openingTime);
        final closing = _formatTime(listing?.closingTime);
        final timings = (opening.isNotEmpty && closing.isNotEmpty)
            ? "$opening – $closing"
            : "Not Available";

        return CustomScrollView(
          slivers: [
            // ── 1. Photo Banner ──────────────────────────────────────────
            const SliverToBoxAdapter(child: NewGymProfileBanner()),

            // ── 2. White card body ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 2a. Profile header ──────────────────────────────
                    _GymProfileHeader(
                      listing: listing,
                      category: category,
                      timings: timings,
                    ),

                    const _SectionDivider(),

                    // ── 2b. Highlight strip (rating + recommendation) ───
                    _HighlightStrip(listing: listing),

                    // ── 2c. Gym Visit card ──────────────────────────────
                    _GymVisitCard(listing: listing, timings: timings),

                    const _SectionDivider(),

                    // ── 2d. Available Gym Shifts & Batches ───────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GYMProfileShiftSection(
                        gymId: listing?.id ?? widget.listingId,
                      ),
                    ),

                    const _SectionDivider(),

                    // ── 2e. About & Facilities ──────────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: GYMprofileAboutAndFacilitiesSection(),
                    ),

                    // ── 2e. Expert Trainers ─────────────────────────────
                    if (hasTrainers) ...[
                      const _SectionDivider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: GYMProfileTrainerSection(),
                      ),
                    ],

                    // ── 2g. Other Branches ──────────────────────────────
                    const _SectionDivider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: GYMProfileOtherBatchSection(),
                    ),

                    // ── 2h. Customer Reviews ────────────────────────────
                    const _SectionDivider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: GYMProfileReviewSection(),
                    ),

                    sizedBoxHeight(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION DIVIDER
// ═══════════════════════════════════════════════════════════════════════════
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: const Color(0xFFF0F2F5),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GYM PROFILE HEADER
// ═══════════════════════════════════════════════════════════════════════════
class _GymProfileHeader extends StatelessWidget {
  final dynamic listing;
  final dynamic category;
  final String timings;

  const _GymProfileHeader({
    required this.listing,
    required this.category,
    required this.timings,
  });

  @override
  Widget build(BuildContext context) {
    final rating = listing?.rating?.average ?? 0.0;
    final recommendPct = rating > 0 ? ((rating / 5.0) * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category?.name ?? "Gym",
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (listing?.genderType != null &&
                  listing!.genderType!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    listing!.genderType!,
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            listing?.title ?? "",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          if (listing?.address != null && listing!.address!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: Color(0xFF757575)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    listing!.address!,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF757575), height: 1.4),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoPill(
                  icon: Icons.flag_outlined,
                  iconColor: const Color(0xFF0277BD),
                  label: "Landmark",
                  value: (listing?.landmark != null &&
                          listing!.landmark!.isNotEmpty)
                      ? listing!.landmark!
                      : "Not Available",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(
                  icon: Icons.thumb_up_alt_rounded,
                  iconColor: const Color(0xFF00897B),
                  label: "Recommend",
                  value: "$recommendPct%",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFF57F17),
                  label: "Avg Rating",
                  value: rating > 0 ? rating.toStringAsFixed(1) : "New",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoPill(
      {required this.icon,
      required this.iconColor,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GYM VISIT CARD
// ═══════════════════════════════════════════════════════════════════════════
class _GymVisitCard extends StatelessWidget {
  final dynamic listing;
  final String timings;

  const _GymVisitCard({required this.listing, required this.timings});

  @override
  Widget build(BuildContext context) {
    final price = listing?.startingPrice ?? 0;
    final phone = listing?.partner?['mobile'] ?? "";
    final deposit = listing?.securityDeposit ?? "0.00";
    final hasDeposit =
        double.tryParse(deposit) != null && double.parse(deposit) > 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Gym Visit",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E)),
              ),
              Row(
                children: [
                  if (hasDeposit) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                const Color(0xFFE11D48).withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        "Dep: ₹${double.parse(deposit).toInt()}",
                        style: const TextStyle(
                            color: Color(0xFFE11D48),
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF00897B),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "₹$price onwards",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: "Book Visit",
                  icon: Icons.calendar_month_outlined,
                  isOutlined: true,
                  onTap: () {
                    final bool isLoggedIn =
                        Get.isRegistered<AuthController>() &&
                            Get.find<AuthController>().isLoggedIn();
                    if (!isLoggedIn) {
                      showLoginRequiredDialog(
                        context: context,
                        title: "Login Required",
                        message:
                            "Please login to your account first before booking a visit.",
                      );
                      return;
                    }
                    navigate(
                        context: context,
                        page: GymBookVisitScreen(
                          listingId: listing?.id,
                          listingModel:
                              listing is ListingModel ? listing : null,
                        ));
                  },
                ),
              ),
              const SizedBox(width: 10),
              if (phone.isNotEmpty)
                _CircleActionButton(
                  icon: Icons.call_rounded,
                  color: const Color(0xFF1565C0),
                  onTap: () => LaunchHelper.callUs(number: phone),
                ),
              const SizedBox(width: 8),
              _CircleActionButton(
                icon: Icons.map_outlined,
                color: const Color(0xFF00897B),
                isImage: true,
                imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/2642/2642502.png",
                onTap: () => LaunchHelper.openGoogleMap(
                    lat: listing?.lat ?? "", lng: listing?.lng ?? ""),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isOutlined;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.isOutlined,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white : const Color(0xFF00897B),
          borderRadius: BorderRadius.circular(10),
          border:
              isOutlined ? Border.all(color: const Color(0xFF00897B)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isOutlined ? const Color(0xFF00897B) : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isOutlined ? const Color(0xFF00897B) : Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isImage;
  final String? imageUrl;

  const _CircleActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isImage = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: isImage && imageUrl != null
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(icon, color: color, size: 20),
                ),
              )
            : Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HIGHLIGHT STRIP
// ═══════════════════════════════════════════════════════════════════════════
class _HighlightStrip extends StatelessWidget {
  final dynamic listing;

  const _HighlightStrip({required this.listing});

  @override
  Widget build(BuildContext context) {
    final rating = listing?.rating?.average ?? 0.0;
    final recommendPct = rating > 0 ? ((rating / 5.0) * 100).round() : 0;
    final deposit = listing?.securityDeposit ?? "0.00";
    final hasDeposit =
        double.tryParse(deposit) != null && double.parse(deposit) > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _HighlightTile(
              icon: Icons.thumb_up_alt_rounded,
              iconColor: const Color(0xFF00897B),
              bgColor: const Color(0xFFE0F2F1),
              value: "$recommendPct%",
              subtitle: "Recommend",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _HighlightTile(
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFF57F17),
              bgColor: const Color(0xFFFFFDE7),
              value: rating > 0 ? rating.toStringAsFixed(1) : "New",
              subtitle: "Avg Rating",
            ),
          ),
          if (hasDeposit) ...[
            const SizedBox(width: 10),
            Expanded(
              child: _HighlightTile(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFFE11D48),
                bgColor: const Color(0xFFFFF1F2),
                value: "₹${double.parse(deposit).toInt()}",
                subtitle: "Deposit",
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String subtitle;

  const _HighlightTile(
      {required this.icon,
      required this.iconColor,
      required this.bgColor,
      required this.value,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: iconColor)),
          const SizedBox(height: 2),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF616161))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PERSISTENT BOTTOM ACTION BAR
// ═══════════════════════════════════════════════════════════════════════════
class _PractoBottomBar extends StatelessWidget {
  final HomeController homeController;

  const _PractoBottomBar({required this.homeController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                final bool isLoggedIn =
                    Get.isRegistered<AuthController>() &&
                        Get.find<AuthController>().isLoggedIn();
                if (!isLoggedIn) {
                  showLoginRequiredDialog(
                    context: context,
                    title: "Login Required",
                    message:
                        "Please login to your account first before booking a visit.",
                  );
                  return;
                }
                navigate(
                  context: context,
                  page: GymBookVisitScreen(
                    listingId: homeController.selectListingModel?.id,
                    listingModel: homeController.selectListingModel,
                  ),
                );
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryColor)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        color: primaryColor, size: 18),
                    SizedBox(width: 6),
                    Text("Book Visit",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: primaryColor)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                final bool isLoggedIn =
                    Get.isRegistered<AuthController>() &&
                        Get.find<AuthController>().isLoggedIn();
                if (!isLoggedIn) {
                  showLoginRequiredDialog(
                    context: context,
                    title: "Login Required",
                    message:
                        "Please login to your account first before booking a membership.",
                  );
                  return;
                }
                navigate(context: context, page: const GymSelectPlanScreen());
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF022C7F),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF022C7F).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_membership_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text("Book Membership",
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
