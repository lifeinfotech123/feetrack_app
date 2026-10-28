import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/job_controller.dart';
import 'package:vlr/data/models/job_post_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/custom_text.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/job/applied_job_history_screen.dart';
import 'package:vlr/views/screens/dashboard/job/job_detail_screen.dart';
import 'package:vlr/views/screens/dashboard/job/widget/ai_top_section.dart';

class JobScreen extends StatelessWidget {
  const JobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initiate API fetching via Controller when screen is built
    final JobController jobController = Get.find<JobController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jobController.getJobList();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await jobController.getJobList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [

                // AI top section
                const AiTopSection(),

                SizedBox(height: 20.h),

                // Job content starts here
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            "Top AI Matches",
                          ),
                          GestureDetector(
                            onTap: () {
                              navigate(
                                context: context,
                                page: const AppliedJobHistoryScreen(),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.work_history_outlined, size: 14.sp, color: primaryColor),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "Applied Jobs",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // GetBuilder binds live data updates from the newly integrated api
                      GetBuilder<JobController>(
                        builder: (controller) {
                          if (controller.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (controller.jobList.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  "No active job listings found",
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.jobList.length,
                            separatorBuilder: (context, index) => SizedBox(height: 14.h),
                            itemBuilder: (context, index) {
                              JobPostModel job = controller.jobList[index];
                              return _jobCard(
                                context: context,
                                job: job,
                              );
                            },
                          );
                        },
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _jobCard({
    required BuildContext context,
    required JobPostModel job,
  }) {
    final title = job.jobTitle ?? "N/A";
    final company = job.department?.name ?? (job.jobCode != null && job.jobCode!.isNotEmpty ? "Code: ${job.jobCode}" : "FeeTrack");

    // Dynamic location resolution from job_city, country, branch, or address
    String location = "";
    if (job.jobCity != null && job.jobCity!.trim().isNotEmpty) {
      final city = capitalize(job.jobCity!.trim());
      if (job.country != null && job.country!.trim().isNotEmpty) {
        location = "$city, ${job.country!.trim()}";
      } else {
        location = city;
      }
    } else if (job.branch?.name != null && job.branch!.name!.trim().isNotEmpty) {
      location = job.branch!.name!.trim();
    } else if (job.address != null && job.address!.trim().isNotEmpty) {
      location = job.address!.trim();
    } else {
      location = "Location Not Specified";
    }

    final salary = (job.salary != null && job.salary!.trim().isNotEmpty)
        ? job.salary!
        : "Salary Not Disclosed";

    final workMode = job.creator?.workingMode ?? (job.radiusRule != null && job.radiusRule!.isNotEmpty ? job.radiusRule! : "Work from Office");
    final employmentType = (job.employmentType != null && job.employmentType!.isNotEmpty) ? job.employmentType! : "Full Time";
    final experience = (job.experience != null && job.experience!.isNotEmpty) ? job.experience! : "Any Experience";
    final referralAmt = job.referralAmount;
    final hasReferral = referralAmt != null && referralAmt != "0" && referralAmt != "0.00" && referralAmt.isNotEmpty;

    return GestureDetector(
      onTap: () {
        navigate(
          context: context,
          page: JobDetailScreen(job: job),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Logo + Job Title + Company Name + Action Chevron
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    image: job.bannerUrl != null && job.bannerUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(job.bannerUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: job.bannerUrl == null || job.bannerUrl!.isEmpty
                      ? Text(
                          title.isNotEmpty ? title[0].toUpperCase() : "J",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1554C0),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101828),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF98A2B3),
                  size: 22.sp,
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Location Row
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16.sp,
                  color: const Color(0xFF667085),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF667085),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Salary Row
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16.sp,
                  color: const Color(0xFF667085),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    salary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Badges Row (Work Mode | Employment Type | Experience | Referral Reward)
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildTagChip(
                  icon: Icons.business_outlined,
                  label: workMode,
                ),
                _buildTagChip(
                  icon: Icons.work_outline_rounded,
                  label: employmentType,
                ),
                _buildTagChip(
                  icon: Icons.card_travel_rounded,
                  label: experience,
                ),
                if (hasReferral)
                  _buildTagChip(
                    icon: Icons.card_giftcard_rounded,
                    label: "Reward: ₹$referralAmt",
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFEF3C7),
                  ),
              ],
            ),

            SizedBox(height: 10.h),

            // "New" Sparkle Badge / Status
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 14.sp,
                  color: const Color(0xFF7C3AED),
                ),
                SizedBox(width: 4.w),
                Text(
                  job.status != null && job.status!.isNotEmpty ? capitalize(job.status) : "Active",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip({
    required IconData icon,
    required String label,
    Color color = const Color(0xFF475569),
    Color bgColor = const Color(0xFFF1F5F9),
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.sp,
            color: color,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
