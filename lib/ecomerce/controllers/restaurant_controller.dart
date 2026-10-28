import 'package:get/get.dart';
import '../models/food_model.dart';
import '../models/restaurant_model.dart';
import '../services/restaurant_service.dart';

class RestaurantController extends GetxController implements GetxService {
  final RestaurantService _apiService = RestaurantService();

  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final Rx<RestaurantDetailModel?> restaurantDetail =
      Rx<RestaurantDetailModel?>(null);
  final Rx<RestaurantMenuData?> menuData = Rx<RestaurantMenuData?>(null);
  final RxList<CategoryMenuModel> categoriesMenu = <CategoryMenuModel>[].obs;
  final RxList<DishModel> allDishes = <DishModel>[].obs;
  final RxList<DishModel> filteredDishes = <DishModel>[].obs;

  final RxString selectedCategory = 'All'.obs;
  final RxString selectedVegFilter = 'All'.obs; // 'All', 'Veg', 'Non-Veg'
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final list = await _apiService.getRestaurants();
      restaurants.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRestaurantDetails(
    int id, {
    int? shopId,
    String? domain,
    RestaurantModel? initialRestaurant,
  }) async {
    try {
      isDetailLoading.value = true;
      restaurantDetail.value = null;
      menuData.value = null;
      categoriesMenu.clear();
      allDishes.clear();
      filteredDishes.clear();
      selectedCategory.value = 'All';
      selectedVegFilter.value = 'All';
      searchQuery.value = '';

      final effectiveShopId = shopId ?? initialRestaurant?.shopId ?? 2;
      final effectiveDomain = (domain != null && domain.isNotEmpty)
          ? domain
          : (initialRestaurant?.domain ?? 'e-team-12');

      // 1. Fetch live full restaurant menu data (categories + dishes)
      final fullMenu = await _apiService.getRestaurantMenuData(
        shopId: effectiveShopId,
        domain: effectiveDomain,
        initialRestaurant: initialRestaurant,
      );

      if (fullMenu != null) {
        menuData.value = fullMenu;
        categoriesMenu.assignAll(fullMenu.categoriesMenu);
        allDishes.assignAll(fullMenu.allDishes);
      }

      // 2. Fetch RestaurantDetailModel for metadata
      final menuDetail = await _apiService.getRestaurantMenu(
        shopId: effectiveShopId,
        domain: effectiveDomain,
      );
      if (menuDetail != null) {
        restaurantDetail.value = menuDetail;
      } else {
        restaurantDetail.value = await _apiService.getRestaurantDetails(id);
      }

      applyFilters();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isDetailLoading.value = false;
    }
  }

  void setCategory(String categoryName) {
    selectedCategory.value = categoryName;
    applyFilters();
  }

  void setVegFilter(String filter) {
    selectedVegFilter.value = filter;
    applyFilters();
  }

  void setSearch(String query) {
    searchQuery.value = query.trim().toLowerCase();
    applyFilters();
  }

  void applyFilters() {
    var list = List<DishModel>.from(allDishes);

    // 1. Category Filter
    if (selectedCategory.value != 'All') {
      list = list
          .where((d) =>
              d.categoryName?.toLowerCase() ==
                  selectedCategory.value.toLowerCase() ||
              d.categorySlug?.toLowerCase() ==
                  selectedCategory.value.toLowerCase())
          .toList();
    }

    // 2. Veg / Non-Veg Filter
    if (selectedVegFilter.value == 'Veg' ||
        selectedVegFilter.value == 'Pure Veg') {
      list = list.where((d) => d.isVeg).toList();
    } else if (selectedVegFilter.value == 'Non-Veg') {
      list = list.where((d) => !d.isVeg).toList();
    }

    // 3. Search Filter
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((d) =>
              d.name.toLowerCase().contains(searchQuery.value) ||
              (d.categoryName?.toLowerCase().contains(searchQuery.value) ??
                  false))
          .toList();
    }

    filteredDishes.assignAll(list);
  }
}
