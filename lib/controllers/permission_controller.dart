import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../views/base/dialogs/request_permission_dialog.dart';

class PermissionController extends GetxController implements GetxService {
  Future<bool> getPermission(
      Permission permission, BuildContext context) async {
    PermissionStatus status = await permission.status;
    if (!status.isGranted && !status.isLimited) {
      status = await permission.request();
    }
    return status.isGranted || status.isLimited;
  }

  // -------------------- LOCATION --------------------

  double? _latitude;
  double? _longitude;
  String? _address;
  bool _locationFetched = false;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;
  bool get locationFetched => _locationFetched;

  Future<bool> requestLocationPermissionAndFetch(BuildContext context) async {
    try {
      log("========== LOCATION START ==========");

      if (_locationFetched && _latitude != null && _longitude != null) {
        log("Location already fetched: $_latitude, $_longitude");
        return true;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text("Location Disabled"),
              content: const Text(
                "Please enable GPS/Location Services.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openLocationSettings();
                  },
                  child: const Text("Settings"),
                ),
              ],
            ),
          );
        }
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Location permission denied"),
            ),
          );
        }
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Permission Required"),
              content: const Text(
                "Location permission is permanently denied. Please enable it from Settings.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  child: const Text("Open Settings"),
                ),
              ],
            ),
          );
        }
        return false;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Reverse geocoding using Google Maps API - use formatted_address for reliable city display
      try {
        final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$_latitude,$_longitude&key=AIzaSyDODsIBKvD4Ft0M58AYjLrdsED5xZDg0A0';
        final response = await http.get(Uri.parse(url));

        log("Geocoding API Status: ${response.statusCode}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          log("Geocoding API Response Status: ${data['status']}");

          if (data['status'] == 'OK') {
            final results = data['results'] as List;
            if (results.isNotEmpty) {
              // Skip results that are just "plus_code" to get a real landmark/address
              String formattedAddress = "";
              for (var result in results) {
                List types = result['types'] ?? [];
                if (!types.contains('plus_code')) {
                  formattedAddress = result['formatted_address'] ?? "";
                  break;
                }
              }

              // Fallback to first result if somehow all are plus_codes
              if (formattedAddress.isEmpty) {
                formattedAddress = results[0]['formatted_address'] ?? "";
              }

              log("Full Formatted Address: $formattedAddress");

              // Strip any Plus Code string if it still appears at the beginning (e.g. "V323+RX8, Lolai, ...")
              formattedAddress = formattedAddress.replaceAll(RegExp(r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,3}[,\s]*'), '');

              // Remove country name (India) and postal code from the end
              formattedAddress = formattedAddress.replaceAll(RegExp(r',?\s*India\s*$'), '');
              formattedAddress = formattedAddress.replaceAll(RegExp(r'\s*\d{6}\s*'), ''); // Remove 6-digit Indian postal codes
              formattedAddress = formattedAddress.replaceAll(RegExp(r',\s*$'), ''); // Remove trailing comma

              if (formattedAddress.isNotEmpty) {
                _address = formattedAddress.trim();
              } else {
                _address = "Location Found";
              }

              print("Final Address: $_address");
            } else {
              _address = await _fallbackGeocoding(_latitude!, _longitude!);
            }
          } else {
            log("Geocoding API Error: ${data['status']} - ${data['error_message'] ?? 'No error message'}");
            _address = await _fallbackGeocoding(_latitude!, _longitude!);
          }
        } else {
          _address = await _fallbackGeocoding(_latitude!, _longitude!);
        }
      } catch (e) {
        log("Geocoding Error: $e");
        _address = await _fallbackGeocoding(_latitude!, _longitude!);
      }

      _locationFetched = true;

      print("Latitude : $_latitude");
      print("Longitude: $_longitude");
      print("Address: $_address");

      update();
      return true;
    } catch (e, st) {
      log("Location Error: $e");
      log(st.toString());
      return false;
    }
  }

  void clearLocation() {
    _latitude = null;
    _longitude = null;
    _address = null;
    _locationFetched = false;
    update();
  }

  Future<String> _fallbackGeocoding(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String state = place.administrativeArea ?? "";
        String city = place.locality ?? "";
        if (city.isEmpty) city = place.subAdministrativeArea ?? "";
        String locality = place.subLocality ?? place.thoroughfare ?? "";

        List<String> parts = [];
        if (locality.isNotEmpty) parts.add(locality);
        if (city.isNotEmpty) parts.add(city);
        if (state.isNotEmpty) parts.add(state);

        if (parts.isNotEmpty) {
          final fallbackAddress = parts.join(", ");
          print("Fallback Address: $fallbackAddress");
          return fallbackAddress;
        }
        final fallbackAddress = place.name ?? place.street ?? "Location Found";
        print("Fallback Address: $fallbackAddress");
        return fallbackAddress;
      }
    } catch(e) {
       log("Fallback geocoding error: $e");
    }
    return "Location Found";
  }
}
