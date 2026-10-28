import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vlr/controllers/job_controller.dart';
import 'package:vlr/data/models/job_post_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class AppliedJobHistoryDetailScreen extends StatefulWidget {
  final dynamic appliedId;
  final JobPostModel? initialJob;

  const AppliedJobHistoryDetailScreen({
    super.key,
    required this.appliedId,
    this.initialJob,
  });

  @override
  State<AppliedJobHistoryDetailScreen> createState() => _AppliedJobHistoryDetailScreenState();
}

class _AppliedJobHistoryDetailScreenState extends State<AppliedJobHistoryDetailScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.appliedId != null) {
        Get.find<JobController>().getAppliedJobDetail(widget.appliedId);
      }
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
    } catch (_) {
      return dateStr.split("T").first;
    }
  }

  Future<Uri?> _getValidUri(String url) async {
    String cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return null;
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      if (cleanUrl.startsWith('/')) {
        cleanUrl = 'https://feetrackhrms.bestitcompanylucknow.com$cleanUrl';
      } else {
        cleanUrl = 'https://feetrackhrms.bestitcompanylucknow.com/$cleanUrl';
      }
    }
    try {
      return Uri.parse(Uri.encodeFull(cleanUrl));
    } catch (_) {
      return Uri.tryParse(cleanUrl);
    }
  }

  Future<void> _openFileUrl(String url) async {
    try {
      final uri = await _getValidUri(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showToast(
          message: "Could not open document URL",
          toastType: ToastType.error,
        );
      }
    } catch (e) {
      showToast(
        message: "Failed to open document: $e",
        toastType: ToastType.error,
      );
    }
  }

  Future<void> _downloadFile(String url) async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
    });

    try {
      showToast(message: "Downloading file...", toastType: ToastType.info);

      final uri = await _getValidUri(url);
      if (uri == null) {
        showToast(message: "Invalid document URL", toastType: ToastType.error);
        return;
      }

      // Extract and sanitize filename
      String rawName = "document_${DateTime.now().millisecondsSinceEpoch}.pdf";
      try {
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          rawName = Uri.decodeComponent(pathSegments.last);
        }
      } catch (_) {}

      final cleanFileName = rawName.replaceAll(RegExp(r'[^\w\.-]'), '_');
      final fileName = cleanFileName.isEmpty ? "document_${DateTime.now().millisecondsSinceEpoch}.pdf" : cleanFileName;

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        Directory directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory() ?? await getTemporaryDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        showToast(message: "File downloaded successfully!", toastType: ToastType.success);

        // Share or open via system sheet
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Downloaded document: $fileName',
        );
      } else {
        // Fallback to system browser / download manager
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          showToast(message: "Failed to download file (Error ${response.statusCode})", toastType: ToastType.error);
        }
      }
    } catch (e) {
      // Fallback to opening in external browser
      try {
        final uri = await _getValidUri(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          showToast(message: "Download failed: $e", toastType: ToastType.error);
        }
      } catch (_) {
        showToast(message: "Download failed: $e", toastType: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
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
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              bottom: 10.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _downloadFile(imageUrl);
                },
                icon: Icon(Icons.download_rounded, size: 18.sp),
                label: Text("Download Image", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          "Application Details",
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
              if (widget.appliedId != null) {
                Get.find<JobController>().getAppliedJobDetail(widget.appliedId);
              }
            },
          ),
        ],
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          final job = controller.appliedJobDetail ?? widget.initialJob;

          if (controller.isAppliedJobDetailLoading && job == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (job == null) {
            return _buildNotFoundState();
          }

          final documentUrl = job.resumeUrl ?? job.bannerUrl;

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              if (widget.appliedId != null) {
                await controller.getAppliedJobDetail(widget.appliedId);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Card
                  _buildHeaderCard(job),

                  SizedBox(height: 16.h),

                  // 2. Uploaded Resume / File / Banner Image Section
                  if (documentUrl != null && documentUrl.isNotEmpty) ...[
                    _buildDocumentSection(documentUrl),
                    SizedBox(height: 16.h),
                  ],

                  // 3. User Application Information (if present)
                  if (job.designation != null || job.address != null || job.referralCode != null) ...[
                    _buildApplicationSubmissionInfo(job),
                    SizedBox(height: 16.h),
                  ],

                  // 4. Job Specifications Grid
                  _buildJobOverviewGrid(job),

                  SizedBox(height: 16.h),

                  // 5. Job Description & Required Skills
                  _buildDescriptionCard(job),

                  SizedBox(height: 16.h),

                  // 6. Recruiter / Creator Information
                  if (job.creator != null) ...[
                    _buildCreatorCard(job.creator!),
                    SizedBox(height: 16.h),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48.sp, color: Colors.grey),
          SizedBox(height: 12.h),
          Text(
            "Application details not found",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF344054)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(JobPostModel job) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Banner / Logo
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1554C0),
              borderRadius: BorderRadius.circular(16.r),
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
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(height: 14.h),

          // Title
          Text(
            job.jobTitle?.trim() ?? "N/A",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
          SizedBox(height: 6.h),

          // Department & Branch
          Text(
            "${job.department?.name ?? "Sales & Marketing"} • ${job.branch?.name ?? "Main Branch"}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF667085),
            ),
          ),

          SizedBox(height: 14.h),

          // Job Code + Status Badges Row
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (job.jobCode != null && job.jobCode!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "Code: ${job.jobCode}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8.r),
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
    );
  }

  Widget _buildDocumentSection(String url) {
    final isImage = url.toLowerCase().contains('.jpg') ||
        url.toLowerCase().contains('.jpeg') ||
        url.toLowerCase().contains('.png') ||
        url.toLowerCase().contains('.webp');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_file_rounded, color: primaryColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "Uploaded Document",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF101828),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _downloadFile(url),
                tooltip: "Download File",
                icon: _isDownloading
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                      )
                    : Icon(Icons.download_rounded, color: primaryColor, size: 22.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          if (isImage)
            Column(
              children: [
                GestureDetector(
                  onTap: () => _showImageDialog(context, url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      height: 180.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.fullscreen, color: Colors.white, size: 24.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          side: const BorderSide(color: primaryColor),
                        ),
                        onPressed: () => _openFileUrl(url),
                        icon: Icon(Icons.open_in_new_rounded, size: 16.sp, color: primaryColor),
                        label: Text("VIEW IN BROWSER", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryColor)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        onPressed: () => _downloadFile(url),
                        icon: _isDownloading
                            ? SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(Icons.download_rounded, size: 16.sp),
                        label: Text("DOWNLOAD", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: const Color(0xFF2563EB),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Uploaded Document",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF101828),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Tap button to download or view",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () => _downloadFile(url),
                    icon: _isDownloading
                        ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.download_rounded, size: 16.sp),
                    label: Text(
                      "DOWNLOAD",
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationSubmissionInfo(JobPostModel job) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_rounded, color: primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "My Application Info",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF101828),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (job.designation != null && job.designation!.isNotEmpty)
            _buildDetailRow("Applied Designation", job.designation!),
          if (job.address != null && job.address!.isNotEmpty)
            _buildDetailRow("Address", job.address!),
          if (job.referralCode != null && job.referralCode!.isNotEmpty)
            _buildDetailRow("Referral Code Used", job.referralCode!),
        ],
      ),
    );
  }

  Widget _buildJobOverviewGrid(JobPostModel job) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "Job Overview & Specifications",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF101828),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            children: [
              _buildGridCard("Employment Type", job.employmentType ?? "Full Time", Icons.work_outline_rounded, const Color(0xFF1D4ED8)),
              _buildGridCard("Salary Package", job.salary ?? "N/A", Icons.payments_outlined, const Color(0xFF047857)),
              _buildGridCard("Experience", job.experience ?? "N/A", Icons.star_outline_rounded, const Color(0xFFC2410C)),
              _buildGridCard("Vacancies", job.vacanciesCount?.toString() ?? "1", Icons.people_outline_rounded, const Color(0xFF7C3AED)),
              _buildGridCard("Referral Budget", job.referralBudget?.toString() ?? "N/A", Icons.card_giftcard_rounded, const Color(0xFF0284C7)),
              _buildGridCard("Referral Amount", job.referralAmount?.toString() ?? "N/A", Icons.monetization_on_outlined, const Color(0xFF059669)),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: 12.h),
          _buildDetailRow("Application Deadline", _formatDate(job.applicationDeadline)),
          if (job.createdAt != null)
            _buildDetailRow("Posted / Created Date", _formatDate(job.createdAt)),
        ],
      ),
    );
  }

  Widget _buildGridCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp, color: const Color(0xFF667085)),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF101828)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(JobPostModel job) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Job Description",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            job.jobDescription != null && job.jobDescription!.trim().isNotEmpty
                ? job.jobDescription!
                : "No description provided.",
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
          if (job.skills != null && job.skills!.trim().isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              "Skills Required",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF101828),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: job.skills!
                  .split(',')
                  .map((skill) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          skill.trim(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreatorCard(JobCreator creator) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            child: Icon(Icons.person_outline_rounded, color: primaryColor, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Posted by ${creator.name ?? "HR Team"}",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF101828),
                  ),
                ),
                if (creator.email != null && creator.email!.isNotEmpty)
                  Text(
                    creator.email!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF667085),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF667085),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF101828),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
