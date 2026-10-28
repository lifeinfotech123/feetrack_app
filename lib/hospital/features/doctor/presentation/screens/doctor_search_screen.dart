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

String? _readHospitalAddress(dynamic value) {
  if (value is String) {
    final address = value.trim();
    return address.isEmpty ? null : address;
  }
  if (value is! Map) return null;

  final map = Map<String, dynamic>.from(value);
  for (final key in [
    'full_address',
    'address',
    'location_address',
    'address_line',
    'formatted_address',
  ]) {
    final address = _readHospitalAddress(map[key]);
    if (address != null) return address;
  }

  final parts = [
    map['address_line_1'],
    map['address_line_2'],
    map['street'],
    map['city'],
    map['state'],
    map['pincode'] ?? map['postal_code'],
  ]
      .where((part) => part != null && part.toString().trim().isNotEmpty)
      .map((part) => part.toString().trim())
      .toList();
  return parts.isEmpty ? null : parts.join(', ');
}

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final DoctorController _controller = Get.isRegistered<DoctorController>()
      ? Get.find<DoctorController>()
      : Get.put(DoctorController());

  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  String _selectedHospital = 'All';
  int _selectedTab = 0; // 0 for Doctors, 1 for Services

  bool _isLoading = false;
  bool _isLoadingServices = false;
  String? _errorMessage;
  String? _servicesErrorMessage;

  List<String> _specialties = ['All'];
  List<String> _hospitals = ['All'];
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    // Immediately hydrate from controller if data is already cached
    if (_controller.rawDoctors.isNotEmpty) {
      _doctors = List<Map<String, dynamic>>.from(_controller.rawDoctors);
      _specialties = List<String>.from(_controller.specialties);
      _hospitals = List<String>.from(_controller.hospitals);
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
          _hospitals = List<String>.from(_controller.hospitals);
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
      final activeDoctors =
          _controller.rawDoctors.isNotEmpty ? _controller.rawDoctors : _doctors;
      final activeServices = _controller.rawServices.isNotEmpty
          ? _controller.rawServices
          : _services;
      final activeSpecialties = _controller.specialties.isNotEmpty
          ? _controller.specialties
          : _specialties;
      final activeHospitals =
          _controller.hospitals.isNotEmpty ? _controller.hospitals : _hospitals;

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

      // Filter doctors based on search & filters
      final filteredDoctors = activeDoctors.where((doc) {
        final name = (doc['name'] ?? '').toString().toLowerCase();
        final spec =
            (doc['specialist']?['name'] ?? '').toString().toLowerCase();
        final hosp = (doc['hospital']?['name'] ?? '').toString().toLowerCase();
        final qual = (doc['qualification'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();

        final matchesSearch = query.isEmpty ||
            name.contains(query) ||
            spec.contains(query) ||
            hosp.contains(query) ||
            qual.contains(query);

        final matchesSpecialty = _selectedSpecialty == 'All' ||
            (doc['specialist']?['name'] ?? '').toString().toLowerCase() ==
                _selectedSpecialty.toLowerCase();

        final matchesHospital = _selectedHospital == 'All' ||
            (doc['hospital']?['name'] ?? '').toString().toLowerCase() ==
                _selectedHospital.toLowerCase();

        return matchesSearch && matchesSpecialty && matchesHospital;
      }).toList();

      // Filter services based on search
      final filteredServices = activeServices.where((srv) {
        final name = (srv['name'] ?? '').toString().toLowerCase();
        final hosp = (srv['hospital_name'] ?? '').toString().toLowerCase();
        final desc = (srv['description'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();

        return query.isEmpty ||
            name.contains(query) ||
            hosp.contains(query) ||
            desc.contains(query);
      }).toList();

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: const Text(
            'Doctors & Services',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorWhite,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchDoctors();
            await _fetchServices();
          },
          child: Column(
            children: [
              // Search & Category Switcher Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Tab Switcher (Doctors vs Services)
                    Container(
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                    const SizedBox(height: 12),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: _selectedTab == 0
                              ? 'Search by doctor name, specialty, clinic...'
                              : 'Search by service name, hospital...',
                          hintStyle:
                              const TextStyle(color: textMuted, fontSize: 13),
                          prefixIcon:
                              const Icon(Icons.search, color: primaryColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    // Specialty Filters (Only for Doctors tab)
                    if (_selectedTab == 0 && activeSpecialties.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: activeSpecialties.length,
                          itemBuilder: (context, index) {
                            final spec = activeSpecialties[index];
                            final isSelected = spec == _selectedSpecialty;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(spec),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected ? primaryColor : colorWhite,
                                ),
                                selected: isSelected,
                                selectedColor: colorWhite,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                checkmarkColor: primaryColor,
                                onSelected: (val) {
                                  setState(() => _selectedSpecialty = spec);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content Subheader
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTab == 0
                          ? '${filteredDoctors.length} Doctors (Nearest First)'
                          : '${filteredServices.length} Hospital Services',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: textDark,
                      ),
                    ),
                    if (_selectedTab == 0 && activeHospitals.length > 1)
                      DropdownButton<String>(
                        value: activeHospitals.contains(_selectedHospital)
                            ? _selectedHospital
                            : 'All',
                        isDense: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: primaryColor, size: 20),
                        items: activeHospitals
                            .map((h) => DropdownMenuItem(
                                value: h,
                                child: Text(h,
                                    style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedHospital = val ?? 'All'),
                      ),
                  ],
                ),
              ),

              // Main Content Body (Doctors View or Services View)
              Expanded(
                child: _selectedTab == 0
                    ? _buildDoctorsList(
                        filteredDoctors,
                        isLoading: isDocsLoading,
                        errorMessage: docError,
                        totalDoctors: activeDoctors.length,
                      )
                    : _buildServicesList(
                        filteredServices,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search,
                size: 60, color: colorGrey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text('No doctors match your criteria',
                style: TextStyle(color: textMuted, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

        final hospitalAddress = _readHospitalAddress(doc['hospital']) ??
            _readHospitalAddress(doc['branch']) ??
            _readHospitalAddress(doc);
        final locationParts = [
          hospitalAddress ?? cityStr,
          distStr,
        ].where((part) => part.isNotEmpty).toList();
        final String location = locationParts.isNotEmpty
            ? locationParts.join(' • ')
            : (hospitalName ?? 'Near you');

        final String? fee = doc['consultation_fees'] != null
            ? '₹${doc['consultation_fees']}'
            : null;
        final String imageUrl = DoctorModel.resolveDoctorPhoto(
          photo: doc['photo'] ??
              doc['image'] ??
              doc['profile_photo'] ??
              doc['avatar'],
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
        } else if (doc['inhouse_hours'] != null &&
            doc['inhouse_hours'].toString().isNotEmpty) {
          availability = doc['inhouse_hours'].toString();
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
                  builder: (_) => DoctorDetailScreen(
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
    List<Map<String, dynamic>> filteredServices, {
    required bool isLoading,
    required String? errorMessage,
    required int totalServices,
  }) {
    if (isLoading && filteredServices.isEmpty && totalServices == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16),
            Text('Fetching hospital services...',
                style: TextStyle(color: textMuted)),
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

    if (filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined,
                size: 60, color: colorGrey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text('No hospital services found',
                style: TextStyle(color: textMuted, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        final srv = filteredServices[index];
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
