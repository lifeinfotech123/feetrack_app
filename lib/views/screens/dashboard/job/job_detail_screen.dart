import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/job_controller.dart';
import 'package:vlr/data/models/job_post_model.dart';
import 'widget/job_detail_header.dart';
import 'widget/job_detail_tabs.dart';
import 'widget/job_detail_content.dart';
import 'widget/job_detail_bottom_bar.dart';

class JobDetailScreen extends StatefulWidget {
  final JobPostModel job;
  final String? referralCode;

  const JobDetailScreen({
    super.key,
    required this.job,
    this.referralCode,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchJobDetails();
    });
  }

  Future<void> _fetchJobDetails() async {
    final controller = Get.find<JobController>();
    if (widget.referralCode != null && widget.referralCode!.isNotEmpty) {
      await controller.getJobDetailsByReferral(widget.referralCode!);
    } else if (widget.job.id != null) {
      await controller.getJobDetails(widget.job.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC), // High-end app background
      body: GetBuilder<JobController>(
        builder: (jobController) {
          final detailData = jobController.selectedJob;

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchJobDetails,
                      color: const Color(0xFF1554C0),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Header Section
                            JobDetailHeader(
                              job: widget.job,
                              detailData: detailData,
                              referralCode: widget.referralCode,
                            ),

                            // Tab Bar Selection
                            Container(
                              margin: EdgeInsets.only(top: 12.h),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: JobDetailTabs(
                                selectedIndex: _currentTabIndex,
                                onTabChanged: (index) {
                                  setState(() {
                                    _currentTabIndex = index;
                                  });
                                },
                              ),
                            ),

                            // Loading state or Content
                            if (jobController.isLoading && detailData == null)
                              Container(
                                height: 300.h,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(color: Color(0xFF1554C0)),
                                    SizedBox(height: 16.h),
                                    Text(
                                      "Loading Job Details...",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF667085),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              JobDetailContent(
                                selectedIndex: _currentTabIndex,
                                job: widget.job,
                                detailData: detailData,
                              ),

                            SizedBox(height: 100.h), // Spacing for sticky bottom bar
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      // Sticky bottom section
      bottomNavigationBar: GetBuilder<JobController>(
        builder: (jobController) {
          final detailData = jobController.selectedJob;
          final jobId = detailData?.id ?? widget.job.id;
          final jobTitle = detailData?.header?.jobTitle ?? widget.job.jobTitle;

          return JobDetailBottomBar(
            jobId: jobId,
            jobTitle: jobTitle,
            referralCode: widget.referralCode,
          );
        },
      ),
    );
  }
}
