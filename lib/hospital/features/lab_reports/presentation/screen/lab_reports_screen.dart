import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/core/constants/colors.dart';

import '../../controller/lab_controller.dart';
import '../../../lab_tests/presentation/screen/diagnostic_labs_screen.dart';
import 'lab_report_detail_screen.dart';

class LabReportsScreen extends StatefulWidget {
  final String? userId;

  const LabReportsScreen({
    super.key,
    this.userId,
  });

  @override
  State<LabReportsScreen> createState() => _LabReportsScreenState();
}

class _LabReportsScreenState extends State<LabReportsScreen> {
  late final LabController controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LabController>()
        ? Get.find<LabController>()
        : Get.put(LabController());

    controller.initLabData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('cancel') || s.contains('fail')) {
      return const Color(0xFFDC2626);
    } else if (s.contains('finish') ||
        s.contains('complete') ||
        s.contains('ready') ||
        s.contains('verified')) {
      return const Color(0xFF16A34A);
    } else if (s.contains('paid') ||
        s.contains('confirm') ||
        s.contains('accept')) {
      return const Color(0xFF2563EB);
    } else if (s.contains('pending') || s.contains('sample')) {
      return const Color(0xFFD97706);
    }
    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: colorWhite),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Lab Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorWhite,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: colorWhite),
            onPressed: () => controller.initLabData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: diagnosticViolet,
        onRefresh: () async {
          await controller.initLabData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Search Banner
              _buildHeaderSearch(),

              // Patient's Bookings & Reports (from api/v1/hospital/patient/lab-bookings)
              _buildMyLabBookingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            Get.to(() => const DiagnosticLabsScreen());
          },
          decoration: InputDecoration(
            hintText: 'Search tests',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: diagnosticViolet),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: diagnosticViolet),
                    onPressed: () {
                      Get.to(() => const DiagnosticLabsScreen());
                    },
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildMyLabBookingsSection() {
    return Obx(() {
      final isLoading = controller.isPatientBookingsLoading.value ||
          (controller.isLoading.value && controller.patientLabBookings.isEmpty);
      final rawBookings = controller.patientLabBookings;
      final q = _searchController.text.trim().toLowerCase();

      final bookings = rawBookings.where((item) {
        if (q.isEmpty) return true;
        final title = item.primaryTestName.toLowerCase();
        final no = (item.bookingNo ?? '').toLowerCase();
        final lab = (item.labName ?? '').toLowerCase();
        final hosp = (item.hospital?.name ?? '').toLowerCase();
        return title.contains(q) ||
            no.contains(q) ||
            lab.contains(q) ||
            hosp.contains(q);
      }).toList();

      if (isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: primaryColor),
                SizedBox(height: 14),
                Text(
                  'Loading lab reports...',
                  style: TextStyle(fontSize: 13, color: textMuted),
                ),
              ],
            ),
          ),
        );
      }

      if (bookings.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.science_outlined,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  q.isNotEmpty
                      ? 'No matching lab reports found'
                      : 'No Lab Reports Found',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  q.isNotEmpty
                      ? 'Try searching with a different test name or ID'
                      : 'You do not have any lab bookings or reports yet.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: textMuted),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const DiagnosticLabsScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, color: colorWhite),
                  label: const Text(
                    'Book New Test',
                    style: TextStyle(
                      color: colorWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Lab Bookings & Reports',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${bookings.length} ${bookings.length == 1 ? "Record" : "Records"}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = bookings[index];
                final testTitle = item.primaryTestName;
                final labName =
                    item.labName ?? item.hospital?.name ?? 'Diagnostic Lab';
                final rawDate = item.bookingDate ?? '';
                final formattedDate = _formatDateToDdMmYyyy(rawDate);
                final status = item.bookingStatus ?? 'Confirmed';
                final formattedStatus = status.isNotEmpty
                    ? '${status[0].toUpperCase()}${status.substring(1)}'
                    : 'Confirmed';
                final statusColor = _getStatusColor(status);

                return Material(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LabReportDetailScreen(
                            booking: item,
                            testName: testTitle,
                            date: formattedDate.isNotEmpty
                                ? formattedDate
                                : item.bookingDate,
                            labName: labName,
                            bookingNo: item.bookingNo,
                            bookingId: item.bookingId,
                          ),
                        ),
                      ).then((_) {
                        controller.fetchPatientLabBookings();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderGrey),
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
                          // Header: Icon + Test Name + Status Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.biotech_rounded,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      testTitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (item.bookingNo != null &&
                                        item.bookingNo!.isNotEmpty)
                                      Text(
                                        'ID: ${item.bookingNo}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: textMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  formattedStatus,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1, color: borderGrey),
                          const SizedBox(height: 10),

                          // Center: Lab Name & Date
                          Row(
                            children: [
                              const Icon(Icons.local_hospital_outlined,
                                  size: 14, color: textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  labName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12, color: textDark),
                                ),
                              ),
                              if (formattedDate.isNotEmpty) ...[
                                const Icon(Icons.calendar_today_outlined,
                                    size: 13, color: textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Bottom: Amount & View Report action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Amount: ',
                                    style: TextStyle(
                                        fontSize: 12, color: textMuted),
                                  ),
                                  Text(
                                    '₹${item.netAmount ?? "250"}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
