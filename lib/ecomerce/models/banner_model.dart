class BannerResourceModel {
  final int? id;
  final String? name;
  final String? slug;
  final double? price;
  final String? thumbnail;

  BannerResourceModel({
    this.id,
    this.name,
    this.slug,
    this.price,
    this.thumbnail,
  });

  factory BannerResourceModel.fromJson(Map<String, dynamic> json) {
    return BannerResourceModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}

class BannerModel {
  final int? id;
  final String? title;
  final String? subTitle;
  final String? buttonText;
  final String? backgroundColor;
  final String? bannerType;
  final String image;
  final String? url;
  final String? resourceType;
  final int? resourceId;
  final String? resourceSlug;
  final BannerResourceModel? resource;
  final String? theme;

  BannerModel({
    this.id,
    this.title,
    this.subTitle,
    this.buttonText,
    this.backgroundColor,
    this.bannerType,
    required this.image,
    this.url,
    this.resourceType,
    this.resourceId,
    this.resourceSlug,
    this.resource,
    this.theme,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title']?.toString(),
      subTitle: json['sub_title']?.toString() ?? json['subtitle']?.toString(),
      buttonText: json['button_text']?.toString(),
      backgroundColor: json['background_color']?.toString(),
      bannerType: json['banner_type']?.toString(),
      image: json['image']?.toString() ?? '',
      url: json['url']?.toString(),
      resourceType: json['resource_type']?.toString(),
      resourceId: json['resource_id'] is int
          ? json['resource_id']
          : int.tryParse(json['resource_id']?.toString() ?? ''),
      resourceSlug: json['resource_slug']?.toString(),
      resource: json['resource'] is Map<String, dynamic>
          ? BannerResourceModel.fromJson(json['resource'])
          : null,
      theme: json['theme']?.toString(),
    );
  }
}
