import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/visit_controller.dart';
import 'package:vlr/data/models/visit_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_visit_detail_screen.dart';

class MyRoomVisitListScreen extends StatefulWidget {
  final VoidCallback? onExploreTap;
  const MyRoomVisitListScreen({super.key, this.onExploreTap});

  @override
  State<MyRoomVisitListScreen> createState() => _MyRoomVisitListScreenState();
}

class _MyRoomVisitListScreenState extends State<MyRoomVisitListScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<VisitController>().fetchPgVisits();
    });
  }

  List<VisitModel> _filterVisits(List<VisitModel> list) {
    if (_selectedFilter == 'all') return list;
    return list.where((v) {
      final s = (v.status ?? "").toLowerCase();
      if (_selectedFilter == 'pending') {
        return s == 'pending';
      } else if (_selectedFilter == 'approved') {
        return s == 'approved' || s == 'confirmed' || s == 'scheduled';
      } else if (_selectedFilter == 'cancelled') {
        return s == 'cancelled' || s == 'rejected';
      } else if (_selectedFilter == 'completed') {
        return s == 'completed' || s == 'visited';
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "My Scheduled Visits",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
        ),
      ),
      body: GetBuilder<VisitController>(
        builder: (visitController) {
          if (visitController.isPgVisitsLoading &&
              visitController.pgVisitList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allVisits = visitController.pgVisitList;
          final filtered = _filterVisits(allVisits);

          return RefreshIndicator(
            onRefresh: () async {
              await visitController.fetchPgVisits();
            },
            child: Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return _RoomVisitCard(
                              visit: filtered[index],
                              onCancel: (id) => _confirmCancel(context, id),
                            );
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

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Approved', 'value': 'approved'},
      {'label': 'Cancelled', 'value': 'cancelled'},
    ];

    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 8, bottom: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = _selectedFilter == f['value'];
          return Center(
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              selectedColor: const Color(0xFF002060),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF002060)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedFilter = f['value']!;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF002060).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        size: 42,
                        color: Color(0xFF002060),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "No Scheduled Visits",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You haven't scheduled any PG or room visits yet. Explore verified listings and schedule a visit anytime.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002060),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text(
                        "Explore PGs & Rooms",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: widget.onExploreTap ??
                          () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Cancel Scheduled Visit?",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: const Text(
          "Are you sure you want to cancel this visit? This action cannot be undone.",
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "Keep Visit",
              style: TextStyle(
                  color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final visitController = Get.find<VisitController>();
              final res = await visitController.cancelPgVisit(id: id);
              if (res.isSuccess) {
                showToast(
                  message: res.message.isNotEmpty
                      ? res.message
                      : "Visit request has been cancelled.",
                  toastType: ToastType.success,
                );
                await visitController.fetchPgVisits();
              } else {
                showToast(message: res.message, typeCheck: false);
              }
            },
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }
}

class _RoomVisitCard extends StatelessWidget {
  final VisitModel visit;
  final Function(String id) onCancel;
  const _RoomVisitCard({required this.visit, required this.onCancel});

  Color _getStatusColor(String? status) {
    final s = (status ?? "").toLowerCase();
    if (s == 'approved' || s == 'confirmed') {
      return const Color(0xFF16A34A);
    }
    if (s == 'pending') {
      return const Color(0xFFD97706);
    }
    if (s == 'cancelled' || s == 'rejected') {
      return const Color(0xFFDC2626);
    }
    if (s == 'completed' || s == 'visited') {
      return const Color(0xFF2563EB);
    }
    return const Color(0xFF64748B);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return "";
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return "${date.day} ${months[date.month - 1]} ${date.year}";
      }
    } catch (_) {}
    return dateStr;
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return "";
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12;
        if (hour == 0) hour = 12;
        final minuteStr = minute.toString().padLeft(2, '0');
        return "$hour:$minuteStr $period";
      }
    } catch (_) {}
    return timeStr;
  }

  void _openDetails(BuildContext context) {
    if (visit.id != null && visit.id!.isNotEmpty) {
      navigate(
        context: context,
        page: RoomVisitDetailScreen(
          visitId: visit.id!,
          initialVisit: visit,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyTitle = visit.listing?.title ?? "";
    final address = [
      visit.listing?.address,
      visit.listing?.city,
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(", ");
    final visitDate = _formatDate(visit.visitDate);
    final visitTime = _formatTime(visit.visitTime);
    final status = (visit.status ?? "").toUpperCase();
    final statusColor = _getStatusColor(visit.status);
    final statusLower = (visit.status ?? "").toLowerCase();
    final canCancel = visit.id != null &&
        statusLower != 'cancelled' &&
        statusLower != 'rejected' &&
        statusLower != 'completed' &&
        statusLower != 'visited';
    final websiteName = visit.website?.name ?? "";
    final phone = visit.listing?.phone?.toString() ?? "";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Property Name & Address & Status
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002060).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFF002060),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (propertyTitle.isNotEmpty)
                            Text(
                              propertyTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 13, color: Color(0xFF64748B)),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Visit Schedule Date & Time box (shown only if dynamic date or time exists)
              if (visitDate.isNotEmpty || visitTime.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (visitDate.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 16, color: Color(0xFF002060)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Visit Date",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  visitDate,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      if (visitDate.isNotEmpty && visitTime.isNotEmpty)
                        Container(
                          width: 1,
                          height: 28,
                          color: const Color(0xFFE2E8F0),
                        ),
                      if (visitTime.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 16, color: Color(0xFF002060)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Visit Time",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  visitTime,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              // Bottom Actions Row: Website / Portal name & Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (websiteName.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.business_outlined,
                              size: 15, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            websiteName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        if (phone.isNotEmpty)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.phone_in_talk_rounded,
                                size: 18, color: Color(0xFF002060)),
                            onPressed: () {
                              LaunchHelper.callUs(number: phone);
                            },
                          ),
                        if (canCancel) ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => onCancel(visit.id!),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002060),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _openDetails(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Details",
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.chevron_right_rounded, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
