import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_room_model.dart';
import 'package:vlr/services/theme.dart';

class RoomCard extends StatelessWidget {
  final PgRoomModel room;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String fallbackImage = Get.isRegistered<RoomController>()
        ? Get.find<RoomController>().selectedListingDetails?.image ?? ""
        : "";

    final bool? isAvailable = room.isAvailable ??
        (room.availableBeds == null ? null : room.availableBeds! > 0);

    String? candidateUrl = (room.images != null && room.images!.isNotEmpty)
        ? room.images![0].url
        : null;
    if (candidateUrl == null || !candidateUrl.startsWith('http')) {
      if (room.listing?.image != null &&
          room.listing!.image!.startsWith('http')) {
        candidateUrl = room.listing!.image;
      } else if (fallbackImage.startsWith('http')) {
        candidateUrl = fallbackImage;
      }
    }

    final String effectiveImageUrl = (candidateUrl != null &&
            (candidateUrl.startsWith('http://') ||
                candidateUrl.startsWith('https://')))
        ? candidateUrl.trim()
        : "";

    final dynamic displayRent =
        room.perBedRent ?? room.startingPrice ?? room.fullRent;
    final String rentUnit = room.perBedRent != null
        ? "per bed"
        : (room.fullRent != null ? "full room" : "/month");

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: room.isSelect ? primaryColor : const Color(0xFFE2E8F0),
            width: room.isSelect ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: room.isSelect
                  ? primaryColor.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Image or Gradient Placeholder with Status Badges
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: Stack(
                children: [
                  if (effectiveImageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: effectiveImageUrl,
                      height: 105,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 105,
                        color: Colors.grey[200],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),

                  // Selected checkmark badge (top-left)
                  if (room.isSelect)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),

                  // Room Type badge (top-right, constrained width)
                  if (room.roomType != null && room.roomType!.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 110),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          room.roomType!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  // Availability tag (bottom-left)
                  if (isAvailable != null)
                    Positioned(
                      bottom: 6,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFF059669)
                              : Colors.red[600],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          isAvailable ? "Available" : "Occupied",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Room Info Body (Guaranteed 0 overflow)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Room Number & Rent (Flexibly sized)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (room.roomNumber?.isNotEmpty == true)
                              Text(
                                "Room ${room.roomNumber}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (room.roomType?.isNotEmpty == true ||
                                room.floorName?.isNotEmpty == true) ...[
                              if (room.roomNumber?.isNotEmpty == true)
                                const SizedBox(height: 1),
                              Text(
                                room.roomType?.isNotEmpty == true
                                    ? room.roomType!
                                    : "Floor: ${room.floorName}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (displayRent != null)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 85),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹$displayRent",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF002060),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                rentUnit,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Row 2: Capacity & Beds status using Wrap (Zero overflow)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (room.capacity != null)
                        _buildChip(
                          icon: Icons.people_outline_rounded,
                          label: "${room.capacity} Sharing",
                          color: const Color(0xFF334155),
                          bgColor: const Color(0xFFF1F5F9),
                        ),
                      if (room.availableBeds != null)
                        _buildChip(
                          icon: Icons.single_bed_outlined,
                          label: "${room.availableBeds} Beds Left",
                          color: room.availableBeds! > 0
                              ? const Color(0xFF059669)
                              : Colors.red[600]!,
                          bgColor: room.availableBeds! > 0
                              ? const Color(0xFF059669).withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                        ),
                      if (room.occupiedBeds != null &&
                          (room.occupiedBeds ?? 0) > 0)
                        _buildChip(
                          icon: Icons.person_rounded,
                          label: "${room.occupiedBeds} Occ",
                          color: const Color(0xFF64748B),
                          bgColor: const Color(0xFFF1F5F9),
                        ),
                    ],
                  ),

                  // Row 3: Full rent & Deposit tags
                  if (room.fullRent != null ||
                      room.securityDeposit != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (room.fullRent != null)
                          Text(
                            "Full Rent: ₹${room.fullRent}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        if (room.securityDeposit != null)
                          Text(
                            "Deposit: ₹${room.securityDeposit}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 105,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF002060), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.king_bed_rounded, size: 30, color: Colors.white70),
            const SizedBox(height: 4),
            Text(
              room.roomNumber != null ? "Room ${room.roomNumber}" : "Room",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
