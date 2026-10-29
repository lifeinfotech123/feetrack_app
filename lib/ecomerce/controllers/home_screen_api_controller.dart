import 'package:get/get.dart';
import '../models/brand_model.dart';
import '../models/home_screen_models.dart';
import '../models/store_model.dart';
import '../services/ecommerce_api_service.dart';
import '../services/home_screen_api_service.dart';

class HomeScreenApiController extends GetxController implements GetxService {
  final HomeScreenApiService _localService = HomeScreenApiService();
  final EcommerceApiService _ecomService = EcommerceApiService();

  // All products fetched from the live API
  final RxList<ApiProductModel> allProducts = <ApiProductModel>[].obs;

  // 1. Featured / Popular Products
  final RxList<ApiProductModel> featuredProducts = <ApiProductModel>[].obs;
  final RxBool isFeaturedLoading = false.obs;
  final RxString featuredErrorMessage = ''.obs;

  // 2. Top Brands
  final RxList<BrandModel> topBrands = <BrandModel>[].obs;
  final RxBool isTopBrandsLoading = false.obs;
  final RxString topBrandsErrorMessage = ''.obs;

  // 3. Flash Deals
  final RxList<FlashDealModel> flashDeals = <FlashDealModel>[].obs;
  final RxBool isFlashDealsLoading = false.obs;
  final RxString flashDealsErrorMessage = ''.obs;

  // 4. Top Sellers / Best Sellers
  final RxList<TopSellerModel> topSellers = <TopSellerModel>[].obs;
  final RxBool isTopSellersLoading = false.obs;
  final RxString topSellersErrorMessage = ''.obs;

  // 5. Most Popular Products
  final RxList<ApiProductModel> mostPopularProducts = <ApiProductModel>[].obs;
  final RxBool isMostPopularLoading = false.obs;
  final RxString mostPopularErrorMessage = ''.obs;

  // 6. New Arrival Products
  final RxList<ApiProductModel> newArrivalsProducts = <ApiProductModel>[].obs;
  final RxBool isNewArrivalsLoading = false.obs;
  final RxString newArrivalsErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchLiveProducts(),
      fetchTopBrands(),
      fetchFlashDeals(),
      fetchTopSellers(),
    ]);
  }

  /// Fetch live products from https://orderknow.com/api/v1/ecommerce/products (excluding food)
  Future<void> fetchLiveProducts() async {
    try {
      isFeaturedLoading.value = true;
      isMostPopularLoading.value = true;
      isNewArrivalsLoading.value = true;
      featuredErrorMessage.value = '';

      // Pass isFood: 0 to only get eCommerce items
      final list = await _ecomService.getProducts(isFood: 0);
      final nonFoodList = list.where((p) => !p.isFood).toList();

      if (nonFoodList.isNotEmpty) {
        allProducts.assignAll(nonFoodList);
        featuredProducts.assignAll(nonFoodList);
        mostPopularProducts.assignAll(nonFoodList.reversed.toList());
        newArrivalsProducts.assignAll(nonFoodList);
      } else {
        allProducts.clear();
        featuredProducts.clear();
        mostPopularProducts.clear();
        newArrivalsProducts.clear();
      }
    } catch (e) {
      featuredErrorMessage.value = e.toString();
      allProducts.clear();
      featuredProducts.clear();
      mostPopularProducts.clear();
      newArrivalsProducts.clear();
    } finally {
      isFeaturedLoading.value = false;
      isMostPopularLoading.value = false;
      isNewArrivalsLoading.value = false;
    }
  }

  /// Filter displayed products when a specific store is selected
  void filterProductsByStore(StoreModel? store) {
    if (store == null) {
      // Show all non-food products from all stores
      final nonFood = allProducts.where((p) => !p.isFood).toList();
      featuredProducts.assignAll(nonFood);
      mostPopularProducts.assignAll(nonFood.reversed.toList());
      newArrivalsProducts.assignAll(nonFood);
    } else {
      // Filter products belonging to this store (excluding food items)
      final filtered = allProducts.where((p) {
        if (p.isFood) return false;
        final matchesShopId = store.shopId != null &&
            (p.shopId == store.shopId || p.store?.shopId == store.shopId);
        final matchesStoreId = store.id != 0 && p.store?.id == store.id;
        final matchesDomain = store.domain != null &&
            p.store?.domain?.toLowerCase() == store.domain?.toLowerCase();
        final matchesSlug = store.slug != null &&
            p.store?.slug?.toLowerCase() == store.slug?.toLowerCase();
        return matchesShopId || matchesStoreId || matchesDomain || matchesSlug;
      }).toList();

      if (filtered.isNotEmpty) {
        featuredProducts.assignAll(filtered);
        mostPopularProducts.assignAll(filtered);
        newArrivalsProducts.assignAll(filtered);
      } else {
        // If store has no products yet in list, query API or keep empty
        featuredProducts.clear();
        mostPopularProducts.clear();
        newArrivalsProducts.clear();
      }
    }
  }

  Future<void> fetchFeaturedProducts() async {
    await fetchLiveProducts();
  }

  /// Fetch Brands from https://orderknow.com/api/v1/ecommerce/brands
  Future<void> fetchTopBrands() async {
    try {
      isTopBrandsLoading.value = true;
      topBrandsErrorMessage.value = '';
      final list = await _ecomService.getBrands();
      if (list.isNotEmpty) {
        topBrands.assignAll(list);
      } else {
        final fallback = await _localService.getTopBrands();
        topBrands.assignAll(fallback);
      }
    } catch (e) {
      topBrandsErrorMessage.value = e.toString();
      final fallback = await _localService.getTopBrands();
      topBrands.assignAll(fallback);
    } finally {
      isTopBrandsLoading.value = false;
    }
  }

  Future<void> fetchFlashDeals() async {
    try {
      isFlashDealsLoading.value = true;
      flashDealsErrorMessage.value = '';
      final list = await _localService.getFlashDeals();
      if (list.isNotEmpty) {
        flashDeals.assignAll(list);
      }
    } catch (e) {
      flashDealsErrorMessage.value = e.toString();
    } finally {
      isFlashDealsLoading.value = false;
    }
  }

  Future<void> fetchTopSellers() async {
    try {
      isTopSellersLoading.value = true;
      topSellersErrorMessage.value = '';
      // Also map stores as top sellers
      final stores = await _ecomService.getStores();
      if (stores.isNotEmpty) {
        final sellerList = stores
            .map((s) => TopSellerModel(
                  id: s.id,
                  sellerId: s.shopId,
                  name: s.name,
                  slug: s.slug,
                  logo: s.logo,
                  banner: s.banner,
                  rating: s.rating,
                  ratingFormatted: s.rating.toString(),
                  productsCount: s.totalProducts,
                  reviewsCount: s.reviewsCount,
                  isInhouse: false,
                ))
            .toList();
        topSellers.assignAll(sellerList);
      } else {
        final fallback = await _localService.getTopSellers();
        topSellers.assignAll(fallback);
      }
    } catch (e) {
      topSellersErrorMessage.value = e.toString();
      final fallback = await _localService.getTopSellers();
      topSellers.assignAll(fallback);
    } finally {
      isTopSellersLoading.value = false;
    }
  }
}
