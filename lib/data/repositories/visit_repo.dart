import 'package:get/get_connect/http/src/response/response.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class VisitRepo {
  final ApiClient apiClient;

  VisitRepo({required this.apiClient});

  Future<Response> createVisit({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.visitsUrl,
        "createVisit",
        data,
      );

  Future<Response> bookGymVisit({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.gymBookVisit,
        "bookGymVisit",
        data,
      );

  Future<Response> fetchVisits({required int page}) async =>
      await apiClient.getData(
        '${AppConstants.visitsUrl}?page=$page',
        "fetchVisits",
      );

  Future<Response> fetchVisitDetail({required String id}) async =>
      await apiClient.getData(
        AppConstants.getVisitDetailUrl(id),
        "fetchVisitDetail",
      );

  Future<Response> cancelVisit({required String id}) async =>
      await apiClient.deleteData(
        AppConstants.getVisitDetailUrl(id),
        "cancelVisit",
      );

  Future<Response> cancelPgVisit({required String id}) async =>
      await apiClient.postData(
        AppConstants.pgCustomerVisitCancel(id: id),
        "cancelPgVisit",
        {},
      );

  Future<Response> schedulePgVisit({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.pgScheduleVisit,
        "schedulePgVisit",
        data,
      );

  Future<Response> fetchPgVisits() async =>
      await apiClient.getData(
        AppConstants.pgVisits,
        "fetchPgVisits",
      );

  Future<Response> fetchPgVisitDetail({required String id}) async =>
      await apiClient.getData(
        AppConstants.pgVisitDetail(id),
        "fetchPgVisitDetail",
      );
}
