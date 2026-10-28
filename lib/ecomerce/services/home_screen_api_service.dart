import '../models/brand_model.dart';
import '../models/home_screen_models.dart';
import '../models/store_model.dart';

class HomeScreenApiService {
  HomeScreenApiService({dynamic client});

  static List<ApiProductModel> get _defaultProducts => [
        ApiProductModel(
          id: 3,
          shopId: 1,
          name: "Man Jeans Pack",
          slug: "man-jeans-pack-jSdk8R",
          thumbnail:
              "https://e-team-12.orderknow.com/storage/product/thumbnail/2026-10-24-6adc8dfb37507.webp",
          unitPrice: 1.8,
          discount: 0.6,
          discountType: "flat",
          finalPrice: 1.2,
          discountedPrice: 1.2,
          rating: 4.8,
          currentStock: 100,
          brand: BrandModel(id: 10, name: "Adidas", slug: "adidas-LHSgNR"),
          store: StoreModel(
            id: 27,
            shopId: 1,
            name: "My Team one",
            slug: "my-team-one-6A4h60",
            domain: "e-team-12",
          ),
        ),
        ApiProductModel(
          id: 2,
          shopId: 1,
          name: "Mobile Phone",
          slug: "mobile-phone-l5O5f0",
          thumbnail:
              "https://e-team-12.orderknow.com/storage/product/thumbnail/2026-10-24-6adc775f8401e.webp",
          unitPrice: 180.0,
          discount: 60.0,
          discountType: "flat",
          finalPrice: 120.0,
          discountedPrice: 120.0,
          rating: 4.8,
          currentStock: 19,
          brand: BrandModel(id: 8, name: "Samsung", slug: "samsung-Bu7gxk"),
          store: StoreModel(
            id: 27,
            shopId: 1,
            name: "My Team one",
            slug: "my-team-one-6A4h60",
            domain: "e-team-12",
          ),
        ),
        ApiProductModel(
          id: 1,
          shopId: 1,
          name: "T-Shart For Man",
          slug: "t-shart-for-man-xOGeex",
          thumbnail:
              "https://e-team-12.orderknow.com/storage/product/thumbnail/2026-10-23-6adb3977c6451.webp",
          unitPrice: 1.8,
          discount: 0.6,
          discountType: "flat",
          finalPrice: 1.2,
          discountedPrice: 1.2,
          rating: 4.8,
          currentStock: 50,
          brand: BrandModel(id: 9, name: "Nike", slug: "nike-IojMGa"),
          store: StoreModel(
            id: 27,
            shopId: 1,
            name: "My Team one",
            slug: "my-team-one-6A4h60",
            domain: "e-team-12",
          ),
        ),
        ApiProductModel(
          id: 4,
          shopId: 1,
          name: "Face Wash",
          slug: "face-wash-cz3mZe",
          thumbnail:
              "https://25-ecomm.orderknow.com/storage/product/thumbnail/2026-10-24-6adc973a163d4.webp",
          unitPrice: 180.0,
          discount: 60.0,
          discountType: "flat",
          finalPrice: 120.0,
          discountedPrice: 120.0,
          rating: 4.8,
          currentStock: 150,
          brand: BrandModel(id: 7, name: "Apple", slug: "apple"),
          store: StoreModel(
            id: 28,
            shopId: 1,
            name: "ABC",
            slug: "abc-Lf6jFO",
            domain: "25-ecomm",
          ),
        ),
      ];

  /// Fetch Featured / Popular Products (Static Mock Data)
  Future<List<ApiProductModel>> getFeaturedProducts() async {
    return List<ApiProductModel>.from(_defaultProducts);
  }

  /// Fetch Top Brands (Static Mock Data)
  Future<List<BrandModel>> getTopBrands() async {
    return [
      BrandModel(
        id: 1,
        name: "Nike",
        slug: "nike",
        image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=85",
        productsCount: 48,
      ),
      BrandModel(
        id: 2,
        name: "Zara",
        slug: "zara",
        image: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=85",
        productsCount: 65,
      ),
      BrandModel(
        id: 3,
        name: "Adidas",
        slug: "adidas",
        image: "https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=800&q=85",
        productsCount: 52,
      ),
      BrandModel(
        id: 4,
        name: "Levi's",
        slug: "levis",
        image: "https://images.unsplash.com/photo-1582552938357-32b906df40cb?auto=format&fit=crop&w=800&q=85",
        productsCount: 38,
      ),
      BrandModel(
        id: 5,
        name: "H&M",
        slug: "hm",
        image: "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?auto=format&fit=crop&w=800&q=85",
        productsCount: 74,
      ),
      BrandModel(
        id: 6,
        name: "Puma",
        slug: "puma",
        image: "https://images.unsplash.com/photo-1608231387042-66d1773070a5?auto=format&fit=crop&w=800&q=85",
        productsCount: 42,
      ),
    ];
  }

  /// Fetch Flash Deals (Static Mock Data)
  Future<List<FlashDealModel>> getFlashDeals() async {
    return [
      FlashDealModel(
        id: 1,
        title: "Super Flash Sale",
        slug: "super-flash-sale",
        banner: "https://i.imgur.com/pRgcbpS.png",
        startDate: "2026-01-01",
        endDate: "2026-12-31",
        countdown: FlashDealCountdown(
          remainingSeconds: 28800,
          days: 0,
          hours: 8,
          minutes: 0,
          seconds: 0,
          isExpired: false,
        ),
        productsCount: 20,
      ),
    ];
  }

  /// Fetch Top Sellers (Static Mock Data)
  Future<List<TopSellerModel>> getTopSellers() async {
    return [
      TopSellerModel(
        id: 1,
        sellerId: 101,
        name: "Nike Official Store",
        slug: "nike",
        logo: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=85",
        rating: 4.9,
        ratingFormatted: "4.9",
        productsCount: 120,
        ordersCount: 1450,
        isInhouse: true,
      ),
      TopSellerModel(
        id: 2,
        sellerId: 102,
        name: "Zara Fashion",
        slug: "zara",
        logo: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=85",
        rating: 4.8,
        ratingFormatted: "4.8",
        productsCount: 95,
        ordersCount: 980,
        isInhouse: false,
      ),
      TopSellerModel(
        id: 3,
        sellerId: 103,
        name: "Adidas Originals",
        slug: "adidas",
        logo: "https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=800&q=85",
        rating: 4.7,
        ratingFormatted: "4.7",
        productsCount: 84,
        ordersCount: 820,
        isInhouse: false,
      ),
      TopSellerModel(
        id: 4,
        sellerId: 104,
        name: "Levi's Denim Co.",
        slug: "levis",
        logo: "https://images.unsplash.com/photo-1582552938357-32b906df40cb?auto=format&fit=crop&w=800&q=85",
        rating: 4.6,
        ratingFormatted: "4.6",
        productsCount: 62,
        ordersCount: 650,
        isInhouse: false,
      ),
    ];
  }

  /// Fetch Most Popular Products (Static Mock Data)
  Future<List<ApiProductModel>> getMostPopularProducts() async {
    return List<ApiProductModel>.from(_defaultProducts.reversed);
  }

  /// Fetch New Arrival Products (Static Mock Data)
  Future<List<ApiProductModel>> getNewArrivalsProducts() async {
    return List<ApiProductModel>.from(_defaultProducts);
  }
}
