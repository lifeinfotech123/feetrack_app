import 'dart:developer';
import 'package:get/get.dart';
import '../data/model/doctor_model.dart';
import '../data/repositories/doctor_repo.dart';

num? _parseNum(dynamic val) {
  if (val == null) return null;
  if (val is num) return val;
  return num.tryParse(val.toString());
}

class DoctorController extends GetxController implements GetxService {
  final DoctorRepo doctorRepo;

  DoctorController({DoctorRepo? doctorRepo})
      : doctorRepo = doctorRepo ??
            (Get.isRegistered<DoctorRepo>()
                ? Get.find<DoctorRepo>()
                : Get.put(DoctorRepo()));

  // Loading & Error States
  final RxBool isLoadingDoctors = false.obs;
  final RxBool isLoadingServices = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString servicesErrorMessage = ''.obs;

  // Raw & Parsed Data
  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxList<Map<String, dynamic>> rawDoctors = <Map<String, dynamic>>[].obs;

  final RxList<DoctorServiceModel> services = <DoctorServiceModel>[].obs;
  final RxList<Map<String, dynamic>> rawServices = <Map<String, dynamic>>[].obs;

  // Filter & Search states
  final RxList<String> specialties = <String>['All'].obs;
  final RxList<String> hospitals = <String>['All'].obs;
  final RxString selectedSpecialty = 'All'.obs;
  final RxString selectedHospital = 'All'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
    fetchServices();
  }

  // 1. Fetch Doctors
  Future<void> fetchDoctors() async {
    try {
      isLoadingDoctors.value = true;
      errorMessage.value = '';

      final res = await doctorRepo.fetchDoctors();

      if (res['status'] == true && res['data'] is List) {
        final List list = res['data'] as List;
        final rawList =
            list.map((item) => Map<String, dynamic>.from(item)).toList();

        // Sort by distance (nearest top)
        rawList.sort((a, b) {
          final num? distA =
              _parseNum(a['distance_km'] ?? a['hospital']?['distance_km']);
          final num? distB =
              _parseNum(b['distance_km'] ?? b['hospital']?['distance_km']);
          if (distA != null && distB != null) {
            return distA.compareTo(distB);
          } else if (distA != null) {
            return -1;
          } else if (distB != null) {
            return 1;
          } else {
            return 0;
          }
        });

        rawDoctors.assignAll(rawList);

        final parsed = rawList.map((m) => DoctorModel.fromJson(m)).toList();
        doctors.assignAll(parsed);

        // Extract Specialties and Hospitals
        final Set<String> specs = {'All'};
        final Set<String> hosps = {'All'};

        for (var doc in rawList) {
          if (doc['specialist'] != null && doc['specialist']['name'] != null) {
            specs.add(doc['specialist']['name'].toString());
          }
          if (doc['hospital'] != null && doc['hospital']['name'] != null) {
            hosps.add(doc['hospital']['name'].toString());
          }
        }

        specialties.assignAll(specs.toList());
        hospitals.assignAll(hosps.toList());
      } else {
        errorMessage.value =
            res['message']?.toString() ?? 'Failed to fetch doctors.';
      }
    } catch (e) {
      log('Error in fetchDoctors: $e', name: 'DoctorController');
      errorMessage.value = e.toString();
    } finally {
      isLoadingDoctors.value = false;
    }
  }

  // 2. Fetch Services
  Future<void> fetchServices() async {
    try {
      isLoadingServices.value = true;
      servicesErrorMessage.value = '';

      final res = await doctorRepo.fetchServices();

      if (res['status'] == true && res['data'] is List) {
        final List list = res['data'] as List;
        final rawList =
            list.map((item) => Map<String, dynamic>.from(item)).toList();
        rawServices.assignAll(rawList);

        final parsed =
            rawList.map((m) => DoctorServiceModel.fromJson(m)).toList();
        services.assignAll(parsed);
      } else {
        servicesErrorMessage.value =
            res['message']?.toString() ?? 'Failed to fetch services.';
      }
    } catch (e) {
      log('Error in fetchServices: $e', name: 'DoctorController');
      servicesErrorMessage.value = e.toString();
    } finally {
      isLoadingServices.value = false;
    }
  }

  // 3. Fetch Doctor By ID
  Future<DoctorModel?> fetchDoctorDetails(dynamic id) async {
    try {
      final res = await doctorRepo.fetchDoctorById(id);
      if (res['status'] == true && res['data'] is Map) {
        return DoctorModel.fromJson(Map<String, dynamic>.from(res['data']));
      }
    } catch (e) {
      log('Error in fetchDoctorDetails: $e', name: 'DoctorController');
    }
    return null;
  }

  // Setters
  void setSelectedSpecialty(String specialty) {
    selectedSpecialty.value = specialty;
  }

  void setSelectedHospital(String hospital) {
    selectedHospital.value = hospital;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Filtered Lists
  List<Map<String, dynamic>> get filteredRawDoctors {
    final query = searchQuery.value.trim().toLowerCase();
    final spec = selectedSpecialty.value;
    final hosp = selectedHospital.value;

    return rawDoctors.where((doc) {
      final nameMatches =
          (doc['name'] ?? '').toString().toLowerCase().contains(query);
      final specMatches = (doc['specialist']?['name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(query);
      final hospMatches = (doc['hospital']?['name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(query);
      final queryMatch =
          query.isEmpty || nameMatches || specMatches || hospMatches;

      final matchesSpecialty = spec == 'All' ||
          (doc['specialist']?['name'] ?? '').toString().toLowerCase() ==
              spec.toLowerCase();

      final matchesHospital = hosp == 'All' ||
          (doc['hospital']?['name'] ?? '').toString().toLowerCase() ==
              hosp.toLowerCase();

      return queryMatch && matchesSpecialty && matchesHospital;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredRawServices {
    final query = searchQuery.value.trim().toLowerCase();
    return rawServices.where((srv) {
      final name = (srv['name'] ?? '').toString().toLowerCase();
      final hosp = (srv['hospital_name'] ?? '').toString().toLowerCase();
      final desc = (srv['description'] ?? '').toString().toLowerCase();

      return query.isEmpty ||
          name.contains(query) ||
          hosp.contains(query) ||
          desc.contains(query);
    }).toList();
  }
}
