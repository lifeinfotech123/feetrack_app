import '../constants.dart';
import 'product_model.dart';

class LinkedProductModel {
  final int id;
  final String name;
  final String slug;
  final double unitPrice;
  final bool inStock;
  final String? thumbnail;

  LinkedProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.unitPrice,
    required this.inStock,
    this.thumbnail,
  });

  factory LinkedProductModel.fromJson(Map<String, dynamic> json) {
    return LinkedProductModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      inStock: json['in_stock'] == true || json['in_stock'] == 1,
      thumbnail: json['thumbnail']?.toString(),
    );
  }

  ProductModel toProductModel({String? storeName, String? storeDomain}) {
    return ProductModel(
      image: (thumbnail != null &&
              thumbnail!.isNotEmpty &&
              !thumbnail!.contains('imgur.com'))
          ? thumbnail!
          : '',
      brandName: storeName ?? "Featured",
      title: name,
      price: unitPrice,
      storeName: storeName,
      storeDomain: storeDomain,
    );
  }
}

class SliderStoreModel {
  final int id;
  final String name;
  final String slug;
  final String domain;

  SliderStoreModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.domain,
  });

  factory SliderStoreModel.fromJson(Map<String, dynamic> json) {
    return SliderStoreModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      domain: json['domain']?.toString() ?? '',
    );
  }
}

class TopSliderModel {
  final int id;
  final String title;
  final String subTitle;
  final String buttonText;
  final String backgroundColor;
  final String bannerType;
  final String theme;
  final int published;
  final String url;
  final String photo;
  final String? mobilePhoto;
  final String resourceType;
  final int? resourceId;
  final LinkedProductModel? linkedProduct;
  final String? createdAt;
  final SliderStoreModel? store;

  TopSliderModel({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.buttonText,
    required this.backgroundColor,
    required this.bannerType,
    required this.theme,
    required this.published,
    required this.url,
    required this.photo,
    this.mobilePhoto,
    required this.resourceType,
    this.resourceId,
    this.linkedProduct,
    this.createdAt,
    this.store,
  });

  factory TopSliderModel.fromJson(Map<String, dynamic> json) {
    LinkedProductModel? linkedProduct;
    if (json['linked_product'] is Map<String, dynamic>) {
      linkedProduct = LinkedProductModel.fromJson(json['linked_product']);
    }

    SliderStoreModel? store;
    if (json['store'] is Map<String, dynamic>) {
      store = SliderStoreModel.fromJson(json['store']);
    }

    return TopSliderModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      subTitle: json['sub_title']?.toString() ?? json['subtitle']?.toString() ?? '',
      buttonText: json['button_text']?.toString() ?? '',
      backgroundColor: json['background_color']?.toString() ?? '#1E3A8A',
      bannerType: json['banner_type']?.toString() ?? 'Main Banner',
      theme: json['theme']?.toString() ?? 'default',
      published: json['published'] is int
          ? json['published']
          : int.tryParse(json['published']?.toString() ?? '1') ?? 1,
      url: json['url']?.toString() ?? '/products',
      photo: json['photo']?.toString() ?? '',
      mobilePhoto: json['mobile_photo']?.toString(),
      resourceType: json['resource_type']?.toString() ?? 'product',
      resourceId: json['resource_id'] is int
          ? json['resource_id']
          : int.tryParse(json['resource_id']?.toString() ?? ''),
      linkedProduct: linkedProduct,
      createdAt: json['created_at']?.toString(),
      store: store,
    );
  }

  /// Converts background color hex string (e.g. #1E3A8A) to Flutter Color
  int get parsedColorValue {
    String hex = backgroundColor.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF$hex";
    }
    return int.tryParse(hex, radix: 16) ?? 0xFF1E3A8A;
  }
}
