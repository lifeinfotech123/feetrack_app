import 'package:get/get.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';
import 'home_screen_api_controller.dart';

class StoreController extends GetxController implements GetxService {
  static StoreController get instance => Get.find<StoreController>();

  final StoreService _apiService = StoreService();

  // Stores List State
  final RxList<StoreModel> stores = <StoreModel>[].obs;
  final RxBool isStoresLoading = false.obs;
  final RxString storesError = ''.obs;

  // Selected Store State (null means "All Stores / Global")
  final Rx<StoreModel?> selectedStore = Rx<StoreModel?>(null);

  // Store Details State
  final Rx<StoreModel?> storeDetails = Rx<StoreModel?>(null);
  final RxBool isStoreDetailsLoading = false.obs;
  final RxString storeDetailsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  /// Fetch all stores from API
  Future<void> fetchStores() async {
    try {
      isStoresLoading.value = true;
      storesError.value = '';
      final list = await _apiService.getStores();
      if (list.isNotEmpty) {
        stores.assignAll(list);
      } else {
        storesError.value = "No stores found";
      }
    } catch (e) {
      storesError.value = e.toString();
    } finally {
      isStoresLoading.value = false;
    }
  }

  /// Select a store (or pass null for All Stores)
  void selectStore(StoreModel? store) {
    selectedStore.value = store;
    // Notify HomeScreenApiController to update product list for this store
    if (Get.isRegistered<HomeScreenApiController>()) {
      Get.find<HomeScreenApiController>().filterProductsByStore(store);
    }
  }

  /// Fetch Store Details by id, slug or domain
  Future<void> fetchStoreDetails(dynamic idOrSlug) async {
    try {
      isStoreDetailsLoading.value = true;
      storeDetailsError.value = '';
      final details = await _apiService.getStoreDetails(idOrSlug);
      if (details != null) {
        storeDetails.value = details;
      } else {
        storeDetailsError.value = "Failed to load store details";
      }
    } catch (e) {
      storeDetailsError.value = e.toString();
    } finally {
      isStoreDetailsLoading.value = false;
    }
  }
}
