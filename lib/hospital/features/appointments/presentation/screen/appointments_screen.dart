import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/appointment_widget.dart';
import '../../../doctor/data/model/doctor_model.dart';
import '../../../doctor/presentation/screens/doctor_search_screen.dart';
import 'package:vlr/services/app_router.dart';
import '../../data/model/appointment_model.dart';
import '../../logics/appointment_controller.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  final String userId;

  const AppointmentsScreen({
    super.key,
    this.userId = "",
  });

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final AppointmentController _controller =
      Get.isRegistered<AppointmentController>()
          ? Get.find<AppointmentController>()
          : Get.put(AppointmentController());

  String _selectedFilter = 'All';
  String _searchQuery = '';

  String _formatDateToDdMmYyyy(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return '';
    final cleaned = rawDate.trim();
    try {
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(cleaned)) {
        return cleaned;
      }
      final dt = DateTime.tryParse(cleaned);
      if (dt != null) {
        final d = dt.day.toString().padLeft(2, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final y = dt.year.toString().padLeft(4, '0');
        return '$d-$m-$y';
      }
      final parts = cleaned.split(RegExp(r'[-/]'));
      if (parts.length >= 3) {
        if (parts[0].length == 4) {
          final y = parts[0];
          final m = parts[1].padLeft(2, '0');
          final d = parts[2].split(' ').first.padLeft(2, '0');
          return '$d-$m-$y';
        } else if (parts[2].length >= 4) {
          final d = parts[0].padLeft(2, '0');
          final m = parts[1].padLeft(2, '0');
          final y = parts[2].split(' ').first.substring(0, 4);
          return '$d-$m-$y';
        }
      }
    } catch (_) {}
    return cleaned;
  }

  @override
  void initState() {
    super.initState();
    _controller.fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<AppointmentModel> currentAppointments =
          _controller.appointments;

      bool isConfirmed(AppointmentModel a) {
        final s = (a.status ?? '').toLowerCase();
        final p = (a.paymentStatus ?? '').toLowerCase();
        if (s.contains('cancel') ||
            p.contains('cancel') ||
            p.contains('fail')) {
          return false;
        }
        final isOnline =
            (a.paymentMode?.toLowerCase().contains('online') == true ||
                a.paymentMode?.toLowerCase().contains('razorpay') == true);
        if (isOnline) {
          return p.contains('paid') ||
              p.contains('complete') ||
              p.contains('success');
        }
        return s.contains('upcoming') ||
            s.contains('booked') ||
            s.contains('approved');
      }

      bool isPendingOrUnpaid(AppointmentModel a) {
        final s = (a.status ?? '').toLowerCase();
        final p = (a.paymentStatus ?? '').toLowerCase();
        if (s.contains('cancel') ||
            p.contains('cancel') ||
            p.contains('fail')) {
          return true;
        }
        final isOnline =
            (a.paymentMode?.toLowerCase().contains('online') == true ||
                a.paymentMode?.toLowerCase().contains('razorpay') == true);
        if (isOnline && (p.contains('pending') || p.contains('unpaid'))) {
          return true;
        }
        return false;
      }

      // Counts for filter pills
      final bookedCount = currentAppointments.where(isConfirmed).length;
      final pendingCount = currentAppointments.where(isPendingOrUnpaid).length;
      final finishedCount = currentAppointments.where((a) {
        final s = (a.status ?? '').toLowerCase();
        return s.contains('finish') || s.contains('complete');
      }).length;

      final filteredAppointments = currentAppointments.where((item) {
        final docName = (item.doctorName ?? '').toLowerCase();
        final desig = (item.designation ?? '').toLowerCase();
        final hosp = (item.hospital?['name']?.toString() ?? '').toLowerCase();
        final q = _searchQuery.toLowerCase();

        final matchesSearch =
            docName.contains(q) || desig.contains(q) || hosp.contains(q);

        final lowerStatus = (item.status ?? '').toLowerCase();
        bool matchesFilter = true;
        if (_selectedFilter == 'Booked') {
          matchesFilter = isConfirmed(item);
        } else if (_selectedFilter == 'Pending') {
          matchesFilter = isPendingOrUnpaid(item);
        } else if (_selectedFilter == 'Finished') {
          matchesFilter = lowerStatus.contains('finish') ||
              lowerStatus.contains('complete');
        }

        return matchesSearch && matchesFilter;
      }).toList();

      return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top App Bar Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Appointments',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: Color(0xFF0F172A), size: 26),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle:
                          TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                      prefixIcon: Icon(Icons.search,
                          color: Color(0xFF94A3B8), size: 22),
                      suffixIcon: Icon(Icons.tune_rounded,
                          color: Color(0xFF94A3B8), size: 22),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              if (!_controller.isLoggedIn)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_outline_rounded,
                                size: 50, color: primaryColor),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Browsing as Guest',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textDark),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please log in to view and manage your booked doctor appointments.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: textMuted),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => AppRouter.goToLogin(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: colorWhite,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Log In to FeeTrack',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                // Filter Chips Bar (Horizontal Scroll)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip(
                          'All',
                          'All (${currentAppointments.length})',
                          Icons.dashboard_outlined),
                      const SizedBox(width: 8),
                      _buildFilterChip('Booked', 'Booked ($bookedCount)',
                          Icons.event_available_outlined),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Pending',
                          'Pending${pendingCount > 0 ? ' ($pendingCount)' : ''}',
                          Icons.cancel_outlined),
                      const SizedBox(width: 8),
                      _buildFilterChip('Finished', 'Finished ($finishedCount)',
                          Icons.check_circle_outline_rounded),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Appointments List
                Expanded(
                  child: _controller.isLoadingAppointments.value &&
                          currentAppointments.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1E3A8A)),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _controller.fetchAppointments(),
                          color: const Color(0xFF1E3A8A),
                          child: filteredAppointments.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 100),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.event_busy_rounded,
                                              size: 50,
                                              color: Color(0xFF94A3B8)),
                                          SizedBox(height: 12),
                                          Text(
                                            'No appointments found',
                                            style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  itemCount: filteredAppointments.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredAppointments[index];
                                    final docName = item.doctorName ?? 'Doctor';
                                    final specialist =
                                        item.doctor?['specialist'];
                                    final desig = (specialist is Map
                                            ? specialist['name']?.toString()
                                            : specialist?.toString()) ??
                                        item.doctor?['qualification']
                                            ?.toString() ??
                                        item.designation ??
                                        'Consultation';
                                    final doctorHospital =
                                        item.doctor?['hospital'];
                                    final hospitalDomain =
                                        item.hospital?['domain']?.toString() ??
                                            (doctorHospital is Map
                                                ? doctorHospital['domain']
                                                    ?.toString()
                                                : null);
                                    final imageUrl =
                                        item.imageUrl?.trim().isNotEmpty == true
                                            ? DoctorModel.resolveDoctorPhoto(
                                                photo: item.imageUrl,
                                                domain: hospitalDomain,
                                              )
                                            : null;
                                    final date =
                                        _formatDateToDdMmYyyy(item.date);
                                    final time = item.slot ?? item.time ?? '';
                                    final pStatus = (item.paymentStatus ?? '')
                                        .toLowerCase();
                                    final isOnline = (item.paymentMode
                                                ?.toLowerCase()
                                                .contains('online') ==
                                            true ||
                                        item.paymentMode
                                                ?.toLowerCase()
                                                .contains('razorpay') ==
                                            true);
                                    final status = (isOnline &&
                                            (pStatus.contains('pending') ||
                                                pStatus.contains('unpaid')))
                                        ? 'Payment Pending'
                                        : (item.status ?? 'Booked');

                                    return AppointmentWidget(
                                      doctorName: docName,
                                      designation: desig,
                                      date: date,
                                      time: time,
                                      status: status,
                                      imageUrl: imageUrl,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AppointmentDetailScreen(
                                              appointmentId: item.id ?? 0,
                                              initialAppointment: item,
                                            ),
                                          ),
                                        ).then((_) {
                                          _controller.fetchAppointments();
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorSearchScreen()),
            ).then((_) {
              _controller.fetchAppointments();
            });
          },
        ),
      );
    });
  }

  Widget _buildFilterChip(String filterKey, String label, [IconData? icon]) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : colorWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : borderGrey,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? colorWhite : textMuted,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorWhite : const Color(0xFF334155),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
