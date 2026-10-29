import 'package:get/get.dart';
import '../models/food_model.dart';
import '../models/home_screen_models.dart';
import '../models/restaurant_model.dart';
import '../services/food_service.dart';
import '../services/product_service.dart';
import '../services/restaurant_service.dart';

class FoodController extends GetxController implements GetxService {
  final FoodService _foodService = FoodService();
  final RestaurantService _restaurantService = RestaurantService();
  final ProductService _productService = ProductService();

  final Rx<FoodHomeDataModel?> foodData = Rx<FoodHomeDataModel?>(null);
  final RxList<CuisineModel> cuisines = <CuisineModel>[].obs;
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final Rxn<RestaurantModel> selectedRestaurant = Rxn<RestaurantModel>();
  final RxList<ApiProductModel> foodProducts = <ApiProductModel>[].obs;
  final RxList<ApiProductModel> filteredFoodProducts = <ApiProductModel>[].obs;

  final RxInt selectedCuisineIndex = 0.obs;
  final RxString selectedVegFilter = 'All'.obs; // 'All', 'Pure Veg', 'Non-Veg'
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFoodData();
  }

  Future<void> fetchFoodData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await Future.wait([
        _foodService.getFoodData(),
        _restaurantService.getRestaurants(),
        _productService.getProducts(isFood: 1),
      ]);

      final data = results[0] as FoodHomeDataModel?;
      final restList = results[1] as List<RestaurantModel>;
      final productsList = results[2] as List<ApiProductModel>;

      if (data != null) {
        foodData.value = data;
        cuisines.assignAll(data.cuisines);

        // Merge restaurants
        final allRestaurants = <RestaurantModel>[...data.restaurants];
        for (var r in restList) {
          if (!allRestaurants.any((existing) => existing.id == r.id && existing.shopId == r.shopId)) {
            allRestaurants.add(r);
          }
        }
        restaurants.assignAll(allRestaurants);
      } else if (restList.isNotEmpty) {
        restaurants.assignAll(restList);
      }

      if (productsList.isNotEmpty) {
        foodProducts.assignAll(productsList);
      }

      applyFilters();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCuisine(int index) {
    selectedCuisineIndex.value = index;
    applyFilters();
  }

  void setVegFilter(String filter) {
    selectedVegFilter.value = filter;
    applyFilters();
  }

  void selectRestaurant(RestaurantModel? restaurant) {
    selectedRestaurant.value = restaurant;
    if (restaurant == null) {
      filteredFoodProducts.assignAll(foodProducts);
    } else {
      final rDomain = (restaurant.domain ?? '').toLowerCase();
      final rName = restaurant.name.toLowerCase();
      final rShopId = restaurant.shopId;
      final list = foodProducts.where((p) {
        final pDomain = (p.store?.domain ?? '').toLowerCase();
        final pStoreName = (p.store?.name ?? '').toLowerCase();
        final pShopId = p.store?.shopId;
        if (rDomain.isNotEmpty && pDomain.isNotEmpty && pDomain == rDomain) return true;
        if (rShopId != null && pShopId != null && pShopId == rShopId) return true;
        if (rName.isNotEmpty && (pStoreName.contains(rName) || rName.contains(pStoreName))) return true;
        return false;
      }).toList();
      filteredFoodProducts.assignAll(list);
    }
  }


  void setSearch(String query) {
    searchQuery.value = query.trim().toLowerCase();
    applyFilters();
  }

  void applyFilters() {
    var list = List<ApiProductModel>.from(foodProducts);

    // 1. Cuisine / Category Filter
    if (selectedCuisineIndex.value > 0 && selectedCuisineIndex.value <= cuisines.length) {
      final selectedCuisine = cuisines[selectedCuisineIndex.value - 1];
      list = list.where((p) {
        final catId = p.category?.id;
        final catName = p.category?.name.toLowerCase() ?? '';
        final catSlug = p.category?.slug?.toLowerCase() ?? '';
        return catId == selectedCuisine.id ||
            catName == selectedCuisine.name.toLowerCase() ||
            catSlug == selectedCuisine.slug.toLowerCase();
      }).toList();
    }

    // 2. Veg / Non-Veg Filter
    if (selectedVegFilter.value == 'Pure Veg' || selectedVegFilter.value == 'Veg') {
      list = list.where((p) {
        final name = p.name.toLowerCase();
        return !name.contains('chicken') && !name.contains('mutton') && !name.contains('egg');
      }).toList();
    } else if (selectedVegFilter.value == 'Non-Veg') {
      list = list.where((p) {
        final name = p.name.toLowerCase();
        return name.contains('chicken') || name.contains('mutton') || name.contains('egg') || name.contains('fish');
      }).toList();
    }

    // 3. Search Query
    if (searchQuery.value.isNotEmpty) {
      list = list.where((p) {
        return p.name.toLowerCase().contains(searchQuery.value) ||
            (p.category?.name.toLowerCase().contains(searchQuery.value) ?? false);
      }).toList();
    }

    filteredFoodProducts.assignAll(list);
  }

  List<RestaurantModel> get filteredRestaurants {
    var list = restaurants.toList();

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((r) =>
        r.name.toLowerCase().contains(q) ||
        (r.address?.toLowerCase().contains(q) ?? false) ||
        (r.domain?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    if (selectedVegFilter.value == 'Pure Veg') {
      final vegOnly = list.where((r) => r.restaurantType?.toLowerCase() == 'veg').toList();
      return vegOnly.isNotEmpty ? vegOnly : list;
    } else if (selectedVegFilter.value == 'Non-Veg') {
      return list.where((r) => r.restaurantType?.toLowerCase() != 'veg').toList();
    }
    return list;
  }
}
