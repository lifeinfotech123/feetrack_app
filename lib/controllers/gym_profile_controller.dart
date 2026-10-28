import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/data/models/gym_profile_model.dart';

class GymProfileController extends GetxController {
  GymProfileModel profile = GymProfileModel();
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchProfile() async {
    isLoading = true;
    errorMessage = null;
    update();
    try {
      final response = await Get.find<AuthController>().fetchProfile();
      if (response.isSuccess) {
        profile = GymProfileModel(user: Get.find<AuthController>().userModel);
      } else {
        errorMessage = response.message;
      }
    } finally {
      isLoading = false;
      update();
    }
  }

}
