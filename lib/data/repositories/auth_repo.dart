import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/constants.dart';
import '../../services/device_id_service.dart';
import '../api/api_client.dart';

class AuthRepo {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;
  AuthRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> postUserRegister({required dynamic data}) async =>
      await apiClient.postData(
        AppConstants.registrationUri,
        "postUserRegister",
        data,
      );

  Future<Response> postVerifyMobileAndEmail({required FormData data}) async =>
      await apiClient.postData(
        AppConstants.verifyMobileAndEmailOtp,
        "postVerifyMobileAndEmail",
        data,
      );

  Future<Response> postResendVerifyMobileAndEmail(
          {required FormData data}) async =>
      await apiClient.postData(
        AppConstants.resendVerifyMobileAndEmailOtp,
        "postResendVerifyMobileAndEmail",
        data,
      );

  Future<Response> postLogin({required FormData data}) async =>
      await apiClient.postData(
        AppConstants.loginUri,
        "postLogin",
        data,
      );

  Future<Response> postEmailPasswordLogin({
    required String email,
    required String password,
  }) async {
    final String cleanLogin = email.trim();
    final String cleanPassword = password.trim();

    final Map<String, dynamic> bodyMap = {
      "login": cleanLogin,
      "password": cleanPassword,
    };

    try {
      final String fullUrl =
          '${AppConstants.baseUrl}${AppConstants.emailPasswordLoginUri}';
      debugPrint("===> Calling email login at: $fullUrl with login: $cleanLogin");

      http.Response httpResponse = await http.post(
        Uri.parse(fullUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyMap),
      );

      // Handle redirect if any
      if ((httpResponse.statusCode == 301 ||
              httpResponse.statusCode == 302 ||
              httpResponse.statusCode == 307 ||
              httpResponse.statusCode == 308) &&
          httpResponse.headers['location'] != null) {
        final redirectUrl = httpResponse.headers['location']!;
        debugPrint("===> Following redirect to: $redirectUrl");
        httpResponse = await http.post(
          Uri.parse(redirectUrl),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bodyMap),
        );
      }

      debugPrint("===> postEmailPasswordLogin HTTP Status: ${httpResponse.statusCode}");
      debugPrint("===> postEmailPasswordLogin HTTP Body: ${httpResponse.body}");

      dynamic responseBody;
      try {
        responseBody = jsonDecode(httpResponse.body);
      } catch (_) {
        responseBody = httpResponse.body;
      }

      return Response(
        statusCode: httpResponse.statusCode,
        body: responseBody,
        statusText: httpResponse.reasonPhrase,
      );
    } catch (e, st) {
      debugPrint("===> postEmailPasswordLogin HTTP Exception: $e\n$st, falling back to ApiClient");
      return await apiClient.postData(
        AppConstants.emailPasswordLoginUri,
        "postEmailPasswordLogin",
        bodyMap,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
    }
  }

  Future<Response> postLoginOtpVerify({required FormData data}) async =>
      await apiClient.postData(
        AppConstants.loginOtpVerify,
        "postLoginOtpVerify",
        data,
      );

  Future<Response> postLoginResendOtpVerify({required FormData data}) async =>
      await apiClient.postData(
        AppConstants.loginResendOtpVerify,
        "postLoginResendOtpVerify",
        data,
      );

  Future<Response> fetchProfile() async => await apiClient.getData(
        AppConstants.getProfileUri,
        "fetchProfile",
      );

  Future<Response> logout({required FormData data}) async =>
      await apiClient.postData(
        AppConstants.postLogout,
        "logout",
        data,
      );

  Future<Response> updateProfile({required FormData data}) async =>
      await apiClient.putData(
        AppConstants.putUpdateProfile,
        "updateProfile",
        data,
      );

  Future<Response> postProfileUpdate({required dynamic data}) async =>
      await apiClient.postData(
        AppConstants.putUpdateProfile,
        "postProfileUpdate",
        data,
      );

  Future<Response> updateFcmToken({required dynamic data}) async =>
      await apiClient.putData(
        AppConstants.putUpdateFcmToken,
        "updateFcmToken",
        data,
      );

  Future<Response> deleteAccount() async => await apiClient.deleteData(
        AppConstants.deleteAccountUri,
        "deleteAccount",
      );

  // Future<Response> verifyOtp({required String phone, required String otp}) async => await apiClient.postData(
  //       AppConstants.verifyOtp,
  //       {
  //         "phone": phone,
  //         "otp": otp,
  //       },
  //     );

  Future<bool> saveFCMToken({
    required String fcmToken,
  }) async {
    try {
      return await sharedPreferences.setString(AppConstants.fcmToken, fcmToken);
    } catch (e, st) {
      log('saveFCMToken error: $e\n$st');
      return false;
    }
  }

  String getFCMToken() {
    return sharedPreferences.getString(AppConstants.fcmToken) ?? "";
  }

  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  Future<void> setUserToken(String token) async {
    apiClient.updateHeader(token);
    await sharedPreferences.setString(AppConstants.token, token);
    await sharedPreferences.setString('token', token);
  }

  String getUserId() {
    return sharedPreferences.getString(AppConstants.userId) ?? "";
  }

  bool isLoggedIn() {
    final token = sharedPreferences.getString(AppConstants.token);
    return token != null && token.trim().isNotEmpty;
  }

  bool clearSharedData() {
    final devId = sharedPreferences.getString('device_id');
    sharedPreferences.clear();
    if (devId != null && devId.isNotEmpty) {
      sharedPreferences.setString('device_id', devId);
    }
    sharedPreferences.remove(AppConstants.token);
    sharedPreferences.remove(AppConstants.userId);
    sharedPreferences.remove(AppConstants.fcmToken);
    sharedPreferences.remove(AppConstants.recentOrders);
    sharedPreferences.remove(AppConstants.isUser);
    sharedPreferences.remove(AppConstants.razorpayKey);
    apiClient.token = '';
    apiClient.updateHeader('');
    return true;
  }

  Future<String> getDeviceId() async {
    return await DeviceIdService.getDeviceId();
  }
}
