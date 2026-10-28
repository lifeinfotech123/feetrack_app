import 'dart:developer';

import 'package:get/get.dart';
import 'package:vlr/views/base/custom_toast.dart';

import '../../controllers/auth_controller.dart';

class ApiChecker {
  static void checkApi(Response response) {
    if (response.statusCode == 401) {
      log('here 401');
      Get.find<AuthController>().clearSharedData();
      // navigatorKey.currentState!.pushAndRemoveUntil(getCustomRoute(child: const SplashScreen()), (route) => false);
    } else if (response.statusCode == 429) {
      Get.find<AuthController>().clearSharedData();
      // navigatorKey.currentState!.pushAndRemoveUntil(getCustomRoute(child: const SplashScreen()), (route) => false);
      log('here 401');
    } else {
      log('${response.statusText} : ${response.body ?? ''}');
      if (response.statusText!.contains('Too many connections')) {
        showCustomToast(msg: 'Too many connections');
      } else {
        showCustomToast(msg: '${response.statusText} ');
      }
    }
  }
}
