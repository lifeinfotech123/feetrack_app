import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class KycRepo {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  KycRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> submitKyc(FormData formData) async {
    return await apiClient.postData(AppConstants.kycUri, "submitKyc", formData);
  }

  Future<Response> getKycProfile() async {
    return await apiClient.getData(AppConstants.kycUri, "getKycProfile");
  }
}
