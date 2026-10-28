import 'package:http/http.dart' as http;
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/deal_model.dart';
import '../models/food_model.dart';
import '../models/home_screen_models.dart' hide FlashDealModel;
import '../models/restaurant_model.dart';
import '../models/store_model.dart';
import '../models/top_slider_model.dart';
import '../models/ecommerce_address_model.dart';
import '../models/product_variant_model.dart';

import 'address_service.dart';
import 'brand_service.dart';
import 'cart_service.dart';
import 'category_service.dart';
import 'deals_service.dart';
import 'food_service.dart';
import 'order_service.dart';
import 'product_service.dart';
import 'restaurant_service.dart';
import 'store_service.dart';
import 'top_slider_service.dart';

export '../models/product_variant_model.dart';
export 'address_service.dart';
export 'brand_service.dart';
export 'cart_service.dart';
export 'category_service.dart';
export 'deals_service.dart';
export 'food_service.dart';
export 'order_service.dart';
export 'product_service.dart';
export 'restaurant_service.dart';
export 'store_service.dart';
export 'top_slider_service.dart';

/// Unified Facade for Ecommerce Services
/// Delegates each domain to its own dedicated service file.
class EcommerceApiService {
  final CategoryService _categoryService;
  final StoreService _storeService;
  final BrandService _brandService;
  final ProductService _productService;
  final DealsService _dealsService;
  final FoodService _foodService;
  final RestaurantService _restaurantService;
  final TopSliderService _topSliderService;
  final OrderService _orderService;
  final CartService _cartService;
  final AddressService _addressService;

  EcommerceApiService({http.Client? client})
      : _categoryService = CategoryService(client: client),
        _storeService = StoreService(client: client),
        _brandService = BrandService(client: client),
        _productService = ProductService(client: client),
        _dealsService = DealsService(client: client),
        _foodService = FoodService(client: client),
        _restaurantService = RestaurantService(client: client),
        _topSliderService = TopSliderService(client: client),
        _orderService = OrderService(client: client),
        _cartService = CartService(client: client),
        _addressService = AddressService(client: client);

  // 1. Categories
  Future<List<CategoryModel>> getCategories({
    String? store,
    String? domain,
  }) =>
      _categoryService.getCategories(store: store, domain: domain);

  // 2. Stores
  Future<List<StoreModel>> getStores({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? search,
    int? isRestaurant,
    String? restaurantType,
    int? isOpen,
    int? hasDining,
    String? sortBy,
    int page = 1,
    int perPage = 20,
  }) =>
      _storeService.getStores(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        search: search,
        isRestaurant: isRestaurant,
        restaurantType: restaurantType,
        isOpen: isOpen,
        hasDining: hasDining,
        sortBy: sortBy,
        page: page,
        perPage: perPage,
      );

  Future<StoreModel?> getStoreDetails(dynamic idOrSlug) =>
      _storeService.getStoreDetails(idOrSlug);

  // 3. Brands
  Future<List<BrandModel>> getBrands({
    String? domain,
    String? search,
    int? hasProducts,
    String? sortBy,
    String? order,
    int page = 1,
    int perPage = 20,
  }) =>
      _brandService.getBrands(
        domain: domain,
        search: search,
        hasProducts: hasProducts,
        sortBy: sortBy,
        order: order,
        page: page,
        perPage: perPage,
      );

  // 4. Products
  Future<List<ApiProductModel>> getProducts({
    String? domain,
    String? search,
    String? category,
    int? categoryId,
    int? subCategoryId,
    String? brand,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    int? isFood,
    String? foodType,
    int? isRecommended,
    int? featured,
    int? inStock,
    int? isInstantDelivery,
    double? latitude,
    double? longitude,
    String? sortBy,
    int? storeId,
    int? shopId,
    int page = 1,
    int perPage = 20,
  }) =>
      _productService.getProducts(
        domain: domain,
        search: search,
        category: category,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        brand: brand,
        brandId: brandId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        isFood: isFood,
        foodType: foodType,
        isRecommended: isRecommended,
        featured: featured,
        inStock: inStock,
        isInstantDelivery: isInstantDelivery,
        latitude: latitude,
        longitude: longitude,
        sortBy: sortBy,
        storeId: storeId,
        shopId: shopId,
        page: page,
        perPage: perPage,
      );

  Future<ProductVariantDetailsModel?> getProductVariants(
    int productId, {
    String? domain,
  }) =>
      _productService.getProductVariants(productId, domain: domain);

  // 5. Flash Deals & Deals
  Future<List<FlashDealModel>> getFlashDeals({
    int? activeOnly = 1,
    String? domain,
    int? featured,
    String? search,
    int withProducts = 1,
    int productsLimit = 10,
    int page = 1,
    int perPage = 20,
  }) =>
      _dealsService.getFlashDeals(
        activeOnly: activeOnly,
        domain: domain,
        featured: featured,
        search: search,
        withProducts: withProducts,
        productsLimit: productsLimit,
        page: page,
        perPage: perPage,
      );

  Future<List<DealOfTheDayModel>> getDealOfTheDay({
    String? search,
    String? domain,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
  }) =>
      _dealsService.getDealOfTheDay(
        search: search,
        domain: domain,
        categoryId: categoryId,
        brandId: brandId,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

  Future<List<FlashDealModel>> getFeaturedDeals({
    String? search,
    String? domain,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int perPage = 20,
  }) =>
      _dealsService.getFeaturedDeals(
        search: search,
        domain: domain,
        categoryId: categoryId,
        brandId: brandId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: page,
        perPage: perPage,
      );

  // 6. Food Delivery
  Future<FoodHomeDataModel?> getFoodData({
    double? latitude,
    double? longitude,
    String? domain,
  }) =>
      _foodService.getFoodData(
        latitude: latitude,
        longitude: longitude,
        domain: domain,
      );

  Future<List<CuisineModel>> getFoodCuisines({String? domain}) =>
      _foodService.getFoodCuisines(domain: domain);

  // 7. Restaurants
  Future<List<RestaurantModel>> getRestaurants({
    double? latitude,
    double? longitude,
    double? distanceKm,
    String? foodType,
    int? isOpen,
    int? hasDining,
    String? search,
    String? sort,
    String? domain,
    int page = 1,
    int perPage = 20,
  }) =>
      _restaurantService.getRestaurants(
        latitude: latitude,
        longitude: longitude,
        distanceKm: distanceKm,
        foodType: foodType,
        isOpen: isOpen,
        hasDining: hasDining,
        search: search,
        sort: sort,
        domain: domain,
        page: page,
        perPage: perPage,
      );

  Future<RestaurantDetailModel?> getRestaurantMenu({
    required int shopId,
    required String domain,
  }) =>
      _restaurantService.getRestaurantMenu(
        shopId: shopId,
        domain: domain,
      );

  Future<RestaurantDetailModel?> getRestaurantDetails(dynamic id) =>
      _restaurantService.getRestaurantDetails(id);

  // 8. Top Slider
  Future<List<TopSliderModel>> getTopSliders() =>
      _topSliderService.getTopSliders();

  // 9. Order
  Future<Map<String, dynamic>?> placeOrder({
    required String domain,
    int? shopId,
    int addressId = 1,
    required double totalAmount,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? customerNote,
    Map<String, dynamic>? extraData,
  }) =>
      _orderService.placeOrder(
        domain: domain,
        shopId: shopId,
        addressId: addressId,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        items: items,
        orderNote: customerNote,
      );

  // 10. Cart
  Future<Map<String, dynamic>?> addToCart({
    int? userId,
    required String domain,
    required int productId,
    required int shopId,
    int quantity = 1,
    String? variant,
    String? color,
    Map<String, dynamic>? choices,
  }) =>
      _cartService.addToCart(
        userId: userId,
        domain: domain,
        productId: productId,
        shopId: shopId,
        quantity: quantity,
        variant: variant,
        color: color,
        choices: choices,
      );

  // 11. Addresses
  Future<AddressApiResponse> getCustomerAddresses({
    String? domain,
    int? userId,
  }) =>
      _addressService.getCustomerAddresses(
        domain: domain,
        userId: userId,
      );

  Future<Map<String, dynamic>> saveCustomerAddress({
    required EcommerceAddressModel address,
    String? domain,
    int? userId,
  }) =>
      _addressService.saveCustomerAddress(
        address: address,
        domain: domain,
        userId: userId,
      );

  Future<Map<String, dynamic>> updateCustomerAddress({
    required EcommerceAddressModel address,
    String? domain,
    int? userId,
  }) =>
      _addressService.updateCustomerAddress(
        address: address,
        domain: domain,
        userId: userId,
      );

  Future<Map<String, dynamic>> deleteCustomerAddress({
    required int addressId,
    String? domain,
    int? userId,
  }) =>
      _addressService.deleteCustomerAddress(
        addressId: addressId,
        domain: domain,
        userId: userId,
      );
}
