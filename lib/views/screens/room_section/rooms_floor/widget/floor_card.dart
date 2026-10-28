import 'package:flutter/material.dart';
import 'package:vlr/data/models/rooom/pg_floor_model.dart';
import 'package:vlr/services/theme.dart';

class FloorCard extends StatelessWidget {
  final PgFloorModel floor;
  final VoidCallback onTap;

  const FloorCard({
    super.key,
    required this.floor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final listing = floor.listing;
    final website = floor.website;
    final bool isSelected = floor.isSelect;
    final stats = <Widget>[
      if (floor.totalRooms != null)
        _buildStatItem(
          icon: Icons.meeting_room_outlined,
          label: "Rooms",
          value: "${floor.totalRooms}",
          color: const Color(0xFF2563EB),
        ),
      if (floor.totalCapacity != null)
        _buildStatItem(
          icon: Icons.groups_outlined,
          label: "Capacity",
          value: "${floor.totalCapacity}",
          color: const Color(0xFF7C3AED),
        ),
      if (floor.availableBeds != null)
        _buildStatItem(
          icon: Icons.single_bed_outlined,
          label: "Available",
          value: "${floor.availableBeds}",
          color: floor.availableBeds! > 0
              ? const Color(0xFF059669)
              : Colors.red.shade600,
        ),
    ];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
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
            // Top Row: Floor Number Badge, Floor Name, and Domain Tag
            Row(
              children: [
                if (floor.floorNumber?.isNotEmpty == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002060).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.layers_rounded,
                            size: 12, color: Color(0xFF002060)),
                        const SizedBox(width: 3),
                        Text(
                          floor.floorNumber == '0'
                              ? "Ground"
                              : "Floor ${floor.floorNumber}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF002060),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (floor.name?.isNotEmpty == true) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      floor.name!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (website != null && website['domain'] != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 85),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      website['domain'].toString(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // Listing Info (PG Title & Address)
            if (listing != null) ...[
              const SizedBox(height: 8),
              if (listing.title != null && listing.title!.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.apartment_rounded,
                        size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        listing.title!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (listing.address != null || listing.city != null) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        [listing.address, listing.city]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(', '),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],

            if (stats.isNotEmpty) ...[
              const Divider(height: 18, color: Color(0xFFF1F5F9)),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    for (var index = 0; index < stats.length; index++) ...[
                      if (index > 0)
                        Container(
                          width: 1,
                          height: 22,
                          color: const Color(0xFFE2E8F0),
                        ),
                      Expanded(child: stats[index]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Action Row: Guaranteed 0 overflow with Expanded
            Row(
              children: [
                if (listing?.securityDeposit != null &&
                    listing!.securityDeposit.toString().isNotEmpty)
                  Expanded(
                    child: Text(
                      "Deposit: ₹${listing.securityDeposit}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE11D48),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 8),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View Floor Rooms",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
