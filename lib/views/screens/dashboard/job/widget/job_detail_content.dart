import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/data/models/job_post_model.dart';
import 'package:vlr/data/models/job_detail_model.dart';
import 'package:vlr/services/lanch_helper.dart';

class JobDetailContent extends StatelessWidget {
  final int selectedIndex;
  final JobPostModel job;
  final JobDetailData? detailData;

  const JobDetailContent({
    super.key,
    required this.selectedIndex,
    required this.job,
    this.detailData,
  });

  void _openUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return;
    String url = rawUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri != null) {
      LaunchHelper.launchInBrowser(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 1) {
      return _buildCompanyTab();
    }
    return _buildJobDetailTab();
  }

  Widget _buildJobDetailTab() {
    // Overview data
    final overview = detailData?.jobDetail?.overview;
    final salary = (overview?.salary != null && overview!.salary!.isNotEmpty)
        ? overview.salary!
        : (job.salary ?? "Not specified");
    final type = (overview?.type != null && overview!.type!.isNotEmpty)
        ? overview.type!
        : (job.employmentType ?? "Full Time");
    final workMode = (overview?.workMode != null && overview!.workMode!.isNotEmpty)
        ? overview.workMode!
        : (job.creator?.workingMode ?? "On-site / Remote");
    final level = (overview?.level != null && overview!.level!.isNotEmpty)
        ? overview.level!
        : (job.experience ?? "Not specified");
    final jobCity = (overview?.jobCity != null && overview!.jobCity!.isNotEmpty)
        ? overview.jobCity!
        : (job.branch?.name ?? job.address ?? "Not specified");
    final distance = overview?.distance;

    // Descriptions
    final descriptions = detailData?.jobDetail?.descriptions ??
        job.jobDescription ??
        "No detailed description available.";

    // Skills
    List<String> skillList = detailData?.jobDetail?.skills ?? [];
    if (skillList.isEmpty && job.skills != null && job.skills!.isNotEmpty) {
      skillList = job.skills!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Responsibilities
    List<String> responsibilityList = detailData?.jobDetail?.responsibilities ?? [];

    // Additional Perks
    List<String> perksList = detailData?.jobDetail?.additionalPerks ?? [];

    // Screening Questions
    List<ScreeningQuestion> screeningQuestions = detailData?.jobDetail?.screeningQuestions ?? [];

    // Branch / Workplace info
    final branch = detailData?.branch;
    final company = detailData?.companyDetail;

    // Social Links
    final linkedin = company?.socialLinks?.linkedin ?? branch?.linkedinUrl;
    final facebook = company?.socialLinks?.facebook ?? branch?.facebookUrl;
    final instagram = company?.socialLinks?.instagram ?? branch?.instagramUrl;
    final website = company?.details?.website ?? branch?.website;
    final shareLink = detailData?.shareLink;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Job Overview Grid Card
          _sectionTitle("Job Overview"),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildOverviewItem(Icons.payments_outlined, "Salary", salary, const Color(0xFF16803C)),
                    SizedBox(width: 16.w),
                    _buildOverviewItem(Icons.work_outline_rounded, "Employment", type, const Color(0xFFFA6A48)),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    _buildOverviewItem(Icons.home_work_outlined, "Work Mode", workMode, const Color(0xFF3B82F6)),
                    SizedBox(width: 16.w),
                    _buildOverviewItem(Icons.grade_outlined, "Experience Level", level, const Color(0xFF6366F1)),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    _buildOverviewItem(Icons.location_city_outlined, "Job City", jobCity, const Color(0xFF099268)),
                    SizedBox(width: 16.w),
                    _buildOverviewItem(
                      Icons.near_me_outlined,
                      "Distance",
                      (distance != null && distance.isNotEmpty) ? distance : "N/A",
                      const Color(0xFFD946EF),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // 2. Job Description
          _sectionTitle("Job Description"),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              descriptions,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF475467),
                height: 1.6,
              ),
            ),
          ),

          // 3. Skills Required (if present)
          if (skillList.isNotEmpty) ...[
            SizedBox(height: 24.h),
            _sectionTitle("Skills Required"),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: skillList.map((skill) => _buildSkillChip(skill)).toList(),
            ),
          ],

          // 4. Responsibilities (if present)
          if (responsibilityList.isNotEmpty) ...[
            SizedBox(height: 24.h),
            _sectionTitle("Key Responsibilities"),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: responsibilityList
                    .map(
                      (res) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildBulletPoint(res),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          // 5. Additional Perks & Benefits (if present)
          if (perksList.isNotEmpty) ...[
            SizedBox(height: 24.h),
            _sectionTitle("Perks & Benefits"),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: perksList.map((perk) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: const Color(0xFF16A34A), size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            perk,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF14532D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // 6. Screening Questions (if present)
          if (screeningQuestions.isNotEmpty) ...[
            SizedBox(height: 24.h),
            _sectionTitle("Screening Questions (${screeningQuestions.length})"),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: screeningQuestions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final q = entry.value;
                  final isRequired = q.required == 1;

                  return Container(
                    margin: EdgeInsets.only(bottom: index == screeningQuestions.length - 1 ? 0 : 16.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Q${index + 1}. ",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1554C0),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                q.question ?? "",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: isRequired ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                isRequired ? "Required" : "Optional",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isRequired ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                "Type: ${q.type ?? 'Text'}",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (q.options != null && q.options!.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Text(
                            "Options: ${q.options}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // 7. Branch / Workplace Details Card (if present)
          if (branch != null) ...[
            SizedBox(height: 24.h),
            _sectionTitle("Workplace Location & Branch"),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_city_rounded, color: const Color(0xFF1554C0), size: 24.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          branch.name ?? "Branch Office",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101828),
                          ),
                        ),
                      ),
                      if (branch.status != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: branch.status == 'active' ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            branch.status!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: branch.status == 'active' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (branch.address != null && branch.address!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.place_outlined, size: 18.sp, color: const Color(0xFF64748B)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            branch.address!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF475467),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (branch.radius != null || branch.gstNumber != null) ...[
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (branch.radius != null)
                          Text("Geofence Radius: ${branch.radius}m", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
                        if (branch.gstNumber != null && branch.gstNumber!.isNotEmpty)
                          Text("GST: ${branch.gstNumber}", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          SizedBox(height: 24.h),

          // 8. Social Media Links Section
          _buildSocialLinksSection(
            linkedin: linkedin,
            facebook: facebook,
            instagram: instagram,
            website: website,
            shareLink: shareLink,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyTab() {
    final company = detailData?.companyDetail;
    final branch = detailData?.branch;
    final details = company?.details;

    final companyName = company?.companyName ??
        branch?.name ??
        detailData?.header?.companyName ??
        job.department?.name ??
        "Company";
    final website = details?.website ?? branch?.website ?? "www.demo.com";
    final headquarters = details?.headquarters ?? branch?.address ?? job.branch?.name ?? "N/A";
    final aboutCompany = company?.aboutCompany ??
        branch?.aboutCompany ??
        "Providing top-tier employment opportunities and professional work culture.";
    final industry = details?.industry ?? branch?.industry ?? "HRMS & Corporate Services";
    final companySize = details?.companySize ?? branch?.companySize ?? "10-50 employees";
    final companyType = details?.companyType ?? branch?.companyType ?? "Private Limited";
    final foundedYear = details?.foundedYear ?? branch?.foundedYear ?? "N/A";
    final logoUrl = company?.logoUrl ?? branch?.companyLogo ?? detailData?.header?.logoUrl ?? detailData?.bannerUrl;

    // Social links
    final linkedin = company?.socialLinks?.linkedin ?? branch?.linkedinUrl;
    final facebook = company?.socialLinks?.facebook ?? branch?.facebookUrl;
    final instagram = company?.socialLinks?.instagram ?? branch?.instagramUrl;
    final shareLink = detailData?.shareLink;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Company Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1554C0),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: (logoUrl != null && logoUrl.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.business_rounded,
                                  color: Colors.white,
                                  size: 30.sp,
                                ),
                              ),
                            )
                          : Icon(Icons.business_rounded, color: Colors.white, size: 30.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF101828),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Industry: $industry",
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

                const Divider(height: 32, color: Color(0xFFF2F4F7)),

                // About Company
                _sectionTitle("About Company"),
                SizedBox(height: 10.h),
                Text(
                  aboutCompany,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475467),
                    height: 1.6,
                  ),
                ),

                SizedBox(height: 24.h),

                // Details Table
                _sectionTitle("Company Overview"),
                SizedBox(height: 16.h),
                _buildCompanyDetailRow("Website", website, isUrl: true),
                _buildCompanyDetailRow("Headquarters", headquarters),
                _buildCompanyDetailRow("Company Size", companySize),
                _buildCompanyDetailRow("Company Type", companyType),
                _buildCompanyDetailRow("Founded Year", foundedYear),
                _buildCompanyDetailRow("Job Code", detailData?.jobCode ?? job.jobCode ?? "N/A"),

                if (branch?.gstNumber != null && branch!.gstNumber!.isNotEmpty)
                  _buildCompanyDetailRow("GST Number", branch.gstNumber!),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Social Media Section
          _buildSocialLinksSection(
            linkedin: linkedin,
            facebook: facebook,
            instagram: instagram,
            website: website,
            shareLink: shareLink,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksSection({
    required String? linkedin,
    required String? facebook,
    required String? instagram,
    required String? website,
    required String? shareLink,
  }) {
    final hasAnyLink = (linkedin != null && linkedin.isNotEmpty) ||
        (facebook != null && facebook.isNotEmpty) ||
        (instagram != null && instagram.isNotEmpty) ||
        (website != null && website.isNotEmpty) ||
        (shareLink != null && shareLink.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Social Media & Links"),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Connect with us on official social channels and platforms:",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF667085),
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: [
                  if (linkedin != null && linkedin.isNotEmpty)
                    _buildSocialButton(
                      label: "LinkedIn",
                      icon: Icons.business_rounded,
                      url: linkedin,
                      color: const Color(0xFF0A66C2),
                    ),
                  if (facebook != null && facebook.isNotEmpty)
                    _buildSocialButton(
                      label: "Facebook",
                      icon: Icons.facebook_rounded,
                      url: facebook,
                      color: const Color(0xFF1877F2),
                    ),
                  if (instagram != null && instagram.isNotEmpty)
                    _buildSocialButton(
                      label: "Instagram",
                      icon: Icons.camera_alt_rounded,
                      url: instagram,
                      color: const Color(0xFFE4405F),
                    ),
                  if (website != null && website.isNotEmpty)
                    _buildSocialButton(
                      label: "Website",
                      icon: Icons.language_rounded,
                      url: website,
                      color: const Color(0xFF2563EB),
                    ),
                  if (shareLink != null && shareLink.isNotEmpty)
                    _buildSocialButton(
                      label: "Share Portal Link",
                      icon: Icons.link_rounded,
                      url: shareLink,
                      color: const Color(0xFF1554C0),
                    ),

                  // Fallback buttons if links not configured in API response yet
                  if (!hasAnyLink) ...[
                    _buildSocialButton(
                      label: "Website",
                      icon: Icons.language_rounded,
                      url: "www.demo.com",
                      color: const Color(0xFF2563EB),
                    ),
                    _buildSocialButton(
                      label: "LinkedIn",
                      icon: Icons.business_rounded,
                      url: "https://www.linkedin.com",
                      color: const Color(0xFF0A66C2),
                    ),
                    _buildSocialButton(
                      label: "Facebook",
                      icon: Icons.facebook_rounded,
                      url: "https://www.facebook.com",
                      color: const Color(0xFF1877F2),
                    ),
                    _buildSocialButton(
                      label: "Instagram",
                      icon: Icons.camera_alt_rounded,
                      url: "https://www.instagram.com",
                      color: const Color(0xFFE4405F),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required String url,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.open_in_new_rounded, color: color, size: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF101828),
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF98A2B3),
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF344054),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF344054),
        ),
      ),
    );
  }

  Widget _buildCompanyDetailRow(String label, String value, {bool isUrl = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF667085),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: isUrl ? () => _openUrl(value) : null,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isUrl ? const Color(0xFF2563EB) : const Color(0xFF101828),
                  decoration: isUrl ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.h, right: 10.w),
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Color(0xFF1554C0),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475467),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
