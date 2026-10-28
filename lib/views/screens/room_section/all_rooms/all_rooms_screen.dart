import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_room_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/room_section/room/room_booking/room_booking_screen.dart';

class AllPgRoomsScreen extends StatefulWidget {
  const AllPgRoomsScreen({super.key});

  @override
  State<AllPgRoomsScreen> createState() => _AllPgRoomsScreenState();
}

class _AllPgRoomsScreenState extends State<AllPgRoomsScreen> {
  String _selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RoomController>().fetchAllPgRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "All PG Rooms",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: GetBuilder<RoomController>(
        builder: (roomController) {
          if (roomController.isAllRoomsLoading &&
              roomController.allRoomsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          var rooms = roomController.filteredAllRoomsList.isNotEmpty
              ? roomController.filteredAllRoomsList
              : roomController.allRoomsList;

          if (_selectedFilter != "all") {
            rooms = rooms.where((r) {
              final type = (r.roomType ?? "").toLowerCase();
              if (_selectedFilter == "single") {
                return type.contains("single") || r.capacity == 1;
              } else if (_selectedFilter == "double") {
                return type.contains("double") || r.capacity == 2;
              } else if (_selectedFilter == "triple") {
                return type.contains("triple") || r.capacity == 3;
              }
              return true;
            }).toList();
          }

          return RefreshIndicator(
            onRefresh: () => roomController.fetchAllPgRooms(),
            child: Column(
              children: [
                // Search Bar
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: roomController.roomSearchController,
                    onChanged: (val) => roomController.searchAllRooms(val),
                    decoration: InputDecoration(
                      hintText: "Search room no, type, PG name, city...",
                      hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF64748B), size: 20),
                      suffixIcon: roomController.roomSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                roomController.roomSearchController.clear();
                                roomController.searchAllRooms("");
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Sharing Filter Chips
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      _buildChip("All Rooms", "all"),
                      const SizedBox(width: 8),
                      _buildChip("Single", "single"),
                      const SizedBox(width: 8),
                      _buildChip("Double", "double"),
                      const SizedBox(width: 8),
                      _buildChip("Triple+", "triple"),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Rooms Count
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${rooms.length} Rooms Available",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const Text(
                        "Live from PGs",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rooms List
                Expanded(
                  child: rooms.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.meeting_room_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                "No rooms match your filter",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: rooms.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            return _buildRoomTile(
                                context, room, roomController);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, String key) {
    final bool isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = key;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF002060) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomTile(
      BuildContext context, PgRoomModel room, RoomController controller) {
    return InkWell(
      onTap: () {
        controller.updateSelectPgRoomModel(room);
        if (room.id != null) {
          controller.fetchPgRoomDetails(room.id!);
        }
        navigate(context: context, page: const RoomBookingScreen());
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Room number, Room type badge, Available beds
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002060),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Room ${room.roomNumber ?? '--'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2563EB).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          room.roomType ?? "Standard",
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (room.availableBeds ?? 0) > 0
                          ? const Color(0xFF059669).withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${room.availableBeds ?? 0}/${room.capacity ?? 0} Beds Left",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: (room.availableBeds ?? 0) > 0
                            ? const Color(0xFF059669)
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // PG Title & Floor
            if (room.listing?.title != null) ...[
              Text(
                room.listing!.title!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 3),
            ],

            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "${room.floorName ?? (room.floorId != null ? 'Floor ${room.floorId}' : 'Ground Floor')} • ${room.listing?.address ?? room.listing?.city ?? 'Lucknow'}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // Rent Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Per Bed Rent",
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    Text(
                      "₹${room.perBedRent ?? room.startingPrice ?? '--'}/mo",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                if (room.fullRent != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Full Room",
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      Text(
                        "₹${room.fullRent}/mo",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Deposit",
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    Text(
                      "₹${room.securityDeposit ?? 3000}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
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
}
