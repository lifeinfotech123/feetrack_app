// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
//     show AutocompletePrediction, FindAutocompletePredictionsResponse, FlutterGooglePlacesSdk;
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// import '../data/api/api_client.dart';
// import '../data/models/response/response_model.dart';
// import '../services/constants.dart';

// class LocationController extends GetxController implements GetxService {
//   bool isLoading = false;
//   bool firstLunch = true;

//   String userLocation = 'Thane, Ambika nagar';
//   LatLng? latLng;

//   Future<void> fetchCurrentLocationPlace() async {
//     log('-------------- fetchCurrentLocationPlace CALLED ---------------------');

//     isLoading = true;
//     update();

//     // Check Location Permission
//     await Geolocator.checkPermission().then((value) async {
//       if (value != LocationPermission.always && value != LocationPermission.whileInUse) {
//         await Geolocator.requestPermission();
//       } else if (value == LocationPermission.denied || value == LocationPermission.deniedForever) {
//         await Geolocator.openAppSettings();
//       }
//     });

//     // To Turn On Device Location
//     await Geolocator.isLocationServiceEnabled().then((value) async {
//       if (!value) {
//         await Geolocator.openLocationSettings();
//       }
//     });

//     Position position = await Geolocator.getCurrentPosition();

//     latLng = LatLng(position.latitude, position.longitude);
//     updateHeaderWithLocation();

//     await getAddressFromLocation(latLng ?? const LatLng(19.198545796504945, 72.95579630029403));

//     isLoading = false;
//     update();
//   }

//   Future<void> getAddressFromLocation(LatLng latLong) async {
//     isLoading = true;
//     update();

//     await placemarkFromCoordinates(latLong.latitude, latLong.longitude).then((placeMark) {
//       if (placeMark.isNotEmpty) {
//         log('${placeMark.first.toJson()}', name: "Location");
//         userLocation = '${placeMark.first.street}, ${placeMark.first.subLocality}, ${placeMark.first.administrativeArea}, ${placeMark.first.country}';
//       }
//     });

//     isLoading = false;
//     update();
//   }

//   // ----- Search Locations -----
//   List<AutocompletePrediction> predictions = [];

//   searchPlaces(String query, CustomLatLng? latLng) async {
//     log('---------- searchPlaces Called() ----------');
//     isLoading = true;
//     update();

//     try {
//       final places = FlutterGooglePlacesSdk(AppConstants.googleMapAndroidKey);
//       final FindAutocompletePredictionsResponse result = await places.findAutocompletePredictions(
//         query,
//         origin: latLng?.toLatLng(),
//       );
//       log('${result.predictions}', name: 'Predictions');
//       predictions = result.predictions;
//     } catch (ex) {
//       log('$ex', name: 'SearchPlacesError()');
//     }

//     isLoading = false;
//     update();
//   }

//   Future<ResponseModel> fetchLatLongFromPlaceId(String placeID, AutocompletePrediction autoAddress) async {
//     log('fetchLatLongFromPlaceId CALLED');
//     ResponseModel responseModel;

//     try {
//       // Storing Top 5 Predictions...
//       await storeRecentPredictions(autoAddress: autoAddress);

//       Uri uri = Uri.parse("https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=${AppConstants.googleMapAndroidKey}&region=in");

//       final http.Response httpResponse = await http.get(uri);
//       if (httpResponse.statusCode == 200) {
//         final requiredResponse = jsonDecode(httpResponse.body);

//         latLng = LatLng(
//           requiredResponse['result']['geometry']['location']['lat'],
//           requiredResponse['result']['geometry']['location']['lng'],
//         );
//         userLocation = "${autoAddress.primaryText}, ${autoAddress.secondaryText}";

//         updateHeaderWithLocation();

//         responseModel = ResponseModel(true, "SUCCESS");
//       } else {
//         responseModel = ResponseModel(false, "UNSUCCESS");
//       }
//     } catch (e) {
//       responseModel = ResponseModel(false, "CATCH");
//       log('++++++++ ${e.toString()} ++++++++', name: 'ERROR AT fetchLatLongFromPlaceId()');
//     }

//     update();
//     return responseModel;
//   }

//   void updateHeaderWithLocation() {
//     log((latLng?.latitude ?? 19.198545796504945).toString(), name: 'Latitude');
//     log((latLng?.longitude ?? 72.95579630029403).toString(), name: 'Longitude');
//     Get.find<DioClient>().dio.options.headers = {
//       'Content-Type': 'application/json; charset=UTF-8',
//       'Authorization': 'Bearer ${Get.find<AuthRepo>().getUserToken()}',
//       'accept': 'application/json',
//       'lat': latLng?.latitude.toString() ?? 19.198545796504945.toString(),
//       'long': latLng?.longitude.toString() ?? 72.95579630029403.toString(),
//     };
//   }

//   // ------ Storing and Fetching Recent Search Locations ------
//   Future<void> storeRecentPredictions({required AutocompletePrediction autoAddress}) async {
//     final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

//     String? locations = sharedPreferences.getString(AppConstants.recentLocations);
//     log(locations.toString(), name: 'Locations');

//     List<AutocompletePrediction> recentLocations = [];
//     if (locations != null) {
//       recentLocations = (jsonDecode(locations) as List<dynamic>)
//           .map((loc) => AutocompletePrediction.fromJson(loc)).toList();
//     }

//     if(recentLocations.every((loc) => loc.placeId != autoAddress.placeId)) {
//       if (recentLocations.length > 5) recentLocations.removeLast();
//       recentLocations.insert(0, autoAddress);

//       sharedPreferences.setString(
//         AppConstants.recentLocations,
//         jsonEncode(recentLocations.map((loc) => loc.toJson()).toList()),
//       );
//     }
//   }

//   Future<void> fetchRecentPredictions() async {
//     final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

//     String? locations = sharedPreferences.getString(AppConstants.recentLocations);
//     log(locations.toString(), name: 'Locations');

//     List<AutocompletePrediction> recentLocations = [];
//     if (locations != null) {
//       recentLocations = (jsonDecode(locations) as List<dynamic>)
//           .map((loc) => AutocompletePrediction.fromJson(loc)).toList();

//       predictions = recentLocations;
//       update();
//     }
//   }
// }
