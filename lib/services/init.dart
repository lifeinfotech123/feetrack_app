import 'dart:developer';
import 'package:get/instance_manager.dart';
import 'package:vlr/controllers/attendance_controller.dart';
import 'package:vlr/controllers/basic_controller.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/controllers/common_controller.dart';
import 'package:vlr/controllers/coupons_controller.dart';
import 'package:vlr/controllers/dashboard_controller.dart';
import 'package:vlr/controllers/notification_controller.dart';
import 'package:vlr/controllers/job_controller.dart';
import 'package:vlr/controllers/job_candidate_profile_update_controller.dart';
import 'package:vlr/data/repositories/job_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/gym_profile_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/kyc_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/controllers/school_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/controllers/transaction_controller.dart';
import 'package:vlr/controllers/transaction_history_controller.dart';
import 'package:vlr/controllers/wallet_controller.dart';
import 'package:vlr/data/repositories/attendance_repo.dart';
import 'package:vlr/data/repositories/book_appoint_repo.dart';
import 'package:vlr/data/repositories/common_repo.dart';
import 'package:vlr/data/repositories/coupons_repo.dart';
import 'package:vlr/data/repositories/gym_repo.dart';
import 'package:vlr/data/repositories/home_repo.dart';
import 'package:vlr/data/repositories/notification_repo.dart';
import 'package:vlr/data/repositories/kyc_repo.dart';
import 'package:vlr/data/repositories/room_repo.dart';
import 'package:vlr/data/repositories/school_repo.dart';
import 'package:vlr/data/repositories/subscription_repo.dart';
import 'package:vlr/data/repositories/transaction_repo.dart';
import 'package:vlr/data/repositories/wallet_repo.dart';
import 'package:vlr/controllers/visit_controller.dart';
import 'package:vlr/data/repositories/visit_repo.dart';
import '../controllers/auth_controller.dart';
import '../controllers/permission_controller.dart';
import '../data/api/api_client.dart';
import '../data/repositories/auth_repo.dart';
import '../data/repositories/basic_repo.dart';
import 'constants.dart';

class Init {
  initialize() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.lazyPut<SharedPreferences>(() => sharedPreferences);

    try {
      // ApiClient
      Get.lazyPut(() => ApiClient(
          appBaseUrl: AppConstants.baseUrl,
          sharedPreferences: sharedPreferences));
      Get.lazyPut(() =>
          KycRepo(apiClient: Get.find(), sharedPreferences: sharedPreferences));
      Get.lazyPut(() => WalletRepo(
            apiClient: Get.find(),
          ));

      Get.lazyPut(() => PermissionController());

      // Get Repo's...
      Get.lazyPut(
          () => AuthRepo(sharedPreferences: Get.find(), apiClient: Get.find()));
      Get.lazyPut(() => BasicRepo(apiClient: Get.find()));
      Get.lazyPut(() => GymRepo(apiClient: Get.find()));
      Get.lazyPut(() => TransactionRepo(apiClient: Get.find()));
      Get.lazyPut(() => BookAppointRepo(apiClient: Get.find()));
      Get.lazyPut(() => RoomRepo(apiClient: Get.find()));
      Get.lazyPut(() => SchoolRepo(apiClient: Get.find()));
      Get.lazyPut(() => HomeRepo(apiClient: Get.find()));
      Get.lazyPut(() => SubscriptionRepo(apiClient: Get.find()));
      Get.lazyPut(() => CommonRepo(apiClient: Get.find()));
      Get.lazyPut(() => CouponsRepo(apiClient: Get.find()));
      Get.lazyPut(() => VisitRepo(apiClient: Get.find()));
      Get.lazyPut(() => AttendanceRepo(apiClient: Get.find()));
      Get.lazyPut(() => NotificationRepo(apiClient: Get.find()));
      Get.lazyPut(() => JobRepo(apiClient: Get.find()));

      // Get Controller's...
      Get.lazyPut(() => DashBoardController());
      Get.lazyPut(() => AuthController(authRepo: Get.find()));
      Get.lazyPut(() => KycController(kycRepo: Get.find()));
      Get.lazyPut(() => BasicController(basicRepo: Get.find()));
      Get.lazyPut(() => GymController(gymRepo: Get.find()));
      Get.lazyPut(() => GymProfileController());
      Get.lazyPut(() => TransactionController(transactionRepo: Get.find()));
      Get.lazyPut(() => TransactionHistoryController(apiClient: Get.find()));
      Get.lazyPut(() => WalletController(walletRepo: Get.find()));
      Get.lazyPut(() => BookAppointController(bookAppointRepo: Get.find()));
      Get.lazyPut(() => RoomController(roomRepo: Get.find()));
      Get.lazyPut(() => SchoolController(schoolRepo: Get.find()));
      Get.lazyPut(() => CommonController(commonRepo: Get.find()));
      Get.lazyPut(() => HomeController(homeRepo: Get.find()));
      Get.lazyPut(() => SubscriptionController(subscriptionRepo: Get.find()));
      Get.lazyPut(() => CouponsController(couponsRepo: Get.find()));
      Get.lazyPut(() => VisitController(visitRepo: Get.find()));
      Get.lazyPut(() => AttendanceController(attendanceRepo: Get.find()));
      Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
      Get.lazyPut(() => JobController(jobRepo: Get.find()));
      Get.lazyPut(
          () => JobCandidateProfileUpdateController(jobRepo: Get.find()));
    } catch (e) {
      log('---- ${e.toString()} ----', name: "ERROR AT initialize()");
    }
  }
}
