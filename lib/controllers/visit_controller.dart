import 'dart:developer';

import 'package:get/get.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/models/visit_model.dart';
import 'package:vlr/data/repositories/visit_repo.dart';

class VisitController extends GetxController implements GetxService {
  final VisitRepo visitRepo;

  VisitController({required this.visitRepo});

  bool isLoading = false;

  List<VisitModel> visitList = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isPaginating = false;

  VisitModel? selectedVisit;

  List<VisitModel> pgVisitList = [];
  bool isPgVisitsLoading = false;
  VisitModel? selectedPgVisit;
  bool isPgVisitDetailLoading = false;

  Future<ResponseModel> createVisit({
    required String listingId,
    required String visitDate,
    required String visitTime,
    String? note,
  }) async {
    log('-----------  createVisit ----------');

    ResponseModel responseModel;
    isLoading = true;
    selectedVisit = null;
    update();

    try {
      final Map<String, dynamic> data = {
        "listing_id": listingId,
        "visit_date": visitDate,
        "visit_time": visitTime,
        if (note != null && note.isNotEmpty) "note": note,
      };

      Response response = await visitRepo.createVisit(data: data);

      final status = response.body['status'];
      if (status == "success" || status == true) {
        responseModel = ResponseModel(
            true, response.body['message'] ?? "Visit booked successfully");
      } else {
        responseModel = ResponseModel(false,
            response.body['message'] ?? "Error while booking visit");
      }
    } catch (e) {
      log('ERROR AT createVisit(): $e');
      responseModel = ResponseModel(false, "Error while booking visit $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> bookGymVisit({
    required String listingId,
    required String visitDate,
    required String preferredTime,
    String? note,
    int? appUserId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
  }) async {
    log('----------- bookGymVisit ----------');
    isLoading = true;
    selectedVisit = null;
    update();

    ResponseModel responseModel;
    try {
      final Map<String, dynamic> data = {
        "listing_id": listingId,
        "visit_date": visitDate,
        "preferred_time": preferredTime,
        if (note != null && note.isNotEmpty) "note": note,
        if (appUserId != null) "app_user_id": appUserId,
        if (customerName != null && customerName.isNotEmpty)
          "customer_name": customerName,
        if (customerPhone != null && customerPhone.isNotEmpty)
          "customer_phone": customerPhone,
        if (customerEmail != null && customerEmail.isNotEmpty)
          "customer_email": customerEmail,
      };

      Response response = await visitRepo.bookGymVisit(data: data);
      final status = response.body?['status'];
      final isSuccess = status == true || status == "success";

      if (isSuccess) {
        responseModel = ResponseModel(
          true,
          response.body?['message'] ?? "Gym visit scheduled successfully!",
          response.body?['data'],
        );
      } else {
        responseModel = ResponseModel(
          false,
          response.body?['message'] ?? "Error while booking gym visit",
          response.body?['data'],
        );
      }
    } catch (e) {
      log('ERROR AT bookGymVisit(): $e');
      responseModel = ResponseModel(false, "Error while booking visit: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchVisits({bool isLoadMore = false}) async {
    log('-----------  fetchVisits ----------');

    if (isLoadMore) {
      if (currentPage >= lastPage) {
        return ResponseModel(false, "No more visits");
      }
      isPaginating = true;
      currentPage++;
      update();
    } else {
      isLoading = true;
      currentPage = 1;
      visitList.clear();
      update();
    }

    ResponseModel responseModel;

    try {
      Response response = await visitRepo.fetchVisits(page: currentPage);

      final status = response.body?['status'];
      final isSuccess = status == true || status == "success";

      if (isSuccess && response.body?['data'] != null) {
        final data = response.body['data'];
        List visitsJson = [];
        if (data is Map && data['data'] is List) {
          visitsJson = data['data'];
          lastPage = data['last_page'] ?? 1;
        } else if (data is List) {
          visitsJson = data;
          lastPage = 1;
        }

        if (isLoadMore) {
          visitList.addAll(visitsJson
              .map((e) => VisitModel.fromJson(Map<String, dynamic>.from(e)))
              .toList());
        } else {
          visitList = visitsJson
              .map((e) => VisitModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }

        responseModel = ResponseModel(
            true, response.body['message'] ?? "Fetched visits successfully");
      } else {
        if (isLoadMore) currentPage--;
        responseModel = ResponseModel(false,
            response.body['message'] ?? "Error while fetching visits");
      }
    } catch (e) {
      log('ERROR AT fetchVisits(): $e');
      if (isLoadMore) currentPage--;
      responseModel = ResponseModel(false, "Error while fetching visits $e");
    }

    isLoading = false;
    isPaginating = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchVisitDetail({required String id}) async {
    log('-----------  fetchVisitDetail ----------');

    ResponseModel responseModel;
    isLoading = true;
    selectedVisit = null;
    update();

    try {
      Response response = await visitRepo.fetchVisitDetail(id: id);

      if (response.body['status'] == "success") {
        selectedVisit = VisitModel.fromJson(response.body['data']);
        responseModel = ResponseModel(
            true, response.body['message'] ?? "Fetched visit detail successfully");
      } else {
        responseModel = ResponseModel(false,
            response.body['message'] ?? "Error while fetching visit detail");
      }
    } catch (e) {
      log('ERROR AT fetchVisitDetail(): $e');
      responseModel = ResponseModel(false, "Error while fetching visit detail $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> cancelPgVisit({required String id}) async {
    log('----------- cancelPgVisit: $id ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await visitRepo.cancelPgVisit(id: id);

      final status = response.body?['status'];
      final isSuccess = status == true || status == "success";

      if (isSuccess) {
        final message =
            response.body?['message'] ?? "Visit request has been cancelled.";
        VisitModel? updatedVisit;
        if (response.body?['data'] != null && response.body?['data'] is Map) {
          updatedVisit = VisitModel.fromJson(
              Map<String, dynamic>.from(response.body['data']));
        }

        // Update local status in pgVisitList
        final index = pgVisitList
            .indexWhere((element) => element.id?.toString() == id.toString());
        if (index != -1) {
          if (updatedVisit != null) {
            pgVisitList[index] = updatedVisit;
          } else {
            pgVisitList[index].status = "cancelled";
            pgVisitList[index].statusLabel = "Cancelled";
          }
        }

        // Update in visitList
        final vIndex = visitList
            .indexWhere((element) => element.id?.toString() == id.toString());
        if (vIndex != -1) {
          if (updatedVisit != null) {
            visitList[vIndex] = updatedVisit;
          } else {
            visitList[vIndex].status = "cancelled";
            visitList[vIndex].statusLabel = "Cancelled";
          }
        }

        if (selectedPgVisit?.id?.toString() == id.toString()) {
          if (updatedVisit != null) {
            selectedPgVisit = updatedVisit;
          } else {
            selectedPgVisit?.status = "cancelled";
            selectedPgVisit?.statusLabel = "Cancelled";
          }
        }
        if (selectedVisit?.id?.toString() == id.toString()) {
          if (updatedVisit != null) {
            selectedVisit = updatedVisit;
          } else {
            selectedVisit?.status = "cancelled";
            selectedVisit?.statusLabel = "Cancelled";
          }
        }

        responseModel = ResponseModel(
            true, message, updatedVisit ?? response.body?['data']);
      } else {
        responseModel = ResponseModel(
          false,
          response.body?['message'] ?? "Error while cancelling visit",
        );
      }
    } catch (e) {
      log('ERROR AT cancelPgVisit(): $e');
      responseModel = ResponseModel(false, "Error while cancelling visit: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> cancelVisit({required String id}) async {
    log('----------- cancelVisit ----------');
    // Try PG customer cancel visit API first
    final pgRes = await cancelPgVisit(id: id);
    if (pgRes.isSuccess) {
      return pgRes;
    }
    // Fallback to legacy deleteData visit
    try {
      Response response = await visitRepo.cancelVisit(id: id);
      if (response.body?['status'] == "success" ||
          response.body?['status'] == true) {
        visitList.removeWhere((element) => element.id == id);
        pgVisitList.removeWhere((element) => element.id == id);
        update();
        return ResponseModel(true,
            response.body?['message'] ?? "Visit cancelled successfully");
      }
    } catch (_) {}
    return pgRes;
  }

  Future<ResponseModel> schedulePgVisit({
    required String listingId,
    required String visitDate,
    required String visitTime,
    String? note,
  }) async {
    log('----------- schedulePgVisit ----------');
    isLoading = true;
    update();

    ResponseModel responseModel;
    try {
      final Map<String, dynamic> data = {
        "listing_id": listingId,
        "visit_date": visitDate,
        "visit_time": visitTime,
        if (note != null && note.isNotEmpty) "note": note,
      };

      Response response = await visitRepo.schedulePgVisit(data: data);
      final status = response.body?['status'];
      final isSuccess = status == true || status == "success";

      if (isSuccess) {
        if (response.body?['data'] != null && response.body?['data'] is Map) {
          selectedVisit = VisitModel.fromJson(response.body['data']);
        }
        responseModel = ResponseModel(
          true,
          response.body?['message'] ?? "Property visit scheduled successfully!",
          response.body?['data'],
        );
      } else {
        responseModel = ResponseModel(
          false,
          response.body?['message'] ?? "Error while scheduling visit",
          response.body?['data'],
        );
      }
    } catch (e) {
      log('ERROR AT schedulePgVisit(): $e');
      responseModel = ResponseModel(false, "Error while scheduling visit: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchPgVisits() async {
    log('----------- fetchPgVisits ----------');
    isPgVisitsLoading = true;
    update();

    ResponseModel responseModel;
    try {
      Response response = await visitRepo.fetchPgVisits();
      final status = response.body?['status'];
      final isSuccess = status == true || status == "success";

      if (isSuccess && response.body?['data'] != null) {
        final data = response.body['data'];
        List visitsJson = [];
        if (data is List) {
          visitsJson = data;
        } else if (data is Map && data['data'] is List) {
          visitsJson = data['data'];
        }

        pgVisitList = visitsJson
            .map((e) => VisitModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        // Also keep visitList in sync as fallback
        visitList = List.from(pgVisitList);

        responseModel = ResponseModel(
          true,
          response.body?['message'] ?? "Visits retrieved successfully.",
          pgVisitList,
        );
      } else {
        responseModel = ResponseModel(
          false,
          response.body?['message'] ?? "Error while fetching PG visits",
        );
      }
    } catch (e) {
      log('ERROR AT fetchPgVisits(): $e');
      responseModel = ResponseModel(false, "Error while fetching PG visits: $e");
    }

    isPgVisitsLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchPgVisitDetail({required String id}) async {
    log('----------- fetchPgVisitDetail ----------');
    isPgVisitDetailLoading = true;
    isLoading = true;
    selectedPgVisit = null;
    selectedVisit = null;
    update();

    ResponseModel responseModel;
    try {
      Response response = await visitRepo.fetchPgVisitDetail(id: id);
      final status = response.body?['status'];
      final isSuccess = status == true || status == "success";

      if (isSuccess && response.body?['data'] != null) {
        selectedPgVisit =
            VisitModel.fromJson(Map<String, dynamic>.from(response.body['data']));
        selectedVisit = selectedPgVisit;
        responseModel = ResponseModel(
          true,
          response.body?['message'] ?? "Visit details retrieved successfully.",
          selectedPgVisit,
        );
      } else {
        responseModel = ResponseModel(
          false,
          response.body?['message'] ?? "Error while fetching visit details",
        );
      }
    } catch (e) {
      log('ERROR AT fetchPgVisitDetail(): $e');
      responseModel =
          ResponseModel(false, "Error while fetching visit detail: $e");
    }

    isPgVisitDetailLoading = false;
    isLoading = false;
    update();
    return responseModel;
  }
}
