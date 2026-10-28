import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/room_detail_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/shimmer.dart';

class SelectRoomSection extends StatelessWidget {
  const SelectRoomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(
      builder: (subscriptionController) {
        // Only show if listing has rooms
        if (!subscriptionController.hasRooms) {
          return const SizedBox.shrink();
        }

        if (!subscriptionController.isLoading &&
            subscriptionController.roomDetailList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sizedBoxHeight(height: 30),
            Text(
              "SELECT ROOM",
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: greyText3,
                    letterSpacing: 1.2,
                  ),
            ),
            sizedBoxHeight(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subscriptionController.isLoading
                  ? 3
                  : subscriptionController.roomDetailList.length,
              separatorBuilder: (_, __) => sizedBoxHeight(height: 12),
              itemBuilder: (context, index) {
                if (subscriptionController.isLoading) {
                  return CustomShimmer(
                    isLoading: true,
                    child: _RoomCard(
                      room: RoomDetailModel(),
                      isSelected: false,
                      onTap: () {},
                    ),
                  );
                }

                final room = subscriptionController.roomDetailList[index];
                final isSelected =
                    subscriptionController.selectedRoomDetail?.id == room.id;

                return Column(
                  children: [
                    _RoomCard(
                      room: room,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          subscriptionController.updateSelectRoomDetail(value: null);
                        } else {
                          subscriptionController.updateSelectRoomDetail(value: room);
                          subscriptionController.updateSelectBedsCount(1);
                        }

                        // Re-fetch plans filtered by selected room
                        final homeController = Get.find<HomeController>();
                        final listingId = homeController.selectListingModel?.id ?? "";
                        subscriptionController.fetchPlanListingById(
                          id: listingId,
                          roomId: isSelected ? null : room.id,
                          // floorId: isSelected ? null : room.floorId?.toString(),
                        );
                      },
                    ),
                    if (isSelected && subscriptionController.selectedPlan?.occupancyType == 'per_bed')
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Beds",
                                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF002060),
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${room.availableBeds ?? '0'} Beds Available",
                                  style: Helper(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF002060).withOpacity(0.7),
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (subscriptionController.selectedBedsCount > 1) {
                                      subscriptionController.updateSelectBedsCount(
                                        subscriptionController.selectedBedsCount - 1,
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF002060).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.remove, size: 20, color: Color(0xFF002060)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "${subscriptionController.selectedBedsCount}",
                                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    final maxBeds = int.tryParse(room.availableBeds ?? '0') ?? 0;
                                    if (subscriptionController.selectedBedsCount < maxBeds) {
                                      subscriptionController.updateSelectBedsCount(
                                        subscriptionController.selectedBedsCount + 1,
                                      );
                                    } else {
                                      showToast(message: "Maximum available beds reached");
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF002060),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.add, size: 20, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomDetailModel room;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF002060).withOpacity(0.04)
              : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            width: isSelected ? 1.5 : 1,
            color: isSelected
                ? const Color(0xFF002060)
                : Colors.grey.withOpacity(0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Row ─────────────────────────────────────────────
            Row(
              children: [
                // Room Icon
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF002060).withOpacity(0.1)
                        : const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.meeting_room_outlined,
                    color: isSelected
                        ? const Color(0xFF002060)
                        : const Color(0xFF5C6BC0),
                    size: 22,
                  ),
                ),
                sizedBoxWidth(width: 12),
                // Room Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Room ${room.roomNumber ?? '--'}",
                        style:
                            Helper(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF002060),
                                ),
                      ),
                      if (room.roomType != null)
                        Text(
                          room.roomType!,
                          style:
                              Helper(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: greyDart2,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                    ],
                  ),
                ),
                // Floor badge
                if (room.floorId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Floor ${room.floorId}",
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                sizedBoxWidth(width: 8),
                // Selected badge
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002060),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.white, size: 10),
                        const SizedBox(width: 3),
                        Text(
                          "Selected",
                          style:
                              Helper(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 9,
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            sizedBoxHeight(height: 12),

            // ─── Details Row ────────────────────────────────────────────
            Row(
              children: [
                _InfoChip(
                  icon: Icons.bed_outlined,
                  label: "${room.availableBeds ?? '0'} Beds Available",
                ),
                sizedBoxWidth(width: 10),
                _InfoChip(
                  icon: Icons.people_outline,
                  label: "Cap: ${room.capacity ?? '--'}",
                ),
                sizedBoxWidth(width: 10),
                if (room.securityDeposit != null &&
                    room.securityDeposit! > 0)
                  _InfoChip(
                    icon: Icons.shield_outlined,
                    label: "Dep: ₹${room.securityDeposit}",
                  ),
              ],
            ),

            // ─── Packages indicator ─────────────────────────────────────
            if (room.packages != null && room.packages!.isNotEmpty) ...[
              sizedBoxHeight(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_offer_outlined,
                        size: 12, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Text(
                      "${room.packages!.length} Package${room.packages!.length > 1 ? 's' : ''} Available",
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: greyDart2),
        const SizedBox(width: 3),
        Text(
          label,
          style: Helper(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: greyDart2,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
