import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/controllers/job_controller.dart';
import 'package:vlr/data/models/job_post_model.dart';
import 'package:vlr/data/models/job_detail_model.dart';
import 'package:vlr/services/appsflyer_service.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/job/applied_job_history_screen.dart';

class JobDetailHeader extends StatelessWidget {
  final JobPostModel job;
  final JobDetailData? detailData;
  final String? referralCode;

  const JobDetailHeader({
    super.key,
    required this.job,
    this.detailData,
    this.referralCode,
  });

  void _shareJob(BuildContext context) async {
    final jobId = detailData?.id ?? job.id;
    final jobTitle = detailData?.header?.jobTitle ?? job.jobTitle ?? "Job";
    final companyName = detailData?.header?.companyName ?? detailData?.companyDetail?.companyName ?? job.department?.name;

    if (jobId == null) return;

    final jobController = Get.find<JobController>();

    final random = Random();
    final digits = List.generate(9, (_) => random.nextInt(10)).join();
    final newReferralCode = 'Feetrack$digits';

    dev.log('==================================================', name: 'SHARE_JOB');
    dev.log('1. Generated Referral Code: $newReferralCode for Job ID: $jobId', name: 'SHARE_JOB');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating share link...'),
        duration: Duration(seconds: 1),
      ),
    );

    bool success = await jobController.shareReferral(
      postId: jobId,
      referralCode: newReferralCode,
    );

    dev.log('2. Share Referral API Response Success: $success', name: 'SHARE_JOB');

    if (success) {
      final shareUrl = await AppsFlyerService.generateJobShareLink(
        jobId: jobId,
        jobTitle: jobTitle,
        companyName: companyName,
        referralCode: newReferralCode,
      );

      dev.log('3. Generated OneLink URL: $shareUrl', name: 'SHARE_JOB');

      if (shareUrl != null) {
        final shareMessage = "Check out this job: $jobTitle\nCompany: ${companyName ?? 'Feetrack'}\n\nUse my referral code: $newReferralCode\n\nApply here: $shareUrl";
        dev.log('4. FINAL SHARE MESSAGE:\n$shareMessage', name: 'SHARE_JOB');
        dev.log('==================================================', name: 'SHARE_JOB');

        Share.share(
          shareMessage,
          subject: "Job Opportunity: $jobTitle",
        );
      }
    } else {
      dev.log('FAILED to record share referral on server.', name: 'SHARE_JOB');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate referral link. Please try again.')),
        );
      }
    }
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(12.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(20.w),
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which data to show from detailData or fallback job
    final title = detailData?.header?.jobTitle ?? job.jobTitle ?? "N/A";
    final company = detailData?.header?.companyName ?? detailData?.companyDetail?.companyName ?? detailData?.branch?.name ?? job.department?.name ?? "Company";
    final type = detailData?.header?.employmentType ?? detailData?.jobDetail?.overview?.type ?? job.employmentType ?? "Full Time";
    final location = detailData?.header?.location ?? detailData?.jobDetail?.overview?.jobCity ?? detailData?.branch?.name ?? job.branch?.name ?? "N/A";
    final applicants = detailData?.header?.applicantsCount ?? 0;
    final jobCode = detailData?.jobCode ?? job.jobCode;
    final logoUrl = detailData?.header?.logoUrl ?? detailData?.companyDetail?.logoUrl ?? detailData?.bannerUrl ?? detailData?.branch?.companyLogo ?? job.bannerUrl;
    final distance = detailData?.jobDetail?.overview?.distance;
    final referralAmount = detailData?.referralAmount;

    return Stack(
      children: [
        // 1. Dark Gradient Top Background
        Container(
          height: 240.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF061A49),
                Color(0xFF03143A),
                Color(0xFF02112F),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35.r),
              bottomRight: Radius.circular(35.r),
            ),
          ),
        ),

        // 2. Navigation & Main Card
        Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 5.h),
            
            // Back & Actions Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          navigate(
                            context: context,
                            page: const AppliedJobHistoryScreen(),
                          );
                        },
                        tooltip: "Applied Job History",
                        icon: Icon(
                          Icons.work_history_outlined,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _shareJob(context),
                        icon: Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Logo & Job Info Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Company Logo
                  GestureDetector(
                    onTap: () {
                      if (logoUrl != null && logoUrl.isNotEmpty) {
                        _showFullImage(context, logoUrl);
                      }
                    },
                    child: Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFEAECF0), width: 1.w),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: (logoUrl != null && logoUrl.isNotEmpty)
                            ? Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    title.isNotEmpty ? title[0].toUpperCase() : "J",
                                    style: TextStyle(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1554C0),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  title.isNotEmpty ? title[0].toUpperCase() : "J",
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1554C0),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Job Code Tag if available
                  if (jobCode != null && jobCode.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        "Code: $jobCode",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],

                  // Job Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101828),
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Company & Job Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          company,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(Icons.circle, size: 4.sp, color: const Color(0xFFD0D5DD)),
                      ),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFA6A48),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Badges Row (Location, Applicants, Distance, Referral Amount)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildMiniBadge(Icons.location_on_outlined, location, const Color(0xFF10B981)),
                      _buildMiniBadge(Icons.people_alt_outlined, "$applicants Applicants", const Color(0xFF3B82F6)),
                      if (distance != null && distance.isNotEmpty)
                        _buildMiniBadge(Icons.near_me_outlined, distance, const Color(0xFF8B5CF6)),
                      if (referralAmount != null && (referralAmount is num ? referralAmount > 0 : referralAmount.toString() != "0"))
                        _buildMiniBadge(Icons.card_giftcard_rounded, "Reward: ₹$referralAmount", const Color(0xFFF59E0B)),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // View Applied History Button
                  GestureDetector(
                    onTap: () {
                      navigate(
                        context: context,
                        page: const AppliedJobHistoryScreen(),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.work_history_outlined, size: 16.sp, color: const Color(0xFF1554C0)),
                          SizedBox(width: 6.w),
                          Text(
                            "View Applied History",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1554C0),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.arrow_forward_ios_rounded, size: 10.sp, color: const Color(0xFF1554C0)),
                        ],
                      ),
                    ),
                  ),

                  // Referral Code Applied Badge (if opened from referral deep link)
                  if (referralCode != null && referralCode!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.card_giftcard_rounded, size: 15.sp, color: const Color(0xFF059669)),
                          SizedBox(width: 6.w),
                          Text(
                            "Referral Applied: $referralCode",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF065F46),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniBadge(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
