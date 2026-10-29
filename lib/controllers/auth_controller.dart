import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/models/user_model.dart';
import 'package:vlr/firebase/get_fcm_token.dart';
import 'package:vlr/services/appsflyer_service.dart';
import 'package:vlr/services/constants.dart';

import '../data/repositories/auth_repo.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;

  AuthController({required this.authRepo});

  bool isLoading = false;
  bool _acceptTerms = true;

  bool get acceptTerms => _acceptTerms;

  File? profileImage;

  updateImages(File? image) {
    profileImage = image;
    update();
  }

  bool isProfileLoading = false;
  bool updateProfileLoading = false;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController bloodGroupController = TextEditingController();
  String? gender;
  List<String> genderList = ["Male", "Female", "Other"];
  String? bloodGroup;
  List<String> bloodGroupList = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-"
  ];

  //* Address TextEditingControllers

  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  String? state;
  String? city;

  void setGender(String? val) {
    gender = val;
    update();
  }

  void setBloodGroup(String? val) {
    bloodGroup = val;
    bloodGroupController.text = val ?? "";
    update();
  }

  void updateFirstAndLastName(String first, String last) {
    fullNameController.text = "$first $last".trim();
    update();
  }

  void updateFullName(String full) {
    List<String> parts = full.trim().split(RegExp(r'\s+'));
    firstNameController.text = parts.isNotEmpty ? parts.first : "";
    lastNameController.text =
        parts.length > 1 ? parts.sublist(1).join(" ") : "";
    update();
  }

  void populateProfileControllers() {
    if (userModel == null) return;

    fullNameController.text = userModel?.name ?? "";
    firstNameController.text = userModel?.firstName ?? "";
    lastNameController.text = userModel?.lastName ?? "";

    if ((firstNameController.text.isEmpty && lastNameController.text.isEmpty) &&
        fullNameController.text.isNotEmpty) {
      List<String> parts = fullNameController.text.trim().split(RegExp(r'\s+'));
      firstNameController.text = parts.isNotEmpty ? parts.first : "";
      lastNameController.text =
          parts.length > 1 ? parts.sublist(1).join(" ") : "";
    } else if (fullNameController.text.isEmpty &&
        (firstNameController.text.isNotEmpty ||
            lastNameController.text.isNotEmpty)) {
      fullNameController.text =
          "${firstNameController.text} ${lastNameController.text}".trim();
    }

    emailController.text = userModel?.email ?? "";
    mobileNoController.text = userModel?.mobile ?? "";
    if (userModel?.dateOfBirth != null && userModel!.dateOfBirth!.isNotEmpty) {
      String rawDob = userModel!.dateOfBirth!.trim();
      if (rawDob.contains("T")) {
        rawDob = rawDob.split("T").first;
      }
      DateTime? parsed = DateTime.tryParse(rawDob);
      if (parsed != null) {
        dobController.text =
            "${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year.toString().padLeft(4, '0')}";
      } else {
        dobController.text = rawDob;
      }
    } else {
      dobController.text = "";
    }

    if (userModel?.gender != null && userModel!.gender!.isNotEmpty) {
      String g = userModel!.gender!.trim();
      int index = genderList
          .indexWhere((element) => element.toLowerCase() == g.toLowerCase());
      if (index != -1) {
        gender = genderList[index];
      } else {
        gender = g;
      }
    } else {
      gender = null;
    }

    if (userModel?.bloodGroup != null && userModel!.bloodGroup!.isNotEmpty) {
      String bg = userModel!.bloodGroup!.trim().toUpperCase();
      int index =
          bloodGroupList.indexWhere((element) => element.toUpperCase() == bg);
      if (index != -1) {
        bloodGroup = bloodGroupList[index];
      } else {
        bloodGroup = bg;
      }
      bloodGroupController.text = bloodGroup ?? "";
    } else {
      bloodGroup = null;
      bloodGroupController.text = "";
    }

    address1Controller.text = userModel?.address ?? "";
    cityController.text = userModel?.city ?? "";
    city = userModel?.city;
    stateController.text = userModel?.state ?? "";
    state = userModel?.state;
    pinCodeController.text = userModel?.pincode ?? "";
    countryController.text =
        (userModel?.country != null && userModel!.country!.isNotEmpty)
            ? userModel!.country!
            : "India";

    update();
  }

  //* Register & Login TextEditingControllers

  TextEditingController mobileOtpCodeController = TextEditingController();
  TextEditingController emailOtpCodeController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  String? lastUsedReferralCode;

  Future<ResponseModel> registerUser() async {
    log('----------- registerUser Called ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      String firstName = firstNameController.text.trim();
      String lastName = lastNameController.text.trim();

      if (firstName.isEmpty && fullNameController.text.trim().isNotEmpty) {
        String fullName = fullNameController.text.trim();
        List<String> nameParts = fullName.split(RegExp(r'\s+'));
        firstName = nameParts.isNotEmpty ? nameParts.first : '';
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }

      Map<String, dynamic> data = {
        "first_name": firstName,
        "last_name": lastName,
        "email": emailController.text.trim(),
        "phone": mobileNoController.text.trim(),
        "password": passwordController.text.trim(),
        "password_confirmation": confirmPasswordController.text.trim(),
      };

      Response response = await authRepo.postUserRegister(
        data: FormData(data),
      );

      log("Raw Response: ${response.body}");

      final body = response.body;
      if (response.isOk &&
          body != null &&
          (body['status'] == true ||
              body['status'] == "success" ||
              body['status'] == 1 ||
              body['status'] == "true" ||
              (body['errors'] == null &&
                  (response.statusCode == 200 ||
                      response.statusCode == 201)))) {
        firstNameController.clear();
        lastNameController.clear();
        fullNameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        responseModel = ResponseModel(
            true, body['message'] ?? "User registered successfully.");
      } else {
        String errorMessage =
            body?['message'] ?? "Error while registering user";

        if (body?['errors'] != null) {
          final errors = body['errors'];
          if (errors is Map) {
            for (var key in errors.keys) {
              if (errors[key] != null && errors[key].isNotEmpty) {
                if (errors[key] is List) {
                  errorMessage = errors[key][0];
                } else {
                  errorMessage = errors[key].toString();
                }
                break;
              }
            }
          }
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT registerUser(): $e');
      responseModel = ResponseModel(false, "Error while registering user: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyMobileAndEmail({
    required String mobileOtp,
    required String emailOtp,
  }) async {
    log('----------- verifyMobileAndEmail Called ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      String referralCode = referralCodeController.text.trim();
      if (referralCode.isEmpty) {
        referralCode = lastUsedReferralCode ?? '';
      }
      if (referralCode.isEmpty) {
        referralCode = (await AppsFlyerService.getSavedReferralCode()) ?? '';
      }
      if (referralCode.isNotEmpty) {
        lastUsedReferralCode = referralCode;
        AppsFlyerService.saveReferralToPrefs(referralCode);
      }

      String deviceId = await authRepo.getDeviceId();

      Map<String, dynamic> data = {
        "email": emailController.text.trim(),
        "mobile": mobileNoController.text.trim(),
        "email_otp": emailOtpCodeController.text.trim(),
        "mobile_otp": mobileOtpCodeController.text.trim(),
        "device_id": deviceId,
        if (referralCode.isNotEmpty) "referral_code": referralCode,
      };

      Response response = await authRepo.postVerifyMobileAndEmail(
        data: FormData(data),
      );

      log("Raw Response: ${response.body}");

      if (response.body['status'] == "success") {
        final responseData = response.body['data'];

        if (responseData != null && responseData['token'] != null) {
          await authRepo.setUserToken(responseData['token']);
          log("Saved token: ${responseData['token']}");
        }

        fullNameController.clear();
        mobileNoController.clear();
        emailController.clear();
        mobileOtpCodeController.clear();
        emailOtpCodeController.clear();
        referralCodeController.clear();

        responseModel = ResponseModel(
            true, response.body['message'] ?? "success verifyMobileAndEmail ");
      } else {
        String errorMessage =
            response.body['message'] ?? "Error while registering user";

        if (response.body['errors'] != null &&
            response.body['errors']['mobile'] != null) {
          errorMessage = response.body['errors']['mobile'][0];
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT verifyMobileAndEmail(): $e');
      responseModel =
          ResponseModel(false, "Error while verifyMobileAndEmail  $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> resendVerifyMobileAndEmail() async {
    log('----------- resendVerifyMobileAndEmail Called ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Map<String, dynamic> data = {
        "email": emailController.text.trim(),
        "mobile": mobileNoController.text.trim(),
      };

      Response response = await authRepo.postResendVerifyMobileAndEmail(
        data: FormData(data),
      );

      // log("Raw Response: ${response.body}");

      if (response.body['status'] == "success") {
        final responseData = response.body['data'];

        if (responseData != null && responseData['token'] != null) {
          await authRepo.setUserToken(responseData['token']);
          log("Saved token: ${responseData['token']}");
        }

        mobileOtpCodeController.clear();
        emailOtpCodeController.clear();

        responseModel = ResponseModel(true,
            response.body['message'] ?? "success resendVerifyMobileAndEmail ");
      } else {
        String errorMessage = response.body['message'] ??
            "Error while resendVerifyMobileAndEmail";

        if (response.body['errors'] != null &&
            response.body['errors']['mobile'] != null) {
          errorMessage = response.body['errors']['mobile'][0];
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT resendVerifyMobileAndEmail(): $e');
      responseModel =
          ResponseModel(false, "Error while resendVerifyMobileAndEmail  $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> loginUser({required bool isSMS}) async {
    log('----------- postLogin Called ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Map<String, dynamic> data = {
        "mobile": mobileNoController.text.trim(),
        // "channel": "whatsapp",
        "channel": isSMS ? "sms" : "whatsapp",
      };

      Response response = await authRepo.postLogin(
        data: FormData(data),
      );

      log("Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body is Map<String, dynamic>) {
        final body = response.body;

        if (body['status'] == "success") {
          responseModel = ResponseModel(
            true,
            body['message'] ?? "OTP sent successfully",
          );

          fullNameController.clear();
        } else {
          responseModel = ResponseModel(
            false,
            body['message'] ?? "Login failed",
          );
        }
      } else {
        String errorMessage =
            response.body['message'] ?? "Error while registering user";

        if (response.body['errors'] != null &&
            response.body['errors']['mobile'] != null) {
          errorMessage = response.body['errors']['mobile'][0];
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT loginUser(): $e');

      responseModel = ResponseModel(
        false,
        "Error while loginUser: $e",
      );
    }

    isLoading = false;
    update();

    return responseModel;
  }

  Future<ResponseModel> loginWithEmailPassword({
    String? email,
    String? password,
  }) async {
    debugPrint('----------- loginWithEmailPassword Called ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      String finalEmail = (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : loginEmailController.text.trim();
      if (finalEmail.isEmpty) {
        finalEmail = emailController.text.trim();
      }

      String finalPassword = (password != null && password.trim().isNotEmpty)
          ? password.trim()
          : loginPasswordController.text.trim();
      if (finalPassword.isEmpty) {
        finalPassword = passwordController.text.trim();
      }

      debugPrint(
          "===> loginWithEmailPassword: email='$finalEmail', password length=${finalPassword.length}");

      Response response = await authRepo.postEmailPasswordLogin(
        email: finalEmail,
        password: finalPassword,
      );

      debugPrint("===> Status Code: ${response.statusCode}");
      debugPrint(
          "===> Raw Response (loginWithEmailPassword): ${response.body}");

      dynamic body = response.body;
      if (body is String) {
        try {
          body = jsonDecode(body);
        } catch (_) {}
      }

      final bool isSuccess =
          (response.statusCode == 200 || response.statusCode == 201) &&
              body != null &&
              body is Map &&
              (body['status'] == true ||
                  body['status'] == "success" ||
                  body['status'] == 1 ||
                  body['status'] == "true" ||
                  body['data'] != null);

      if (isSuccess) {
        final responseData = body is Map ? body['data'] : null;

        String? token;
        if (responseData != null && responseData is Map) {
          token = responseData['token']?.toString() ??
              responseData['access_token']?.toString();
        } else if (responseData != null &&
            responseData is String &&
            responseData.isNotEmpty) {
          token = responseData;
        }
        token ??= (body is Map
            ? (body['token']?.toString() ?? body['access_token']?.toString())
            : null);

        if (token != null && token.isNotEmpty) {
          await authRepo.setUserToken(token);
          debugPrint("Saved token: $token");
          AppsFlyerService.markAppReady(isLoggedIn: true);
        }

        // Set userModel directly from response data
        if (responseData != null &&
            responseData is Map &&
            responseData['user'] != null) {
          try {
            final userJson = Map<String, dynamic>.from(responseData['user']);
            userModel = UserModel.fromJson(userJson);
            populateProfileControllers();
            final uId = userModel?.id ?? userJson['id']?.toString();
            if (uId != null && uId.isNotEmpty) {
              await authRepo.sharedPreferences
                  .setString(AppConstants.userId, uId);
            }
            debugPrint("User model populated successfully: ${userModel?.name}");
          } catch (e) {
            debugPrint(
                "Error parsing userModel directly from login response: $e");
          }
        }

        // Background profile fetch and FCM update without blocking login success
        try {
          fetchProfile();
        } catch (_) {}
        try {
          updateFcmToken();
        } catch (_) {}

        loginEmailController.clear();
        loginPasswordController.clear();

        responseModel = ResponseModel(
          true,
          (body is Map && body['message'] != null)
              ? body['message'].toString()
              : "Login successful.",
        );
      } else {
        String errorMessage = "Login failed. Please check your credentials.";

        if (body is Map) {
          if (body['message'] != null) {
            errorMessage = body['message'].toString();
          } else if (body['error'] != null) {
            errorMessage = body['error'].toString();
          }

          if (body['errors'] != null) {
            final errors = body['errors'];
            if (errors is Map) {
              for (var key in errors.keys) {
                if (errors[key] != null && errors[key].isNotEmpty) {
                  if (errors[key] is List) {
                    errorMessage = errors[key][0].toString();
                  } else {
                    errorMessage = errors[key].toString();
                  }
                  break;
                }
              }
            } else if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          }
        } else if (response.statusText != null &&
            response.statusText!.isNotEmpty) {
          errorMessage = response.statusText!;
        }

        debugPrint(
            "===> LOGIN FAILED: $errorMessage (status: ${response.statusCode})");
        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e, st) {
      debugPrint('ERROR AT loginWithEmailPassword(): $e\n$st');
      responseModel = ResponseModel(false, "Login error: $e");
    } finally {
      isLoading = false;
      update();
    }

    return responseModel;
  }

  Future<ResponseModel> loginOtpVerify() async {
    log('----------- loginOtpVerify Called ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final data = {
        "mobile": mobileNoController.text.trim(),
        "otp": mobileOtpCodeController.text.trim(),
      };

      final Response response = await authRepo.postLoginOtpVerify(
        data: FormData(data),
      );

      log("Raw Response: ${response.body}");

      if (response.body['status'] == "success") {
        final responseData = response.body['data'];

        if (responseData != null && responseData['token'] != null) {
          await authRepo.setUserToken(responseData['token']);
          log("Saved token: ${responseData['token']}");
        }

        responseModel = ResponseModel(
          true,
          response.body['message'] ?? "Logged in successfully",
        );
      } else {
        String errorMessage =
            response.body['message'] ?? "Error while registering user";

        if (response.body['errors'] != null &&
            response.body['errors']['mobile'] != null) {
          errorMessage = response.body['errors']['mobile'][0];
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT loginOtpVerify(): $e');
      responseModel = ResponseModel(false, "Error while login otp verify $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> postLoginResendOtpVerify({required bool isSMS}) async {
    log('----------- postLoginResendOtpVerify Called ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final data = {
        "mobile": mobileNoController.text.trim(),
        "channel": isSMS ? "sms" : "whatsapp",
      };

      final Response response = await authRepo.postLoginResendOtpVerify(
        data: FormData(data),
      );

      log("Raw Response: ${response.body}");

      if (response.body['status'] == "success") {
        final responseData = response.body['data'];

        if (responseData != null && responseData['token'] != null) {
          await authRepo.setUserToken(responseData['token']);
          log("Saved token: ${responseData['token']}");
        }

        responseModel = ResponseModel(
          true,
          response.body['message'] ?? "Resend opt in postLoginResendOtpVerify",
        );
      } else {
        String errorMessage = response.body['message'] ??
            "Error while postLoginResendOtpVerify user";

        if (response.body['errors'] != null &&
            response.body['errors']['mobile'] != null) {
          errorMessage = response.body['errors']['mobile'][0];
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT postLoginResendOtpVerify(): $e');
      responseModel = ResponseModel(
          false, "Error while postLoginResendOtpVerify otp verify $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  UserModel? userModel;

  void clearProfileControllers() {
    fullNameController.clear();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    mobileNoController.clear();
    gender = null;
    dobController.clear();
    address1Controller.clear();
    cityController.clear();
    stateController.clear();
    pinCodeController.clear();
    countryController.clear();
  }

  void continueAsGuest() {
    authRepo.clearSharedData();
    userModel = null;
    clearProfileControllers();
    isProfileLoading = false;
    isLoading = false;
    AppsFlyerService.markAppReady(isLoggedIn: false);
    update();
  }

  Future<ResponseModel> fetchProfile() async {
    log('----------- fetchProfile Called ----------');

    if (!isLoggedIn()) {
      userModel = null;
      isProfileLoading = false;
      update();
      return ResponseModel(false, "User not logged in");
    }

    ResponseModel responseModel;
    isProfileLoading = true;
    update();

    try {
      Response response = await authRepo.fetchProfile();
      log("Fetch Profile Response: ${response.body}");

      final body = response.body;
      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        final data = body['data'];
        final userData =
            (data != null && data is Map && data.containsKey('user'))
                ? data['user']
                : data;

        if (userData != null) {
          userModel = UserModel.fromJson(userData);
          populateProfileControllers();
          log("Profile fetched successfully: ${userModel?.name}");
        }

        responseModel = ResponseModel(
            true, body['message'] ?? "User profile retrieved successfully.");
      } else {
        String errorMessage =
            body?['message'] ?? "Error while fetching profile";

        if (body?['errors'] != null) {
          final errors = body['errors'];
          if (errors is Map) {
            for (var key in errors.keys) {
              if (errors[key] != null && errors[key].isNotEmpty) {
                if (errors[key] is List) {
                  errorMessage = errors[key][0];
                } else {
                  errorMessage = errors[key].toString();
                }
                break;
              }
            }
          }
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT fetchProfile(): $e');
      responseModel = ResponseModel(false, "Error while fetching profile: $e");
    }

    isProfileLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> logout() async {
    log('----------- logout Called ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await authRepo.logout(data: FormData({}));

      if (response.body != null &&
          (response.body['status'] == "success" ||
              response.body['status'] == true)) {
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success logout user ");
      } else {
        responseModel = ResponseModel(true, "Logged out successfully");
      }
    } catch (e) {
      log('ERROR AT logout(): $e');
      responseModel = ResponseModel(true, "Logged out");
    } finally {
      continueAsGuest();
      isLoading = false;
      update();
    }

    return responseModel;
  }

  Future<ResponseModel> deleteAccount() async {
    log('----------- deleteAccount Called ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await authRepo.deleteAccount();

      if (response.body['status'] == "success") {
        authRepo.clearSharedData();
        responseModel = ResponseModel(
            true, response.body['message'] ?? "Account deleted successfully");
      } else {
        responseModel = ResponseModel(
            false, response.body['message'] ?? "Error while deleting account");
      }
    } catch (e) {
      log('ERROR AT deleteAccount(): $e');
      responseModel = ResponseModel(false, "Error while deleting account $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> updateProfile() async {
    log('----------- updateProfile Called ----------');

    ResponseModel responseModel;
    updateProfileLoading = true;
    isLoading = true;
    update();

    try {
      String fullName = fullNameController.text.trim();
      String firstName = firstNameController.text.trim();
      String lastName = lastNameController.text.trim();

      if (firstName.isEmpty && fullName.isNotEmpty) {
        List<String> nameParts = fullName.split(RegExp(r'\s+'));
        firstName = nameParts.isNotEmpty ? nameParts.first : '';
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      } else if (fullName.isEmpty &&
          (firstName.isNotEmpty || lastName.isNotEmpty)) {
        fullName = "$firstName $lastName".trim();
      }

      final Map<String, dynamic> data = {
        if (fullName.isNotEmpty) "name": fullName,
        if (firstName.isNotEmpty) "first_name": firstName,
        if (lastName.isNotEmpty) "last_name": lastName,
        if (emailController.text.trim().isNotEmpty)
          "email": emailController.text.trim(),
        if (mobileNoController.text.trim().isNotEmpty)
          "phone": mobileNoController.text.trim(),
        if (gender != null && gender!.isNotEmpty) "gender": gender,
        if (dobController.text.trim().isNotEmpty)
          "date_of_birth": dobController.text.trim(),
        if (bloodGroup != null && bloodGroup!.isNotEmpty)
          "blood_group": bloodGroup
        else if (bloodGroupController.text.trim().isNotEmpty)
          "blood_group": bloodGroupController.text.trim(),
        if (address1Controller.text.trim().isNotEmpty)
          "address": address1Controller.text.trim(),
        if (cityController.text.trim().isNotEmpty)
          "city": cityController.text.trim()
        else if (city != null && city!.isNotEmpty)
          "city": city,
        if (stateController.text.trim().isNotEmpty)
          "state": stateController.text.trim()
        else if (state != null && state!.isNotEmpty)
          "state": state,
        if (pinCodeController.text.trim().isNotEmpty)
          "pincode": pinCodeController.text.trim(),
        if (countryController.text.trim().isNotEmpty)
          "country": countryController.text.trim(),
      };

      if (profileImage != null) {
        data['avatar'] = MultipartFile(profileImage!,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      log("Update Profile Request Data: $data");

      Response response =
          await authRepo.postProfileUpdate(data: FormData(data));

      log("Update Profile Response: ${response.body}");

      final body = response.body;
      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        profileImage = null; // Clear local image after success
        final responseData = body['data'];
        final userData = (responseData != null &&
                responseData is Map &&
                responseData.containsKey('user'))
            ? responseData['user']
            : responseData;

        if (userData != null) {
          userModel = UserModel.fromJson(userData);
          populateProfileControllers();
        } else {
          await fetchProfile();
        }

        responseModel = ResponseModel(
            true, body['message'] ?? "Profile updated successfully.");
      } else {
        String errorMessage =
            body?['message'] ?? "Error while updating profile";

        if (body?['errors'] != null) {
          final errors = body['errors'];
          if (errors is Map) {
            for (var key in errors.keys) {
              if (errors[key] != null && errors[key].isNotEmpty) {
                if (errors[key] is List) {
                  errorMessage = errors[key][0];
                } else {
                  errorMessage = errors[key].toString();
                }
                break;
              }
            }
          }
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT updateProfile(): $e');
      responseModel = ResponseModel(false, "Error while updating profile: $e");
    }

    updateProfileLoading = false;
    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> updateFcmToken() async {
    log('----------- updateFcmToken Called ----------');

    ResponseModel responseModel;

    try {
      String token = await NotificationServices().getDeviceToken();
      if (token.isNotEmpty) {
        await saveFMCToken(token);
      } else {
        token = authRepo.getFCMToken();
      }

      final data = {
        "fcm_token": token,
      };
      Response response = await authRepo.updateFcmToken(data: data);

      if (response.body['status'] == "success") {
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success updateFcmToken user ");
      } else {
        responseModel = ResponseModel(false,
            response.body['message'] ?? "Error while updateFcmToken user ");
      }
    } catch (e) {
      log('ERROR AT updateFcmToken(): $e');
      responseModel =
          ResponseModel(false, "Error while updateFcmToken user  $e");
    }

    return responseModel;
  }

  Future<void> saveFMCToken(String fcmToken) async {
    final saveFCMToken = await authRepo.saveFCMToken(fcmToken: fcmToken);
    log('loginUser: saved FCM token: $saveFCMToken');
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  bool clearSharedData() {
    return authRepo.clearSharedData();
  }

  String getUserToken() {
    return authRepo.getUserToken();
  }
}
