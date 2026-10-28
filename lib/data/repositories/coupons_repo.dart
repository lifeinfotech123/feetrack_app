import 'package:get/get_connect.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class CouponsRepo {
  final ApiClient apiClient;

  CouponsRepo({required this.apiClient});

  Future<Response> fetchCouponsList({required String id}) async =>
      await apiClient.getData(
        AppConstants.getCouponsList(id: id),
        "fetchCouponsList",
      );

  Future<Response> applyCouponCode({required FormData data}) async =>
      await apiClient.postData(
        AppConstants.postApplyCouponCode,
        "  applyCouponCode",
        data,
      );
}
