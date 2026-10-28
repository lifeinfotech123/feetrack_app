import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/data/models/common/row_auto_pay_setup_success_model.dart';
import 'package:vlr/data/models/category_model/banner_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/common_repo.dart';

enum SelectTypeService { gym, room, pg, school }

class CommonController extends GetxController implements GetxService {
  final CommonRepo commonRepo;

  CommonController({required this.commonRepo});

  bool isLoading = false;
  SelectTypeService currentSelectService = SelectTypeService.gym;

  void updateSelectedServiceType({required SelectTypeService value}) {
    currentSelectService = value;
    log("Select service type ${currentSelectService.name}");
    update();
  }

  bool isTermAndConditions = false;

  void setIsTermAndConditionToFalse() {
    isTermAndConditions = false;
    update();
  }

  void updateIsTermAndCondition() {
    isTermAndConditions = !isTermAndConditions;
    update();
  }

  TextEditingController searchController = TextEditingController();

  TextEditingController searchCouponsController = TextEditingController();

  List<RowOfAutoSetupSuccessModel> rowOfAutoSetupSuccessModelList = [
    RowOfAutoSetupSuccessModel(title: "Amount", subTitle: "129.00"),
    RowOfAutoSetupSuccessModel(title: "Frequency", subTitle: "Monthly"),
    RowOfAutoSetupSuccessModel(title: "Start Date", subTitle: "Oct 26, 2023"),
    RowOfAutoSetupSuccessModel(title: "Auto-pay ID", subTitle: "#VC-882910"),
  ];

  @override
  void dispose() {
    super.dispose();
    searchController.clear();
    searchCouponsController.clear();
  }

  List<BannerModel> bannerModelList = [];
  Future<ResponseModel> fetchBanner() async {
    log('-----------  fetchBanner ----------');
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await commonRepo.fetchBanner();

      if (response.body['status'] == "success") {
        bannerModelList = (response.body['data'] as List)
            .map((e) => BannerModel.fromJson(e))
            .toList();

        responseModel = ResponseModel(
            true, response.body['message'] ?? "success fetchBanner  ");
      } else {
        responseModel = ResponseModel(
            false, response.body['message'] ?? "Error while fetchBanner  ");
      }
    } catch (e) {
      log('ERROR AT fetchBanner(): $e');
      responseModel = ResponseModel(false, "Error while fetchBanner   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }
}
