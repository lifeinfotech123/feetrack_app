import 'package:vlr/ecomerce/models/banner_model.dart';

class BannerService {
  BannerService({dynamic client});

  /// Fetch banners by banner_type (Static Mock Data)
  Future<List<BannerModel>> getBanners({String bannerType = 'main-banner'}) async {
    return [
      BannerModel(
        id: 1,
        title: "New items with \nFree shipping",
        subTitle: "Free shipping on orders above \$50",
        buttonText: "Shop Now",
        bannerType: bannerType,
        image:
            "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800&auto=format&fit=crop&q=80",
      ),
      BannerModel(
        id: 2,
        title: "Black \nfriday",
        subTitle: "Collection",
        buttonText: "Claim 50% Off",
        bannerType: bannerType,
        image:
            "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&auto=format&fit=crop&q=80",
      ),
      BannerModel(
        id: 3,
        title: "SUMMER \nSALE",
        subTitle: "SPECIAL OFFER",
        buttonText: "Explore Now",
        bannerType: bannerType,
        image:
            "https://images.unsplash.com/photo-1445205170230-053b83016050?w=800&auto=format&fit=crop&q=80",
      ),
    ];
  }
}
