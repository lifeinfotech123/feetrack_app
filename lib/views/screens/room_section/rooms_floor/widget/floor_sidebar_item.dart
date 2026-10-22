import 'package:flutter/material.dart';
import 'package:vlr/data/models/rooom/pg_floor_model.dart';
import 'package:vlr/services/theme.dart';

class FloorSidebarItem extends StatelessWidget {
  final PgFloorModel floor;
  final VoidCallback onTap;

  const FloorSidebarItem({
    super.key,
    required this.floor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelect = floor.isSelect;
    final String floorBadge = floor.floorBadge;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 95,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelect ? primaryColor : Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
          border: Border(
            left: BorderSide(
              color: isSelect ? const Color(0xFF002060) : Colors.transparent,
              width: 3.5,
            ),
          ),
          boxShadow: isSelect
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(2, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelect
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFF002060).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                floorBadge,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelect ? Colors.white : const Color(0xFF002060),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              floor.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelect ? Colors.white : const Color(0xFF1E293B),
                fontWeight: isSelect ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (floor.availableBeds != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelect
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFF059669).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${floor.availableBeds} beds",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelect ? Colors.white : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
