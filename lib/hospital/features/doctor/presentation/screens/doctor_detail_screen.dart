import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../appointments/presentation/screen/select_date_and_time_screen.dart';
import '../../data/model/doctor_model.dart';
import '../../data/repositories/doctor_repo.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String name;
  final String specialty;
  final String? doctorName;
  final String? hospital;
  final dynamic rating;
  final dynamic reviewsCount;
  final Map<String, dynamic>? doctorData;
  final DoctorModel? doctorModel;
  final dynamic doctorId;

  const DoctorDetailScreen({
    super.key,
    this.name = "Dr. Thomas Micheal",
    this.specialty = "Cardiologist",
    this.doctorName,
    this.hospital,
    this.rating,
    this.reviewsCount,
    this.doctorData,
    this.doctorModel,
    this.doctorId,
  });

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  bool _isFavorite = false;
  Map<String, dynamic>? _doctorData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _doctorData = widget.doctorData ?? widget.doctorModel?.rawJson;
    final id = widget.doctorId ?? _doctorData?['id'] ?? widget.doctorModel?.id;
    if (_doctorData == null && id != null) {
      _loadDoctorDetails(id);
    }
  }

  Future<void> _loadDoctorDetails(dynamic id) async {
    setState(() => _isLoading = true);
    try {
      final repo = Get.isRegistered<DoctorRepo>()
          ? Get.find<DoctorRepo>()
          : Get.put(DoctorRepo());
      final res = await repo.fetchDoctorById(id);
      if (mounted && res['status'] == true && res['data'] is Map) {
        setState(() {
          _doctorData = Map<String, dynamic>.from(res['data']);
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _doctorData ??
        (widget.doctorModel != null
            ? widget.doctorModel!.rawJson
            : widget.doctorData);

    if (_isLoading && data == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final displayName = data?['name']?.toString() ??
        widget.doctorModel?.name ??
        widget.doctorName ??
        (widget.name.isNotEmpty ? widget.name : "Dr. Thomas Micheal");

    final displaySpecialty = widget.doctorModel?.specialtyName ??
        data?['specialist']?['specialist_name']?.toString() ??
        data?['specialist']?['name']?.toString() ??
        (widget.specialty.isNotEmpty ? widget.specialty : "General Specialist");

    final rawQual = data?['qualification']?.toString();
    final displayQualification = (rawQual != null && rawQual.isNotEmpty)
        ? rawQual.toUpperCase()
        : 'MBBS';

    final rawFee = data?['consultation_fees'] ??
        data?['fee'] ??
        data?['fees'] ??
        widget.doctorModel?.consultationFees;
    final displayFee = rawFee != null
        ? (rawFee.toString().trim().startsWith('₹')
            ? rawFee.toString().trim()
            : "₹$rawFee")
        : "₹500";

    final rawExp = data?['work_experience']?.toString();
    final displayExperience =
        (rawExp != null && rawExp.isNotEmpty) ? rawExp : "12 Years";

    final displayGender = data?['gender']?.toString() ?? 'Male';

    final displayPhoto = DoctorModel.resolveDoctorPhoto(
      photo: data?['photo'] ?? data?['image'] ?? data?['profile_photo'] ?? widget.doctorModel?.photo,
      domain: data?['hospital']?['domain']?.toString() ?? widget.doctorModel?.hospital?.domain,
      gender: displayGender,
    );
    final displayPhone = data?['phone']?.toString() ?? '';
    final displayEmail = data?['email']?.toString() ?? '';
    final displayStaffId = data?['staff_id']?.toString() ?? '';
    final displayDoctorType = (data?['doctor_type']?.toString() == 'in_house')
        ? 'In-House Doctor'
        : (data?['doctor_type']?.toString() ?? 'Visiting Doctor');

    final inhouseDays = data?['inhouse_days'];
    final visitingDays = data?['visiting_days'];
    final List<dynamic> workingDays =
        (inhouseDays is List && inhouseDays.isNotEmpty)
            ? inhouseDays
            : ((visitingDays is List && visitingDays.isNotEmpty)
                ? visitingDays
                : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']);

    final String workingHours = data?['inhouse_hours']?.toString() ??
        data?['visiting_hours']?.toString() ??
        '10:00 - 17:00';

    final List<dynamic> services =
        (data?['services'] is List) ? data!['services'] as List : [];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section with Soft Gradient
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFEBF2FE),
                        Color(0xFFF5F8FF),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 90),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Doctor Basic Details
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      displaySpecialty,
                                      style: const TextStyle(
                                        color: Color(0xFF3B82F6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    displayQualification,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                      height: 1.3,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        displayFee,
                                        style: const TextStyle(
                                          color: Color(0xFF3B82F6),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '/ session',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Doctor Portrait
                            Expanded(
                              flex: 5,
                              child: Container(
                                height: 180,
                                alignment: Alignment.bottomCenter,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    displayPhoto,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.network(
                                      DoctorModel.resolveDoctorPhoto(photo: null, gender: displayGender),
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stat Cards Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                value: displayExperience,
                                label: 'Experience',
                                icon: Icons.work_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                value: displayFee,
                                label: 'Consult Fee',
                                icon: Icons.payments_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                value: displayDoctorType,
                                label: 'Doctor Type',
                                icon: Icons.badge_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Main Details Body (Without Tabs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Doctor Card
                      _buildSectionCard(
                        title: 'About Doctor',
                        icon: Icons.person_outline,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$displayName is a dedicated $displaySpecialty with $displayExperience of medical experience in general and specialist care. Holding a qualification of $displayQualification.',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 14),
                            _buildInfoRow(
                                Icons.person, 'Gender', displayGender),
                            if (displayStaffId.isNotEmpty)
                              _buildInfoRow(
                                  Icons.badge, 'Staff ID', displayStaffId),
                            if (displayPhone.isNotEmpty)
                              _buildInfoRow(
                                  Icons.phone_outlined, 'Phone', displayPhone),
                            if (displayEmail.isNotEmpty)
                              _buildInfoRow(
                                  Icons.email_outlined, 'Email', displayEmail),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Schedule & Availability Card
                      _buildSectionCard(
                        title: 'Working Hours & Availability',
                        icon: Icons.access_time_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Timing Hours',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    workingHours,
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Available Days',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: workingDays.map((day) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6)
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF3B82F6)
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    day.toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Services Card
                      if (services.isNotEmpty) ...[
                        _buildSectionCard(
                          title: 'Offered Services',
                          icon: Icons.medical_services_outlined,
                          child: Column(
                            children: services.map((service) {
                              final sName =
                                  service['name']?.toString() ?? 'Consultation';
                              final sFee = service['fees'] != null
                                  ? "₹${service['fees']}"
                                  : displayFee;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle_outline,
                                              color: Color(0xFF3B82F6),
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              sName,
                                              style: const TextStyle(
                                                color: Color(0xFF1E293B),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      sFee,
                                      style: const TextStyle(
                                        color: Color(0xFF3B82F6),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Padding for bottom button
              ],
            ),
          ),

          // Custom Top Floating Bar (Back, Favorite, Share)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  _buildCircleIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      // Favorite Button
                      _buildCircleIconButton(
                        icon: _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        iconColor:
                            _isFavorite ? Colors.red : const Color(0xFF1E293B),
                        onPressed: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      // Share Button
                      _buildCircleIconButton(
                        icon: Icons.share_outlined,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Button
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              final bool isLoggedIn = Get.isRegistered<AuthController>() &&
                  Get.find<AuthController>().isLoggedIn();
              if (!isLoggedIn) {
                showLoginRequiredDialog(
                  context: context,
                  title: "Login Required",
                  message:
                      "Please login to your account first before booking an appointment with the doctor.",
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectDateAndTimeScreen(
                    doctorName: displayName,
                    designation: displaySpecialty,
                    doctorData: data,
                    consultationFee: displayFee,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C80ED),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = const Color(0xFF1E293B),
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
