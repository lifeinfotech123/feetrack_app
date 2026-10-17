import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/data/models/category_model/package_model.dart';
import 'package:vlr/data/models/rooom/pg_floor_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/screens/room_section/room/room_profile_screen/room_profile_screen.dart';
import 'package:vlr/views/screens/room_section/room_book_visit/room_book_visit_screen.dart';
import 'package:vlr/views/screens/room_section/rooms_floor/rooms_and_floor_screen.dart';

class PgProfileScreen extends StatefulWidget {
  final String? listingId;
  final ListingModel? initialModel;

  const PgProfileScreen({
    super.key,
    this.listingId,
    this.initialModel,
  });

  @override
  State<PgProfileScreen> createState() => _PgProfileScreenState();
}

class _PgProfileScreenState extends State<PgProfileScreen> {
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final roomController = Get.find<RoomController>();
      final targetId = widget.listingId ??
          widget.initialModel?.id ??
          Get.find<HomeController>().selectListingModel?.id ??
          "";

      if (targetId.isNotEmpty) {
        await roomController.fetchPgListingDetails(targetId);
      }
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
      backgroundColor: const Color(0xFFF6F8FA),
      bottomNavigationBar: _buildBottomBar(),
      body: GetBuilder<RoomController>(
        builder: (roomController) {
          final listing = roomController.selectedListingDetails ??
              widget.initialModel ??
              Get.find<HomeController>().selectListingModel;

          if (roomController.isDetailsLoading && listing == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (listing == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.home_work_outlined,
                      size: 54, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text("PG details not found",
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            );
          }

          List<String> images = [];
          if (listing.images != null && listing.images!.isNotEmpty) {
            images = listing.images!
                .map((i) => i.url ?? i.imagePath ?? "")
                .where((u) => u.isNotEmpty)
                .toList();
          }
          if (images.isEmpty &&
              listing.image != null &&
              listing.image!.isNotEmpty) {
            images = [listing.image!];
          }
          if (images.isEmpty) {
            images = [
              (listing.genderType?.toLowerCase().contains("girl") ?? false)
                  ? "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=800&auto=format&fit=crop"
                  : "https://images.unsplash.com/photo-1555854877-bab0e564b8d5?q=80&w=800&auto=format&fit=crop"
            ];
          }

          final opening = _formatTime(listing.openingTime);
          final closing = _formatTime(listing.closingTime);
          final timings = (opening.isNotEmpty && closing.isNotEmpty)
              ? "$opening – $closing"
              : "06:00 AM – 10:30 PM";

          return CustomScrollView(
            slivers: [
              // ── 1. Image Banner ───────────────────────────────────
              SliverToBoxAdapter(
                child: _buildImageBanner(images),
              ),

              // ── 2. Header & Overview Card ─────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGenderBadge(listing.genderType),
                          if (listing.listingNumber != null &&
                              listing.listingNumber!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                listing.listingNumber!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        listing.title ?? "PG Accommodation",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Address Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 16, color: Color(0xFF2563EB)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              listing.fullAddress ??
                                  listing.address ??
                                  "${listing.landmark ?? ''}, ${listing.city ?? ''}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Quick Highlights Strip
                      _buildQuickHighlights(listing, timings),
                      const SizedBox(height: 14),

                      // Contact & Navigation Actions
                      _buildContactActionRow(listing),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // ── 3. Schedule Visit Promo Card ──────────────────────
              SliverToBoxAdapter(
                child: _buildVisitPromoCard(listing),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // ── 4. About Property ─────────────────────────────────
              if (listing.description != null &&
                  listing.description!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About Property",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          listing.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // ── 5. Packages Section (api/v1/pg/listings/{id}/packages) ─────────────
              if (roomController.listingPackagesList.isNotEmpty ||
                  (listing.packages != null && listing.packages!.isNotEmpty))
                SliverToBoxAdapter(
                  child: _buildPackagesSection(
                    roomController.listingPackagesList.isNotEmpty
                        ? roomController.listingPackagesList
                        : listing.packages!,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // ── 6. Floors & Rooms Preview (api/v1/pg/listings/{id}/rooms) ───────────
              if (roomController.pgFloorModelList.isNotEmpty ||
                  (listing.floors != null && listing.floors!.isNotEmpty))
                SliverToBoxAdapter(
                  child: _buildFloorsPreviewSection(
                    roomController.pgFloorModelList.isNotEmpty
                        ? roomController.pgFloorModelList
                        : listing.floors!,
                    listing.id,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 36)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageBanner(List<String> images) {
    return Stack(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (idx) {
              setState(() {
                _activeImageIndex = idx;
              });
            },
            itemBuilder: (context, index) {
              final url = images[index];
              return CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (c, e, s) => Image.network(
                    "https://images.unsplash.com/photo-1555854877-bab0e564b8d5?q=80&w=800&auto=format&fit=crop",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (c2, e2, s2) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(Icons.apartment_rounded,
                            size: 60, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Top Back Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 18, color: Colors.black87),
                    onPressed: () => Get.back(),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    "${_activeImageIndex + 1}/${images.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderBadge(String? gender) {
    final g = (gender ?? "").toLowerCase();
    Color bg = const Color(0xFFEFF6FF);
    Color fg = const Color(0xFF2563EB);
    IconData icon = Icons.male_rounded;
    String label = "Boys PG";

    if (g.contains("girl") || g.contains("female")) {
      bg = const Color(0xFFFDF2F8);
      fg = const Color(0xFFDB2777);
      icon = Icons.female_rounded;
      label = "Girls PG";
    } else if (g.contains("coliving") || g.contains("unisex")) {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF16A34A);
      icon = Icons.people_rounded;
      label = "Co-living PG";
    } else if (g.contains("hostel")) {
      bg = const Color(0xFFECFEFF);
      fg = const Color(0xFF0891B2);
      icon = Icons.school_rounded;
      label = "Student Hostel";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHighlights(ListingModel listing, String timings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHighlightItem(
            icon: Icons.currency_rupee_rounded,
            title: "Starts at",
            value: "₹${listing.startingPrice ?? 7000}/mo",
            color: const Color(0xFF002060),
          ),
          Container(height: 30, width: 1, color: Colors.grey[300]),
          _buildHighlightItem(
            icon: Icons.shield_outlined,
            title: "Security",
            value: "₹${listing.securityDeposit ?? 3000}",
            color: const Color(0xFF059669),
          ),
          Container(height: 30, width: 1, color: Colors.grey[300]),
          _buildHighlightItem(
            icon: Icons.single_bed_rounded,
            title: "Available",
            value: "${listing.availableBedsCount ?? 3} Beds",
            color: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildContactActionRow(ListingModel listing) {
    final phone = listing.phone?.toString() ?? "";
    final hasPhone = phone.isNotEmpty;
    final lat = listing.lat;
    final lng = listing.lng;
    final hasLocation =
        lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty;
    final portalUrl = listing.website?['portal_url']?.toString();

    return Row(
      children: [
        if (hasPhone)
          Expanded(
            child: GestureDetector(
              onTap: () {
                LaunchHelper.callUs(number: phone);
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      "Call Host",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (hasPhone && hasLocation) const SizedBox(width: 10),
        if (hasLocation)
          Expanded(
            child: GestureDetector(
              onTap: () {
                LaunchHelper.openGoogleMap(lat: lat, lng: lng);
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFF2563EB), width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_rounded,
                        size: 16, color: Color(0xFF2563EB)),
                    SizedBox(width: 6),
                    Text(
                      "Directions",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (portalUrl != null && portalUrl.isNotEmpty) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              LaunchHelper.launchInBrowser(Uri.parse(portalUrl));
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.language_rounded,
                  color: Color(0xFF7C3AED), size: 20),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVisitPromoCard(ListingModel listing) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002060), Color(0xFF0A3D91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002060).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Schedule a Free Visit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Explore rooms, mess & amenities in person",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF002060),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              final bool isLoggedIn = Get.isRegistered<AuthController>() &&
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
                page: RoomBookVisitScreen(
                  listingId: listing.id,
                  listingModel: listing,
                ),
              );
            },
            child: const Text(
              "Book",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesSection(List<PackageModel> packages) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Stay Packages & Plans",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF002060).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${packages.length} Plans",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002060),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pkg = packages[index];
              return InkWell(
                onTap: () => _showPackageDetailsSheet(context, pkg),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    color: const Color(0xFFF8FAFC),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pkg.name ?? "Monthly Package",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF002060),
                              ),
                            ),
                          ),
                          Text(
                            "₹${pkg.price ?? 0}",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${pkg.durationDays ?? 30} Days • ${pkg.occupancyType == 'per_bed' ? 'Per Bed' : 'Full Room'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (pkg.features != null && pkg.features!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: pkg.features!.map((f) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 12, color: Color(0xFF059669)),
                                  const SizedBox(width: 4),
                                  Text(
                                    f,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF334155),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPackageDetailsSheet(BuildContext context, PackageModel pkg) {
    final roomController = Get.find<RoomController>();
    if (pkg.id != null) {
      roomController.fetchPgPackageDetails(pkg.id!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GetBuilder<RoomController>(
          builder: (rc) {
            final activePkg = rc.selectedPackageDetails ?? pkg;
            final features =
                (activePkg.features != null && activePkg.features!.isNotEmpty)
                    ? activePkg.features!
                    : (pkg.features ?? []);

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activePkg.name ?? "Stay Package",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${activePkg.durationDays ?? 30} Days • ${activePkg.occupancyType == 'per_bed' ? 'Per Bed Occupancy' : 'Full Room Stay'}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF059669).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "₹${activePkg.price ?? 0}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      "What's Included in this Plan",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (rc.isSinglePackageLoading && features.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (features.isEmpty)
                      const Text(
                        "Standard stay amenities included.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: features.map((f) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    size: 14, color: Color(0xFF059669)),
                                const SizedBox(width: 6),
                                Text(
                                  f,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    if (activePkg.listing?.securityDeposit != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined,
                                color: Color(0xFFD97706), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Security Deposit: ₹${activePkg.listing!.securityDeposit} (Refundable)",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Close"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002060),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              Get.snackbar(
                                "Package Selected",
                                "${activePkg.name ?? 'Package'} selected.",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF002060),
                                colorText: Colors.white,
                              );
                            },
                            child: const Text(
                              "Select Plan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFloorsPreviewSection(List<PgFloorModel> floors,
      [String? listingId]) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Floors & Available Rooms",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () {
                  navigate(
                    context: context,
                    page: RoomsAndFloorScreen(listingId: listingId),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF002060),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: floors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, fIndex) {
              final floor = floors[fIndex];
              final rooms = floor.rooms ?? [];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      floor.name ?? "Floor ${floor.floorNumber ?? fIndex}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (rooms.isEmpty)
                      const Text("No rooms listed",
                          style: TextStyle(fontSize: 12, color: Colors.grey))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: rooms.map((room) {
                          return InkWell(
                            onTap: () {
                              final rc = Get.find<RoomController>();
                              rc.updateSelectPgFloor(floor);
                              rc.updateSelectPgRoomModel(room);
                              if (room.id != null) {
                                rc.fetchPgRoomDetails(room.id!);
                              }
                              navigate(
                                context: context,
                                page: const RoomProfileScreen(),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Room ${room.roomNumber ?? ''}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF002060),
                                    ),
                                  ),
                                  Text(
                                    "${room.roomType ?? 'Standard'} • ₹${room.perBedRent ?? room.startingPrice ?? 7000}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return GetBuilder<RoomController>(
      builder: (roomController) {
        final listing = roomController.selectedListingDetails ??
            widget.initialModel ??
            Get.find<HomeController>().selectListingModel;
        final price = listing?.startingPrice ?? 7000;

        return Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Monthly Rent",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "₹$price",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF002060),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF002060),
                          side: const BorderSide(
                              color: Color(0xFF002060), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
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
                            page: RoomBookVisitScreen(
                              listingId: listing?.id,
                              listingModel: listing,
                            ),
                          );
                        },
                        child: const Text(
                          "Book Visit",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002060),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          navigate(
                            context: context,
                            page: const RoomsAndFloorScreen(),
                          );
                        },
                        child: const Text(
                          "Select Room",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13),
                        ),
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
}
