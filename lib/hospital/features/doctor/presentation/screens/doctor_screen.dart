import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vlr/hospital/core/constants/colors.dart';
import 'package:vlr/hospital/core/widgets/animated_widgets.dart';
import '../../../appointments/presentation/screen/select_date_and_time_screen.dart';
import '../../data/model/doctor_model.dart';
import '../../logics/doctor_controller.dart';
import '../widget/doctor_show_data_widget.dart';
import 'doctor_detail_screen.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';

num? _parseNum(dynamic val) {
  if (val == null) return null;
  if (val is num) return val;
  return num.tryParse(val.toString());
}

double? _parseDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString());
}

int? _parseInt(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString());
}

class DoctorScreen extends StatefulWidget {
  final String? initialSpecialty;
  const DoctorScreen({super.key, this.initialSpecialty});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final DoctorController _controller = Get.isRegistered<DoctorController>()
      ? Get.find<DoctorController>()
      : Get.put(DoctorController());

  late String selectedSpecialty;
  int _selectedTab = 0; // 0 for Doctors, 1 for Services

  bool _isLoading = false;
  bool _isLoadingServices = false;
  String? _errorMessage;
  String? _servicesErrorMessage;

  List<String> _specialties = ['All'];
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    selectedSpecialty = widget.initialSpecialty ?? 'All';

    // Hydrate immediately if already cached in controller
    if (_controller.rawDoctors.isNotEmpty) {
      _doctors = List<Map<String, dynamic>>.from(_controller.rawDoctors);
      _specialties = List<String>.from(_controller.specialties);
      _isLoading = false;
    } else {
      _isLoading = true;
    }

    if (_controller.rawServices.isNotEmpty) {
      _services = List<Map<String, dynamic>>.from(_controller.rawServices);
      _isLoadingServices = false;
    }

    _fetchDoctors();
    _fetchServices();
  }

  Future<void> _fetchDoctors() async {
    if (_doctors.isEmpty && _controller.rawDoctors.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      await _controller.fetchDoctors();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _doctors = List<Map<String, dynamic>>.from(_controller.rawDoctors);
          _specialties = List<String>.from(_controller.specialties);
          _isLoading = false;
          _errorMessage = _controller.errorMessage.value.isNotEmpty
              ? _controller.errorMessage.value
              : null;
        });
      }
    }
  }

  Future<void> _fetchServices() async {
    if (_services.isEmpty && _controller.rawServices.isEmpty) {
      setState(() {
        _isLoadingServices = true;
        _servicesErrorMessage = null;
      });
    }

    try {
      await _controller.fetchServices();
    } catch (e) {
      if (mounted) {
        setState(() {
          _servicesErrorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _services = List<Map<String, dynamic>>.from(_controller.rawServices);
          _isLoadingServices = false;
          _servicesErrorMessage =
              _controller.servicesErrorMessage.value.isNotEmpty
                  ? _controller.servicesErrorMessage.value
                  : null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeDoctors = _controller.rawDoctors.isNotEmpty
          ? _controller.rawDoctors
          : _doctors;
      final activeServices = _controller.rawServices.isNotEmpty
          ? _controller.rawServices
          : _services;
      final activeSpecialties = _controller.specialties.isNotEmpty
          ? _controller.specialties
          : _specialties;

      final bool isDocsLoading =
          (_controller.isLoadingDoctors.value || _isLoading) &&
              activeDoctors.isEmpty;
      final bool isServsLoading =
          (_controller.isLoadingServices.value || _isLoadingServices) &&
              activeServices.isEmpty;

      final String? docError = _controller.errorMessage.value.isNotEmpty
          ? _controller.errorMessage.value
          : _errorMessage;
      final String? srvError = _controller.servicesErrorMessage.value.isNotEmpty
          ? _controller.servicesErrorMessage.value
          : _servicesErrorMessage;

      // Filter doctors based on selected specialty
      final filteredDoctors = selectedSpecialty == 'All'
          ? activeDoctors
          : activeDoctors.where((doc) {
              final specName = (doc['specialist']?['name'] ?? '').toString();
              return specName.toLowerCase() == selectedSpecialty.toLowerCase();
            }).toList();

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: const Text(
            'Doctors & Hospital Services',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchDoctors();
            await _fetchServices();
          },
          child: Column(
            children: [
              // Toggle Switcher (Doctors vs Services)
              Container(
                color: primaryColor,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services_outlined,
                                  size: 16,
                                  color: _selectedTab == 0
                                      ? primaryColor
                                      : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Doctors (${activeDoctors.length})',
                                  style: TextStyle(
                                    color: _selectedTab == 0
                                        ? primaryColor
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_hospital_outlined,
                                  size: 16,
                                  color: _selectedTab == 1
                                      ? primaryColor
                                      : Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Services (${activeServices.length})',
                                  style: TextStyle(
                                    color: _selectedTab == 1
                                        ? primaryColor
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Specialty Selector (Only for Doctors tab)
              if (_selectedTab == 0 && activeSpecialties.isNotEmpty)
                Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeSpecialties.length,
                    itemBuilder: (context, index) {
                      final specName = activeSpecialties[index];
                      final isSelected = selectedSpecialty == specName;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSpecialty = specName;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              specName,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Section Info Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _selectedTab == 0
                        ? '${filteredDoctors.length} Doctors Available (Nearest Top)'
                        : '${activeServices.length} Hospital Services Available',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textMuted),
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: _selectedTab == 0
                    ? _buildDoctorsList(
                        filteredDoctors,
                        isLoading: isDocsLoading,
                        errorMessage: docError,
                        totalDoctors: activeDoctors.length,
                      )
                    : _buildServicesList(
                        activeServices,
                        isLoading: isServsLoading,
                        errorMessage: srvError,
                        totalServices: activeServices.length,
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDoctorsList(
    List<Map<String, dynamic>> filteredDoctors, {
    required bool isLoading,
    required String? errorMessage,
    required int totalDoctors,
  }) {
    if (isLoading && filteredDoctors.isEmpty && totalDoctors == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16),
            Text('Fetching doctors...', style: TextStyle(color: textMuted)),
          ],
        ),
      );
    }

    if (errorMessage != null && totalDoctors == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(color: textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchDoctors,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredDoctors.isEmpty) {
      return const Center(
        child: Text('No doctors found for this specialty'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        final doc = filteredDoctors[index];

        final String doctorName = doc['name']?.toString() ?? '';
        final String specialty = doc['specialist']?['name']?.toString() ?? '';
        final String? experience = doc['work_experience']?.toString();
        final String? hospitalName = doc['hospital']?['name']?.toString();

        // Calculate distance and location text for card bottom
        final num? distanceVal =
            _parseNum(doc['distance_km'] ?? doc['hospital']?['distance_km']);
        final String distStr = distanceVal != null
            ? '${distanceVal.toStringAsFixed(1)} km away'
            : '';
        final String cityStr = (doc['branch']?['city'] != null &&
                doc['branch']['city'].toString().isNotEmpty)
            ? doc['branch']['city'].toString()
            : (doc['branch']?['name'] != null &&
                    doc['branch']['name'].toString().isNotEmpty)
                ? doc['branch']['name'].toString()
                : '';

        final List<String> locParts =
            [cityStr, distStr].where((s) => s.isNotEmpty).toList();
        final String location = locParts.isNotEmpty
            ? locParts.join(' • ')
            : (hospitalName ?? 'Near you');

        final String? fee = doc['consultation_fees'] != null
            ? '₹${doc['consultation_fees']}'
            : null;
        final String imageUrl = DoctorModel.resolveDoctorPhoto(
          photo: doc['photo'] ?? doc['image'] ?? doc['profile_photo'] ?? doc['avatar'],
          domain: doc['hospital']?['domain']?.toString(),
          gender: doc['gender']?.toString(),
        );

        final double? rating = _parseDouble(doc['rating']);
        final int? reviews = _parseInt(doc['reviews'] ?? doc['rating_count']);

        String? availability;
        if (doc['inhouse_days'] is List &&
            (doc['inhouse_days'] as List).isNotEmpty) {
          final days = (doc['inhouse_days'] as List).join(', ');
          final hours = doc['inhouse_hours']?.toString() ?? '';
          availability = '$days ${hours.isNotEmpty ? "($hours)" : ""}'.trim();
        } else if (doc['visiting_hours'] != null &&
            doc['visiting_hours'].toString().isNotEmpty) {
          availability = doc['visiting_hours'].toString();
        }

        return FadeSlideTransitionWidget(
          index: index,
          child: DoctorShowDataWidget(
            name: doctorName,
            specialty: specialty,
            experience: experience,
            hospital: hospitalName,
            location: location,
            rating: rating,
            reviews: reviews,
            fee: fee,
            availability: availability,
            imageUrl: imageUrl,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailScreen(
                    name: doctorName,
                    specialty: specialty,
                    hospital: hospitalName,
                    rating: rating,
                    reviewsCount: reviews,
                    doctorData: doc,
                    doctorId: doc['id'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildServicesList(
    List<Map<String, dynamic>> servicesList, {
    required bool isLoading,
    required String? errorMessage,
    required int totalServices,
  }) {
    if (isLoading && servicesList.isEmpty && totalServices == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16),
            Text('Fetching services...', style: TextStyle(color: textMuted)),
          ],
        ),
      );
    }

    if (errorMessage != null && totalServices == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(color: textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchServices,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (servicesList.isEmpty) {
      return const Center(
        child: Text('No hospital services found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: servicesList.length,
      itemBuilder: (context, index) {
        final srv = servicesList[index];
        final String sName = srv['name']?.toString() ?? 'Hospital Service';
        final String sHosp = srv['hospital_name']?.toString() ?? 'Hospital';
        final String sDesc = srv['description']?.toString() ?? '';
        final String sPrice =
            srv['price'] != null ? "₹${srv['price']}" : '₹500';
        final String sType = srv['service_type']?.toString() ?? 'doctor';

        return FadeSlideTransitionWidget(
          index: index,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderGrey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.local_hospital_outlined,
                                  size: 14, color: textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  sHosp,
                                  style: const TextStyle(
                                      color: textMuted, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sPrice,
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                if (sDesc.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    sDesc,
                    style: const TextStyle(color: textMuted, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Type: ${sType.toUpperCase()}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: textMuted,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final bool isLoggedIn =
                            Get.isRegistered<AuthController>() &&
                                Get.find<AuthController>().isLoggedIn();
                        if (!isLoggedIn) {
                          showLoginRequiredDialog(
                            context: context,
                            title: "Login Required",
                            message:
                                "Please login to your account first before booking an appointment.",
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectDateAndTimeScreen(
                              doctorName: sHosp,
                              designation: sName,
                              doctorData: {
                                'hospital': {
                                  'name': sHosp,
                                  'domain': srv['domain']
                                },
                                'services': [srv],
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Book Service',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
