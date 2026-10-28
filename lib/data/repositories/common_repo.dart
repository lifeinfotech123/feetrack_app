import 'package:get/get_connect/http/src/response/response.dart';
import 'package:vlr/data/api/api_checker.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class CommonRepo {
  final ApiClient apiClient;

  CommonRepo({required this.apiClient});

  Future<Response> fetchBanner() async => await apiClient.getData(
        AppConstants.getBanner,
        "fetchBanner",
      );
}
