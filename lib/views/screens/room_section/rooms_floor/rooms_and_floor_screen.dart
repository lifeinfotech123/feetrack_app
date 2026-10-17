import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/room_section/room/room_profile_screen/room_profile_screen.dart';
import 'package:vlr/views/screens/room_section/rooms_floor/widget/floor_card.dart';
import 'package:vlr/views/screens/room_section/rooms_floor/widget/floor_sidebar_item.dart';
import 'package:vlr/views/screens/room_section/rooms_floor/widget/room_card.dart';

class RoomsAndFloorScreen extends StatefulWidget {
  final String? listingId;
  final int initialTab; // 0 = Interactive Split, 1 = All Floors list

  const RoomsAndFloorScreen({
    super.key,
    this.listingId,
    this.initialTab = 0,
  });

  @override
  State<RoomsAndFloorScreen> createState() => _RoomsAndFloorScreenState();
}

class _RoomsAndFloorScreenState extends State<RoomsAndFloorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomController = Get.find<RoomController>();
      roomController.fetchPgFloors(listingId: widget.listingId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "PG Floors & Rooms",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Color(0xFF1E293B)),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelColor: primaryColor,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(
              icon: Icon(Icons.view_sidebar_rounded, size: 18),
              text: "Floors & Rooms",
            ),
            Tab(
              icon: Icon(Icons.layers_rounded, size: 18),
              text: "All Floors List",
            ),
          ],
        ),
      ),
      bottomNavigationBar: _tabController.index == 1
          ? null
          : GetBuilder<RoomController>(
              builder: (controller) {
                final selectedRoom = controller.pgRoomModelList
                    .firstWhereOrNull((e) => e.isSelect);
                final bool isEnabled = selectedRoom != null;

                return Container(
                  padding: EdgeInsets.fromLTRB(
                      16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 12,
                        offset: Offset(0, -4),
                      )
                    ],
                  ),
                  child: GestureDetector(
                    onTap: !isEnabled
                        ? null
                        : () {
                            if (selectedRoom.id != null) {
                              controller.fetchPgRoomDetails(selectedRoom.id!);
                            }
                            navigate(
                              context: context,
                              page: const RoomProfileScreen(),
                            );
                          },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? const Color(0xFF002060)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !isEnabled
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0xFF002060)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                      ),
                      child: Center(
                        child: Text(
                          isEnabled
                              ? "Continue with Room ${selectedRoom.roomNumber ?? ''}"
                              : "Select a Room to Continue",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isEnabled ? Colors.white : Colors.grey[600],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      body: GetBuilder<RoomController>(
        builder: (controller) {
          if (controller.isFloorsLoading &&
              controller.pgFloorModelList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Interactive Split View (Sidebar Floors + Rooms List)
              _buildSplitFloorAndRoomsView(controller),

              // Tab 2: All Floors Card List (From API 1: /v1/pg/floors)
              _buildAllFloorsListView(controller),
            ],
          );
        },
      ),
    );
  }

  /// Tab 1: Split sidebar floors + rooms
  Widget _buildSplitFloorAndRoomsView(RoomController controller) {
    if (controller.pgFloorModelList.isEmpty && !controller.isFloorsLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.layers_clear_outlined,
                size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              "No floors available",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  controller.fetchPgFloors(listingId: widget.listingId),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final selectedFloor = controller.selectedFloor ??
        controller.pgFloorModelList.firstWhereOrNull((e) => e.isSelect) ??
        (controller.pgFloorModelList.isNotEmpty
            ? controller.pgFloorModelList.first
            : null);

    final bool isRoomsBusy =
        controller.isFloorDetailsLoading || controller.isLoading;

    return Row(
      children: [
        // Left Sidebar for Floors
        Container(
          width: 100,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: ListView.separated(
            itemCount: controller.pgFloorModelList.length,
            padding: const EdgeInsets.symmetric(vertical: 14),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final floor = controller.pgFloorModelList[index];
              return FloorSidebarItem(
                floor: floor,
                onTap: () {
                  controller.selectFloor(floor);
                },
              );
            },
          ),
        ),

        // Right Area: Selected Floor Banner + Rooms List
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Floor Header Banner
              if (selectedFloor != null)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedFloor.name ??
                                  (selectedFloor.floorNumber != null
                                      ? (selectedFloor.floorNumber == '0'
                                          ? "Ground Floor"
                                          : "Floor ${selectedFloor.floorNumber}")
                                      : "Floor"),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (selectedFloor.listing?.securityDeposit != null &&
                              selectedFloor.listing!.securityDeposit.toString().isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 95),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE11D48)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Dep: ₹${selectedFloor.listing!.securityDeposit}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE11D48),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (selectedFloor.listing?.title != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          selectedFloor.listing!.title!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildMiniBadge(
                            icon: Icons.meeting_room_outlined,
                            text: "${selectedFloor.totalRooms ?? 0} Rooms",
                            color: const Color(0xFF2563EB),
                          ),
                          _buildMiniBadge(
                            icon: Icons.single_bed_outlined,
                            text:
                                "${selectedFloor.availableBeds ?? 0} Beds Available",
                            color: const Color(0xFF059669),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Rooms List
              Expanded(
                child: isRoomsBusy
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryColor))
                    : controller.pgRoomModelList.isEmpty
                        ? const Center(
                            child: Text(
                              "No rooms found for this floor",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: controller.pgRoomModelList.length,
                            itemBuilder: (context, index) {
                              final room = controller.pgRoomModelList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: RoomCard(
                                  room: room,
                                  onTap: () {
                                    controller.selectRoom(room);
                                    if (room.id != null) {
                                      controller.fetchPgRoomDetails(room.id!);
                                    }
                                    navigate(
                                      context: context,
                                      page: const RoomProfileScreen(),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tab 2: Full List of all floors from API 1 (/v1/pg/floors)
  Widget _buildAllFloorsListView(RoomController controller) {
    if (controller.pgFloorModelList.isEmpty && !controller.isFloorsLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.layers_clear_outlined,
                size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text("No floors available"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  controller.fetchPgFloors(listingId: widget.listingId),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchPgFloors(listingId: widget.listingId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.pgFloorModelList.length,
        itemBuilder: (context, index) {
          final floor = controller.pgFloorModelList[index];
          return FloorCard(
            floor: floor,
            onTap: () {
              // Click floor from list: trigger API 2 & API 3, switch to Split View
              controller.selectFloor(floor);
              _tabController.animateTo(0);
            },
          );
        },
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
