import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/food_model.dart';
import '../models/home_screen_models.dart';
import '../models/restaurant_model.dart';
import '../services/food_service.dart';
import '../services/product_service.dart';
import '../services/restaurant_service.dart';
import 'food_controller.dart';

class RestaurantController extends GetxController implements GetxService {
  final RestaurantService _apiService = RestaurantService();
  final ProductService _productService = ProductService();
  final FoodService _foodService = FoodService();

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
    List<ApiProductModel>? foodProductsList,
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

      final targetDomain = effectiveDomain.trim().toLowerCase();
      final targetShopId = shopId ?? initialRestaurant?.shopId;
      final targetRestaurantId = initialRestaurant?.id ?? id;
      final targetName = (initialRestaurant?.name ?? '').trim().toLowerCase();

      // 1. Fetch live full restaurant menu data (categories + dishes)
      final fullMenu = await _apiService.getRestaurantMenuData(
        shopId: effectiveShopId,
        domain: effectiveDomain,
        initialRestaurant: initialRestaurant,
      );

      if (fullMenu != null) {
        menuData.value = fullMenu;
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

      // 3. Assemble dishes for this restaurant
      final List<DishModel> dishes = [];

      // Primary source: Fetch live food dishes directly from api/v1/ecommerce/food/dishes
      try {
        final apiDishes = await _foodService.getFoodDishes(
          domain: effectiveDomain,
          shopId: effectiveShopId,
        );
        for (var d in apiDishes) {
          if (!dishes.any((item) =>
              item.id == d.id ||
              item.name.trim().toLowerCase() == d.name.trim().toLowerCase())) {
            dishes.add(d);
          }
        }
      } catch (e) {
        debugPrint("RestaurantController getFoodDishes error: $e");
      }

      // Helper to check if a product from the list belongs to this restaurant's domain / shop
      bool matchesRestaurant(ApiProductModel p) {
        final pDomain = (p.store?.domain ?? '').trim().toLowerCase();
        final pShopId = p.shopId ?? p.store?.shopId;
        final pStoreId = p.store?.id;
        final pStoreName = (p.store?.name ?? '').trim().toLowerCase();

        // Check domain match
        if (targetDomain.isNotEmpty && pDomain.isNotEmpty) {
          if (pDomain == targetDomain ||
              pDomain.contains(targetDomain) ||
              targetDomain.contains(pDomain)) {
            return true;
          }
        }

        // Check shopId match
        if (targetShopId != null && pShopId != null && targetShopId == pShopId) {
          return true;
        }

        // Check restaurantId / storeId match
        if (targetRestaurantId > 0 && pStoreId != null && targetRestaurantId == pStoreId) {
          return true;
        }

        // Check store name match
        if (targetName.isNotEmpty && pStoreName.isNotEmpty) {
          if (targetName == pStoreName ||
              targetName.contains(pStoreName) ||
              pStoreName.contains(targetName)) {
            return true;
          }
        }

        return false;
      }

      DishModel dishFromApiProduct(ApiProductModel p) {
        final orig = p.unitPrice;
        final deal = p.finalPrice ?? p.discountedPrice ?? orig;
        final nameLower = p.name.toLowerCase();
        final isChickenOrNonVeg = nameLower.contains('chicken') ||
            nameLower.contains('mutton') ||
            nameLower.contains('egg') ||
            nameLower.contains('fish') ||
            nameLower.contains('meat') ||
            nameLower.contains('prawn') ||
            nameLower.contains('buff') ||
            nameLower.contains('non-veg') ||
            nameLower.contains('non veg');

        return DishModel(
          id: p.id,
          name: p.name,
          slug: p.slug ?? '',
          originalPrice: orig,
          dealPrice: deal > 0 ? deal : orig,
          discount: p.discount ?? 0.0,
          discountType: p.discountType ?? 'flat',
          discountAmount: (orig > deal) ? (orig - deal) : 0.0,
          currentStock: p.currentStock ?? 100,
          inStock: (p.currentStock ?? 100) > 0,
          thumbnail: p.thumbnail,
          isFood: true,
          foodType: isChickenOrNonVeg ? 'non_veg' : 'veg',
          categoryId: p.category?.id,
          categoryName: (p.category?.name != null && p.category!.name.isNotEmpty)
              ? p.category!.name
              : 'Dishes',
          categorySlug: p.category?.slug,
          variants: const [],
          shopId: p.shopId ?? p.store?.shopId ?? effectiveShopId,
          domain: p.store?.domain ?? effectiveDomain,
          storeName: p.store?.name ?? initialRestaurant?.name,
          rating: p.rating ?? 4.8,
        );
      }

      // PRIMARY SOURCE: Candidate products from products list (foodProductsList / FoodController / ProductService)
      final List<ApiProductModel> candidateProducts = [];
      if (foodProductsList != null && foodProductsList.isNotEmpty) {
        candidateProducts.addAll(foodProductsList);
      } else if (Get.isRegistered<FoodController>()) {
        final fc = Get.find<FoodController>();
        if (fc.foodProducts.isNotEmpty) {
          candidateProducts.addAll(fc.foodProducts);
        }
      }

      if (candidateProducts.isEmpty) {
        try {
          final allFood = await _productService.getProducts(isFood: 1);
          candidateProducts.addAll(allFood);
        } catch (_) {}
      }

      // Add matching products from candidateProducts FIRST (domain filtering: 10 me se 5 is restaurant k)
      for (var p in candidateProducts) {
        if (matchesRestaurant(p)) {
          if (!dishes.any((d) =>
              d.id == p.id ||
              d.name.trim().toLowerCase() == p.name.trim().toLowerCase())) {
            dishes.add(dishFromApiProduct(p));
          }
        }
      }

      // SECONDARY FALLBACK: If candidate products list had no matching products for this restaurant
      if (dishes.isEmpty && fullMenu != null && fullMenu.allDishes.isNotEmpty) {
        dishes.addAll(fullMenu.allDishes);
      }

      // TERTIARY FALLBACK: If still empty, fetch by domain via ProductService
      if (dishes.isEmpty && effectiveDomain.isNotEmpty) {
        try {
          final domainProducts = await _productService.getProducts(
            domain: effectiveDomain,
            isFood: 1,
          );
          for (var p in domainProducts) {
            if (!dishes.any((d) => d.id == p.id)) {
              dishes.add(dishFromApiProduct(p));
            }
          }
        } catch (_) {}
      }

      allDishes.assignAll(dishes);

      // 4. Build categoriesMenu dynamically from restaurant's dishes
      final Map<String, List<DishModel>> catMap = {};
      for (var dish in allDishes) {
        final cName = (dish.categoryName != null && dish.categoryName!.trim().isNotEmpty)
            ? dish.categoryName!.trim()
            : 'General';
        catMap.putIfAbsent(cName, () => []).add(dish);
      }

      final List<CategoryMenuModel> dynamicCats = [];
      catMap.forEach((catName, items) {
        dynamicCats.add(CategoryMenuModel(
          categoryName: catName,
          categoryId: items.first.categoryId ?? 0,
          dishesCount: items.length,
          items: items,
        ));
      });

      if (fullMenu != null && fullMenu.categoriesMenu.isNotEmpty) {
        for (var c in fullMenu.categoriesMenu) {
          if (!dynamicCats.any((dc) =>
              dc.categoryName.toLowerCase() == c.categoryName.toLowerCase())) {
            dynamicCats.add(c);
          }
        }
      }

      categoriesMenu.assignAll(dynamicCats);

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
              (d.categoryName ?? '').toLowerCase() ==
                  selectedCategory.value.toLowerCase() ||
              (d.categorySlug ?? '').toLowerCase() ==
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
