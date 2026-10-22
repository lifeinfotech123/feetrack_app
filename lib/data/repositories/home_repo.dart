import 'package:get/get_connect/http/src/response/response.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class HomeRepo {
  final ApiClient apiClient;

  HomeRepo({required this.apiClient});

  Future<Response> fetchCategories() async => await apiClient.getData(
        AppConstants.getCategories,
        "fetchCategories",
      );

  Future<Response> fetchCategoriesListing({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.getData(
        AppConstants.getListing,
        "fetchCategoriesListing",
        query: data,
      );

  Future<Response> fetchGyms({Map<String, dynamic>? query}) async {
    // The gym directory is public for both guests and signed-in users. Keep
    // this request unauthenticated consistently: some backend deployments
    // return an empty/filtered directory when an app-user bearer token is
    // included, while the public request returns the gym catalogue.
    return apiClient.getData(
      AppConstants.getGyms,
      "fetchGyms",
      query: query,
      headers: const {'Accept': 'application/json'},
    );
  }

  Future<Response> fetchGymDetails({
    required String id,
  }) async =>
      await apiClient.getData(
        AppConstants.gymDetails(id: id),
        "fetchGymDetails",
      );

  Future<Response> fetchPgDetails({
    required String id,
  }) async =>
      await apiClient.getData(
        AppConstants.pgListingDetails(id: id),
        "fetchPgDetails",
      );

  Future<Response> fetchGymCities() async => await apiClient.getData(
        AppConstants.gymCities,
        "fetchGymCities",
      );

  Future<Response> fetchCategoriesListingById({
    required String id,
  }) async =>
      await apiClient.getData(
        "${AppConstants.getListingById}/$id/profile",
        "fetchCategoriesListingById",
      );

  Future<Response> fetchBannerCategoriesListingById({
    required int id,
  }) async =>
      await apiClient.getData(
        AppConstants.categoryBanner(id: id),
        "fetchBannerCategoriesListingById",
      );

  Future<Response> fetchFacilitiesListingById({
    required String id,
  }) async =>
      await apiClient.getData(
        AppConstants.getProfileFacilities(id: id),
        "fetchFacilitiesListingById",
      );

  Future<Response> fetchStaffListingById({
    required String id,
  }) async =>
      await apiClient.getData(
        AppConstants.gymStaff(id: id),
        "fetchStaffListingById",
      );

  Future<Response> fetchStaffProfileById({
    required String id,
    required String staffId,
  }) async =>
      await apiClient.getData(
        AppConstants.gymStaffProfile(id: id, staffId: staffId),
        "fetchStaffProfileById",
      );

  Future<Response> fetchBranchesListingById({
    required int id,
  }) async =>
      await apiClient.getData(
        AppConstants.getProfileBranches(id: id),
        "fetchBranchesListingById",
      );
}
