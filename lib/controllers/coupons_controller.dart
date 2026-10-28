import 'dart:developer';

import 'package:get/get.dart';
import 'package:vlr/data/models/coupons_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/coupons_repo.dart';

class CouponsController extends GetxController implements GetxService {
  final CouponsRepo couponsRepo;

  CouponsController({required this.couponsRepo});

  bool isLoading = false;

  List<CouponsCodeModel> couponsCodeModelList = [];
  Future<ResponseModel> fetchCouponsList({required String id}) async {
    log('-----------  fetchCouponsList ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await couponsRepo.fetchCouponsList(id: id);
      if (response.body['status'] == "success") {
        couponsCodeModelList = (response.body['data'] as List)
            .map((e) => CouponsCodeModel.fromJson(e))
            .toList();

        log("Coupons Count: ${couponsCodeModelList.length}");

        responseModel = ResponseModel(
          true,
          response.body['message'] ?? "success fetchCouponsList",
        );
      } else {
        String errorMessage =
            response.body['message'] ?? "Error while fetchCouponsList";

        if (response.body['errors'] != null &&
            response.body['errors']['mobile'] != null) {
          errorMessage = response.body['errors']['mobile'][0];
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT fetchCouponsList(): $e');
      responseModel = ResponseModel(false, "Error while fetchCouponsList   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  CouponsCodeModel? selectCouponsCodeModel;

  void updateSelectCouponsCodeModel({required CouponsCodeModel value}) {
    selectCouponsCodeModel = value;
    update();
  }

  Future<ResponseModel> applyCouponCode({
    required String listingId,
    required String planId,
    required String durationId,
  }) async {
    log('-----------  applyCouponCode ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final data = {
        "listing_id": 1,
        "coupon_code": selectCouponsCodeModel?.code ?? "",
        "plan_id": 1,
        "duration_id": 1
      };
      Response response =
          await couponsRepo.applyCouponCode(data: FormData(data));
      if (response.body['status'] == "success") {
        responseModel = ResponseModel(
          true,
          response.body['message'] ?? "success applyCouponCode",
        );
      } else {
        String errorMessage =
            response.body['message'] ?? "Error while applyCouponCode";

        if (response.body['errors'] != null &&
            response.body['errors']['mobile'] != null) {
          errorMessage = response.body['errors']['mobile'][0];
        }

        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT applyCouponCode(): $e');
      responseModel = ResponseModel(false, "Error while applyCouponCode   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }
}
