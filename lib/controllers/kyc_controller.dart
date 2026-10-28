import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/data/models/kyc_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/kyc_repo.dart';

class KycController extends GetxController implements GetxService {
  final KycRepo kycRepo;

  KycController({required this.kycRepo});

  bool isLoading = false;
  KycProfileModel? kycProfile;

  Future<void> getKycProfile() async {
    isLoading = true;
    update();
    try {
      Response response = await kycRepo.getKycProfile();
      if (response.body != null && response.body['status'] == "success") {
        kycProfile = KycProfileModel.fromJson(response.body['data']);
      }
    } catch (e) {
      log("Error fetching KYC profile: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  //* Identity Details TextEditingControllers
  String? kycType;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String? gender;
  List<String> genderList = ["Male", "Female", "Other"];
  TextEditingController penNoController = TextEditingController();
  TextEditingController aadhaarNoController = TextEditingController();

  //* Address TextEditingControllers
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  String? state;
  String? city;
  TextEditingController pinCodeController = TextEditingController();

  //* KYC Documents
  File? livePhoto;
  File? aadhaarFrontImage;
  File? aadhaarBackImage;
  File? panFrontImage;
  File? panBackImage;
  File? bankStatement;
  File? passportFrontImage;
  File? passportBackImage;
  File? drivingLicenseFrontImage;
  File? drivingLicenseBackImage;

  void setFile(String type, File file) {
    switch (type) {
      case 'live_photo':
        livePhoto = file;
        break;
      case 'aadhaar_front':
        aadhaarFrontImage = file;
        break;
      case 'aadhaar_back':
        aadhaarBackImage = file;
        break;
      case 'pan_front':
        panFrontImage = file;
        break;
      case 'pan_back':
        panBackImage = file;
        break;
      case 'bank_statement':
        bankStatement = file;
        break;
      case 'passport_front':
        passportFrontImage = file;
        break;
      case 'passport_back':
        passportBackImage = file;
        break;
      case 'driving_license_front':
        drivingLicenseFrontImage = file;
        break;
      case 'driving_license_back':
        drivingLicenseBackImage = file;
        break;
    }
    update();
  }

  Future<ResponseModel> submitKyc() async {
    isLoading = true;
    update();

    try {
      Map<String, dynamic> data = {
        'full_name': fullNameController.text,
        'dob': dobController.text,
        'gender': gender ?? "",
        'pan_no': penNoController.text,
        'aadhaar_no': aadhaarNoController.text,
        'address_line_1': address1Controller.text,
        'address_line_2': address2Controller.text,
        'state': state ?? "",
        'city': city ?? "",
        'pincode': pinCodeController.text,
      };

      if (livePhoto != null) {
        data['live_photo_file'] = MultipartFile(livePhoto!, filename: 'live_photo.jpg');
      }
      if (aadhaarFrontImage != null) {
        data['aadhaar_front'] = MultipartFile(aadhaarFrontImage!, filename: 'aadhaar_front.jpg');
      }
      if (aadhaarBackImage != null) {
        data['aadhaar_back'] = MultipartFile(aadhaarBackImage!, filename: 'aadhaar_back.jpg');
      }
      if (panFrontImage != null) {
        data['pan_front'] = MultipartFile(panFrontImage!, filename: 'pan_front.jpg');
      }
      if (panBackImage != null) {
        data['pan_back'] = MultipartFile(panBackImage!, filename: 'pan_back.jpg');
      }
      if (bankStatement != null) {
        data['bank_statement'] = MultipartFile(bankStatement!, filename: 'bank_statement.pdf');
      }
      if (passportFrontImage != null) {
        data['passport_front'] = MultipartFile(passportFrontImage!, filename: 'passport_front.jpg');
      }
      if (passportBackImage != null) {
        data['passport_back'] = MultipartFile(passportBackImage!, filename: 'passport_back.jpg');
      }
      if (drivingLicenseFrontImage != null) {
        data['driving_license_front'] = MultipartFile(drivingLicenseFrontImage!, filename: 'dl_front.jpg');
      }
      if (drivingLicenseBackImage != null) {
        data['driving_license_back'] = MultipartFile(drivingLicenseBackImage!, filename: 'dl_back.jpg');
      }

      Response response = await kycRepo.submitKyc(FormData(data));

      if (response.body != null && response.body['status'] == 'success') {
        return ResponseModel(true, response.body['message'] ?? "KYC submitted successfully");
      } else {
        return ResponseModel(false, response.body?['message'] ?? "Failed to submit KYC");
      }
    } catch (e) {
      log("Error submitting KYC: $e");
      return ResponseModel(false, "An error occurred during submission");
    } finally {
      isLoading = false;
      update();
    }
  }

  //* Personal details for Auto pay setup
  TextEditingController customerNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  //* Mandate details
  TextEditingController upiIdController = TextEditingController();
  TextEditingController mandateAmountController = TextEditingController();
  TextEditingController maxAmountController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  String? frequent;

  List<String> frequentList = [
    "Daily",
    "Weekly",
    "Monthly",
    "Quarterly",
    "Half Yearly",
    "Yearly",
  ];

  String? purpose;

  List<String> purposeList = [
    "GYM Subscription",
    "Room Rental",
  ];

  //*------ GYM Review --------------
  double currentRating = 0.0;
  TextEditingController reviewController = TextEditingController();
}
