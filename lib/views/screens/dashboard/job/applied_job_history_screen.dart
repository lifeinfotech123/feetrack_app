import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/job_controller.dart';
import 'package:vlr/data/models/job_post_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';
import 'package:vlr/views/screens/dashboard/job/applied_job_history_detail_screen.dart';

class AppliedJobHistoryScreen extends StatefulWidget {
  const AppliedJobHistoryScreen({super.key});

  @override
  State<AppliedJobHistoryScreen> createState() => _AppliedJobHistoryScreenState();
}

class _AppliedJobHistoryScreenState extends State<AppliedJobHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
      if (authCtrl != null && authCtrl.isLoggedIn()) {
        Get.find<JobController>().getAppliedJobList();
      }
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat("dd MMM yyyy").format(dt);
    } catch (_) {
      return dateStr.split("T").first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final bool isLoggedIn = authCtrl?.isLoggedIn() ?? false;

    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF101828), size: 18.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Applied Job History",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 48.sp,
                    color: Colors.amber.shade800,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Browsing as Guest",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: const Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Please log in to view and track your submitted job applications.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF667085)),
                ),
                SizedBox(height: 20.h),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(Icons.login_rounded, color: Colors.white, size: 18.sp),
                  label: Text(
                    "Log In to FeeTrack",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF101828), size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Applied Job History",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryColor, size: 22.sp),
            onPressed: () {
              Get.find<JobController>().getAppliedJobList();
            },
          ),
        ],
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              await controller.getAppliedJobList();
            },
            child: controller.isAppliedJobsLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : controller.appliedJobList.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.w),
                        itemCount: controller.appliedJobList.length,
                        separatorBuilder: (context, index) => SizedBox(height: 14.h),
                        itemBuilder: (context, index) {
                          final job = controller.appliedJobList[index];
                          return _buildAppliedJobCard(context, job);
                        },
                      ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_history_outlined,
                size: 56.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "No Applied Jobs Found",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF101828),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "You have not applied for any jobs yet. Browse available jobs and apply to see your application history here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF667085),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedJobCard(BuildContext context, JobPostModel job) {
    return GestureDetector(
      onTap: () {
        navigate(
          context: context,
          page: AppliedJobHistoryDetailScreen(
            appliedId: job.id,
            initialJob: job,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Logo/Avatar + Title + Code
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1554C0),
                    borderRadius: BorderRadius.circular(12.r),
                    image: job.bannerUrl != null && job.bannerUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(job.bannerUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: job.bannerUrl == null || job.bannerUrl!.isEmpty
                      ? Center(
                          child: Text(
                            job.jobTitle != null && job.jobTitle!.trim().isNotEmpty
                                ? job.jobTitle!.trim()[0].toUpperCase()
                                : "J",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              job.jobTitle?.trim() ?? "N/A",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                              ),
                            ),
                          ),
                          if (job.jobCode != null && job.jobCode!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                job.jobCode!,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        job.department?.name ?? job.branch?.name ?? "Main Org",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 12.h),

            // Chips / Meta Info (Employment Type, Salary, Experience)
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (job.employmentType != null && job.employmentType!.isNotEmpty)
                  _buildMetaChip(
                    icon: Icons.work_outline_rounded,
                    label: job.employmentType!,
                    bgColor: const Color(0xFFEFF6FF),
                    textColor: const Color(0xFF1D4ED8),
                  ),
                if (job.salary != null && job.salary!.isNotEmpty)
                  _buildMetaChip(
                    icon: Icons.payments_outlined,
                    label: job.salary!,
                    bgColor: const Color(0xFFECFDF5),
                    textColor: const Color(0xFF047857),
                  ),
                if (job.experience != null && job.experience!.isNotEmpty)
                  _buildMetaChip(
                    icon: Icons.star_outline_rounded,
                    label: job.experience!,
                    bgColor: const Color(0xFFFFF7ED),
                    textColor: const Color(0xFFC2410C),
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            // Footer: Deadline & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14.sp, color: const Color(0xFF94A3B8)),
                    SizedBox(width: 4.w),
                    Text(
                      "Deadline: ${_formatDate(job.applicationDeadline)}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        job.status?.toUpperCase() ?? "APPLIED",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
