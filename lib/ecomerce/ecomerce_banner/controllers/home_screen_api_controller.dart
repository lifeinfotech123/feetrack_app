import 'package:get/get.dart';

import '../../models/brand_model.dart';
import '../../models/home_screen_models.dart';
import '../../services/home_screen_api_service.dart';


class HomeScreenApiController extends GetxController implements GetxService {
  final HomeScreenApiService _apiService = HomeScreenApiService();

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
      fetchFeaturedProducts(),
      fetchTopBrands(),
      fetchFlashDeals(),
      fetchTopSellers(),
      fetchMostPopularProducts(),
      fetchNewArrivalsProducts(),
    ]);
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      isFeaturedLoading.value = true;
      featuredErrorMessage.value = '';
      final list = await _apiService.getFeaturedProducts();
      if (list.isNotEmpty) {
        featuredProducts.assignAll(list);
      } else {
        featuredErrorMessage.value = "No featured products found";
      }
    } catch (e) {
      featuredErrorMessage.value = e.toString();
    } finally {
      isFeaturedLoading.value = false;
    }
  }

  Future<void> fetchTopBrands() async {
    try {
      isTopBrandsLoading.value = true;
      topBrandsErrorMessage.value = '';
      final list = await _apiService.getTopBrands();
      if (list.isNotEmpty) {
        topBrands.assignAll(list);
      } else {
        topBrandsErrorMessage.value = "No top brands found";
      }
    } catch (e) {
      topBrandsErrorMessage.value = e.toString();
    } finally {
      isTopBrandsLoading.value = false;
    }
  }

  Future<void> fetchFlashDeals() async {
    try {
      isFlashDealsLoading.value = true;
      flashDealsErrorMessage.value = '';
      final list = await _apiService.getFlashDeals();
      if (list.isNotEmpty) {
        flashDeals.assignAll(list);
      } else {
        flashDealsErrorMessage.value = "No flash deals found";
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
      final list = await _apiService.getTopSellers();
      if (list.isNotEmpty) {
        topSellers.assignAll(list);
      } else {
        topSellersErrorMessage.value = "No top sellers found";
      }
    } catch (e) {
      topSellersErrorMessage.value = e.toString();
    } finally {
      isTopSellersLoading.value = false;
    }
  }

  Future<void> fetchMostPopularProducts() async {
    try {
      isMostPopularLoading.value = true;
      mostPopularErrorMessage.value = '';
      final list = await _apiService.getMostPopularProducts();
      if (list.isNotEmpty) {
        mostPopularProducts.assignAll(list);
      } else {
        mostPopularErrorMessage.value = "No most popular products found";
      }
    } catch (e) {
      mostPopularErrorMessage.value = e.toString();
    } finally {
      isMostPopularLoading.value = false;
    }
  }

  Future<void> fetchNewArrivalsProducts() async {
    try {
      isNewArrivalsLoading.value = true;
      newArrivalsErrorMessage.value = '';
      final list = await _apiService.getNewArrivalsProducts();
      if (list.isNotEmpty) {
        newArrivalsProducts.assignAll(list);
      } else {
        newArrivalsErrorMessage.value = "No new arrivals found";
      }
    } catch (e) {
      newArrivalsErrorMessage.value = e.toString();
    } finally {
      isNewArrivalsLoading.value = false;
    }
  }
}
