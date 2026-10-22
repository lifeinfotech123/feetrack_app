import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/data/models/category_model/category_model.dart';
import 'package:vlr/data/models/category_model/facilities_model.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/data/models/gym_city_model.dart';
import 'package:vlr/data/models/pagination/pagination_state.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/home_repo.dart';

import '../services/constants.dart';

class HomeController extends GetxController implements GetxService {
  final HomeRepo homeRepo;

  HomeController({required this.homeRepo});

  // -------------------- DISTANCE CALCULATION --------------------

  /// Calculates distance between two coordinates using the Haversine formula.
  /// Returns distance in kilometers.
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Calculates distance for each listing from user's location, sets calculatedDistanceKm,
  /// and sorts listings by distance (nearest first).
  void _calculateDistanceForListings({
    required List<ListingModel> listings,
    required double? userLat,
    required double? userLng,
  }) {
    if (userLat == null || userLng == null) return;

    for (final listing in listings) {
      final double? listingLat = double.tryParse(listing.lat ?? '');
      final double? listingLng = double.tryParse(listing.lng ?? '');

      if (listingLat != null && listingLng != null) {
        listing.calculatedDistanceKm = _calculateDistance(
          userLat,
          userLng,
          listingLat,
          listingLng,
        );
      }
    }

    // Sort listings by effective distance (nearest first)
    listings.sort((a, b) {
      final aDist = a.effectiveDistanceKm ?? double.infinity;
      final bDist = b.effectiveDistanceKm ?? double.infinity;
      return aDist.compareTo(bDist);
    });
  }

  bool isLoading = false;
  bool isListingLoading = false;
  bool isFacilitiesLoading = false;
  bool isStaffLoading = false;

  List<CategoryModel> categoryModelList = [];

  CategoryModel? selectCategoryModel;

  void updateSelectCategoryModel(CategoryModel value) {
    selectCategoryModel = value;
    log("selectCategoryModel : ${selectCategoryModel?.name ?? ""}");
    update();
  }

  TextEditingController searchController = TextEditingController();

  Future<ResponseModel> fetchCategories() async {
    log('----------- logout fetchCategories ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await homeRepo.fetchCategories();

      final status = response.body['status'];
      if (status == true || status == "success") {
        categoryModelList = (response.body['data'] as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();

        log("categoryModelList ; ${categoryModelList.length}");

        responseModel = ResponseModel(
            true, response.body['message'] ?? "success fetchCategories  ");
      } else {
        responseModel = ResponseModel(
            false, response.body['message'] ?? "Error while fetchCategories  ");
      }
    } catch (e) {
      log('ERROR AT fetchCategories(): $e');
      responseModel = ResponseModel(false, "Error while fetchCategories   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  List<ListingModel> listingModelList = [];

  // Categorized lists for home screen sections
  bool isGymLoading = false;
  List<ListingModel> gymList = [];
  bool isGymCitiesLoading = false;
  List<GymCityModel> gymCityList = [];
  GymCityModel? selectedGymCity;

  /// The gym-home UI must always render from the dedicated gym endpoint.
  /// `listingModelList` is shared with the other service home screens and can
  /// be replaced by their requests, so it is intentionally not used here.
  List<ListingModel> get displayedGymList {
    final city = selectedGymCity?.city.trim().toLowerCase();
    if (city == null || city.isEmpty) return gymList;

    return gymList.where((gym) {
      final gymCity = gym.city?.trim().toLowerCase() ?? '';
      final address = gym.address?.trim().toLowerCase() ?? '';
      final fullAddress = gym.fullAddress?.trim().toLowerCase() ?? '';
      final landmark = gym.landmark?.trim().toLowerCase() ?? '';
      return gymCity == city ||
          address.contains(city) ||
          fullAddress.contains(city) ||
          landmark.contains(city);
    }).toList();
  }

  bool isDanceLoading = false;
  List<ListingModel> danceList = [];

  bool isPgHostelLoading = false;
  List<ListingModel> pgHostelList = [];

  bool isSearchLoading = false;
  List<ListingModel> searchResultList = [];

  Future<ResponseModel> searchListings({
    required String search,
    required double? latitude,
    required double? longitude,
  }) async {
    log('----------- searchListings ----------');
    ResponseModel responseModel;
    isSearchLoading = true;
    update();
    try {
      final Map<String, dynamic> queryParameters = {
        if (latitude != null) "latitude": latitude.toString(),
        if (longitude != null) "longitude": longitude.toString(),
        "category_id": "",
        "search": search,
        "page": "1",
      };
      final Response response =
          await homeRepo.fetchCategoriesListing(data: queryParameters);
      if (response.body['status'] == "success") {
        searchResultList = (response.body['data']['data'] as List)
            .map((e) => ListingModel.fromJson(e))
            .toList();
        _calculateDistanceForListings(
          listings: searchResultList,
          userLat: latitude,
          userLng: longitude,
        );
        responseModel = ResponseModel(true, "success");
      } else {
        searchResultList = [];
        responseModel =
            ResponseModel(false, response.body['message'] ?? "Error");
      }
    } catch (e) {
      log('ERROR AT searchListings(): $e');
      searchResultList = [];
      responseModel = ResponseModel(false, "Error: $e");
    }
    isSearchLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchGyms({
    double? latitude,
    double? longitude,
    String? search,
    String? city,
  }) async {
    log('----------- fetchGyms (v1/gym/gyms) ----------');
    ResponseModel responseModel;
    // Keep gym loading independent from the shared home loader.  `isLoading`
    // is also used by categories/listings and can otherwise hide this screen's
    // already-loaded gym data when another home request is in progress.
    isGymLoading = true;
    update();

    try {
      final Map<String, dynamic> queryParameters = {
        if (latitude != null) "latitude": latitude.toString(),
        if (longitude != null) "longitude": longitude.toString(),
        if (search != null && search.isNotEmpty) "search": search,
        if (city != null && city.isNotEmpty && city.toLowerCase() != 'all')
          "city": city,
      };

      final Response response = await homeRepo.fetchGyms(
        query: queryParameters.isNotEmpty ? queryParameters : null,
      );

      dynamic body = response.body;
      if (body is String) {
        try {
          body = jsonDecode(body);
        } catch (_) {}
      }
      log("fetchGyms response body type: ${body.runtimeType}");
      log("fetchGyms response status: ${body?['status']} (type: ${body?['status']?.runtimeType})");
      log("fetchGyms response data type: ${body?['data']?.runtimeType}");
      if (body?['data'] is List) {
        log("fetchGyms data is List, length: ${(body['data'] as List).length}");
      } else if (body?['data'] is Map) {
        log("fetchGyms data is Map, keys: ${(body['data'] as Map).keys.toList()}");
      } else {
        log("fetchGyms data is UNEXPECTED type or null: ${body?['data']}");
      }

      if (body != null &&
          (body['status'] == true ||
              body['status'] == 'true' ||
              body['status'] == "success")) {
        log("fetchGyms: STATUS CHECK PASSED ✓");
        List items = [];
        if (body['data'] is List) {
          items = body['data'] as List;
        } else if (body['data'] is Map && body['data']['data'] is List) {
          items = body['data']['data'] as List;
        }
        log("fetchGyms: items count after extraction: ${items.length}");

        gymList = items
            .whereType<Map>()
            .map((e) => ListingModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        log("fetchGyms: gymList count after parsing: ${gymList.length}");
        if (gymList.isNotEmpty) {
          log("fetchGyms: First gym title: ${gymList.first.title}, id: ${gymList.first.id}");
        }

        // If location was passed but returned 0 gyms (outside radius), fallback to all gyms
        if (gymList.isEmpty && (latitude != null || longitude != null)) {
          log("No gyms returned with location filter, falling back to all gyms...");
          final fallbackRes = await homeRepo.fetchGyms(query: null);
          dynamic fbBody = fallbackRes.body;
          if (fbBody is String) {
            try {
              fbBody = jsonDecode(fbBody);
            } catch (_) {}
          }
          if (fbBody != null &&
              (fbBody['status'] == true ||
                  fbBody['status'] == 'true' ||
                  fbBody['status'] == "success")) {
            List fbItems = [];
            if (fbBody['data'] is List) {
              fbItems = fbBody['data'] as List;
            } else if (fbBody['data'] is Map &&
                fbBody['data']['data'] is List) {
              fbItems = fbBody['data']['data'] as List;
            }
            gymList = fbItems
                .whereType<Map>()
                .map((e) => ListingModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }

        _calculateDistanceForListings(
          listings: gymList,
          userLat: latitude,
          userLng: longitude,
        );

        if (selectedGymCity != null) {
          filterGymsByCity(selectedGymCity);
        } else {
          listingModelList = List.from(gymList);
        }
        log("fetchGyms: FINAL listingModelList count: ${listingModelList.length}");
        log("fetchGyms: FINAL gymList count: ${gymList.length}");
        responseModel = ResponseModel(true, body['message'] ?? "success");
      } else {
        responseModel =
            ResponseModel(false, body?['message'] ?? "Error fetching gyms");
      }
    } catch (e) {
      log('ERROR AT fetchGyms(): $e');
      responseModel = ResponseModel(false, "Error: $e");
    }

    isGymLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchGymCities() async {
    log('----------- fetchGymCities (v1/gym/cities) ----------');
    ResponseModel responseModel;
    isGymCitiesLoading = true;
    update();

    try {
      final Response response = await homeRepo.fetchGymCities();
      final body = response.body;
      log("fetchGymCities response: $body");

      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        List items = [];
        if (body['data'] is List) {
          items = body['data'] as List;
        }

        // Deduplicate case-insensitively while accumulating gym counts
        final Map<String, GymCityModel> cityMap = {};
        for (var item in items) {
          if (item is Map) {
            final model =
                GymCityModel.fromJson(Map<String, dynamic>.from(item));
            final rawCity = model.city.trim();
            final key = rawCity.toLowerCase();
            if (key.isNotEmpty) {
              final formattedName =
                  rawCity[0].toUpperCase() + rawCity.substring(1).toLowerCase();
              if (cityMap.containsKey(key)) {
                cityMap[key] = GymCityModel(
                  city: cityMap[key]!.city,
                  gymsCount: cityMap[key]!.gymsCount + model.gymsCount,
                );
              } else {
                cityMap[key] = GymCityModel(
                  city: formattedName,
                  gymsCount: model.gymsCount,
                );
              }
            }
          }
        }

        gymCityList = cityMap.values.toList();
        responseModel = ResponseModel(true, body['message'] ?? "success");
      } else {
        gymCityList = [];
        responseModel = ResponseModel(
            false, body?['message'] ?? "Error fetching gym cities");
      }
    } catch (e) {
      log('ERROR AT fetchGymCities(): $e');
      gymCityList = [];
      responseModel = ResponseModel(false, "Error: $e");
    }

    isGymCitiesLoading = false;
    update();
    return responseModel;
  }

  void filterGymsByCity(GymCityModel? city) {
    selectedGymCity = city;
    if (city == null || city.city.trim().toLowerCase() == 'all') {
      listingModelList = List.from(gymList);
    } else {
      final target = city.city.trim().toLowerCase();
      listingModelList = gymList.where((gym) {
        final gCity = gym.city?.trim().toLowerCase() ?? '';
        final gAddress = gym.address?.trim().toLowerCase() ?? '';
        final gFull = gym.fullAddress?.trim().toLowerCase() ?? '';
        final gLandmark = gym.landmark?.trim().toLowerCase() ?? '';
        return gCity.contains(target) ||
            target.contains(gCity) ||
            gAddress.contains(target) ||
            gFull.contains(target) ||
            gLandmark.contains(target);
      }).toList();
    }
    update();
  }

  Future<ResponseModel> fetchGymDetails({required String id}) async {
    log('----------- fetchGymDetails (v1/gym/gyms/$id) ----------');
    ResponseModel responseModel;
    isLoading = true;
    isListingLoading = true;
    update();

    try {
      final Response response = await homeRepo.fetchGymDetails(id: id);
      final body = response.body;
      log('fetchGymDetails response: $body');

      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        final Map<String, dynamic> gymData =
            body['data'] is Map<String, dynamic>
                ? body['data'] as Map<String, dynamic>
                : Map<String, dynamic>.from(body['data']);

        selectListingModel = ListingModel.fromJson(gymData);

        // Populate amenities into facilityList so GYMprofileAboutAndFacilitiesSection renders them
        if (gymData['amenities'] is List) {
          facilityList = (gymData['amenities'] as List)
              .map((e) => FacilityModel(
                    label: e.toString(),
                    value: "1",
                    fieldType: "checkbox",
                  ))
              .toList();
        }

        responseModel = ResponseModel(true, body['message'] ?? "success");
      } else {
        responseModel = ResponseModel(
            false, body?['message'] ?? "Error while fetching gym details");
      }
    } catch (e) {
      log('ERROR AT fetchGymDetails(): $e');
      responseModel = ResponseModel(false, "Error: $e");
    }

    isLoading = false;
    isListingLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchPgDetails({required String id}) async {
    log('----------- fetchPgDetails (v1/pg/listings/$id) ----------');
    ResponseModel responseModel;
    isLoading = true;
    isListingLoading = true;
    update();

    try {
      final Response response = await homeRepo.fetchPgDetails(id: id);
      final body = response.body;
      log('fetchPgDetails response: $body');

      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        final Map<String, dynamic> pgData = body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : Map<String, dynamic>.from(body['data']);

        selectListingModel = ListingModel.fromJson(pgData);
        responseModel = ResponseModel(true, body['message'] ?? "success");
      } else {
        responseModel = ResponseModel(
            false, body?['message'] ?? "Error while fetching PG details");
      }
    } catch (e) {
      log('ERROR AT fetchPgDetails(): $e');
      responseModel = ResponseModel(false, "Error: $e");
    }

    isLoading = false;
    isListingLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchGymListing({
    required double? latitude,
    required double? longitude,
    String? categoryId,
  }) async {
    return await fetchGyms(latitude: latitude, longitude: longitude);
  }

  Future<ResponseModel> fetchDanceListing({
    required double? latitude,
    required double? longitude,
  }) async {
    log('----------- fetchDanceListing ----------');
    ResponseModel responseModel;
    isDanceLoading = true;
    update();
    try {
      final Map<String, dynamic> queryParameters = {
        if (latitude != null) "latitude": latitude.toString(),
        if (longitude != null) "longitude": longitude.toString(),
        "category_id": "2",
        "page": "1",
        "search": "",
      };

      String queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      log("FULL URL HIT (Dance): ${AppConstants.baseUrl}${AppConstants.getListing}?$queryString");

      final Response response =
          await homeRepo.fetchCategoriesListing(data: queryParameters);
      if (response.body['status'] == "success") {
        danceList = (response.body['data']['data'] as List)
            .map((e) => ListingModel.fromJson(e))
            .toList();
        _calculateDistanceForListings(
          listings: danceList,
          userLat: latitude,
          userLng: longitude,
        );
        responseModel =
            ResponseModel(true, response.body['message'] ?? "success");
      } else {
        responseModel =
            ResponseModel(false, response.body['message'] ?? "error");
      }
    } catch (e) {
      responseModel = ResponseModel(false, "error $e");
    }
    isDanceLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchPgHostelListing({
    required double? latitude,
    required double? longitude,
    String? categoryId,
  }) async {
    log('----------- fetchPgHostelListing ----------');

    ResponseModel responseModel;
    isPgHostelLoading = true;
    update();

    try {
      final String targetCatId = categoryId ??
          categoryModelList
              .firstWhereOrNull((c) =>
                  (c.name ?? '').toLowerCase().contains('room') ||
                  (c.name ?? '').toLowerCase().contains('pg') ||
                  (c.name ?? '').toLowerCase().contains('hostel') ||
                  (c.slug ?? '').toLowerCase().contains('room'))
              ?.id
              ?.toString() ??
          "12";

      final Map<String, dynamic> queryParameters = {
        if (latitude != null) "latitude": latitude.toString(),
        if (longitude != null) "longitude": longitude.toString(),
        "category_id": targetCatId,
        "page": "1",
        "search": "",
      };

      String queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      log("FULL URL HIT (PG): ${AppConstants.baseUrl}${AppConstants.getListing}?$queryString");

      final Response response =
          await homeRepo.fetchCategoriesListing(data: queryParameters);

      if (response.body['status'] == "success") {
        pgHostelList = (response.body['data']['data'] as List)
            .map((e) => ListingModel.fromJson(e))
            .toList();
        _calculateDistanceForListings(
          listings: pgHostelList,
          userLat: latitude,
          userLng: longitude,
        );

        log("pgHostelList count: ${pgHostelList.length}");

        responseModel = ResponseModel(
            true, response.body['message'] ?? "success fetchPgHostelListing");
      } else {
        responseModel = ResponseModel(false,
            response.body['message'] ?? "Error while fetchPgHostelListing");
      }
    } catch (e) {
      log('ERROR AT fetchPgHostelListing(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchPgHostelListing $e");
    }

    isPgHostelLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchCategoriesListing({
    required double? latitude,
    required double? longitude,
    String? categoryId,
  }) async {
    log('----------- fetchCategoriesListing ----------');

    final String activeCatId =
        categoryId ?? selectCategoryModel?.id?.toString() ?? "";
    final String catName = (selectCategoryModel?.name ?? '').toLowerCase();
    final String catSlug = (selectCategoryModel?.slug ?? '').toLowerCase();

    // If Gym category is selected, hit dedicated gym API (v1/gym/gyms)
    if (activeCatId == "11" ||
        activeCatId == "1" ||
        catName.contains("gym") ||
        catSlug.contains("gym")) {
      return await fetchGyms(latitude: latitude, longitude: longitude);
    }

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final Map<String, dynamic> queryParameters = {
        "latitude": latitude?.toString() ?? "",
        "longitude": longitude?.toString() ?? "",
        "category_id": categoryId ?? selectCategoryModel?.id?.toString() ?? "1",
        "page": "1",
        "search": "",
      };

      // Construct and print full URL
      String queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      String fullUrl =
          "${AppConstants.baseUrl}${AppConstants.getListing}?$queryString";
      log("FULL URL HIT: $fullUrl");

      final Response response =
          await homeRepo.fetchCategoriesListing(data: queryParameters);

      log("Raw response body: ${response.body}");

      final body = response.body;

      if (body == null) {
        responseModel = ResponseModel(false, "Empty response from server");
      } else if (body is Map<String, dynamic> && body['status'] == "success") {
        final listingResponse = body['data'];

        if (listingResponse is Map<String, dynamic> &&
            listingResponse['data'] is List) {
          listingModelList = (listingResponse['data'] as List)
              .map((e) => ListingModel.fromJson(e))
              .toList();
          _calculateDistanceForListings(
            listings: listingModelList,
            userLat: latitude,
            userLng: longitude,
          );

          log("Listing count: ${listingModelList.length}");

          responseModel = ResponseModel(
            true,
            body['message'] ?? "success fetchCategoriesListing",
          );
        } else {
          responseModel = ResponseModel(
            false,
            "Invalid listing response format",
          );
        }
      } else {
        responseModel = ResponseModel(
          false,
          body is Map<String, dynamic>
              ? (body['message'] ?? "Error while fetchCategoriesListing")
              : "Invalid server response",
        );
      }
    } catch (e) {
      log('ERROR AT fetchCategoriesListing(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchCategoriesListing $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  // final PaginationState<ListingModel> listingState =
  //     PaginationState<ListingModel>();

  // List<ListingModel> get listingList => listingState.items;

  // Future<ResponseModel> fetchCategoriesListingPagination({
  //   required double? latitude,
  //   required double? longitude,
  //   bool loadMore = false,
  //   bool refresh = false,
  // }) async {
  //   log('fetchCategoriesListingPagination called '
  //       '(loadMore: $loadMore, refresh: $refresh)');

  //   ResponseModel responseModel = ResponseModel(false, "Unknown error");

  //   if (refresh) {
  //     listingState.page = 1;
  //     listingState.lastPage = 1;
  //     listingState.items.clear();
  //     listingState.dedupeIds.clear();
  //   }

  //   if (loadMore) {
  //     if (!listingState.canLoadMore) {
  //       return ResponseModel(false, "No more pages");
  //     }
  //     listingState.isMoreLoading = true;
  //     listingState.page += 1;
  //   } else {
  //     listingState.isInitialLoading = true;
  //     listingState.page = 1;
  //     listingState.items.clear();
  //     listingState.dedupeIds.clear();
  //   }

  //   update();

  //   try {
  //     final Map<String, dynamic> data = {
  //       "latitude": latitude?.toString() ?? "",
  //       "longitude": longitude?.toString() ?? "",
  //       "category_id": selectCategoryModel?.id?.toString() ?? "",
  //       "search": searchController.text.trim(),
  //       "page": listingState.page.toString(),
  //     };

  //     final Response response =
  //         await homeRepo.fetchCategoriesListing(data: data);

  //     log("Raw response body: ${response.body}");

  //     if (response.statusCode != 200) {
  //       responseModel =
  //           ResponseModel(false, "Status code: ${response.statusCode}");
  //     } else if (response.body is Map<String, dynamic> &&
  //         response.body['status'] == "success") {
  //       final paginated = response.body['data'];

  //       if (paginated is Map<String, dynamic> && paginated['data'] is List) {
  //         final List itemsJson = paginated['data'] as List;

  //         final List<ListingModel> parsedData = itemsJson
  //             .map((e) => ListingModel.fromJson(e as Map<String, dynamic>))
  //             .toList();

  //         final int currentPage =
  //             int.tryParse(paginated['current_page'].toString()) ??
  //                 listingState.page;
  //         final int lastPage =
  //             int.tryParse(paginated['last_page'].toString()) ?? currentPage;

  //         listingState.lastPage = lastPage;
  //         listingState.page = currentPage;

  //         if (loadMore) {
  //           for (final item in parsedData) {
  //             if (!listingState.dedupeIds.contains(item.id)) {
  //               listingState.dedupeIds.add(item.id);
  //               listingState.items.add(item);
  //             }
  //           }
  //         } else {
  //           listingState.items
  //             ..clear()
  //             ..addAll(parsedData);

  //           listingState.dedupeIds
  //             ..clear()
  //             ..addAll(parsedData.map((e) => e.id));
  //         }

  //         log("Listing count: ${listingState.items.length}");
  //         responseModel = ResponseModel(
  //           true,
  //           response.body['message'] ?? "success fetchCategoriesListing",
  //         );
  //       } else {
  //         responseModel =
  //             ResponseModel(false, "Invalid listing response format");
  //       }
  //     } else {
  //       responseModel = ResponseModel(
  //         false,
  //         response.body is Map<String, dynamic>
  //             ? (response.body['message'] ??
  //                 "Error while fetchCategoriesListing")
  //             : "Invalid server response",
  //       );
  //     }
  //   } catch (e) {
  //     log('ERROR AT fetchCategoriesListingPagination(): $e');
  //     responseModel =
  //         ResponseModel(false, "Error while fetchCategoriesListing $e");
  //   }

  //   listingState.isInitialLoading = false;
  //   listingState.isMoreLoading = false;
  //   update();
  //   return responseModel;
  // }

  final PaginationState<ListingModel> listingStateSearch =
      PaginationState<ListingModel>();

  List<ListingModel> get listingSearchList => listingStateSearch.items;

  Future<ResponseModel> searchFetchCategoriesListingPagination({
    required double? latitude,
    required double? longitude,
    bool loadMore = false,
    bool refresh = false,
  }) async {
    log('searchFetchCategoriesListingPagination called '
        '(loadMore: $loadMore, refresh: $refresh)');

    ResponseModel responseModel = ResponseModel(false, "Unknown error");

    if (refresh) {
      listingStateSearch.page = 1;
      listingStateSearch.lastPage = 1;
      listingStateSearch.items.clear();
      listingStateSearch.dedupeIds.clear();
    }

    if (loadMore) {
      if (!listingStateSearch.canLoadMore) {
        return ResponseModel(false, "No more pages");
      }
      listingStateSearch.isMoreLoading = true;
      listingStateSearch.page += 1;
    } else {
      listingStateSearch.isInitialLoading = true;
      listingStateSearch.page = 1;
      listingStateSearch.items.clear();
      listingStateSearch.dedupeIds.clear();
    }

    update();

    try {
      final Map<String, dynamic> queryParameters = {
        if (latitude != null) "latitude": latitude.toString(),
        if (longitude != null) "longitude": longitude.toString(),
        "category_id": selectCategoryModel?.id?.toString() ?? "",
        "search": searchController.text.trim(),
        "page": listingStateSearch.page.toString(),
      };

      final Response response =
          await homeRepo.fetchCategoriesListing(data: queryParameters);

      log("Raw response body: ${response.body}");

      if (response.statusCode != 200) {
        responseModel =
            ResponseModel(false, "Status code: ${response.statusCode}");
      } else if (response.body is Map<String, dynamic> &&
          response.body['status'] == "success") {
        final paginated = response.body['data'];

        if (paginated is Map<String, dynamic> && paginated['data'] is List) {
          final List itemsJson = paginated['data'] as List;

          final List<ListingModel> parsedData = itemsJson
              .map((e) => ListingModel.fromJson(e as Map<String, dynamic>))
              .toList();

          final int currentPage =
              int.tryParse(paginated['current_page'].toString()) ??
                  listingStateSearch.page;
          final int lastPage =
              int.tryParse(paginated['last_page'].toString()) ?? currentPage;

          listingStateSearch.lastPage = lastPage;
          listingStateSearch.page = currentPage;

          if (loadMore) {
            for (final item in parsedData) {
              if (!listingStateSearch.dedupeIds.contains(item.id)) {
                listingStateSearch.dedupeIds.add(item.id);
                listingStateSearch.items.add(item);
              }
            }
          } else {
            listingStateSearch.items
              ..clear()
              ..addAll(parsedData);

            listingStateSearch.dedupeIds
              ..clear()
              ..addAll(parsedData.map((e) => e.id));
          }

          _calculateDistanceForListings(
            listings: listingStateSearch.items,
            userLat: latitude,
            userLng: longitude,
          );

          log("Listing count: ${listingStateSearch.items.length}");
          responseModel = ResponseModel(
            true,
            response.body['message'] ??
                "success searchFetchCategoriesListingPagination",
          );
        } else {
          responseModel =
              ResponseModel(false, "Invalid listing response format");
        }
      } else {
        responseModel = ResponseModel(
          false,
          response.body is Map<String, dynamic>
              ? (response.body['message'] ??
                  "Error while searchFetchCategoriesListingPagination")
              : "Invalid server response",
        );
      }
    } catch (e) {
      log('ERROR AT searchFetchCategoriesListingPagination(): $e');
      responseModel = ResponseModel(
          false, "Error while searchFetchCategoriesListingPagination $e");
    }

    listingStateSearch.isInitialLoading = false;
    listingStateSearch.isMoreLoading = false;
    update();
    return responseModel;
  }

  ListingModel? selectListingModel;

  updateSelectListingModel({required ListingModel value}) async {
    selectListingModel = value;
    update();
  }

  Future<ResponseModel> fetchCategoriesListingById() async {
    log('-----------  fetchCategoriesListingById ----------');

    final id = selectListingModel?.id ?? "";
    final catSlug = selectListingModel?.category?.slug?.toLowerCase() ?? "";
    final catName = selectListingModel?.category?.name?.toLowerCase() ?? "";
    final isGym = catSlug.contains("gym") ||
        catName.contains("gym") ||
        selectCategoryModel?.slug?.toLowerCase() == "gym" ||
        selectCategoryModel?.name?.toLowerCase() == "gym";

    if (isGym && id.isNotEmpty) {
      return await fetchGymDetails(id: id);
    }

    ResponseModel responseModel;
    isLoading = true;
    isListingLoading = true;
    update();

    try {
      log('fetchCategoriesListingById: Fetching for ID: $id');
      Response response = await homeRepo.fetchCategoriesListingById(id: id);

      if (response.body['status'] == "success") {
        selectListingModel = ListingModel.fromJson(response.body['data']);

        responseModel = ResponseModel(true,
            response.body['message'] ?? "success fetchCategoriesListingById  ");
      } else {
        responseModel = ResponseModel(
            false,
            response.body['message'] ??
                "Error while fetchCategoriesListingById  ");
      }
    } catch (e) {
      log('ERROR AT fetchCategoriesListingById(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchCategoriesListingById   $e");
    }

    isLoading = false;
    isListingLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchBannerCategoriesListingById() async {
    log('-----------  fetchBannerCategoriesListingById ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      log("Cate ${selectCategoryModel?.id ?? ""}");
      Response response = await homeRepo.fetchBannerCategoriesListingById(
          id: selectCategoryModel?.id ?? 0);

      if (response.body['status'] == "success") {
        // selectListingModel = ListingModel.fromJson(response.body['data']);

        responseModel = ResponseModel(
            true,
            response.body['message'] ??
                "success fetchBannerCategoriesListingById  ");
      } else {
        responseModel = ResponseModel(
            false,
            response.body['message'] ??
                "Error while fetchBannerCategoriesListingById  ");
      }
    } catch (e) {
      log('ERROR AT fetchBannerCategoriesListingById(): $e');
      responseModel = ResponseModel(
          false, "Error while fetchBannerCategoriesListingById   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  List<FacilityModel> facilityList = [];

  Future<ResponseModel> fetchFacilitiesListingById() async {
    log('-----------  fetchFacilitiesListingById ----------');

    // If facilities are already loaded from gym amenities, don't overwrite
    if (facilityList.isNotEmpty &&
        (selectListingModel?.amenities?.isNotEmpty == true ||
            selectListingModel?.category?.slug?.toLowerCase() == "gym")) {
      return ResponseModel(true, "Facilities already loaded from amenities");
    }

    ResponseModel responseModel;
    isLoading = true;
    isFacilitiesLoading = true;
    update();

    try {
      Response response = await homeRepo.fetchFacilitiesListingById(
          id: selectListingModel?.id ?? "");

      if (response.body['status'] == "success") {
        facilityList = (response.body['data'] as List)
            .map((e) => FacilityModel.fromJson(e))
            .toList();
        responseModel = ResponseModel(true,
            response.body['message'] ?? "success fetchFacilitiesListingById  ");
      } else {
        responseModel = ResponseModel(
            false,
            response.body['message'] ??
                "Error while fetchFacilitiesListingById  ");
      }
    } catch (e) {
      log('ERROR AT fetchFacilitiesListingById(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchFacilitiesListingById   $e");
    }

    isLoading = false;
    isFacilitiesLoading = false;
    update();
    return responseModel;
  }

  List<StaffModel> staffList = [];
  StaffModel? selectedStaffProfile;

  Future<ResponseModel> fetchStaffProfileById({
    required String? id,
    required String? staffId,
  }) async {
    log('-----------  fetchStaffProfileById ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await homeRepo.fetchStaffProfileById(
        id: id ?? "",
        staffId: staffId ?? "",
      );

      if (response.body != null && response.body['status'] == "success") {
        var data = response.body['data'];
        if (data is List && data.isNotEmpty) {
          if (data[0] is Map) {
            selectedStaffProfile =
                StaffModel.fromJson(Map<String, dynamic>.from(data[0]));
          } else {
            selectedStaffProfile = null;
          }
        } else if (data is Map && data.isNotEmpty) {
          if (data.containsKey('id')) {
            selectedStaffProfile =
                StaffModel.fromJson(Map<String, dynamic>.from(data));
          } else {
            // Handle map with numeric keys like {"1": {...}}
            var firstValue = data.values.first;
            var finalData = firstValue is List
                ? (firstValue.isNotEmpty ? firstValue[0] : null)
                : firstValue;
            if (finalData is Map) {
              selectedStaffProfile =
                  StaffModel.fromJson(Map<String, dynamic>.from(finalData));
            } else {
              selectedStaffProfile = null;
            }
          }
        } else {
          selectedStaffProfile = null;
        }

        responseModel = ResponseModel(true,
            response.body['message'] ?? "success fetchStaffProfileById  ");
      } else {
        selectedStaffProfile = null;
        responseModel = ResponseModel(false,
            response.body?['message'] ?? "Error while fetchStaffProfileById  ");
      }
    } catch (e) {
      selectedStaffProfile = null;
      log('ERROR AT fetchStaffProfileById(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchStaffProfileById   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchStaffListingById() async {
    log('-----------  fetchStaffListingById ----------');

    ResponseModel responseModel;
    isLoading = true;
    isStaffLoading = true;
    update();

    try {
      Response response = await homeRepo.fetchStaffListingById(
          id: selectListingModel?.id ?? "");

      if (response.body != null && response.body['status'] == "success") {
        var data = response.body['data'];
        if (data is List) {
          staffList = data.map((e) => StaffModel.fromJson(e)).toList();
        } else if (data is Map && data['data'] is List) {
          staffList = (data['data'] as List)
              .map((e) => StaffModel.fromJson(e))
              .toList();
        } else {
          staffList = [];
        }

        responseModel = ResponseModel(true,
            response.body['message'] ?? "success fetchStaffListingById  ");
      } else {
        staffList = [];
        responseModel = ResponseModel(false,
            response.body?['message'] ?? "Error while fetchStaffListingById  ");
      }
    } catch (e) {
      staffList = [];
      log('ERROR AT fetchStaffListingById(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchStaffListingById   $e");
    }

    isLoading = false;
    isStaffLoading = false;
    update();
    return responseModel;
  }

  List<dynamic> otherBrandedList = [];
//! NO Data is add
  Future<ResponseModel> fetchBranchesListingById() async {
    log('-----------  fetchBranchesListingById ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      log("Id banner ${selectCategoryModel?.id}");
      Response response = await homeRepo.fetchBranchesListingById(
          id: selectCategoryModel?.id ?? 0);

      if (response.body['status'] == "success") {
        // staffList = (response.body['data'] as List)
        //     .map((e) => StaffModel.fromJson(e))
        //     .toList();
        responseModel = ResponseModel(true,
            response.body['message'] ?? "success fetchBranchesListingById  ");
      } else {
        responseModel = ResponseModel(
            false,
            response.body['message'] ??
                "Error while fetchBranchesListingById  ");
      }
    } catch (e) {
      log('ERROR AT fetchBranchesListingById(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchBranchesListingById   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }
}
