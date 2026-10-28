import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class BasicRepo {
  final ApiClient apiClient;
  const BasicRepo({required this.apiClient});

  Future<Response> fetchListingReviewsById({
    required String? id,
  }) async =>
      await apiClient.getData(
        AppConstants.getReviews(id: id),
        "fetchListingReviewsById",
      );

  Future<Response> submitReviewsById({
    required String? id,
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.putSubmitReviews(id: id),
        "submitReviewsById",
        data,
      );
}
