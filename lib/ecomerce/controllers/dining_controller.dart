import 'package:get/get.dart';
import '../models/restaurant_model.dart';
import '../services/dining_service.dart';

class DiningController extends GetxController {
  final DiningService _service = DiningService();

  final RxList<RestaurantModel> diningRestaurants = <RestaurantModel>[].obs;
  final RxBool isLoadingRestaurants = false.obs;

  final RxMap<String, dynamic> slotsData = <String, dynamic>{}.obs;
  final RxBool isLoadingSlots = false.obs;

  final RxMap<String, dynamic> tablesData = <String, dynamic>{}.obs;
  final RxBool isLoadingTables = false.obs;

  final RxMap<String, dynamic> menuData = <String, dynamic>{}.obs;
  final RxBool isLoadingMenu = false.obs;

  final RxList<dynamic> myBookings = <dynamic>[].obs;
  final RxBool isLoadingBookings = false.obs;

  Future<void> fetchDiningRestaurants({String domain = 'e-team-12'}) async {
    try {
      isLoadingRestaurants.value = true;
      final list = await _service.getDiningRestaurants(domain: domain);
      diningRestaurants.assignAll(list);
    } finally {
      isLoadingRestaurants.value = false;
    }
  }

  Future<void> fetchDiningSlots({required String domain, String? date, int? guests}) async {
    try {
      isLoadingSlots.value = true;
      final res = await _service.getDiningSlots(domain: domain, date: date, guests: guests);
      if (res != null) slotsData.assignAll(res);
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Future<void> fetchAvailableTables({
    required String domain,
    required int shopId,
    required String date,
    required String timeSlot,
    int? guests,
  }) async {
    try {
      isLoadingTables.value = true;
      final res = await _service.getAvailableTables(
        domain: domain,
        shopId: shopId,
        date: date,
        timeSlot: timeSlot,
        guests: guests,
      );
      if (res != null) tablesData.assignAll(res);
    } finally {
      isLoadingTables.value = false;
    }
  }

  Future<void> fetchDiningMenu({required String domain, required int shopId}) async {
    try {
      isLoadingMenu.value = true;
      final res = await _service.getDiningMenu(domain: domain, shopId: shopId);
      if (res != null) menuData.assignAll(res);
    } finally {
      isLoadingMenu.value = false;
    }
  }

  Future<void> fetchMyBookings({required String domain}) async {
    try {
      isLoadingBookings.value = true;
      final res = await _service.getMyBookings(domain: domain);
      if (res != null && res['data'] != null && res['data']['bookings'] != null) {
        myBookings.assignAll(res['data']['bookings']);
      }
    } finally {
      isLoadingBookings.value = false;
    }
  }
}
