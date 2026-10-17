import 'package:get/get.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class GymRepo {
  final ApiClient apiClient;

  GymRepo({required this.apiClient});

  Future<Response> fetchGymTrainers({String? id}) async =>
      await apiClient.getData(
        id != null && id.isNotEmpty
            ? "${AppConstants.gymTrainers}?gym_id=$id"
            : AppConstants.gymTrainers,
        "fetchGymTrainers",
      );

  Future<Response> fetchTrainerDetails({required String id}) async =>
      await apiClient.getData(
        AppConstants.gymTrainerDetails(id: id),
        "fetchTrainerDetails",
      );

  Future<Response> fetchMyGymBookings() async =>
      await apiClient.getData(
        AppConstants.myGymBookings,
        "fetchMyGymBookings",
      );

  Future<Response> bookGymVisit({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.gymBookVisit,
        "bookGymVisit",
        data,
      );

  Future<Response> bookGymMembership({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.gymBookMembership,
        "bookGymMembership",
        data,
      );

  Future<Response> fetchGymCities() async =>
      await apiClient.getData(
        AppConstants.gymCities,
        "fetchGymCities",
      );

  Future<Response> verifyPaymentBooking({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.gymVerifyPayment,
        "verifyPaymentBooking",
        data,
      );

  Future<Response> fetchGymShifts() async => await apiClient.getData(
        AppConstants.gymShifts,
        "fetchGymShifts",
      );

  Future<Response> fetchGymShiftsByGymId({required String gymId}) async =>
      await apiClient.getData(
        AppConstants.gymSpecificShifts(gymId: gymId),
        "fetchGymShiftsByGymId",
      );

  Future<Response> fetchGymShiftDetails({required String id}) async =>
      await apiClient.getData(
        AppConstants.gymShiftDetails(id: id),
        "fetchGymShiftDetails",
      );
}
